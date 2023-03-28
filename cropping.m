%function [] = cropping(image,radius, przesuniecie)


image = imread('zagiel.jpg');
% circle_x = 3.9936e+03;
% circle_y = 2.5865e+03;
% radius = 1.1010e+03;
radius = 1.1251e+03;
przesuniecie =  [-815.6993  623.5831];
disp(radius);
disp(przesuniecie);
    square = ceil(2*radius);
    image_x = square/2 + przesuniecie(1);
    image_y = square/2 + przesuniecie(2);
    new_im_center_x = image_x;
    new_im_center_y = image_y;
    [rows, columns, numberOfColorChannels] = size(image);

    base = zeros(square, square, 3);
    baseR = uint8(base(:,:,1));
    if numberOfColorChannels > 1
        baseG = uint8(base(:,:,2));
        baseB = uint8(base(:,:,3));
    end
    earthR = image(:,:,1);
    if numberOfColorChannels > 1
        earthG = image(:,:,2);
        earthB = image(:,:,3);
    end
    for y_pixel = 1:rows
        for x_pixel = 1:columns
                baseR((new_im_center_y - rows/2 + y_pixel),(new_im_center_x - columns/2 + x_pixel)) = earthR(y_pixel,x_pixel);
                if numberOfColorChannels > 1
                    baseG((new_im_center_y - rows/2 + y_pixel),(new_im_center_x - columns/2 + x_pixel)) = earthG(y_pixel,x_pixel);
                    baseB((new_im_center_y - rows/2 + y_pixel),(new_im_center_x - columns/2 + x_pixel)) = earthB(y_pixel,x_pixel);
                end
        end
    end
    


    if numberOfColorChannels > 1
        composed = cat(3,baseR,baseG,baseB);
    end
    if numberOfColorChannels == 1
        
        composed = baseR;
    end
    a=('success')
    image_centred = composed;
    imwrite(image_centred,'cropped.jpg');
            
%end