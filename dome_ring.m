function [] = dome_ring(r,relation,rs,longnitude,lattitude,position,attitude,hight_s,fin_angle,steps)

%% Rysowanie globu do wycinania czaszy
cdata = imread('world.jpg');
hight = hight_s;
sphere_n = 1000;
r_z = 6371.0087714;
[X,Y,Z] = sphere(sphere_n);
center = [0,0,0];
X2 = X * r_z;
Y2 = Y * r_z;
Z2 = Z * r_z;
figure();

basic_rot = -90;
lat = lattitude; %lattitude = szerokość -90-+90
long = longnitude; %longnitude = długość -180-+180
az = 90 - (lat);

if long >= 0
    el = long;
end
if long < 0
    el = long;
end


Z2 = -Z2;
props.FaceColor= 'texture';
props.EdgeColor = 'none';
props.FaceLighting = 'phong';
globe = surf(X2,Y2,Z2,props);
alpha = 1;
set(globe, 'FaceColor', 'texturemap', 'CData', cdata, 'FaceAlpha', alpha, 'EdgeColor', 'none');
axis equal
xlabel('X [km]');
ylabel('Y [km]');
zlabel('Z [km]');

%% Z1
rotate(globe,[0 0 1],basic_rot);
Xz1 = X2*cos(deg2rad(basic_rot)) - Y2*sin(deg2rad(basic_rot));
Yz1 = X2*sin(deg2rad(basic_rot)) + Y2*cos(deg2rad(basic_rot));
Zz1 = Z2;

%% Z2
rotate(globe,[0 0 1],-el);
Xz2 = Xz1*cos(deg2rad(-el)) - Yz1*sin(deg2rad(-el));
Yz2 = Xz1*sin(deg2rad(-el)) + Yz1*cos(deg2rad(-el));
Zz2 = Zz1;

%% X
rotate(globe,[1 0 0],-az);
Xx = Xz2;
Yx = Yz2*cos(deg2rad(-az)) - Zz2*sin(deg2rad(-az));
Zx = Yz2*sin(deg2rad(-az)) + Zz2*cos(deg2rad(-az));

%% usunięcie części globu poza czaszą i jej obniżenie 
figure();


for i = 1:sphere_n+1
    for j = 1:sphere_n+1
        if Zx(i,j) < hight
            Xx(i,j) = NaN;
            Yx(i,j) = NaN;
            Zx(i,j) = NaN;
        end
    end
end

z_min = min(Zx,[],'all');
Z_low = Zx - z_min;

globe = surf(Xx,Yx,Z_low,props);
alpha = 1;
set(globe, 'FaceColor', 'texturemap', 'CData', cdata, 'FaceAlpha', alpha, 'EdgeColor', 'none');
hold on
plot3(0,0,attitude,'o','MarkerFaceColor','k','MarkerSize',5);
axis equal
xlabel('X [km]');
ylabel('Y [km]');
zlabel('Z [km]');

%% Wycięcie obszaru ze środka czaszy
x_max = max(Xx,[],'all');
r_in = relation*x_max;

X_cr = Xx;
Y_cr = Yx;
Z_cr = Z_low;
for k=1:sphere_n+1
    for l=1:sphere_n+1
        if (((X_cr(k,l) - center(1))^2) + ((Y_cr(k,l) - center(2))^2)) < r_in^2
                X_cr(k,l) = NaN;
                Y_cr(k,l) = NaN;
                Z_cr(k,l) = NaN;
        end
    end
end

%% wybór obszaru - pierścień mapy
fig = figure('WindowState', 'maximized');
title('Choose point on left ring');
subplot(1,2,1); 
my_ring = surf(X_cr,Y_cr,Z_cr,'EdgeColor', 'none', 'FaceColor', 'texturemap', 'CData', cdata, 'FaceAlpha', 1) ;
xlabel('[km]');
ylabel('[km]');
zlabel('[km]');
axis equal
        ax = gca;               % get the current axis
        ax.Clipping = 'off';    % turn clipping off
hold on
plot3(0,0,attitude,'o','MarkerFaceColor','r');
view(0,89);

cropped = imread('cropped.jpg');
cropped = flipud(cropped);
[X_c,Y_c] = meshgrid(linspace(-rs,rs,300),linspace(-rs,rs,300)) ;
Z_c = sqrt( r^2 - X_c.^2 - Y_c.^2) ;
for i_c=1:300
    for j_c=1:300
        if (((X_c(i_c,j_c) - center(1))^2) + ((Y_c(i_c,j_c) - center(2))^2)) > rs^2
                X_c(i_c,j_c) = NaN;
                Y_c(i_c,j_c) = NaN;
                Z_c(i_c,j_c) = NaN;
        end
    end
end

