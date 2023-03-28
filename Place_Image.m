function [image_centred square] = Place_Image(image)

    [rows, columns, numberOfColorChannels] = size(image);

    square = columns*10;
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
                baseR((square/2 - rows/2 + y_pixel),(square/2 - columns/2 + x_pixel)) = earthR(y_pixel,x_pixel);
                if numberOfColorChannels > 1
                    baseG((square/2 - rows/2 + y_pixel),(square/2 - columns/2 + x_pixel)) = earthG(y_pixel,x_pixel);
                    baseB((square/2 - rows/2 + y_pixel),(square/2 - columns/2 + x_pixel)) = earthB(y_pixel,x_pixel);
                end
        end
    end
    
    if numberOfColorChannels > 1
        composed = cat(3,baseR,baseG,baseB);
    end
    if numberOfColorChannels == 1
        
        composed = baseR;
    end
    %a=('success')
    image_centred = composed;

end 