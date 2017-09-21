function [gridOut] = genMotorGrid(gType,iSet,gPitch,rNA,cPos,fSet)
%%
%genMotorGrid Function
%
%Purpose: This is an updated motor grid code that allows for more modular
%sampling schemes than the prior square grid design. This enables circular
%grids and square grids with center spatial frequency values that should
%closely map to the values in the camera used for imaging. This function is
%effectively a decorator of the simGrid function and adds the conversion of
%the NA values into physical motor positions for the light source motors to
%use. this function also saves the motor grid like the original
%makeMotorGrid function. 
%
%Inputs:    gType: String describing which grid type to make
%           iSet: Structure with imaging system settings used for simGrid
%           function.
%               iSet.pixL = double describing camera pixel pitch
%               iSet.Mag = double describing microscope objective magnification
%               iSet.nPix = 2x1 double describing camera pixel count in x
%                           and y.
%               iSet.fL = double describing objective focal length
%               iSet.lambda = double describing illumination wavelength
%               
%          gPitch: 2x1 double vector describing grid pitch to use between
%                  each source position. These settings change based on
%                  gType as discussed below:
%                       'square' = [(Motor distance in x) (Motor distance in y)]
%                       'squareNA' = [(NA separation in x) (NA separation in y)]
%                       'circle' = [(radial NA step size) (Angle step size(rad))]
%          rNA: 2x1 double vector describing minimum and maximum NA values
%               user requires in grid.
%          cPos: 2x1 double describing motor center position in mm
%          fSet: Structure containing file saving information.
%                fSet.fpath: String containing desired folder path for
%                            saving the grid
%                fSet.date: String containing date of meas. acquisition.
%                fSet.fol: String containing folder name for saving grid
%                          information.
%                fSet.iter: scalar double describing current measurement
%                           run number.

%-------------------------------------------------------------------------%
%Variable initialization
maxM = 6; %Maximum motor position (mm)
sfD = [(1./(iSet.nPix(1)*(iSet.pixL/iSet.Mag))) (1./(iSet.nPix(2)*(iSet.pixL/iSet.Mag)))]; %Generate SF pitch in x and y
sfx = -(iSet.nPix(1))/2 * sfD(1):sfD(1):((iSet.nPix(1)/2 - 1)*sfD(1)); %Generate SF range along horizontal direction
sfy = -(iSet.nPix(1))/2 * sfD(2):sfD(2):((iSet.nPix(1)/2 - 1)*sfD(2)); %Generate SF range along vertical direction
[U,V] = meshgrid(sfx,sfy); %Generate meshgrids of SF for creating 2-D SF grid
saveFile = 1;

%Catch nargin errors
if(nargin < 6)
    disp('Grid file saving information not provided.');
    saveFile = 0; %Turns off file saving
end

%Generate standard square grid
if(strcmp(lower(gType),'square') || strcmp(lower(gType),'s'))
    
   %Convert motor pitch into SF value
   tmp = iSet.fL .* tan(asin(rNA)); %Converts maximum and minimum NA values into motor max. and min. positions
   %Generate full range of available motor positions from 0 - 6mm in x and y
   mX = [0:gPitch(1):(cPos(1)-gPitch(1)), cPos(1):gPitch(1):6]; %Generate motor step size in x
   mY = [6:-gPitch(2):cPos(2), (cPos(2)-gPitch(2)):gPitch(2):0];  %Generate motor step size in y
   
   %Generate meshgrid of motor positions
   [MX,MY] = meshgrid(mX,mY); %Create meshgrids of available motor positions based on input motor pitch
   
   %Filter motor positions using NA range of values
   if(tmp(1) ~= 0)
    mFil = circ(sqrt(((MX-cPos(1))./tmp(2)).^2 + (((MY-cPos(2))./tmp(2)).^2))) - circ(sqrt(((MX-cPos(1))./tmp(1)).^2 + (((MY-cPos(2))./tmp(1)).^2))); %Generates motor position filter based on max, min NA
   else
       mFil = circ(sqrt(((MX-cPos(1))./tmp(2)).^2 + (((MY-cPos(2))./tmp(2)).^2)));
   end
   MX = (mFil .* MX)'; %Filter x motor values
   MY = (mFil .* MY)'; %Filter y motor values
   %Remove all filtered values (possibly removes desired 0 motor positions but this never is desired in imaging grid)
   tmp = MX(:);
   tmp(tmp == 0) = [];
   mVal(:,1) = tmp;
   tmp = MY(:);
   tmp(tmp == 0) = [];
   mVal(:,2) = tmp;


   
   %Convert NA range into motor position, set values outside to zero
   %Convert remaining values into vectors, remove zeroed terms (except
   %centerpoint
   %output motor values from function
%Generate square NA or circle grid
else
    outNA = simGrid(gType,U,V,iSet.lambda,gPitch,rNA); %Generate NA values based on input grid type
    mVal = iSet.fL .* tan(asin(outNA)); %Convert values into physical positions
    mVal = mVal + repmat(cPos,[size(mVal,1) 1]); %Adds motor position to physical distance values from outNA
    %Force any motor position values into the 0 - 6mm range
    mVal(mVal > 6) = 6;  %Forces upper bound on motor position values
    mVal(mVal <= 0) = 0; %Forces lower bound on motor position values
end

gridOut = zeros(size(mVal,1),size(mVal,2)+1);
gridOut(:,1) = 1:size(mVal,1);
gridOut(:,2:3) = mVal;
%Save grid information to file
if(saveFile)

    fSet.iter = fSet.iter + 1; %Updates iteration number to prevent grid file overlap    
    mkdir([fSet.fpath '\' fSet.date '\' fSet.fol]); %Make new directory for saving grid information
    fID = fopen([fSet.fpath '\' fSet.date '\' fSet.fol '\' gType '_' fSet.date '_' num2str(fSet.iter) '.txt'],'w');
    fprintf(fID,'Measurement Number\tx\ty\r\n');
    %Write data to file
    for k = 1:size(gridOut,1)
        fprintf(fID,'%f\t%1.3f\t%1.3f\r\n',gridOut(k,:));
    end
    fclose(fID); %Close file
end %End of saveFile if statement


end %End of makeMotorGrid_2 Function