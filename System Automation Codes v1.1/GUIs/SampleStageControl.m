function varargout = SampleStageControl(varargin)
% SAMPLESTAGECONTROL MATLAB code for SampleStageControl.fig
%      SAMPLESTAGECONTROL, by itself, creates a new SAMPLESTAGECONTROL or raises the existing
%      singleton*.
%
%      H = SAMPLESTAGECONTROL returns the handle to a new SAMPLESTAGECONTROL or the handle to
%      the existing singleton*.
%
%      SAMPLESTAGECONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAMPLESTAGECONTROL.M with the given input arguments.
%
%      SAMPLESTAGECONTROL('Property','Value',...) creates a new SAMPLESTAGECONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SampleStageControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SampleStageControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SampleStageControl

% Last Modified by GUIDE v2.5 29-Aug-2017 13:21:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SampleStageControl_OpeningFcn, ...
                   'gui_OutputFcn',  @SampleStageControl_OutputFcn, ...
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


% --- Executes just before SampleStageControl is made visible.
function SampleStageControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SampleStageControl (see VARARGIN)

% Choose default command line output for SampleStageControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SampleStageControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Camera 1 Setting Initialization
c1Set.exp = -7.58;  %Sets exposure percentage to lowest value (no image change observed)
c1Set.shut = 326;   %Sets camera shutter time to 500ms
c1Set.gn = 0;       %Turns off camera gain
c1Set.gam = 0.5;    %turns gamma modifications by camera to min. value
c1Set.sharp = 0;    %Turns off HP filter in camera
c1Set.br = 0;       %Turns brightness down to lowest value

global c1
%Initialize Camera 1
c1 = videoinput('pointgrey', 1, 'F7_Mono16_2048x2048_Mode0'); %Opens camera 1 for sample acquisition in 16 bit mode with no binning
c1Par = getselectedsource(c1);     %Grabs handle controlling cam 1 settings
setC1Param(c1,c1Par,c1Set);        %Initializes camera 1 settings


axes(handles.axes1);
start(c1)
imshow(mat2gray(getdata(c1)));

%{
set(handles.text2,'String','Connecting...')
set(handles.text4,'String','Connecting...')
set(handles.text6,'String','Connecting...')
set(handles.text3,'String','')
set(handles.text5,'String','')
set(handles.text7,'String','')
%}




% --- Outputs from this function are returned to the command line.
function varargout = SampleStageControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
set(handles.pushbutton1, 'Enable', 'Off');
set(handles.edit1, 'Enable', 'Off');
set(handles.pushbutton2, 'Enable', 'Off');
set(handles.edit2, 'Enable', 'Off');
set(handles.pushbutton3, 'Enable', 'Off');
set(handles.edit3, 'Enable', 'Off');

%{
global motors
[motors, flag] = Connect2Piezo_3axis

set(handles.text2,'String','Ready')
set(handles.text4,'String','Ready')
set(handles.text6,'String','Ready')
set(handles.text3,'String','')
set(handles.text5,'String','')
set(handles.text7,'String','')
%}


% --- Text box for moving z-motor
function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

global motors

inputStr = get(hObject,'String') %Saves position to move to as string
inputDouble = str2double(inputStr) %Changes that string to a double
if isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    set(handles.text6, 'String', 'Invalid!') 
else %Moves motor to entered coordinate
    set(handles.text6, 'String', 'Moving...')
    
    % Use custom movement function to move to desired coordinate
    MovePiezoStage(motors(2), 1, str2double(inputStr))
    
    [tst,pos] = motors(2).GetPosOutput(0,0)
    
    % Waits for motor to reach desired coordinates
    tic
    while round(pos,3) ~= round(inputDouble,3)
        [tst,pos] = motors(2).GetPosOutput(0,0);
        posum = strcat(num2str(round(pos,4)),'um') %Prepares location string
        set(handles.text7, 'String', posum) %Updates location indicator
        pause(.1)
        timeElapsed = toc
        if timeElapsed >= .5
            break
        end
    end
    
    set(handles.text6, 'String', 'Stopped')
end

set(handles.text12, 'Visible', 'On')
global c1
axes(handles.axes1);
start(c1)
imshow(mat2gray(getdata(c1)));
set(handles.text12, 'Visible', 'Off')


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Homes z-motor
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global motors
motors(2).ZeroPosition(0);

% Disable button and textbox while homing
set(handles.text6, 'String', 'Homing...')
set(handles.text7, 'String', '')
set(handles.pushbutton3, 'Enable', 'Off');
set(handles.edit3, 'Enable', 'Off');
pause(15)
set(handles.pushbutton3, 'Enable', 'On');
set(handles.edit3, 'Enable', 'On');
set(handles.text6, 'String', 'Stopped')
set(handles.text7, 'String', '0um')

% Refresh image preview
set(handles.text12, 'Visible', 'On')
global c1
axes(handles.axes1);
start(c1)
imshow(mat2gray(getdata(c1)));
set(handles.text12, 'Visible', 'Off')

% --- Text box to control position of y-motor
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

global motors

