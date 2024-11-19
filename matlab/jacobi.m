function [r, N, xi, E, Re, c, A] = jacobi(x0, A, b, Tol, niter, error_type)
    x0 = eval(x0);
    A = eval(A);
    b = eval(b);
    c = 0;
    error = Tol + 1;
    D = diag(diag(A));
    L = -tril(A, -1);
    U = -triu(A, +1);
    Tr = inv(D) * (L + U);
    C = inv(D) * b;

    autovalores = eig(Tr);
    calculo_re = max(abs(autovalores));
    Re = sprintf('Radio espectral: %f', calculo_re);

    xi = []; % Inicializar xi como una matriz vacía
    E = [];  % Inicializar E como una lista vacía
    N = [];  % Inicializar N como una lista vacía

    while error > Tol && c < niter
        x1 = Tr * x0 + C;

        if strcmp(error_type, 'Error Absoluto')
            E(c + 1) = norm(x1 - x0, 'inf');
        else
            E(c + 1) = norm((x1 - x0) ./ x1, 'inf');
        end

        error = E(c + 1);
        xi = [xi; x1]; % Agregar x1 como una nueva fila en la matriz xi
        N(c + 1) = c + 1;   % Agregar n a la lista N
        x0 = x1;
        c = c + 1;
    end

    if error < Tol
        r = sprintf('%s Es una aproximación de la solución del sistema con una tolerancia= %f\n', mat2str(x1), Tol);
    else 
        r = sprintf('Fracasó en %f iteraciones\n', c); 
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

        saveas(fig, 'app/static/grafica_jacobi.png');
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