function [] = real_cropped(circle_y, circle_x,radius,image)
    radius = round(radius)+1;
    new_im = zeros(4*radius,4*radius,3);
    [rows, columns, numberOfColorChannels] = size(image);
    image_x = columns*5;
    image_y = columns*5;
    new_imR = uint8(new_im(:,:,1));
    if numberOfColorChannels > 1
        new_imG = uint8(new_im(:,:,2));
        new_imB = uint8(new_im(:,:,3));
    end
    earthR = image(:,:,1);
    if numberOfColorChannels > 1
        earthG = image(:,:,2);
        earthB = image(:,:,3);
    end
    
    
    trans_x = image_x - circle_x;
    trans_y = image_y - circle_y;
    new_im_x = 2*radius + trans_x;
    new_im_y = 2*radius + trans_y;
    for y_pixel = 1:rows
        for x_pixel = 1:columns
                new_imR(round(new_im_y - rows/2 + y_pixel),round(new_im_x - columns/2 + x_pixel)) = earthR(y_pixel,x_pixel);
                if numberOfColorChannels > 1
                    new_imG(round(new_im_y - rows/2 + y_pixel),round(new_im_x - columns/2 + x_pixel)) = earthG(y_pixel,x_pixel);
                    new_imB(round(new_im_y - rows/2 + y_pixel),round(new_im_x - columns/2 + x_pixel)) = earthB(y_pixel,x_pixel);
                end
        end
    end
    if numberOfColorChannels > 1
        composed = cat(3,new_imR,new_imG,new_imB);
    end
    if numberOfColorChannels == 1
        
        composed = new_im_R;
    end
    image_centred = composed;
    figure();
    imshow(image_centred);
    hold on
    viscircles([2*radius,2*radius],radius,'Color','c','LineWidth',0.3);
    
    cropped = imcrop(image_centred,[radius-10 radius-10  (2*radius)+10 (2*radius)+10 ]);
    
    imwrite(cropped,'cropped.jpg');
end