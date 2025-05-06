function [res, methods, E, X1, fX1, iter] = Informe2(f, g, x0, x1, xi, xs, tol, niter, error_type)
    [res_b, N_b, x1_b, f_b, E_b] = biseccion(f, xi, xs, tol, niter, error_type);
    [res_new, N_new, x1_new, f_new, df_new, E_new, c_new] = newton(f, x0, tol, niter, error_type);
    [res_pf, N_pf, x1_pf, f_pf, E_pf] = pf(f, g, x0, tol, niter, error_type);
    %[x1_rm, E_rm, res_rm] = multiple_roots(f, x0, tol, niter, error_type);
    
    
    
    % Suponiendo que x1_j, x1_g, etc. son vectores columna
    X1 = [x1_j; x1_g; x1_s1; x1_s2; x1_s3];
    res = repmat({'Fracasa'}, 1, 5);
    %r = zeros(1, 5);
    E = [error_j; error_g; error_sor1; error_sor2; error_sor3];
    Re = [Re_j; Re_g; Re1; Re2; Re3];
    iter = [iter_j; iter_g; iter_sor1; iter_sor2; iter_sor3];
    methods = {'Jacobi'; 'Gauss-Seidel'; 'SOR-w1'; 'SOR-w2'; 'SOR-w3'};
    
    for i = (1:5)
        if E(i)<Tol
            res{i} = 'Triunfa';
            %r(i) = 1;
        end
    end
    % Crear nombres para las variables x1, x2, ..., xn
    n = length(x1_j); 
    var_names = arrayfun(@(i) sprintf('x%d', i), 1:n, 'UniformOutput', false);
    
    % Crear tabla con todos los datos
    x_table = array2table(X1, 'VariableNames', var_names);
    T = table(methods, iter, E, Re, r', 'VariableNames', {'Method', 'Iteration', 'Error', 'RE', 'Result'});
    T = [T, x_table];
    
    % Crear directorio si no existe
    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    
    % Escribir CSV
    csvFilePath = fullfile(tablesDir, 'tabla_informe1.csv');
    writetable(T, csvFilePath);