inputStr = get(hObject,'String') %Saves position to move to as string
inputDouble = str2double(inputStr) %Changes that string to a double
if isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    set(handles.text4, 'String', 'Invalid!') 
else %Moves motor to entered coordinate
    set(handles.text4, 'String', 'Moving...')
    
    % Use custom movement function to move to desired coordinate
    MovePiezoStage(motors(3), 1, str2double(inputStr))
    
    [tst,pos] = motors(3).GetPosOutput(0,0)
    
    % Waits for motor to reach desired coordinates
    tic
    while round(pos,3) ~= round(inputDouble,3)
        [tst,pos] = motors(3).GetPosOutput(0,0);
        posum = strcat(num2str(round(pos,4)),'um') %Prepares location string
        set(handles.text5, 'String', posum) %Updates location indicator
        pause(.1)
        timeElapsed = toc
        if timeElapsed >= .5
            break
        end
    end
    
    set(handles.text4, 'String', 'Stopped')
end

set(handles.text12, 'Visible', 'On')
global c1
axes(handles.axes1);
start(c1)
imshow(mat2gray(getdata(c1)));
set(handles.text12, 'Visible', 'Off')

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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global motors
motors(3).ZeroPosition(0);

% Disable button and textbox while homing
set(handles.text4, 'String', 'Homing...')
set(handles.text5, 'String', '')
set(handles.pushbutton2, 'Enable', 'Off');
set(handles.edit2, 'Enable', 'Off');
pause(15)
set(handles.pushbutton2, 'Enable', 'On');
set(handles.edit2, 'Enable', 'On');
set(handles.text4, 'String', 'Stopped')
set(handles.text5, 'String', '0um')

% Refresh image preview
set(handles.text12, 'Visible', 'On')
global c1
axes(handles.axes1);
start(c1)
imshow(mat2gray(getdata(c1)));
set(handles.text12, 'Visible', 'Off')


% --- Text box for controlling x-axis motor
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

global motors

inputStr = get(hObject,'String') %Saves position to move to as string
inputDouble = str2double(inputStr) %Changes that string to a double
if isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    set(handles.text2, 'String', 'Invalid!') 
else %Moves motor to entered coordinate
    set(handles.text2, 'String', 'Moving...')
    
    % Use custom movement function to move to desired coordinate
    MovePiezoStage(motors(1), 1, str2double(inputStr))
    
    [tst,pos] = motors(1).GetPosOutput(0,0)
    
    % Waits for motor to reach desired coordinates
    tic
    while round(pos,3) ~= round(inputDouble,3)
        [tst,pos] = motors(1).GetPosOutput(0,0);
        posum = strcat(num2str(round(pos,4)),'um') %Prepares location string
        set(handles.text3, 'String', posum) %Updates location indicator
        pause(.1)
        timeElapsed = toc
        if timeElapsed >= .5
            break
        end
    end
    
    set(handles.text2, 'String', 'Stopped')
end

set(handles.text12, 'Visible', 'On')
global c1
axes(handles.axes1);
start(c1)
imshow(mat2gray(getdata(c1)));
set(handles.text12, 'Visible', 'Off')


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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global motors
motors(1).ZeroPosition(0);

% Disable button and textbox while homing
set(handles.text2, 'String', 'Homing...')
set(handles.text3, 'String', '')
set(handles.pushbutton1, 'Enable', 'Off');
set(handles.edit1, 'Enable', 'Off');
pause(15)
set(handles.pushbutton1, 'Enable', 'On');
set(handles.edit1, 'Enable', 'On');
set(handles.text2, 'String', 'Stopped')
set(handles.text3, 'String', '0um')

% Refresh image preview
set(handles.text12, 'Visible', 'On')
global c1
axes(handles.axes1);
start(c1)
imshow(mat2gray(getdata(c1)));
set(handles.text12, 'Visible', 'Off')


% --- Refresh button
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Refresh image preview
set(handles.text12, 'Visible', 'On')
global c1
axes(handles.axes1);
start(c1)
imshow(mat2gray(getdata(c1)));
set(handles.text12, 'Visible', 'Off')


% --- Starts motors
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.text2,'String','Connecting...')
set(handles.text4,'String','Connecting...')
set(handles.text6,'String','Connecting...')
set(handles.text3,'String','')
set(handles.text5,'String','')
set(handles.text7,'String','')

global motors
[motors, flag] = Connect2Piezo_3axis

set(handles.pushbutton1, 'Enable', 'On');
set(handles.edit1, 'Enable', 'On');
set(handles.pushbutton2, 'Enable', 'On');
set(handles.edit2, 'Enable', 'On');
set(handles.pushbutton3, 'Enable', 'On');
set(handles.edit3, 'Enable', 'On');

set(handles.text2,'String','Ready')
set(handles.text4,'String','Ready')
set(handles.text6,'String','Ready')

% Update position of x-motor
[tst,pos] = motors(1).GetPosOutput(0,0);
posum = strcat(num2str(round(pos,4)),'um') %Prepares location string
set(handles.text3, 'String', posum) %Updates location indicator

% Update position of y-motor
[tst,pos] = motors(3).GetPosOutput(0,0);
posum = strcat(num2str(round(pos,4)),'um') %Prepares location string
set(handles.text5, 'String', posum) %Updates location indicator

% Update position of z-motor
[tst,pos] = motors(2).GetPosOutput(0,0);
posum = strcat(num2str(round(pos,4)),'um') %Prepares location string
set(handles.text7, 'String', posum) %Updates location indicator
