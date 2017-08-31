%%
tstart = tic;
%clear all
%close all
%%
%Program Notes

%Things to improve on
% 1. Expand Motor control capabilities beyond basic control scheme
% 2. Make obtaining today's date automatic for this system
% 3. Add automatic control of source stadjgkge to system
% 4. Convert data acquisition method to saving all oblique illumination
%    images into a single 3-D data stack 
% 5. On startup, the software only thinks that the max cam1 shutter speed
% time is 24ms where it can really be set to 700ms in 16 bit mode


%--------------------------Variable Initialization------------------------%
%Save Folder Parameters
%fpath = 'D:\David\SP-IRIS Project\Data';     %Data Acquistion file path
global illum
global datFol

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

%date = '170607';    %Date of test being taken
%datFol = 'Test Images 1';     %Test folder name
fName = 'Image_'; %Baseline File Name
imType = 'tiff';    %Sets type of image to acquire with system
iter = 1; %Measurement iteration number, needed for not overwriting grids currently

%Illumination Grid Initialization
calCnt = 0;
%{
illum.pitch = [0.145 0.145]; 
illum.grid = 'squareNA';
illum.centerPos = [1.8 4.1]; %Saves illum. grid center, used first for initial motor position guess
illum.numImg = 169; %Sets number of images to obtain
illum.fL = 1; %Lens focal length/working distance (mm), used for circular grid only
illum.NAval = [0 1]; %Illumination NA range, not currently used
illum.fpath = 'C:\Users\amatlock\Documents\SP-IRIS Project\Documentation\Source Grids';
    %Old grid implementation method
    % illumFile = 'C:\Users\amatlock\Documents\SP-IRIS Project\Documentation\Source Grids\13x13Grid_Optimization3.txt'; %Text document containing source absolute coordinates
    % illumPos = double(table2array(readtable(illumFile,'Format','%f%f%f'))); %Grab source coordinates from text document
%}
    
%Camera 1 Setting Initialization
c1Set.exp = -7.58;  %Sets exposure percentage to lowest value (no image change observed)
c1Set.shut = 326;   %Sets camera shutter time to default 326ms
c1Set.gn = 0;       %Turns off camera gain
c1Set.gam = 0.5;    %turns gamma modifications by camera to min. value
c1Set.sharp = 0;    %Turns off HP filter in camera
c1Set.br = 0;       %Turns brightness down to lowest value

%Camera 2 Setting Initialization
c2Set.exp = -7.58;  %Sets exposure percentage to lowest value (no image change observed)
c2Set.shut = 100;   %Sets camera shutter time to 500ms
c2Set.gn = 0;       %Turns off camera gain
c2Set.gam = 0.5;    %turns gamma modifications by camera to min. value
c2Set.sharp = 0;    %Turns off HP filter in camera
c2Set.br = 0;       %Turns brightness down to lowest value
c2Set.fr = 6.5;     %Sets camera frame rate to 6.5 ms(?)

