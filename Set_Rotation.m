function [rotated angle] = Set_Rotation(bin_image)
    [size_y size_x] = size(bin_image);
    
    NE = 0;
    NW = 0;
    SW = 0;
    SE = 0;
    for x = 1:size_x
        for y = 1:size_y
            if bin_image(y,x) == 0
                if x <= size_x/2 && y <= size_y/2
                    NW = NW + 1;
                end
                if x >= size_x/2 && y <= size_y/2
                    NE = NE + 1;
                end
                if x <= size_x/2 && y >= size_y/2
                    SW = SW + 1;
                end
                if x >= size_x/2 && y >= size_y/2
                    SE = SE + 1;
                end
                
            end
        end
    end
    
    directions = [ NE+NW NW+SW SW+SE SE+NE];
    if max(directions) == NE + NW
        sprintf('No rotation needed');
        rotated = bin_image;
        angle = 0;
    end
    if max(directions) == NW + SW
        rotated = imrotate(bin_image,-90);
        angle = -90;
    end
    if max(directions) == SW + SE
        rotated = imrotate(bin_image,-180);
        angle = -180;
    end
    if max(directions) == SE + NE
        rotated = imrotate(bin_image,-270);
        angle = -270;
    end  

end 