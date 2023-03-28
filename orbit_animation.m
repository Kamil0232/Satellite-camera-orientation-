function [longnitude, lattitude] = orbit_animation(relation)
%% pobranie i przypisanie mapy poglądowej
    image_file = 'earth_low.jpg';
    %cdata = imread('map.jpg');
    cdata = imread(image_file);
    addpath ('SciLab');
    load output.mat
    steps = length(position_eci);
%% utworzenie kuli ziemskiej i naniesienie mapy
    r_z = 6371.0087714;
    [X,Y,Z] = sphere(50);
    X2 = X * r_z;
    Y2 = Y * r_z;
    Z2 = Z * r_z;
    figure();
    surf(X2,Y2,Z2)
    props.FaceColor= 'texture';
    props.EdgeColor = 'none';
    props.FaceLighting = 'phong';
    globe = surf(X2,Y2,-Z2,props);
    alpha = 1;
    set(globe, 'FaceColor', 'texturemap', 'CData', cdata, 'FaceAlpha', alpha, 'EdgeColor', 'none');
    hold on
    axis equal
    xlabel('X [km]');
    ylabel('Y [km]');
    zlabel('Z [km]');
    view(127.5,30)

%% utworzenie orbit (nad powierzchnią i pod powierzchnią) dla ISS w ECI za pomocą funkcji orbit_circle 
    Orbit_ECF = position_ecf/1000;
    Orbit_ECI = position_eci/1000;
    %plot3(Orbit_ECI(1,1),Orbit_ECI(2,1),Orbit_ECI(3,1),'o')
    %plot3(Orbit_ECF(1,1),Orbit_ECF(2,1),Orbit_ECF(3,1),'o')
    disp(x_sph(1));
    [azimuth,elevation,r] = cart2sph(Orbit_ECI(1,1),Orbit_ECI(2,1),Orbit_ECI(3,1));
    azimuth = rad2deg(azimuth);
    [azimuth2,elevation2,r2] = cart2sph(Orbit_ECF(1,1),Orbit_ECF(2,1),Orbit_ECF(3,1));
    azimuth2 = rad2deg(azimuth2);
    disp(azimuth);
    disp(azimuth2);
    if azimuth < 0
         azimuth = 180 + (180+azimuth);
    end
    %rotate(globe,[0 0 1], 90,[0,0,0]); %obrót Ziemi %UWAGA DODANE
    fin_angle = (azimuth-azimuth2); 
    rotate(globe,[0 0 1], fin_angle,[0,0,0]); %obrót Ziemi
%% początkowa pozycja satelity na liście parametrów orbity 
satellite_pos = 0;
first_position = [Orbit_ECI(1,1),Orbit_ECI(2,1),Orbit_ECI(3,1)];
d = sqrt(first_position(1)^2 + first_position(2)^2 + first_position(3)^2);
l = sqrt(d^2 - r_z^2);
t = asin(r_z/d);
h = l * cos(t);
rc = l * sin(t);

[az1,el1,r1] = cart2sph(first_position(1),first_position(2),first_position(3));
r2 = r1-h;
[xp2,yp2,zp2] = sph2cart(az1,el1,r2);
second_position = [xp2,yp2,zp2];

%% pierwszy stożek i stałe parametry
n = 40;
cyl_color='y';
closed=0;
lines = 1;
[Cone,EndPlate1,EndPlate2] = cone(first_position,second_position,[1;rc],n,cyl_color,closed, lines);
var = {'Cone','EndPlate1','EndPlate2'};
rc_tab = zeros(1,400);
timing = time_to_save + 2433282.5;
%% pętla animacji 
    for satellite = 1:steps
        disp(satellite); %wyświetl numer iteracji
        delete([Cone,EndPlate1,EndPlate2]) %usuń poprzedni stożek
        clear cone
        clear (var{:});
        plot3(Orbit_ECI(1,:),Orbit_ECI(2,:),Orbit_ECI(3,:),'Color','r','LineWidth',2) %rysowanie orbity nad powierzchnią
        hold on
        current_time = timing + satellite*(15/86400) - 15/86400;
        title(datestr(datetime(current_time,'convertfrom','juliandate')));
        satellite_pos = satellite_pos + 1;
        actual_position = [Orbit_ECI(1,satellite_pos), Orbit_ECI(2,satellite_pos), Orbit_ECI(3,satellite_pos)];
        d = sqrt(actual_position(1)^2 + actual_position(2)^2 + actual_position(3)^2);
        l = sqrt(d^2 - r_z^2);
        t = asin(r_z/d);
        h = l * cos(t);
        rc = l * sin(t);
        rc_tab(satellite) = rc;
        
        [az_a,el_a,r_a] = cart2sph(actual_position(1),actual_position(2),actual_position(3));
        r2 = d-h;
        [xp2,yp2,zp2] = sph2cart(az_a,el_a,r2);
        cone_ending = [xp2,yp2,zp2];
        
        hold on
        [Cone,EndPlate1,EndPlate2] = cone(actual_position,cone_ending,[1;rc],n,cyl_color,closed, lines); %utworzenie nowego stożka
        hold on;
        grid on;
        ax = gca;               % get the current axis
        ax.Clipping = 'off';    % turn clipping off
        direction = [0 0 1];
        rotate(globe,direction, 0.0625,[0,0,0]); %obrót Ziemi
        rotate3d on; %włączenie możliwości podlądu animacji z dowolnej strony
        pause(0.15);
        if satellite == steps
            longnitude = x_sph(end);
            lattitude = y_sph(end);
            final_position = actual_position;
        end
    end 
    
dome_ring(r_z,relation,rc, longnitude, lattitude,final_position,h,r2,fin_angle,steps);
end