function [resultado, n, xi, fxi, errores] = raices_multiples(fn_str, xi, tol, k, et)
    % Validar el tipo de error
    if ~ismember(et, {'Decimales Correctos', 'Cifras Significativas'})
        error('El tipo de error no es valido');
    end

    % Convertir la función de entrada a un handle numérico
    fn = str2func(['@(x)', fn_str]);
    dfn = @(x) (fn(x + 1e-6) - fn(x)) / 1e-6; % Derivada numérica
    ddfn = @(x) (dfn(x + 1e-6) - dfn(x)) / 1e-6; % Segunda derivada numérica

    % Inicializar variables
    errores = [tol + 1];
    xis = [xi]; % Inicializar con el valor inicial
    error = tol+1;
    n = 0;

    % Iteración principal del método
    while error > tol && n < k
        fxi = fn(xi);
        fxi_1 = dfn(xi);
        fxi_2 = ddfn(xi);

        if fxi == 0
            errores = [errores, 0];
            break;
        end

        xi_1 = xi - (fxi * fxi_1) / (fxi_1^2 - fxi * fxi_2);

        if strcmp(et, 'Decimales Correctos')
            error = abs(xi_1 - xi);
        else
            error = abs(xi_1 - xi) / abs(xi_1);
        end

        % Actualizar variables
        errores = [errores, error];
        xis = [xis, xi_1];
        xi = xi_1;
        n = n + 1;
    end

    % Ajustar las longitudes de los vectores
    if length(errores) < length(xis)
        errores(end+1) = NaN; % Rellenar con NaN si falta un error
    end

    % Determinar el resultado final
    if fn(xi) == 0
        resultado = sprintf('%f es raíz de f(x)\n', xi);
    elseif error < tol
        resultado = sprintf('%f es una aproximación de una raíz de f(x) con una tolerancia = %f\n', xi, tol);
    else
        resultado = sprintf('Fracasó en %d iteraciones\n', k);
    end

    % Graficar resultados
    fig = figure('Visible', 'off');
    x_vals = linspace(min(xis) - 1, max(xis) + 1, 1000);
    y_vals = arrayfun(fn, x_vals);
    plot(x_vals, y_vals, 'b', 'LineWidth', 1.5);
    hold on;
    scatter(xis, arrayfun(fn, xis), 'ro');
    title(['f(x) = ', fn_str]); % Título dinámico
    xlabel('x');
    ylabel('f(x)');
    grid on;

    % Generar un nombre seguro para el archivo basado en la función
    safe_fn_str = regexprep(fn_str, '[^a-zA-Z0-9]', '_');

    % Guardar la gráfica
    currentDir = fileparts(mfilename('fullpath'));
    staticDir = fullfile(currentDir, '..', 'app', 'static');
    if ~exist(staticDir, 'dir')
        mkdir(staticDir);
    end

    % Guardar como SVG
    svgPath = fullfile(staticDir, [safe_fn_str, '.svg']);
    saveas(fig, svgPath, 'svg');
    disp(['Gráfica SVG generada en: ', svgPath]);

    close(fig);


    % Guardar resultados en un archivo CSV
    T = table((1:length(xis))', xis', arrayfun(fn, xis)', errores', ...
        'VariableNames', {'Iteración', 'xi', 'f(xi)', 'Error'});
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    csvFilePath = fullfile(tablesDir, 'multiple_roots_results.csv');
    writetable(T, csvFilePath);
end
