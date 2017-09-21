function [gridOut] = makeMotorGrid(cPos,pitch,gType,nImg, f, NArange, fpath,date,iter)
%%
%makeMotorGrid function
%
%Purpose: This code generates a grid of the specified type gType using the
%provided center motor positions from cPos, a pitch in either cartesian or
%polar coordinates from pitch, within a specified NA range. This function
% generates both a text file containing the coordinates for a given measurement
% and passes the coordinates out of the function. Currently this function will only be usable with the processing
%code in the square grid creation.
% 
%Inputs: cPos - 2x1 vector describing center x and y positions,respectively
%        pitch - 2x1 vector describing x and y pitch sizes in 'square' grid
%                generation and radius and polar angle pitch sizes in
%                'circular' grid generation
%        gType - variable selecting grid type.
%                'square','Square','s', or 's' = square grid generation
%                'circ','Circ','c', or 'C' = circular/annular grid gen.
%        nImg - number of images to use in grid generation. I'm not sure
%               how to use this for circular grid gen. yet
%        f = variable describing distance from source to lens for
%            calculating illumination NA assuming air medium
%        NArange - 2x1 vector describing min. and max. allowable NA values
%                  in the generated grid
%        fpath - folder path for saving grid text file
%        date - today's date as a string
%        iter - grid iteration number
%
%Outputs: gridOut = 3 x 1 vector containing the image number, x motor, and
%                   y motor coordinates to use during image acquisition.
%-------------------------------------------------------------------------%

 %Variable Initialization
 maxD = 6; %Maximum distance motors can move away from their homed position
 xyGrid = zeros(nImg,3); %Preallocates motor position value array
 xyGrid(:,1) = 1:nImg; %Numbers image array
 
 %Square Grid generation
 if(strcmp(lower(gType),'square') || strcmp(lower(gType),'s'))
    sL = sqrt(nImg); %Determine the grid side length

    %Check if side length is even or odd for generating source grid
    if(mod(sL,2) ~= 0)
        mF = (sL-1)/2; %Finds multiplier for obtaining min and max grid values in x and y
    else
        mF = sL/2;
    end
        maxPos = [cPos(1) - mF*pitch(1), cPos(1) + mF*pitch(1),cPos(2) - mF*pitch(2),cPos(2) + mF*pitch(2)]; %find max and min positions for motors
        %Generate x positions if max and min are within motor range
        if(maxPos(1) > 0 && maxPos(2) < maxD)
            xyGrid(:,2) = repmat((maxPos(1) + (0:(sL-1))*pitch(1))',[sL 1]); %Generates repeating step sequence assuming x-direction sequential scanning
        else
            disp('x-values not generated, grid exceeded motor distance range');
        end
        %Generate y positions if max and min exist within motor range
        if(maxPos(3) > 0 && maxPos(4) < maxD)
            tmp = repmat(maxPos(3) + ((sL-1):-1:0)*pitch(2),[sL 1]); %Generate repeated y position values
            xyGrid(:,3) = tmp(:); %Add y values to grid matrix
        else
            disp('y-values not generated, grid exceeded motor distance range');
        end
 %Square grid with equal NA spacing
 elseif(strcmp(lower(gType),'squarena') || strcmp(lower(gType),'sna'));
    sL = sqrt(nImg); %Determine the grid side length
    
    %Check if side length is even or odd for generating source grid
    if(mod(sL,2) ~= 0)
        mF = (sL-1)/2; %Finds multiplier for obtaining min and max grid values in x and y
    else
        
        mF = sL/2;
    end
        maxPosNA = [-mF*pitch(1), mF*pitch(1),-mF*pitch(2),mF*pitch(2)]; %Finds max and min NA values based on provided NA pitch distances
        maxPos = f .* tan(asin(maxPosNA)) + [cPos(1) cPos(1) cPos(2) cPos(2)]; %Finds corresponding max and min motor positions shifted by center coordinates
        %Generate x positions if max and min are within motor range
        if(maxPos(1) > 0 && maxPos(2) < maxD)
            xyGrid(:,2) = repmat((maxPosNA(1) + (0:(sL-1))*pitch(1))',[sL 1]); %Generates repeating step sequence assuming x-direction sequential scanning
            xyGrid(:,2) = f .* tan(asin(xyGrid(:,2))); %Converts to actual motor positions
        else
            disp('x-values not generated, grid exceeded motor distance range');
        end
        %Generate y positions if max and min exist within motor range
        if(maxPos(3) > 0 && maxPos(4) < maxD)
            tmp = repmat(maxPosNA(3) + ((sL-1):-1:0)*pitch(2),[sL 1]); %Generate repeated y position values
            xyGrid(:,3) = tmp(:); %Add y values to grid matrix
            xyGrid(:,3) = f .* tan(asin(xyGrid(:,3)));
        else
            disp('y-values not generated, grid exceeded motor distance range');
        end
        xyGrid(:,2:3) = xyGrid(:,2:3) + repmat(cPos,[nImg 1]); %Shifts motor positions based on center coordinates
 %Circular Grid Generation
 elseif(strcmp(lower(gType),'circ') || strcmp(lower(gType),'c'))
     
     
 end %End of grid selection if-else statement
 
 %Save Motor positions to a text file
 mkdir([fpath '\Source Grid']);
 fID = fopen([fpath '\Source Grid\' gType '_' date '_' num2str(iter) '.txt'],'w');
 fprintf(fID,'Measurement Number\tx\ty\r\n');
 %Write data to file
 for k = 1:size(xyGrid,1)
     fprintf(fID,'%f\t%1.3f\t%1.3f\r\n',xyGrid(k,:));
 end
 fclose(fID);
 gridOut = xyGrid;
end %End of makeMotorGrid function
