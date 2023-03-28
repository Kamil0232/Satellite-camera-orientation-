

// Let's clear the workspace
clear();
xdel(winsid())

// Accessing the astronomical constants
disp("Getting some astronomical constants...");
radiusSun = CL_dataGet("body.Sun.eqRad");
radiusEarth = CL_dataGet("body.Earth.eqRad");
// Defining default simulation time and sampling rate
Td = 15;             // sampling time in seconds
Tscale = 86400;     // numer of seconds in a julian day
Tmax = 7200;    // simulation time in seconds

[fd,SST,Sheetnames,Sheetpos] = xls_open('Data.xls')
[Value,TextInd] = xls_read(fd,Sheetpos(1))
parameters = Value(:,2);

// Defining default starting moment of the simulation
//year = 2020;
//month = 11;
//day = 25;
//hour = 00;
//minute = 3;
//second = 00;

year = parameters(1);
month = parameters(2);
day = parameters(3);
hour = parameters(4);
minute = parameters(5);
second = parameters(6);
photo_year = parameters(13);
photo_month = parameters(14);
photo_day = parameters(15);
photo_hour = parameters(16);
photo_minute = parameters(17);
photo_second = parameters(18);

// Asking for the simulation parameters

desc_param = list(..
CL_defParam("t0 Year", year, units=[], id='$year', valid=''),..
CL_defParam("t0 Month", month, units=[], id='$month', valid='$month>=1 & month<=12'),..
CL_defParam("t0 Day", day, units=[], id='$day', valid='$day>=1 & $day <= 31'),..
CL_defParam("t0 Hour", hour, units=[], id='$hour', valid='$hour>=0 & $hour <= 23'),..
CL_defParam("t0 Minute", minute, units=[], id='$minute', valid='$minute>=0 & $minute <= 59'),..
CL_defParam("t0 Second", second, units=[], id='$second', valid='$second>=0 & $second <= 59'),..
CL_defParam("t_photo Year", photo_year, units=[], id='$photo_year', valid=''),..
CL_defParam("t0 Month", photo_month, units=[], id='$photo_month', valid='$Photo_month>=1 & photo_month<=12'),..
CL_defParam("t0 Day", photo_day, units=[], id='$photo_day', valid='$photo_day>=1 & $photo_day <= 31'),..
CL_defParam("t0 Hour", photo_hour, units=[], id='$photo_hour', valid='$photo_hour>=0 & $photo_hour <= 23'),..
CL_defParam("t0 Minute", photo_minute, units=[], id='$photo_minute', valid='$photo_minute>=0 & $photo_minute <= 59'),..
CL_defParam("t0 Second", photo_second, units=[], id='$photo_second', valid='$photo_second>=0 & $photo_second <= 59'),..
CL_defParam("Simulation duration [seconds]", Tmax, units=[], id='$Tmax', valid='$Tmax>0'),..
CL_defParam("Simulation period [seconds]", Td, units=[], id='$Td', valid='$Td>0')..
);

//[year,month,day,hour,minute,second,Tmax,Td,OK] = CL_inputParam(desc_param);

// Check if the dialog box returned the correct data
//if ~OK then
//      error('Script ended because simulation parameters were not specified');
//end
epoch = [year;month;day;hour;minute;second];
photo = [photo_year;photo_month;photo_day;photo_hour;photo_minute;photo_second];

// Defining default parameters of the orbit
//sma = 6868980;
//ecc = 0.004416;
//inc = 97.7928 * %pi/180;
//pom = 284.6375 * %pi/180;
//gom = 53.9815 * %pi/180;
//anm = 75.4372 * %pi/180;
sma = parameters(7)*1000;
ecc = parameters(8);
inc = parameters(9) * %pi/180;
pom = parameters(10) * %pi/180;
gom = parameters(11) * %pi/180;
anm = parameters(12) * %pi/180;
kep = [sma; ecc; inc; pom; gom; anm];
//disp(kep)

// Asking for the parameters of the orbit
desc_param = list(..
CL_defParam("Semi major axis", sma, units=['m','km'], id='$sma', valid='$sma>=6371'),..
CL_defParam("Eccentricity", ecc, units=[], id='$ecc', valid='$ecc>=0 & ecc<=1'),..
CL_defParam("Inclination", inc, units=['rad','deg'], id='$inc', valid='$inc>=0 & $inc <= 180'),..
CL_defParam("Argument of perigee", pom, units=['rad','deg'], id='$pom', valid='$pom>=0 & $pom <= 360'),..
CL_defParam("RAAN", gom, units=['rad','deg'], id='$gom', valid='$gom>=0 & $gom <= 360'),..
CL_defParam("Mean anomaly", anm, units=['rad','deg'], id='$anm', valid='$anm>=0 & $anm <= 360')..
);
//[sma,ecc,inc,pom,gom,anm,OK] = CL_inputParam(desc_param);
//
////Check if the dialog box returned the correct data
//if ~OK then
//error('Script ended because orbital parameters were not speciified');
//end

// Putting orbit parameters into properly formated vectors
kep = [sma; ecc; inc; pom; gom; anm];
disp("new")
//disp(kep)
orbit = [sma; ecc; inc * 180/%pi; pom * 180/%pi; gom * 180/%pi; anm * 180/%pi];

// Propagating the orbit
disp("Performing orbital propagation");
t1 = CL_dat_cal2cjd(epoch);
t_photo = CL_dat_cal2cjd(photo);
//disp(t1);
//t1 = CL_dat_cal2cjd(epoch) - (1/24); //rozpoczęcie o godzinę przed zrobieniem zdjęcia
disp(t1);
//t2 = t1:(Td/Tscale):(t1+Tmax/Tscale);
//t2 = CL_dat_now("cjd"):(Td/Tscale):(CL_dat_now("cjd")+Tmax/Tscale) 
t2 = (t_photo - (1/24)):(Td/Tscale):(t_photo) 
time_to_save = (t_photo-(1/24));
t = (t2-t1) * Tscale;
[mean_kep_t2,osc_kep_t2] = CL_ex_lyddaneLp(t1,kep,t2);


