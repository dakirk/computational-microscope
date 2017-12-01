
%Author: Alex Matlock, modified by David Kirk

%Purpose: captureScript is run when the user presses the "Capture" button
%in the main GUI. It handles the photographing and saving of each image and
%the movement of the illumination source throughout each run, as defined by
%the global "illum" variable. It uses the genMotorGrid function to acquire
%the coordinates for each illumination stage movement, and then moves that
%stage to those coordinates in sync with the camera. Once all photos are
%stored to memory, it saves these photos to a folder bearing the run name
%in a date-specific directory within the "Data" folder.

%Things to improve on
% 1. On startup, the software only thinks that the max cam1 shutter speed
% time is 24ms where it can really be set to 700ms in 16 bit mode
% (Grasshopper camera only)


%%
tstart = tic;
%clear all
%close all
%%

%--------------------------Variable Initialization------------------------%
%Save Folder Parameters
%fpath = 'D:\David\SP-IRIS Project\Data';     %Data Acquistion file path
global illum
global datFol

%{
%collects date string from variable date
currDate = date;
%takes last two digits (year) as first two for formatted string
dateStr = currDate(10:11);
%determines month for next two digits
switch currDate(4:6)
    case 'Jan'
        dateStr = strcat(dateStr,'01');
    case 'Feb'
        dateStr = strcat(dateStr,'02');
    case 'Mar'
        dateStr = strcat(dateStr,'03');
    case 'Apr'
        dateStr = strcat(dateStr,'04');
    case 'May'
        dateStr = strcat(dateStr,'05');
    case 'Jun'
        dateStr = strcat(dateStr,'06');
    case 'Jul'
        dateStr = strcat(dateStr,'07');
    case 'Aug'
        dateStr = strcat(dateStr,'08');
    case 'Sep'
        dateStr = strcat(dateStr,'09');
    case 'Oct'
        dateStr = strcat(dateStr,'10');
    case 'Nov'
        dateStr = strcat(dateStr,'11');
    case 'Dec'
        dateStr = strcat(dateStr,'12');
end
%uses first two digits (day) as last two digits in formatted string
date = strcat(dateStr,currDate(1:2));
%}
global dateStr
date = dateStr
%date = '170607';    %Date of test being taken
%datFol = 'Test Images 1';     %Test folder name
fName = 'Image_'; %Baseline File Name
imType = 'tiff';    %Sets type of image to acquire with system
iter = 1; %Measurement iteration number, needed for not overwriting grids currently


   
%% Make a new grid

% Illumination Grid Initialization
calCnt = 0;
% Set up structures needed as input for grid maker

iSet = struct;
iSet.pixL = illum.pixL;
iSet.Mag = illum.Mag;
iSet.nPix = illum.nPix;
iSet.fL = illum.fL;
iSet.lambda = illum.lambda
fSet = struct;
fSet.date = date;
fSet.fpath = illum.fpath;
fSet.fol = datFol;
fSet.iter = calCnt

%Generate Grid based on center position
illumPos = genMotorGrid(illum.grid,iSet,illum.pitch,illum.NAval,illum.centerPos,fSet);
%-------------------------------------------------------------------------%


illum.numImg = size(illumPos,1);

