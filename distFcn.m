function distance = distFcn(circle, data_points)
%% check the quality of fitting 
    circle_x = circle(1);
    circle_y = circle(2);
    circle_r = circle(3);
    x_d = data_points(:, 1) - circle_x;
    y_d = data_points(:, 2) - circle_y;
%% find the error of fitting 
    distance = abs(sqrt(x_d.^2 + y_d.^2) - circle_r);