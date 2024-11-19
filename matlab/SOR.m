function [r, n, xi, E, radio, c, A] = SOR(x0, A, b, Tol, niter, w, tipe)
    format long;
    A = eval(A);
    b = eval(b);
    x0 = eval(x0);

    c = 0;
    error = Tol + 1;
    D = diag(diag(A));
    L = -tril(A, -1);
    U = -triu(A, 1);
    xi = []; % Lista de listas para almacenar xi
    E = [];  % Lista para almacenar errores
    n = [];  % Lista para almacenar n

    while error > Tol && c < niter
        T = inv(D - w * L) * ((1 - w) * D + w * U);
        radio_value= max(abs(eig(T))); 
        radio = sprintf('El radio espectral es de %f', radio_value);
        C = w * inv(D - w * L) * b;
        x1 = T * x0 + C;
        if strcmp(tipe, 'Cifras Significativas')
            error = norm((x1 - x0) ./ x1, 'inf');
        else
            error = norm(x1 - x0, 'inf'); 
        end

        E(end + 1) = error;
        xi(:, end + 1) = x1; % Agregar x1 a la lista de listas xi
        n(end + 1) = c + 1;   % Agregar n a la lista n
        x0 = x1;
        
        c = c + 1;
    end
    
    if error < Tol
        r = sprintf('es una aproximación de la solución del sistema con una tolerancia= %f\n', Tol);
    else
        r = sprintf('Fracasó en %d iteraciones\n', niter);
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

        saveas(fig, 'app/static/grafica_sor.png');
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