// Performing the reference frame transformations
[position_eci, velocity_eci, jacob] = CL_oe_kep2car(mean_kep_t2);
position_ecf = CL_fr_convert("ECI", "ECF", t2, position_eci);

//Plot groundtrack
disp("Plotting groundtrack...");
figure('BackgroundColor',[1,1,1], 'Figure_name', 'Satellite groundtrack');
CL_plot_earthMap();

//----------------------------------------------------------------------
//FRAGMENT DOPISANY W CELU WYDOBYCIA WSPÓŁRZĘDNYCH GEOGRAFICZNYCH 
[pos_sph] = CL_co_car2sph(position_ecf)
data_bounds = [-180,-90;180,90]; // degrees
bmin = (data_bounds(1,1)+data_bounds(2,1))/2 - 180; 
bmax = (data_bounds(1,1)+data_bounds(2,1))/2 + 180; 
[x_sph, y_sph] = CL__plot_genxy(CL_rad2deg(pos_sph(1,:)), CL_rad2deg(pos_sph(2,:)), bmin, bmax);
//
//PRZESUNIĘCIE O OSIEM STOPNI NA WSCHÓD 
//x_sph = x_sph - 30
//

//NANIESIENIE WYLICZONYCH WSPÓŁRZĘDNYCH NA MAPĘ ZIEMI (POKRYWA SIĘ Z WYNIKIEM CL_plot_ephem(position_ecf, color_id=5, thickness=1);)
plot2d(x_sph,y_sph);
//
//---------------------------------------------------------------------

CL_plot_ephem(position_ecf, color_id=5, thickness=1);
xlabel('Longitude [deg]');
ylabel('Latitude [deg]');

//// Plot globe
//disp("Plotting the globe...");
//figure('BackgroundColor',[1,1,1], 'Figure_name', 'Satellite trajectory in 3D');
//deff("[x,y,z]=sph(alp,tet)",["x=radiusEarth*cos(alp).*cos(tet)+orig(1)*ones(tet)";.. 
//"y=radiusEarth*cos(alp).*sin(tet)+orig(2)*ones(tet)";.. 
//"z=radiusEarth*sin(alp)+orig(3)*ones(tet)"]); 
//orig=[0 0 0];
//[xx,yy,zz]=eval3dp(sph,linspace(-%pi/2,%pi/2,40),linspace(0,%pi*2,20)); 
//earth_color=(xx)*0 + 9;
//plot3d1(xx,yy,list([zz],[earth_color]),theta=70,alpha=80,flag=[5,6,0]);
//a=gca(); // get the handle of the current axes
//a.box="back_half"; // Plot the grid 
//param3d(position_eci(1,:), position_eci(2,:), position_eci(3,:),theta=170,alpha=80, flag=[0,0]);
//e=gce() //the handle on the 3D polyline
//e.foreground=color('red');
//e.thickness=4;


////Magnetic field value
//disp("Calculating magnetic field vectors...");
//[B_ecf, bdot] = CL_mod_geomagField(t2, position_ecf);      // calculate the magnetic field in ECF frame
//B = CL_fr_convert("ECF", "ECI", t2, B_ecf);                       // convert the magnetic field to ECI frame
//
//// Plotting the magnetic in ECI frame at satellite position
//figure('BackgroundColor',[1,1,1], 'Figure_name', 'Magnetic in ECI frame at satellite position');
//plot(t, B);
//xlabel('Time [s]');
//ylabel('B [T]');
//legend('X','Y','Z');
//
////Sun position
//disp("Calculating Sun position vectors...");
//[S, vel_sun] = CL_eph_sun(t2);
//
//// Plotting the Sun position in ECI frame
//figure('BackgroundColor',[1,1,1], 'Figure_name', 'Sun position in ECI frame');
//plot(t, S);
//xlabel('Time [s]');
//ylabel('Position [m]');
//legend('X','Y','Z');
//
////Eclipsing
//disp("Simulating eclipse conditions...");
//position_sun = S; // Sun
//position_earth = [0; 0; 0]; // Earth
//rat_ecl = CL_gm_eclipseCheck(position_eci, position_sun, position_earth, radiusSun, radiusEarth);
//sunlight = floor(1-rat_ecl);
//
//// Plotting the eclipse conditinons
//figure('BackgroundColor',[1,1,1], 'Figure_name', 'Is satellite in sunlight?');
//plot(sunlight);
//a=gca(); // get the handle of the current axes
//ticks = a.y_ticks
//ticks.labels = ["darkness"; "sunlight"];
//ticks.locations = [0; 1];
//a.y_ticks = ticks;
//a.data_bounds =[0,Tmax/Td,-1,2];

// Asking for a filename to save the data
filename = 'output.mat';
//disp("Asking for output file name...");
desc_param = list(..
CL_defParam("*.mat file name", filename, units=[], id='$filename', valid='', typ='s'));
//[filename,OK] = CL_inputParam(desc_param);
//if ~OK then
//      error('Script ended because output file name was not specified');
//end

// Saving the data
disp("Saving the data");
//savematfile(filename, 't','B', 'S', 'sunlight', 'position_eci', 'Td', 'Tscale', 'Tmax', 'orbit', 'epoch', 'position_ecf', "-v7");
savematfile(filename, 't', 'position_eci', 'position_ecf', 'x_sph', 'y_sph', 'Td', 'Tscale', 'Tmax', 'orbit', 'epoch' ,'time_to_save',"-v7");





