function [r, N, xn, fm, E] = pf(f_str, g_str, x0, Tol, niter, tipe)
    f = str2func(['@(x)' f_str]);
    g = str2func(['@(x)' g_str]);

    % Inicializar variables como vectores
    fm = zeros(1, niter + 1);
    E = zeros(1, niter + 1);
    xn = zeros(1, niter + 1);
    N = zeros(1, niter + 1);

    c = 0;
    xn(c + 1) = x0;
    fm(c + 1) = f(x0);
    fe = fm(c + 1);
    E(c + 1) = Tol + 1;
    error = E(c + 1);
    N(c + 1) = c;

    while error > Tol && fe ~= 0 && c < niter
        xn(c + 2) = g(x0);
        fm(c + 2) = f(xn(c + 2));
        fe = fm(c + 2);

        if strcmp(tipe, 'Cifras Significativas')
            E(c + 2) = abs(xn(c + 2) - x0) / abs(xn(c + 2));
        else
            E(c + 2) = abs(xn(c + 2) - x0);
        end

        error = E(c + 2);
        x0 = xn(c + 2);
        N(c + 2) = c + 1;
        c = c + 1;
    end

    % Recortar las variables a las iteraciones realmente necesarias
    N = N(1:c + 1);
    xn = xn(1:c + 1);
    fm = fm(1:c + 1);
    E = E(1:c + 1);

    if fe == 0
        r = sprintf('%f es raíz de f(x)\n', x0);
    elseif error < Tol
        r = sprintf('%f es una aproximación de una raíz de f(x) con una tolerancia= %f\n', x0, Tol);
    else
        r = sprintf('Fracasó en %f iteraciones\n', niter);
    end

    % Guardar los resultados en un archivo CSV
    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    csv_file_path = fullfile(tablesDir, 'tabla_pf.csv');
    T = table(N', xn', fm', E', 'VariableNames', {'Iteration', 'xn', 'fxn', 'E'});
    writetable(T, csv_file_path);

    % Generar un nombre seguro para el archivo basado en la función
    safe_f_str = regexprep(f_str, '[^a-zA-Z0-9]', '_'); % Reemplazar caracteres no permitidos

    % Generar y guardar la gráfica como SVG
    fig = figure('Visible', 'off');
    x_min = min(xn) - 2;
    x_max = max(xn) + 2;
    xplot = linspace(x_min, x_max, 1000);
    yplot = arrayfun(f, xplot);

    hold on;
    yline(0, '--', 'Color', 'black'); % Línea del eje Y
    plot(xplot, yplot, 'b', 'LineWidth', 1.5); % Curva de la función
    scatter(xn(end), fm(end), 'r', 'filled', 'DisplayName', 'Raíz aproximada'); % Raíz aproximada
    title(['f(x) = ' f_str]); % Título dinámico con la función
    xlabel('x');
    ylabel('f(x)');
    legend;
    grid on;


    staticDir = fullfile(currentDir, '..', 'app', 'static');
    if ~exist(staticDir, 'dir')
        mkdir(staticDir);
    end
    svgPath = fullfile(staticDir, ['grafica_' safe_f_str '.svg']);
    saveas(fig, svgPath, 'svg'); % Guardar como SVG
    disp(['Gráfica SVG generada en: ', svgPath]);

    hold off;
    close(fig);
end
