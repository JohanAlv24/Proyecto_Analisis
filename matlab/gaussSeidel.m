function [r, N, xn, E, re, c, A] = gaussSeidel(x0, A, b, et, Tol, niter)
    disp(x0)
    disp(A)
    disp(b)
    x0 = eval(x0);
    A = eval(A);
    b = eval(b);
    c = 0;
    error = Tol + 1;
    D = diag(diag(A));
    L = -tril(A, -1);
    U = -triu(A, 1);
    N(c+1) = c;

    while error > Tol && c < niter
        T = inv(D-L) * U;
        C = inv(D-L) * b;
        x1 = T * x0 + C;

        if strcmp(et, 'Error Absoluto')
            E(c+1)=norm(x1-x0,'inf');
        else
            E(c+1) = norm((x1 - x0) ./ x1, 'inf');
        end
        error = E(c+1);
        x0 = x1;
        N(c+1) = c + 1;
        c = c + 1;
        xn{c} = mat2str(x1);
    end
    Re=max(abs(eig(T)));
    
    if error < Tol
        re = sprintf('Radio espectral de T= %f\n',Re)
        r = sprintf('%s Es una aproximación de la solución del sistema con una tolerancia= %f\n',xn{c}, Tol)
    else 
        re = sprintf('Radio espectral de T= %f\n',Re)
        r = sprintf('Fracasó en %f iteraciones\n', niter) 
    end

    if size(A, 1) == 2 && size(A, 2) == 2
        % Crear la figura para graficar las líneas del sistema
        fig = figure('Visible', 'off');
        hold on;
        grid on;
        xlabel('x');
        ylabel('y');
        title('Líneas del sistema de ecuaciones');
            
        % Definir el rango para x
        x_range = linspace(-10, 10, 100);
            
        % Graficar cada ecuación del sistema
        for i = 1:2
        % Calcular y en función de x: A(i,1)*x + A(i,2)*y = b(i)
        y_line = (b(i) - A(i, 1) * x_range) / A(i, 2);
        plot(x_range, y_line, 'DisplayName', sprintf('Ecuación %d', i));
            end
            
        legend('show');
        hold off;   

        saveas(fig, 'app/static/grafica_ecuaciones_gs.png');
        close(fig); 
    else
        % Si la matriz no es 2x2, no se genera la gráfica
        fprintf('Advertencia: La matriz no es 2x2. No se generará una gráfica.\n');
    end

end


 % Función para formatear números
function str = formatNumber(num)
    if abs(num) >= 1e6
        str = sprintf('%.4e', num);
    else
        str = sprintf('%.8f', num);
    end
end

function [sizee, const] = calculate(b)
    switch b
        case {1, 2, 3}
            sizee = 3;
            const = 0.15;  
        case 4
            sizee= 3.4;
            const = 0.135;   
        case 5
            sizee = 4.2; 
            const = 0.11;   
        case {6, 7, 8}
            sizee = 4.6; 
            const = 0.105;  
    end
end