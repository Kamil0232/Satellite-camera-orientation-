function [] = main_scr(image_name)
    close all;
    addpath('Grafiki\Camera');
    [image_diagonal, circle_x, circle_y, circle_radious, image_center_x, image_center_y, relation] = find_earth(image_name);

    
    [longnitude, lattitude] = orbit_animation(relation);
    disp('Położenie:')
    disp(longnitude);
    disp(lattitude);
    
    
    
end