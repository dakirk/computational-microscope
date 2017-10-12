%Finish later--all buttons laid out, just needs functionality


function varargout = Installer(varargin)
% INSTALLER MATLAB code for Installer.fig
%      INSTALLER, by itself, creates a new INSTALLER or raises the existing
%      singleton*.
%
%      H = INSTALLER returns the handle to a new INSTALLER or the handle to
%      the existing singleton*.
%
%      INSTALLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSTALLER.M with the given input arguments.
%
%      INSTALLER('Property','Value',...) creates a new INSTALLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Installer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Installer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Installer

% Last Modified by GUIDE v2.5 15-Sep-2017 13:52:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Installer_OpeningFcn, ...
                   'gui_OutputFcn',  @Installer_OutputFcn, ...
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


% --- Executes just before Installer is made visible.
function Installer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Installer (see VARARGIN)

% Choose default command line output for Installer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Installer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Sets checkbox to be checked by default
set(handles.checkbox1, 'Value', 1);

% --- Outputs from this function are returned to the command line.
function varargout = Installer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global illum

illum.mainPath = get(hObject,'String') %Saves input as string


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
set(hObject, 'String', '') %Sets textbox to initially show the default file path for saving images


% --- Button to open folder selection dialog
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global illum
directory = uigetdir(pwd); %Allows user to select a new path
if directory ~= 0 %If the user selects something (and therefore uigetdir doesn't return zero), set their input as the new file path
    illum.mainPath = directory
end

set(handles.edit1, 'String', illum.mainPath) %Update the text box to display new path


% --- Finish button--closes window, creates necessary folders 
% (including config file), and launches main control program
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global illum

% Default settings--can be changed later in settings window
%{
illum.pitch = [0.1405 0.1405]; 
illum.grid = 'squareNA';
illum.centerPos = [4.2741 3.5895]; %Saves illum. grid center, used first for initial motor position guess
illum.numImg = 169; %Sets number of images to obtain
illum.fL = 1; %Lens focal length/working distance (mm), used for circular grid only
illum.NAval = [0 1]; %Illumination NA range, not currently used
illum.fpath = strcat([illum.mainPath, '\Documentation\Source Grids']);
%}
% Creates necessary subfolders
disp('Creating new folders...')
mkdir([illum.mainPath '\Data']);
mkdir([illum.mainPath '\Documentation']);
disp('Done')

% Creates config file
%{
savePath = [illum.mainPath, '\ConfigVars.mat']
save(savePath,'illum')
%}

% Copies zipped code from installer folder to the new main folder and
% unzips it
disp('Installing updated code...')
currPath = mfilename('fullpath');
currPath = strrep(currPath,'\Installer', '');
copyfile('System Automation Codes.zip', illum.mainPath);
cd(illum.mainPath);
unzip('System Automation Codes.zip');
disp('Done')

% Adds new code to path
addpath(genpath('System Automation Codes'))

if (get(handles.checkbox1,'Value') == get(handles.checkbox1,'Max')) %Gets checkbox value
    close
    MainControl
    
else
    close
end



% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