%-----------------------------Camera Initialization-----------------------%
%%
%Preset Camera Folder Initialization
c1Fol = 'Camera 1';
c2Fol = 'Camera 2';
mkdir([illum.mainPath '\Data\' date '\' datFol '\' c1Fol]); %Generate folder pathway for saving camera 1 images
mkdir([illum.mainPath '\Data\' date '\' datFol '\' c2Fol]); %Generate folder pathway for saving camera 2 images

%Initialize Camera 1
c1 = videoinput('pointgrey', 1, 'F7_Mono16_2048x2048_Mode0'); %Opens camera 1 for sample acquisition in 16 bit mode with no binning
c1Par = getselectedsource(c1);     %Grabs handle controlling cam 1 settings
setC1Param(c1,c1Par,c1Set);        %Initializes camera 1 settings
c1.FramesPerTrigger = 1
triggerconfig(c1, 'manual');
c1.TriggerRepeat = illum.numImg-1 %reserves number of images to take


%Initialize Camera 2
c2 = videoinput('pointgrey', 2, 'F7_Mono16_2592x1944_Mode0');
c2Par = getselectedsource(c2);  %Grabs handle controlling cam 2 settings
setC2Param(c2,c2Par,c2Set); %Initializes camera 2 settings
c2.FramesPerTrigger = 1
triggerconfig(c2, 'manual');
c2.TriggerRepeat = illum.numImg-1 %reserves number of images to take


%-------------------------------------------------------------------------%
%------------------------Source Motor Initialization----------------------%
%%
%Initialize Motor 1
%m1 = initKDC(27250777); %Controls x-direction on source
%m2 = initKDC(27250826); %Controls y-direction on source motion
global m1
global m2
%%
%Homes Motors to revert to absolute position measurements.
%NOTE: This may still fail currently
%{
global autoHomeM1
global autoHomeM2
disp(autoHomeM1)
disp(autoHomeM2)
if autoHomeM1 == 1
    m1.MoveHome(0,0); %used default homing function because m1 doesn't overcurrent
    pause(.5)
    [tst,pos] = m1.GetPosition(0,0);
    while pos ~= 0
        [tst,pos] = m1.GetPosition(0,0);
        pause(.1)
    end
end

if autoHomeM2 == 1
    HomeSafeTest(m2);
    pause(10)
end 


    
%%
global autoCenter
if autoCenter
    illum.centerPos = findCenterPos(m1,m2,c1,illum.centerPos);
    calCnt = calCnt + 1;
    disp(illum.centerPos);
end
%}
%%




%Generate Grid based on center position
illumPos = makeMotorGrid(illum.centerPos,illum.pitch,illum.grid,illum.numImg,illum.fL,illum.NAval,illum.fpath,date,calCnt);
%-------------------------------------------------------------------------%
%--------------------------------Acquire Data-----------------------------%
%%

c1Mat = uint16(zeros(2048,2048,illum.numImg)); %Preallocates 3-D matrix for saving images
c2Mat = uint16(zeros(1944,2592,illum.numImg)); %Preallocates 3-D matrix for saving images

num = illumPos(1); %Grabs initia image number in source grid
start(c1)
start(c2)

for k = 1:size(illumPos,1)
    tic
    num = illumPos(k,1); %Grabs initial image number in source grid
    numReadable = sprintf('%.3d', num) %makes file names start with extra zeros if not 3 digits (ex: 001, 002, etc.)

    %Translate Motors to grid position'
    moveMotor_Basic(m1,illumPos(k,2));
    %waitForMovement(m1,illumPos(k,2));
    moveMotor_Basic(m2,illumPos(k,3));
    %waitForMovement(m2,illumPos(k,3));
    movementTime = toc
    disp(['Movement time: ', num2str(movementTime)])
    if movementTime < .7
        pause(.7-movementTime)
    end
    
    %{
    if (k == 1)
        pause(10);
    else
        pause(5);
    end
    %}
    
    trigger(c2)
    trigger(c1)
    pause(.5)

    

    disp(['Total loop time: ', num2str(toc)])
end

num = illumPos(1);
%%
for k = 1:size(illumPos,1)
    %pause(.5)
    c1Mat(:,:,k) = getdata(c1,c1.FramesPerTrigger);
    num = illumPos(k,1); %Grabs initial image number in source grid
    numReadable = sprintf('%.3d', num) %makes file names start with extra zeros if not 3 digits (ex: 001, 002, etc.)
    imwrite(c1Mat(:,:,k),[illum.mainPath '\Data\' date '\' datFol '\' c1Fol '\' fName numReadable '.' imType]);

    c2Mat(:,:,k) = getdata(c2,c2.FramesPerTrigger);
    %imwrite(getdata(c2),[illum.mainPath '\Data\' date '\' datFol '\' c2Fol '\' fName numReadable '.' imType]);
    imwrite(c2Mat(:,:,k),[illum.mainPath '\Data\' date '\' datFol '\' c2Fol '\' fName numReadable '.' imType]);

end
disp(toc);
disp('Saving .mat file')
tic
save([illum.mainPath '\Data\' date '\' datFol '\' datFol '.mat'],'c1Mat','-v7.3');
toc
disp('Acquisition Complete');
%moveMotor_Basic(m1,0);
%moveMotor_Basic(m2,0);
m1.MoveHome(0,0);
m2.MoveHome(0,0);
finalTime = toc(tstart)
%-------------------------------------------------------------------------%