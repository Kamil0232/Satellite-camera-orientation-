function proportions = Set_Proportion(image)

    [rows, columns, numberOfColorChannels] = size(image);
    r_image = image(:,:,1);
    if numberOfColorChannels > 1
        g_image = image(:,:,2);
        b_image = image(:,:,3);
    end
    
    if rem(rows,2) > 0
        r_image(rows,:) = [];
        if numberOfColorChannels > 1
            g_image(rows,:) = [];
            b_image(rows,:) = [];
        end
    end 
    if rem(columns,2) > 0
        r_image(:,columns) = [];
        if numberOfColorChannels > 1
            g_image(:,columns) = [];
            b_image(:,columns) = [];
        end
    end
    if numberOfColorChannels > 1
        proportions = cat(3,r_image,g_image,b_image);
    end
    if numberOfColorChannels == 1
        proportions = r_image;
    end
end 
