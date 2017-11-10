%Z axis capture script

%% General setup

% Use two vars below to set what range of images is taken
imRange = [5 15] %range of movement
numImages = 10 %number of images to take

stepSize = (imRange(2)-imRange(1))/numImages;
fName = 'Image_'; %Baseline File Name
imType = 'tiff';    %Sets type of image to acquire with system
c1Fol = 'Camera 1';
datFol = 'Z Axis Test 1';
%mainPath = uigetdir('D:\David\SP-IRIS Project'); %select main folder
mainPath = 'D:\David\SP-IRIS Project';
mkdir([mainPath '\Data\' dateFormatted '\' datFol '\' c1Fol '\']); %makes folder for this run

%% Determine today's date
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
dateFormatted = strcat(dateStr,currDate(1:2));

%% Camera setup
global c1
c1 = videoinput('winvideo', 2, 'RGB32_2048x2048'); %Opens camera 1 for sample acquisition in 16 bit mode with no binning
c1.ReturnedColorSpace = 'grayscale';
c1.FramesPerTrigger = 1
triggerconfig(c1, 'manual');
c1.TriggerRepeat = numImages+1 %reserves number of images to takes
c1Mat = uint16(zeros(2048, 2048, numImages+1)); %preallocates space for images

%% Sample stage z-motor startup
[motors, flag] = Connect2Piezo_3axis; %inefficient, starts all motors when only z needed
targetMotor = motors(3);
disp('Homing z-motor (waiting 25 seconds)...')
targetMotor.ZeroPosition(1); %homes z-motor
pause(25)
disp('Complete.')
disp('')

%% Image capture

start(c1)
totalImages = sprintf('%.3d', ((imRange(2)-imRange(1))/stepSize)+1);

for k = imRange(1):stepSize:imRange(2)
    tic;
    num = ((k-imRange(1))/stepSize); %Grabs image number
    numReadable = sprintf('%.3d', num+1); %makes file names start with extra zeros if not 3 digits (ex: 001, 002, etc.)
    disp(['Logging image ' numReadable ' of ' totalImages])
    
    %Translate motor to grid position
    MovePiezoStage(targetMotor, 1, k);
    [tst,pos] = targetMotor.GetPosOutput(0,0);
    
    % Waits for motor to reach desired coordinates
    tic;
    while round(pos,3) ~= k
        [tst,pos] = targetMotor.GetPosOutput(0,0);
        posum = strcat(num2str(round(pos)),'um'); %Prepares location string
        %disp(posum) %Updates location indicator
        pause(.1)
        timeElapsed = toc;
        if timeElapsed >= .5
            break
        end
    end
    disp(['Z-position: ', posum])
    trigger(c1);
    wait(c1,2,'logging'); %waits for logging to complete

    disp(['Total loop time: ', num2str(toc)])
    disp(' ')
end

%% Image saving

for k = 1:numImages+1
    
    imgMat = getdata(c1,c1.FramesPerTrigger,'uint16');
    c1Mat(:,:,k) = imgMat; 
    numReadable = sprintf('%.3d', k); %makes file names start with extra zeros if not 3 digits (ex: 001, 002, etc.)
    imwrite(c1Mat(:,:,k),[mainPath '\Data\' dateFormatted '\' datFol '\' c1Fol '\' fName numReadable '.' imType]);
    disp('');
    disp(['Saving image ' numReadable ' of ' totalImages])

end

%% Cleanup

delete(c1)