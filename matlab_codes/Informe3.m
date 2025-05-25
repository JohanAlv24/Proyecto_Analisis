function [error_lagrange, error_newton, error_vander, val1, val3] = Informe3(x,y)
    x = x;
    y = y;
    x_comp = x(end);
    y_comp = y(end);

    x = x(1:end-1);
    y = y(1:end-1);
    n = length(x);
    pol_vander = vander(x, y);
    pol_lagrange = lagrange(x, y);
    [T_N, pol_Newton] = Newtonint(x, y);
    
    
    f_lagrange = 0;
    f_newton = 0;
    f_vander = 0;
    for i = (1:n-1)
        f_lagrange = f_lagrange + x_comp^(n-i)*pol_lagrange(i);
        f_newton = f_newton + x_comp^(n-i)*pol_Newton(i);
        f_vander = f_vander + x_comp^(n-i)*pol_vander(i);
    end
    
    error_lagrange = f_lagrange - y_comp;
    error_newton = f_newton - y_comp;
    error_vander = f_vander - y_comp;

    A1=zeros((2)*(n-1));
    b1=zeros((2)*(n-1),1);

    A3=zeros((4)*(n-1));
    b3=zeros((4)*(n-1),1);
    
    cua=x.^2;
    cub=x.^3;
    
    %lineal
    c=1;
    h=1;
    for i=1:n-1
        A1(i,c)=x(i);
        A1(i,c+1)=1;
        b1(i)=y(i);
        c=c+2;
        h=h+1;
    end
        
    c=1;
    for i=2:n
        A1(h,c)=x(i);
        A1(h,c+1)=1;
        b1(h)=y(i);
        c=c+2;
        h=h+1;
    end

    %% Cubic
    c=1;
    h=1;
    for i=1:n-1
        A3(i,c)=cub(i);
        A3(i,c+1)=cua(i);
        A3(i,c+2)=x(i);
        A3(i,c+3)=1;
        b3(i)=y(i);
        c=c+4;
        h=h+1;
    end
        
    c=1;
    for i=2:n
        A3(h,c)=cub(i);
        A3(h,c+1)=cua(i);
        A3(h,c+2)=x(i);
        A3(h,c+3)=1;
        b3(h)=y(i);
        c=c+4;
        h=h+1;
    end
        
    c=1;
    for i=2:n-1
        A3(h,c)=3*cua(i);
        A3(h,c+1)=2*x(i);
        A3(h,c+2)=1;
        A3(h,c+4)=-3*cua(i);
        A3(h,c+5)=-2*x(i);
        A3(h,c+6)=-1;
        b3(h)=0;
        c=c+4;
        h=h+1;
    end
        
    c=1;
    for i=2:n-1
        A3(h,c)=6*x(i);
        A3(h,c+1)=2;
        A3(h,c+4)=-6*x(i);
        A3(h,c+5)=-2;
        b3(h)=0;
        c=c+4;
        h=h+1;
    end
        
    A3(h,1)=6*x(1);
    A3(h,2)=2;
    b3(h)=0;
    h=h+1;
    A3(h,c)=6*x(end);
    A3(h,c+1)=2;
    b3(h)=0;

    val1 = reshape(A1\b1, 2, n-1)';
    val3 = reshape(A3\b3, 4, n-1)';
    
    f_spline1 = 0;
    f_spline2 = 0;


end