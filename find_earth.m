function [image_diagonal, circle_x, circle_y, circle_radious, image_center_x, image_center_y, relation] = find_earth(image_path)
%% Image read
    image = imread(image_path);
    

%% Diagonal
    [y_o x_o chann] = size(image);
    diagonal = hypot(y_o, x_o);
    image_diagonal = diagonal;
    
%% Image proportions and orientation
    image_o = image;
    image = Set_Proportion(image);
    image = Set_Rotation(image);
    org = image;
    


%% Binar
    image_gray = rgb2gray(image);
    bin_image = im2bw(image_gray,50/255);
    %se = strel('square', 400);% dobierz parametry element strukturalnego
    se = strel('square',50);
    zamkniety = imclose(bin_image, se);
    label1 = bwlabel(zamkniety);
    %res = regionprops(label1);
    %wyczyszczony = bwareaopen(zamkniety,400); % dobierz parametry
    wyczyszczony = bwareaopen(zamkniety,400);

%% Edges
    BW1 = edge(wyczyszczony,'zerocross');
%% Place image with edges on black background
    [BW1 s] = Place_Image(BW1);

%% Get the points from edges
    [sizey, sizex] = size(BW1);
    points = {};
    for x = 1:sizex
        for y = 1:sizey
            if BW1(y,x) == 1
                points{end+1} = [x,y];
            end
        end
    end
    
    [sizey ilosc_punktow] = size(points);
    punkty = zeros(ilosc_punktow,2);
    for i = 1:ilosc_punktow
        punkty(i,1) = points{i}(1);
        punkty(i,2) = points{i}(2);
    end

%% Remove outliners from points
    [points2, TF] = rmoutliers(punkty,'gesd');
    

%% Determine set of cirlces fitting to points
    circles = find_fitting_circles(punkty);
    if length(circles) > 0
        [ile_kol params] = size(circles);
    
%% Display all of the circles from set
%     
%         for j = 1:ile_kol
%         figure();
%         subplot(1,2,1);
%         imshow(image_o);
%         subplot(1,2,2);
%         a = Place_Image(image);
%         imshow(a);
%         hold on
%         [y_cor, x_cor, channels] = size(a);
%         x_center = x_cor/2;
%         y_center = y_cor/2;
% 
%         maybe = [circles(j,1), circles(j,2), circles(j,3)];
%         r = maybe(3);
%         x_r = maybe(2);
%         y_r = maybe(1);
%         viscircles([y_r,x_r],r,'Color','c','LineWidth',0.3);
%         hold on
%         plot([y_center,y_r], [x_center x_r], 'LineWidth',2,'Color','r');
%         hold on
%         plot([y_r],[x_r],'o','Color','c');
%         hold on
%         viscircles([y_r,x_r],abs(r-diagonal/2),'Color','r','LineWidth',0.1);
%          hold off
%         end
%% Display only first circle from set - ORIGINAL - VALID
    

            figure();
            subplot(1,2,1);
            imshow(image_o);
            title('Oryginał');
            subplot(1,2,2);
            [a kords] = Place_Image(image);
            imshow(a);
            hold on
            [y_cor, x_cor, channels] = size(a);
            x_center = x_cor/2;
            y_center = y_cor/2;
            image_center_x = x_center;
            image_center_y = y_center;

            maybe = [circles(1,1), circles(1,2), circles(1,3)];
            r = maybe(3);
            r = 0.995*r;
            x_r = maybe(2);
            y_r = maybe(1);
            circle_x = x_r;
            circle_y = y_r;
            circle_radious = r;
            viscircles([y_r,x_r],r,'Color','c','LineWidth',0.3);
            hold on
            %plot([y_center,y_r], [x_center x_r], 'LineWidth',2,'Color','r');
            hold on
            plot([y_r],[x_r],'o','Color','c');
            hold on
            inside_circle_r = abs(r-diagonal/2);
            relation = inside_circle_r/r;
            viscircles([y_r,x_r],inside_circle_r,'Color','r','LineWidth',0.1);
            title('Earth fitting');
            hold off
            sprintf('Earth radius is %f pixels',r)
            imwrite(a,'main.jpg');
            cropped = a;
            cropped = imcrop(a,[y_r-r-10 x_r-r-10  (2*r)+10 (2*r)+10 ]);
            imwrite(cropped,'cropped.jpg');
            real_cropped(x_r, y_r,r,org)
%             srodek = kords/2;
%             disp(srodek);
%             przesuniecie = [srodek - x_r, srodek - y_r];
%             cropping(org,r,przesuniecie);
            
            
            

    else 
        image_diagonal = 0;
        circle_x = 0;
        circle_y = 0;
        circle_radious = 0;
        image_center_x = 0;
        image_center_y = 0; 
        relation = 0;
    end

end