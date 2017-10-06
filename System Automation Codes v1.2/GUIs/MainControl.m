%{
This is the main GUI through which all features are accessible. It includes
ways to manually and automatically home and center the motors, move them to
specific locations, capture images according to a pre-defined grid, and pan
and focus with the sample stage motors.

VERSION HISTORY
8/26/17: Version 1.0
8/28/17: Version 1.1
    -Increased size of primary camera preview image in the sample stage
    window
    -Re-implemented automatic saving of a workspace file after each capture
9/15/17: Version 1.2
    -Added warning before overwriting an existing run
    -Added logging before each run (records status of illum structure, name
    of run, and time and date when run was initiated)
    -Added basic "installer" if no default folder present
        -Code now recognizes main folder relative to its directory--should
        allow it to run from anywhere, as long as proper folder structure
        is present
        -Installer moves a zip file containing all code in proper
        directories into the main directory, and unzips it there
    -Added compatibility with new circular grid settings

TO DO:
    -Create new version for Blackfly S camera
    -Allow user to switch between Blackfly S and Grasshopper (or add
    installer option)
    -Remove re-initialization of camera in every run
    -Find a way to allow the system to work with different cameras
    -Add "launcher" program
        -Launcher is shortcut that points to main directory
        -Auto-generated during installation?
%}

function varargout = MainControl(varargin)
% MAINCONTROLGUI MATLAB code for MainControl.fig
%      MAINCONTROLGUI, by itself, creates a new MAINCONTROLGUI or raises the existing
%      singleton*.
%
%      H = MAINCONTROLGUI returns the handle to a new MAINCONTROLGUI or the handle to
%      the existing singleton*.
%
%      MAINCONTROLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINCONTROLGUI.M with the given input arguments.
%
%      MAINCONTROLGUI('Property','Value',...) creates a new MAINCONTROLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainControl

% Last Modified by GUIDE v2.5 23-Aug-2017 11:10:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainControl_OpeningFcn, ...
                   'gui_OutputFcn',  @MainControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before MainControl is made visible.
function MainControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainControl (see VARARGIN)

% Choose default command line output for MainControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%% Motor Setup
% Initialize motors

disp('Starting motors...')

global m1; %Horizontal motor
global m2; %Vertical motor
m1 = initKDC(27250777); %Controls x-direction on source
m2 = initKDC(27250826); %Controls y-direction on source motion

% Set motor settings (velocity and acceleration, at least)
[g,h,i,j] = m1.GetVelParams(0,0,0,0)
m1.SetVelParams(g,h,5,2.6)
[k,l,m,n] = m2.GetVelParams(0,0,0,0)
m2.SetVelParams(k,l,5,2.6)
global autoHomeM1 %Boolean for homing horizontal motor at beginning of capture
global autoHomeM2 %Boolean for homing vertical motor at beginning of capture
global autoCenter %Boolean for centering motors at beginning of capture
% All checkboxes should be checked at beginning, so all booleans set to true
autoHomeM1 = true
autoHomeM2 = true
autoCenter = false

disp('Done.')

%% Portability functionality

% Find username, for file saving purposes
username = getenv('username')

% Get current file path
currPath = mfilename('fullpath')
% Gets main folder path from current one
mainPath = strrep(currPath,'\System Automation Codes\GUIs\MainControl', '')

%% Loading saved settings

global illum %Illumination settings?
global datFol

illum = struct
illum.mainPath = mainPath%'D:\David\SP-IRIS Project'

if exist([illum.mainPath, '\ConfigVars.mat'], 'file');
    disp('Config file exists. Loading...')
    load([illum.mainPath, '\ConfigVars']);
    disp('Done.')
else
    disp('Config file not found. Using default settings.')
    datFol = 'Normal Run (circle)';     %Test folder name
    illum.pitch = [.12 pi/6]; 
    illum.grid = 'circle';
    illum.centerPos = [4 3.6651]; %Saves illum. grid center, used first for initial motor position guess
    illum.numImg = 169; %Sets number of images to obtain
    illum.fL = 20; %Lens focal length/working distance (mm), used for circular grid only
    illum.NAval = [0 .148]; %Illumination NA range, not currently used
    illum.fpath = strcat([illum.mainPath, '\Documentation\Source Grids']);
    illum.pixL = 5.50E-03
    illum.Mag = 10
    illum.nPix = [2048 2048]
    illum.lambda = 5.30E-04
    
end

%% Camera setup

disp('Starting cameras...')

%Camera 1 Setting Initialization
global c1Set
c1Set.exp = -7.58;  %Sets exposure percentage to lowest value (no image change observed)
c1Set.shut = 326;   %Sets camera shutter time to 500ms
c1Set.gn = 0;       %Turns off camera gain
c1Set.gam = 0.5;    %turns gamma modifications by camera to min. value
c1Set.sharp = 0;    %Turns off HP filter in camera
c1Set.br = 0;       %Turns brightness down to lowest value