zc_min = min(Z_c,[],'all');
Z_c_low = Z_c - zc_min;
X_cr_r = X_c;
Y_cr_r = Y_c;
Z_cr_r = Z_c_low;
for k_r=1:300
    for l_r=1:300
        if (((X_cr_r(k_r,l_r) - center(1))^2) + ((Y_cr_r(k_r,l_r) - center(2))^2)) < r_in^2
                X_cr_r(k_r,l_r) = NaN;
                Y_cr_r(k_r,l_r) = NaN;
                Z_cr_r(k_r,l_r) = NaN;
        end
    end
end

%% Wybór obszaru - pierścień zdjęcia
subplot(1,2,2); 
my_2_ring = surf(X_cr_r,Y_cr_r,Z_cr_r,'EdgeColor', 'none', 'FaceColor', 'texturemap', 'CData', cropped, 'FaceAlpha', 1) ;
xlabel('[km]');
ylabel('[km]');
zlabel('[km]');
axis equal
        ax = gca;               % get the current axis
        ax.Clipping = 'off';    % turn clipping off
view(0,89);

zoom(fig,'on')

k = waitforbuttonpress;
if k == 0
    dcm_obj = datacursormode(fig);
    datacursormode on
end
w = waitforbuttonpress;
if w == 0
c_info = getCursorInfo(dcm_obj);
end

pozycjax = c_info.Position(1);
pozycjay = c_info.Position(2);
pozycjaz = c_info.Position(3);


pozycja = [pozycjax,pozycjay,pozycjaz];
x_pozycja = pozycja(1);
y_pozycja = pozycja(2);
z_pozycja = pozycja(3);
z_pozycja = z_pozycja + z_min; %podnieś kopułę
%% cofnij obrót wokoł osi X
X_back1 = x_pozycja;
Y_back1 = y_pozycja*cos(deg2rad(az)) - z_pozycja*sin(deg2rad(az));
Z_back1 = y_pozycja*sin(deg2rad(az)) + z_pozycja*cos(deg2rad(az));

%% cofnij drugi obrót wokół Z
X_back2 = X_back1*cos(deg2rad(el)) - Y_back1*sin(deg2rad(el));
Y_back2 = X_back1*sin(deg2rad(el)) + Y_back1*cos(deg2rad(el));
Z_back2 = Z_back1;

%% cofnij pierwszy obrót wokół Z
X_back3 = X_back2*cos(deg2rad(-basic_rot)) - Y_back2*sin(deg2rad(-basic_rot));
Y_back3 = X_back2*sin(deg2rad(-basic_rot)) + Y_back2*cos(deg2rad(-basic_rot));
Z_back3 = Z_back2;

%% obrót zgodny z przesunięciem z animacją
X_back4 = X_back3*cos(deg2rad(fin_angle)) - Y_back3*sin(deg2rad(fin_angle));
Y_back4 = X_back3*sin(deg2rad(fin_angle)) + Y_back3*cos(deg2rad(fin_angle));
Z_back4 = Z_back3;

%% obrót zgodny z przesunięciem z animacją i obrotem Ziemi
angle_obrotu = steps*0.0625;
X_back5 = X_back4*cos(deg2rad(angle_obrotu)) - Y_back4*sin(deg2rad(angle_obrotu));
Y_back5 = X_back4*sin(deg2rad(angle_obrotu)) + Y_back4*cos(deg2rad(angle_obrotu));
Z_back5 = Z_back4;


%% Globus z wektorem
figure();
[X_f,Y_f,Z_f] = sphere(sphere_n);
center = [0,0,0];
X2_f = X_f * r_z;
Y2_f = Y_f * r_z;
Z2_f = Z_f * r_z;
Z2_f = -Z2_f;
props.FaceColor= 'texture';
props.EdgeColor = 'none';
props.FaceLighting = 'phong';
globe = surf(X2,Y2,Z2,props);
alpha = 1;
set(globe, 'FaceColor', 'texturemap', 'CData', cdata, 'FaceAlpha', alpha, 'EdgeColor', 'none');
rotate(globe,[0 0 1], fin_angle,[0,0,0]); 
rotate(globe,[0 0 1],(steps*0.0625),[0,0,0]);
axis equal
        ax = gca;               % get the current axis
        ax.Clipping = 'off';    % turn clipping off
hold on
grid off
%set(gca,'visible','off');
plot3(position(1),position(2),position(3),'o','MarkerFaceColor','r','MarkerSize',6);

v1 = [position(1),position(2),position(3)];
v2 = [X_back5,Y_back5,Z_back5];
vX = [v1(:,1) v2(:,1)] ;
vY = [v1(:,2) v2(:,2)] ;
vZ = [v1(:,3) v2(:,3)] ;
wektor = [v2(1) - v1(1),v2(2) - v1(2), v2(3) - v1(3)];
%quiver3(v1(1),v1(2),v1(3),wektor(1),wektor(2),wektor(3),'LineWidth',1.5);
plot3(vX',vY',vZ','r','LineWidth',3)
xlabel('X [km]');
ylabel('Y [km]');
zlabel('Z [km]');
title(['X = ', num2str(wektor(1)), ' Y = ', num2str(wektor(2)), ' Z = ',num2str(wektor(3))]);






end