%% Writes a new entry to the log file
    
    % Opens log file with a filepath based on the main path
    fields = fieldnames(illum);
    fid=fopen([illum.mainPath, '\Log.txt'],'a');
    
    % Generates first line, which includes the date and run name
    currDate = datestr(datetime);
    fprintf(fid, ['\r\n' currDate '. Run name: "' datFol '".'])
    
    % Adds a new line for every variable in the illum structure
    for i = 1:numel(fields)
        data = illum.(fields{i});
        if isnumeric(data) % If it's a number
            data = num2str(data);
        elseif ischar(data) % If it's a string
            strCell = strsplit(data, '\'); % If there are backslashes, splits into substrings
            data = strjoin(strCell, '\\'); % Re-adds backslashes with escapes so they're written properly
        end
        fprintf(fid, '\r\n    '); 
        fprintf(fid, '%-20s%s', [fields{i} ': '], data); % Writes new line to log
    end
    
    fprintf(fid, '\r\n');
    
%%

%Camera 1 Setting Initialization
c1Set.exp = -7.58;  %Sets exposure percentage to lowest value (no image change observed)
c1Set.shut = 326;   %Sets camera shutter time to default 326ms
c1Set.gn = 0;       %Turns off camera gain
c1Set.gam = 0.5;    %turns gamma modifications by camera to min. value
c1Set.sharp = 0;    %Turns off HP filter in camera
c1Set.br = 0;       %Turns brightness down to lowest value

%Camera 2 Setting Initialization <--unused currently
%{
c2Set.exp = -7.58;  %Sets exposure percentage to lowest value (no image change observed)
c2Set.shut = 100;   %Sets camera shutter time to 500ms
c2Set.gn = 0;       %Turns off camera gain
c2Set.gam = 0.5;    %turns gamma modifications by camera to min. value
c2Set.sharp = 0;    %Turns off HP filter in camera
c2Set.br = 0;       %Turns brightness down to lowest value
c2Set.fr = 6.5;     %Sets camera frame rate to 6.5 ms(?)
%}

%-----------------------------Camera Initialization-----------------------%
%%
%Preset Camera Folder Initialization
c1Fol = 'Camera 1';
%c2Fol = 'Camera 2';
mkdir([illum.mainPath '\Data\' date '\' datFol '\' c1Fol]); %Generate folder pathway for saving camera 1 images
%mkdir([illum.mainPath '\Data\' date '\' datFol '\' c2Fol]); %Generate folder pathway for saving camera 2 images

%Initialize Camera 1
global c1
c1 = videoinput('winvideo', 2, 'RGB32_2048x2048'); %Opens camera 1 for sample acquisition in 16 bit mode with no binning
c1.ReturnedColorSpace = 'grayscale';
%c1Par = getselectedsource(c1);     %Grabs handle controlling cam 1 settings
%setC1Param(c1,c1Par,c1Set);        %Initializes camera 1 settings
c1.FramesPerTrigger = 1
triggerconfig(c1, 'manual');
c1.TriggerRepeat = size(illumPos, 1)-1 %reserves number of images to take


%Initialize Camera 2 <--unused currently
%{
c2 = videoinput('pointgrey', 2, 'F7_Mono16_2592x1944_Mode0');
c2Par = getselectedsource(c2);  %Grabs handle controlling cam 2 settings
setC2Param(c2,c2Par,c2Set); %Initializes camera 2 settings
c2.FramesPerTrigger = 1
triggerconfig(c2, 'manual');
c2.TriggerRepeat = size(illumPos, 1)-1 %reserves number of images to take
%}

%-------------------------------------------------------------------------%
%------------------------Source Motor Initialization----------------------%
%%
%Initialize Motor 1
%m1 = initKDC(27250777); %Controls x-direction on source
%m2 = initKDC(27250826); %Controls y-direction on source motion
global m1
global m2
%--------------------------------Acquire Data-----------------------------%
%%

c1Mat = uint16(zeros(2048,2048,size(illumPos, 1))); %Preallocates 3-D matrix for saving images
%c2Mat = uint16(zeros(1944,2592,size(illumPos, 1))); %Preallocates 3-D matrix for saving images

start(c1)
%start(c2) <--unused currently
num = illumPos(1); %Grabs initial image number in source grid
totalImages = sprintf('%.3d',size(illumPos,1));

for k = 1:size(illumPos,1)
    tic
    num = illumPos(k,1); %Grabs initial image number in source grid
    numReadable = sprintf('%.3d', num); %makes file names start with extra zeros if not 3 digits (ex: 001, 002, etc.)
    disp(['Logging image ' numReadable ' of ' totalImages])
    
    %Translate Motors to grid position'
    moveMotor_Basic(m1,illumPos(k,2));
    moveMotor_Basic(m2,illumPos(k,3));
    movementTime = toc;
    %disp(['Movement time: ', num2str(movementTime)])
    pause(.4);
    
    %trigger(c2) <--unused currently
    trigger(c1)
    wait(c1,2,'logging') %waits for logging to complete

    disp(['Total loop time: ', num2str(toc)])
    disp(' ')
end

disp(' ');
num = illumPos(1);
%%
for k = 1:size(illumPos,1)
    %pause(.5)
    imgMat = getdata(c1,c1.FramesPerTrigger,'uint16');
    %imgMat = mat2gray(imgMat(:,:,(1:3))); %Convert matrix to grayscale
    c1Mat(:,:,k) = imgMat; %Temporary? takes only one layer of image
    num = illumPos(k,1); %Grabs initial image number in source grid
    numReadable = sprintf('%.3d', num); %makes file names start with extra zeros if not 3 digits (ex: 001, 002, etc.)
    imwrite(c1Mat(:,:,k),[illum.mainPath '\Data\' date '\' datFol '\' c1Fol '\' fName numReadable '.' imType]);
    disp('');
    disp(['Saving image ' numReadable ' of ' totalImages])

    %c2Mat(:,:,k) = getdata(c2,c2.FramesPerTrigger);
    %imwrite(getdata(c2),[illum.mainPath '\Data\' date '\' datFol '\' c2Fol '\' fName numReadable '.' imType]);
    %imwrite(c2Mat(:,:,k),[illum.mainPath '\Data\' date '\' datFol '\' c2Fol '\' fName numReadable '.' imType]);

end
%disp(toc);
disp(' ');
disp('Saving .mat file');
%tic;
save([illum.mainPath '\Data\' date '\' datFol '\' datFol '.mat'],'c1Mat','-v7.3');
%toc;
disp('Acquisition Complete');
%moveMotor_Basic(m1,0);
%moveMotor_Basic(m2,0);
m1.MoveHome(0,0);
m2.MoveHome(0,0);
finalTime = toc(tstart);
delete(c1);
%delete(c2)
clear c1
%-------------------------------------------------------------------------%