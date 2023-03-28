function circle = fit_circle_from_data(data_points) 
%% determine x and y
    x_d = data_points(:, 1);
    y_d = data_points(:, 2);
%% create the equation
    X_fcn = [(-2)*x_d, (-2)*y_d, ones(size(x_d))]; 
    Y_fcn = -x_d.^2 - y_d.^2;
    circle = mldivide(X_fcn,Y_fcn);
%% transpose solution by element
    circle = circle.';
%% find radius
    circle_x = circle(1);
    circle_y = circle(2);
    circle_r = circle(3);
    radius = -circle_r + circle_x.^2 + circle_y.^2; 
%% check if the radius is valid
    if radius <= 0
         circle(3) = 0;
    end

    if radius > 0
    %% assign radius to circle output data
        circle(3) = sqrt(radius);
end
