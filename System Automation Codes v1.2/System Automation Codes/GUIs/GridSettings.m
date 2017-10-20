%{
This program allows the user to easily change the grid settings for image
capture.
%}

function varargout = GridSettings(varargin)
% GRIDSETTINGS MATLAB code for GridSettings.fig
%      GRIDSETTINGS, by itself, creates a new GRIDSETTINGS or raises the existing
%      singleton*.
%
%      H = GRIDSETTINGS returns the handle to a new GRIDSETTINGS or the handle to
%      the existing singleton*.
%
%      GRIDSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRIDSETTINGS.M with the given input arguments.
%
%      GRIDSETTINGS('Property','Value',...) creates a new GRIDSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GridSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GridSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GridSettings

% Last Modified by GUIDE v2.5 25-Aug-2017 10:55:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GridSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @GridSettings_OutputFcn, ...
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


% --- Executes just before GridSettings is made visible.
function GridSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GridSettings (see VARARGIN)

% Choose default command line output for GridSettings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes GridSettings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GridSettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Text box for pitch on the x-axis
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global illum


inputStr = get(hObject,'String') %Saves input as string
inputDouble = str2double(inputStr) %Changes that string to a double
if ~isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    if inputDouble > 0
        illum.pitch(1) = inputDouble
    else
        disp('Invalid entry (pitch must be greater than 0)')
    end
else
    disp('Not recognized')
end




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

global illum
set(hObject, 'String', illum.pitch(1)) %Sets text box to show default x-axis pitch on startup


% --- Text box for pitch on the y-axis
function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
global illum

inputStr = get(hObject,'String') %Saves input as string
inputDouble = str2double(inputStr) %Changes that string to a double
if ~isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    if inputDouble > 0
        illum.pitch(2) = inputDouble
    else
        disp('Invalid entry (pitch must be greater than 0)')
    end
else
    disp('Not recognized')
end


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global illum
set(hObject, 'String', illum.pitch(2)) %Sets text box to show default y-axis pitch on startup


% --- Behavior for the drop-down menu that controls the grid type
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global illum

contents = cellstr(get(hObject, 'String'))
currVal = contents{get(hObject,'Value')}

switch currVal % Switches grid shape
    case 'Square'
        illum.grid = 'square' 
    case 'Square NA'
        illum.grid = 'squareNA' 
    case 'Circular'
        illum.grid = 'circle' 
end

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global illum

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

currSetting = illum.grid

% Sets initial value for dropdown menu (1 is square, 2 is square NA)
switch currSetting
    case 'square'
        set(hObject, 'Value', 1)
    case 'squareNA'
        set(hObject, 'Value', 2)
    case 'circle'
        set(hObject, 'Value', 3)
end

% --- Text box for magnification
function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
global illum

inputStr = get(hObject,'String') %Saves input as string
inputDouble = str2double(inputStr) %Changes that string to a double
if ~isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    if inputDouble > 0
        illum.Mag = inputDouble
    else
        disp('Invalid entry (magnification must be greater than 0)')
    end
else
    disp('Not recognized')
end


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global illum
set(hObject, 'String', illum.Mag) %Sets contents of textbox to reflect default number of pictures, 169

% --- Text box to set focal length
function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
global illum

inputStr = get(hObject,'String') %Saves input as string
inputDouble = str2double(inputStr) %Changes that string to a double
if ~isnan(inputDouble) %Checks if not a number, informs user that input is invalid
    if inputDouble >= 0
        illum.fL = inputDouble
    else
        disp('Invalid entry (focal length can''t be negative)')
    end
else
    disp('Not recognized')
end


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global illum
set(hObject, 'String', illum.fL) %Sets contents of textbox to reflect default focal length, 1mm


% --- Sets center x-coordinate
function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
global illum

inputStr = get(hObject,'String') %Saves input as string
inputDouble = str2double(inputStr) %Changes that string to a double
if ~isnan(inputDouble) %Checks if not a valid number, informs user that input is invalid
    if inputDouble >= 0 & inputDouble <= 6
        illum.centerPos(1) = inputDouble
    else
        disp('Invalid entry (center position must be between 0 and 6 millimeters)')
    end
else
    disp('Not recognized')
end



% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global illum
set(hObject, 'String', illum.centerPos(1)) %Sets contents of textbox to reflect default focal length, 1mm




% --- Sets center y-coordinate
function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
global illum

inputStr = get(hObject,'String') %Saves input as string
inputDouble = str2double(inputStr) %Changes that string to a double
if ~isnan(inputDouble) %Checks if not a valid number, informs user that input is invalid
    if inputDouble >= 0 & inputDouble <= 6
        illum.centerPos(2) = inputDouble
    else
        disp('Invalid entry (center position must be between 0 and 6 millimeters)')
    end
else
    disp('Not recognized')
end

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global illum
set(hObject, 'String', illum.centerPos(2)) %Sets contents of textbox to reflect default focal length, 1mm


% --- Text box for setting grid file path
function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
global illum

inputStr = get(hObject,'String') %Saves input as string
inputDouble = str2double(inputStr) %Changes that string to a double
if ~isnan(inputDouble) & inputDouble >= 0 & inputDouble <= 6 %Checks if not a valid number, informs user that input is invalid
    illum.NAval(1) = inputDouble
else
    disp('Not recognized')
end 


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global illum
set(hObject, 'String', illum.NAval(1)) %Sets textbox to initially show the default file path for grid files


% --- Text box for editing main directory
function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
global illum

inputStr = get(hObject,'String') %Saves input as string
inputDouble = str2double(inputStr) %Changes that string to a double
if ~isnan(inputDouble) & inputDouble >= 0 & inputDouble <= 6 %Checks if not a valid number, informs user that input is invalid
    illum.NAval(2) = inputDouble
else
    disp('Not recognized')
end


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global illum
set(hObject, 'String', illum.NAval(2)) %Sets textbox to initially show the default file path for saving images


% --- Textbox for changing the name of the run
function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double
global datFol
datFol = get(hObject,'String') %Saves input as string

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global datFol
set(hObject, 'String', datFol) %Sets textbox to initially show the default run name
