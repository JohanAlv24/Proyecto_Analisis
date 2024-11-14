function [r, N, xn, fm, dfm, E, c] = newton(f_str, x0, Tol, niter, et)
    % Crear función anónima directamente
    f = str2func(['@(x) ' f_str]);
    
    % Calcular la derivada numéricamente
    h = 1e-7;
    df = @(x) (f(x + h) - f(x)) / h;
    
    % Inicializar variables
    c = 0;
    fm(c+1) = f(x0);
    fe = fm(c+1);
    dfm(c+1) = df(x0);
    dfe = dfm(c+1);
    E(c+1) = Tol + 1;
    error = E(c+1);
    xn(c+1) = x0;
    N(c+1) = c;
    
    % Iteraciones del método
    while error > Tol && c < niter
        xn(c+2) = x0 - fe / dfe;
        fm(c+2) = f(xn(c+2));
        fe = fm(c+2);
        dfm(c+2) = df(xn(c+2));
        dfe = dfm(c+2);
        
        if strcmp(et, 'Error Absoluto')
            E(c+2) = abs(xn(c+2)-x0);
        else
            E(c+2) = abs(xn(c+2) - x0) / abs(xn(c+2));
        end
        
        error = E(c+2);
        x0 = xn(c+2);
        N(c+2) = c+1;
        c = c + 1;
    end
    
    % Mensajes de resultado
    if fe == 0
       r = sprintf('%f es raiz de f(x) \n', x0);
    elseif error < Tol
       r = sprintf('%f es una aproximación de una raiz de f(x) con una tolerancia= %f \n', x0, Tol);
    elseif dfe == 0
       r = sprintf('%f es una posible raiz múltiple de f(x) \n', x0);
    else 
       r = sprintf('Fracasó en %f iteraciones \n', niter);
    end

    % Crear gráfica
    currentDir = fileparts(mfilename('fullpath'));
    
    % Crear directorio para tablas si no existe
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    
    % Guardar tabla CSV
    csv_file_path = fullfile(tablesDir, 'tabla_newton.csv');
    T = table(N', xn', fm', E', 'VariableNames', {'Iteration', 'xn', 'fxn', 'E'});
    writetable(T, csv_file_path);

    % Crear gráfica
    fig = figure('Visible', 'off');
    x_plot = linspace(min(xn)-2, max(xn)+2, 100);
    y_plot = zeros(size(x_plot));
    for i = 1:length(x_plot)
        y_plot(i) = f(x_plot(i));
    end
    
    hold on
    yline(0);
    plot(x_plot, y_plot);
    
    % Guardar gráfica
    staticDir = fullfile(currentDir, '..', 'app', 'static');
    if ~exist(staticDir, 'dir')
        mkdir(staticDir);
    end
    img = getframe(gcf);
    imgPath = fullfile(staticDir, 'grafica_newton.png');
    imwrite(img.cdata, imgPath);

    hold off
    close(fig);
end