%Camera 2 Setting Initialization <--unused right now
%{
global c2Set
c2Set.exp = -7.58;  %Sets exposure percentage to lowest value (no image change observed)
c2Set.shut = 100;   %Sets camera shutter time to 500ms
c2Set.gn = 0;       %Turns off camera gain
c2Set.gam = 0.5;    %turns gamma modifications by camera to min. value
c2Set.sharp = 0;    %Turns off HP filter in camera
c2Set.br = 0;       %Turns brightness down to lowest value
c2Set.fr = 6.5;     %Sets camera frame rate to 6.5 ms(?)
%}

%Initialize Camera 1
global c1
c1 = videoinput('winvideo', 2, 'RGB32_2448x2048'); %Opens camera 1 for sample acquisition in 16 bit mode with no binning

%NOTE: following two lines don't work with winvideo drivers

%c1Par = getselectedsource(c1);     %Grabs handle controlling cam 1 settings
%setC1Param(c1,c1Par,c1Set);        %Initializes camera 1 settings

%Initialize Camera 2 <--unused right now
%{
global c2
c2 = videoinput('pointgrey', 2, 'F7_Mono16_2592x1944_Mode0');
c2Par = getselectedsource(c2);  %Grabs handle controlling cam 2 settings
setC2Param(c2,c2Par,c2Set); %Initializes camera 2 settings
%}
disp('Done.')

%% Date formatting
global dateStr
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

dateStr = strcat(dateStr,currDate(1:2)); %final date string, to be used in file names

%% File saving settings

global fName 
fName = 'Image_'; %Baseline File Name
global imType 
imType = 'tiff';    %Sets type of image to acquire with system
global iter 
iter = 1; %Measurement iteration number, needed for not overwriting grids currently

%% GUI setup

%Initialize checkboxes
set(handles.checkbox1, 'Value', 1); %Autohome checkbox for vertical motor
set(handles.checkbox2, 'Value', 1); %Autohome checkbox for horizontal motor
set(handles.checkbox5, 'Value', 0); %Autocenter checkbox

% Set indicators to current position
[tst,pos] = m1.GetPosition(0,0); %for x-motor
posmm = strcat(num2str(round(pos,4)),'mm') %Prepares location string
set(handles.text8, 'String', posmm)

[tst,pos] = m2.GetPosition(0,0); %for y-motor
posmm = strcat(num2str(round(pos,4)),'mm') %Prepares location string
set(handles.text6, 'String', posmm) %Updates location indicator

% UIWAIT makes MainControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end

% --- Outputs from this function are returned to the command line.
function varargout = MainControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end
%%

% --- Homes horizontal motor
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m1;

% Set status text
set(handles.text9, 'String', 'Homing...')
set(handles.text8, 'String', '')

% Run default motor homing function
m1.MoveHome(0,0)

notHitEnd = true
%pause(5)
% Waits for homing to finish--checks if motor has reached position 0
pause(.5)
[tst,pos] = m1.GetPosition(0,0);
while pos ~= 0
    [tst,pos] = m1.GetPosition(0,0);
    %Timeout(5)
    pause(.1);
    %fprintf(num2str(pos))
end

% Sets status text
set(handles.text8, 'String', '0mm')
set(handles.text9, 'String', 'Stopped')
end

%%
% --- Homes vertical motor
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m2;

% Sets status text
set(handles.text5, 'String', 'Homing...')
set(handles.text6, 'String', '')

% Runs custom homing function for vertical motor (workaround for defect)
m2.MoveHome(0,0)
pause(.5)

[tst,pos] = m2.GetPosition(0,0);
% Waits for homing to finish--checks if motor has reached position 0
while pos ~= 0
    [tst,pos] = m2.GetPosition(0,0);
    %Timeout(5)
    pause(.1);
    %set(handles.text8, 'String', pos)
end

% Sets status text
set(handles.text6, 'String', '0mm')
set(handles.text5, 'String', 'Stopped')
end

%%
% --- Run Alex's image capture function (auto-homes, centers, and takes images).
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Defining necessary global variables
global m1
global m2
global c1
global c2
global illum
global autoHomeM1
global autoHomeM2
global autoCenter
global datFol
global dateStr

