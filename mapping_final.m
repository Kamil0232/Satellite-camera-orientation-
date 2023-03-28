close all;
clear all;
cdata = imread('world.jpg');
hight = 5000;
r_z = 6371.0087714;
[X,Y,Z] = sphere(1000);
X2 = X * r_z;
Y2 = Y * r_z;
Z2 = Z * r_z;
figure();

basic_rot = -90;
lat = 40; %lattitude = szerokość -90-+90
long = -74; %longnitude = długość -180-+180
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
xlabel('X');
ylabel('Y');
zlabel('Z');

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


figure();


for i = 1:1001
    for j = 1:1001
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
axis equal
xlabel('X');
ylabel('Y');
zlabel('Z');





