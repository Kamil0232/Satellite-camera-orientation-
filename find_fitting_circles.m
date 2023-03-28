function circles = find_fitting_circles(points)
%% set parameters
min_points_in_circle = 100;
sampleSize = 3;
maxDistance = 4;
x = points(:, 1);
y = points(:, 2);

%% database for circles
circles = {};

%% loop to find maximum 10 circles in data
for counter=0:9
    %% check if the number of points is high enough
    if length(x) > sampleSize 
        try
            %% ransac
            [circle_det, inlierIdx] = ransac([x, y], @fit_circle_from_data, @distFcn, sampleSize, maxDistance);
        catch
            %% no circles
            disp('NOTHING WAS FOUND');
            break
        end
        
        %% fit the output data
        circle = fit_circle_from_data([x(inlierIdx) y(inlierIdx)]);
        distance = distFcn(circle, [x y]);
        %% check the valid solutions by distance checking
        fit_confirmed = zeros(1,length(distance));
        for k=1:length(distance)
            if distance(k) < maxDistance
                fit_confirmed(k) = 1;
            else
                fit_confirmed(k) = 0;
            end
        end
        fit_confirmed = logical(fit_confirmed);
        
        %% check if number of fitting points is high enough
        if sum(fit_confirmed) > min_points_in_circle 
            %% add new circle to database
            circles{end+1} = circle; 
            %% delete coordinates from x and y
            x(fit_confirmed) = []; 
            y(fit_confirmed) = []; 
        end    
    end
end

%% concatenate circles vertically
circles = vertcat(circles{:});

%% check if the circles exist
how_many = length(circles);
if how_many == 0
    disp('NO CIRCLES FOUND ON IMAGE');
end