%%
overwrite = 'Ok'
fileList = dir([illum.mainPath '\Data\' dateStr])
for i = 1:size(fileList)
    disp(strcmp(datFol, fileList(i).name))
    if strcmp(datFol, fileList(i).name)
        overwrite = questdlg('Your current run shares the name of a previous run. Overwrite previous run?', 'Overwrite?', 'Ok', 'Cancel', 'Cancel')
    end
end
%%
if strcmp(overwrite, 'Ok')
    %illum.centerPos = [1.8 4.1]; %Saves illum. grid center, used first for initial motor position guess

    %%
    % Homes horizontal motor if checkbox is checked
    if autoHomeM1 == 1
        % Runs same code as horizontal homing button
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles)
    end

    %%
    % Homes vertical motor if checkbox is checked
    if autoHomeM2 == 1
        % Runs same code as vertical homing button
        pushbutton2_Callback(handles.pushbutton2, eventdata, handles)
    end

    %%
    % Centers motors if checkbox is checked
    if autoCenter
        % Runs same code as centering button
        pushbutton4_Callback(handles.pushbutton4, eventdata, handles)
    end

    % Updates status text to indicate the capture is ongoing
    set(handles.text5, 'String', 'Capturing...')
    set(handles.text9, 'String', 'Capturing...')
    set(handles.text6, 'String', '')
    set(handles.text8, 'String', '')
    drawnow
    %{
    set(handles.pushbutton1, 'Enable', 'Off'); %Disables capture button
    set(handles.edit1, 'Enable', 'Off'); %Disables vertical control textbox
    set(handles.edit2, 'Enable', 'Off'); %Disables horizontal control textbox
    set(handles.pushbutton4, 'Enable', 'Off'); %Disables centering button
    set(handles.pushbutton2, 'Enable', 'Off'); %Disables vertical homing button
    set(handles.pushbutton3, 'Enable', 'Off'); %Disables horizontal homing button
    %}

    %%
    % Writes a new entry to the log file
    fields = fieldnames(illum);
    fid=fopen([illum.mainPath, '\Log.txt'],'a');
    currDate = datestr(datetime)
    fprintf(fid, ['\r\n' currDate '. Run name: "' datFol '".'])
    
    for i = 1:numel(fields)
        data = illum.(fields{i})
        if isnumeric(data)
            data = num2str(data)
        elseif ischar(data)
            strCell = strsplit(data, '\')
            data = strjoin(strCell, '\\\')
        end
        fprintf(fid, '\r\n    ') 
        fprintf(fid, '%-20s%s', [fields{i} ': '],data)
    end
    fprintf(fid, '\r\n')
    %fprintf(fid, ['\r\n    ' illum.pitch])
    %%
        
    % Runs the image capture script
    captureScript

    % Updates status text to reflect final positions
    [tst1,pos1] = m1.GetPosition(0,0)
    [tst2,pos2] = m2.GetPosition(0,0)
    pos1mm = strcat(num2str(pos1),'mm')
    pos2mm = strcat(num2str(pos2),'mm')
    set(handles.text6, 'String', pos2mm)
    set(handles.text8, 'String', pos1mm)
    set(handles.text5, 'String', 'Stopped')
    set(handles.text9, 'String', 'Stopped')

    set(handles.pushbutton1, 'Enable', 'On'); %Enables capture button
    set(handles.edit1, 'Enable', 'On'); %Enables vertical homing button
    set(handles.edit2, 'Enable', 'On'); %Enables horizontal homing button
    set(handles.pushbutton4, 'Enable', 'On'); %Enables centering button
    set(handles.pushbutton2, 'Enable', 'On'); %Enables vertical homing button
    set(handles.pushbutton3, 'Enable', 'On'); %Enables horizontal homing button
end
end

%%
% --- Text box for horizontal motor movement
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global m1

% Sets motors to given position
inputStr = get(hObject,'String') %Saves position to move to as string
inputDouble = str2double(inputStr) %Changes that string to a double
if isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    set(handles.text9, 'String', 'Invalid!')
else %Moves motor to entered coordinate
    set(handles.text9, 'String', 'Moving...')
    drawnow
    % Use custom movement function to move to desired coordinate
    moveMotor_Basic(m1,str2double(inputStr))
    
    [tst,pos] = m1.GetPosition(0,0)
    
    tic
    % Waits for motor to reach desired coordinate
    while round(pos,4) ~= round(inputDouble,4)
        [tst,pos] = m1.GetPosition(0,0);
        posmm = strcat(num2str(round(pos,4)),'mm') %Prepares location string
        set(handles.text8, 'String', posmm) %Updates location indicator
        pause(.1)
        if toc > 5
            disp('Timed out')
            break
        end
    end
    
    [tst,pos] = m1.GetPosition(0,0)
    posmm = strcat(num2str(round(pos,4)),'mm') %Prepares location string
    set(handles.text8, 'String', posmm) %Updates location indicator
    
    set(handles.text9, 'String', 'Stopped')
end
end

%%
% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%%
% --- Text box for vertical motor movement
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global m2

% Sets motors to given position
inputStr = get(hObject,'String') %Saves position to move to as string
inputDouble = str2double(inputStr) %Changes that string to a double
if isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    set(handles.text5, 'String', 'Invalid!') 
else %Moves motor to entered coordinate
    set(handles.text5, 'String', 'Moving...')
    drawnow
    % Use custom movement function to move to desired coordinate
    moveMotor_Basic(m2,str2double(inputStr))
    
    [tst,pos] = m2.GetPosition(0,0)
    
    tic
    % Waits for motor to reach desired coordinates
    while round(pos,4) ~= round(inputDouble,4)
        [tst,pos] = m2.GetPosition(0,0);
        posmm = strcat(num2str(round(pos,4)),'mm') %Prepares location string
        set(handles.text6, 'String', posmm) %Updates location indicator
        pause(.1)
        if toc > 5
            disp('Timed out')
            break
        end
    end
    [tst,pos] = m2.GetPosition(0,0)
    posmm = strcat(num2str(round(pos,4)),'mm') %Prepares location string
    set(handles.text6, 'String', posmm) %Updates location indicator
    
    set(handles.text5, 'String', 'Stopped')
end
end

%%
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%%
% --- Centering button.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Gets parameters needed for centering function
global illum %Illumination settings (used in centering function)
global m1 %Horizontal motor
global m2 %Vertical motor
global c1 %Main camera

% Sets default center position
%illum.centerPos = [1.8 4.1];

% Updates status text
set(handles.text5, 'String', 'Centering...')
set(handles.text9, 'String', 'Centering...')
set(handles.text6, 'String', '')
set(handles.text8, 'String', '')

%{
set(handles.pushbutton1, 'Enable', 'Off'); %Disables capture button
set(handles.edit1, 'Enable', 'Off'); %Disables vertical control textbox
set(handles.edit2, 'Enable', 'Off'); %Disables horizontal control textbox
set(handles.pushbutton4, 'Enable', 'Off'); %Disables centering button
set(handles.pushbutton2, 'Enable', 'Off'); %Disables vertical homing button
set(handles.pushbutton3, 'Enable', 'Off'); %Disables horizontal homing button
%}

% Initializes timer
tstart = tic

% Runs centering function
illum.centerPos = findCenterPos(m1,m2,c1,illum.centerPos);

% Ends timer
toc(tstart)
pause(.5)

% Updates status text with final position
[tst1,pos1] = m1.GetPosition(0,0)
[tst2,pos2] = m2.GetPosition(0,0)
pos1mm = strcat(num2str(pos1),'mm')
pos2mm = strcat(num2str(pos2),'mm')
set(handles.text6, 'String', pos2mm)
set(handles.text8, 'String', pos1mm)
set(handles.text5, 'String', 'Stopped')
set(handles.text9, 'String', 'Stopped')

% Saves a picture of the final location using calibration camera
global c2 %Calibration camera
global dateStr %Date in string form
global datFol %Folder name to put picture
global fName %File name for picture
global imType %Image type (default .tiff)

% Initialize camera 2
start(c2)
% Save final calibration image to its own folder
mkdir([illum.mainPath '\Data\' dateStr '\' datFol '\Calibration Image']);
imwrite(getdata(c2),[illum.mainPath '\Data\' dateStr '\' datFol '\' '\Calibration Image\' fName '.' imType]);

set(handles.pushbutton1, 'Enable', 'On'); %Enables capture button
set(handles.edit1, 'Enable', 'On'); %Enables vertical control textbox
set(handles.edit2, 'Enable', 'On'); %Enables horizontal control textbox
set(handles.pushbutton4, 'Enable', 'On'); %Enables centering button
set(handles.pushbutton2, 'Enable', 'On'); %Enables vertical homing button
set(handles.pushbutton3, 'Enable', 'On'); %Enables horizontal homing button

end


%%
% --- Opens sample stage control.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Runs image viewer
SampleStageControl
end

%%
% --- Grid settings.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GridSettings

end

%%
% --- Checkbox for vertical motor auto-homing
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

% If true, vertical autohoming is on--false, autohoming is off
global autoHomeM2
if (get(hObject,'Value') == get(hObject,'Max')) %Gets checkbox value
	autoHomeM2 = true
else
	autoHomeM2 = false
end
end

%%
% --- Checkbox for horizontal motor auto-homing
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

global autoHomeM1

% If true, horizontal autohoming is on--false, autohoming is off
if (get(hObject,'Value') == get(hObject,'Max')) %Gets checkbox value
	autoHomeM1 = true
else
	autoHomeM1 = false
end
end

%%
% --- Checkbox for auto-centering
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
global autoCenter

% If true, centering is on--false, autohoming is off
if (get(hObject,'Value') == get(hObject,'Max')) %Gets checkbox value
	autoCenter = true
else
	autoCenter = false
end
end

%useless callback for closing window
function uipanel3_DeleteFcn(varargin)
disp('meep')
global illum
global datFol
illum
datFol
savePath = [illum.mainPath, '\ConfigVars.mat']
save(savePath,'illum','datFol')
close all
clear all
end
