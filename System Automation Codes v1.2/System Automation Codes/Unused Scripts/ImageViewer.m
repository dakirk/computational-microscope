%{
Author: David Kirk

Purpose: This program is an image viewer with two panes to view the images taken so
far during capture, and also the position of the illumination stage at that
point. It will also run on its own. Currently not used, because the capture
program no longer saves each image one-by-one, instead saving them all at
once.
%}

function varargout = ImageViewer(varargin)
% IMAGEVIEWER MATLAB code for ImageViewer.fig
%      IMAGEVIEWER, by itself, creates a new IMAGEVIEWER or raises the existing
%      singleton*.
%
%      H = IMAGEVIEWER returns the handle to a new IMAGEVIEWER or the handle to
%      the existing singleton*.
%
%      IMAGEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEVIEWER.M with the given input arguments.
%
%      IMAGEVIEWER('Property','Value',...) creates a new IMAGEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageViewer

% Last Modified by GUIDE v2.5 23-Aug-2017 11:09:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageViewer_OutputFcn, ...
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

% --- Executes just before ImageViewer is made visible.
function ImageViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageViewer (see VARARGIN)

% Choose default command line output for ImageViewer
handles.output = hObject;
global fpath

%get a list of all files in directory
global slider1Attribs;
global slider2Attribs;
slider1Attribs.nameList = {};
slider1Attribs.folderName = fpath;
slider2Attribs.nameList = {};
slider2Attribs.folderName = fpath;

global dateStr;
global scrollSync;
scrollSync = 0;
%folderName = 'C:\Users\dsak\Documents\SP-IRIS Project\Data\'

% Update handles structure
startSlider(handles, handles.slider1, handles.text2, handles.axes1, slider1Attribs);
disp(ans)
startSlider(handles, handles.slider2, handles.text3, handles.axes2, slider2Attribs);
guidata(hObject, handles);

% UIWAIT makes ImageViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Assigns settings to the targeted slider--text and axis are UI objects
% that should be grouped with the slider, and sliderAttribs is a structure
% containing various slider attributes, like the names of the files it
% should scroll through
function nameList = startSlider(handles, slider, text, axis, sliderAttribs)
%nameList = sliderAttribs.nameList
nameList = {};
folderName = sliderAttribs.folderName;
fileList = dir(folderName);
listSize = size(fileList);
%%

%parses list looking for .tiff, .jpg, and .png files only, saves them in nameList
for i = 1:listSize(1);
    currFile = fileList(i).name;
    currFileSize = size(currFile);
    if currFileSize(2) >= 3;
        if strcmp(currFile(end-3:end),'tiff') | strcmp(currFile(end-3:end),'.jpg') | strcmp(currFile(end-3:end),'.png') | strcmp(currFile(end-3:end),'.bmp') ;
            nameList{end+1} = currFile;
        end
    end
end
%%
nameList;
size(nameList);
%%
%Initializes slider settings--from 0 to 6, with steps 1 through 7
%(integers)
nameListLength = size(nameList);
maxNameListLength = nameListLength(2)-1;
imPath = '';
%set(handles.slider1, 'Min', 1);
if nameListLength(2) >= 2 % Default behavior for 2 or more images
    set(slider, 'Max', maxNameListLength);
    set(slider, 'SliderStep', [1/maxNameListLength , 1/maxNameListLength]);
    imPath = strcat(folderName,'\',nameList(1));
    set(slider, 'Enable', 'On');
    set(slider, 'Visible', 'On');
    set(slider, 'Value', 0);
    set(text, 'String', nameList(1));
elseif nameListLength(2) == 1 % Same as multiple images but hides slider
    imPath = strcat(folderName,'\',nameList(1));
    set(slider, 'Enable', 'Off');
    set(slider, 'Visible', 'On');
    set(text, 'String', nameList(1));
else % For zero images--displays an X to indicate the folder is empty
    imPath = 'x-30465_960_720.png';
    set(text, 'String', 'Nothing Selected');
    set(slider, 'Visible', 'Off');
end
%%
%imPath = strcat(folderName,'/',nameList(1));
axes(axis);
imshow(char(imPath));

%sliderAttribs.nameList = nameList
end

% --- Outputs from this function are returned to the command line.
function varargout = ImageViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Behavior for the left-hand slider
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
global slider1Attribs;
global scrollSync

nameList = slider1Attribs.nameList;
folderName = slider1Attribs.folderName;

%%
%forces slider position to be whole number
val=round(hObject.Value);
hObject.Value=val;

%%
%scrollSync
if scrollSync == 1 & get(hObject, 'Value') <= get(handles.slider2, 'Max') & get(handles.slider2, 'Max') > 1
    %disp('made it here')
    set(handles.slider2, 'Value', get(handles.slider1, 'Value'));
    slider2_Callback(hObject, eventdata, handles)
end

%%
%gets slider value for later use
sliderValue = 1+get(handles.slider1, 'Value');
imPath = strcat(folderName,'/',nameList(round(sliderValue)));

%sets caption text to show file name
set(handles.text2, 'String', nameList(round(sliderValue)));

%shows image on selected axis object
axes(handles.axes1);
%imshow(char(nameList(round(sliderValue))));
imshow(char(imPath));

%}
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
guidata(hObject, handles);
end


% --- Refresh button for the first image set
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global slider1Attribs;

% Re-initializes slider to update it
%ImageViewer_OpeningFcn(hObject, eventdata, handles)
startSlider(handles, handles.slider1, handles.text2, handles.axes1, slider1Attribs);
slider1Attribs.nameList = ans;
end


% --- Select button for the first image set
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global slider1Attribs;
global fpath

prevFolderName = slider1Attribs.folderName

% Opens folder selection interface
slider1Attribs.folderName = uigetdir(fpath)

if slider1Attribs.folderName ~= 0
    % Refreshes scrollbar/slider
    startSlider(handles, handles.slider1, handles.text2, handles.axes1, slider1Attribs);
    slider1Attribs.nameList = ans;
else
    % Resets to initial folder if none selected
    slider1Attribs.folderName = prevFolderName
end
end


% --- Behavior for the right-hand slider
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%%
global slider2Attribs;
global scrollSync

nameList = slider2Attribs.nameList;
folderName = slider2Attribs.folderName;

%%
%forces slider position to be whole number
val=round(hObject.Value);
hObject.Value=val;

%%
%{
if scrollSync == 1 & get(hObject, 'Value') <= get(handles.slider1, 'Max')
    %disp('made it here')
    set(handles.slider1, 'Value', get(handles.slider1, 'Value'));
    %slider1_Callback(hObject, eventdata, handles)
end
%}

%%
%gets slider value for later use
sliderValue = 1+get(handles.slider2, 'Value');
imPath = strcat(folderName,'/',nameList(round(sliderValue)));

%sets caption text to show file name
set(handles.text3, 'String', nameList(round(sliderValue)));

%displays image on given axis
axes(handles.axes2);
%imshow(char(nameList(round(sliderValue))));
imshow(char(imPath));

end

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Refresh button for the second image set
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global slider2Attribs

% Refreshes slider
startSlider(handles, handles.slider2, handles.text3, handles.axes2, slider2Attribs);
slider2Attribs.nameList = ans;

end

% --- Select button for the second image set
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global slider2Attribs
global fpath

prevFolderName = slider2Attribs.folderName

% Opens folder selection interface
slider2Attribs.folderName = uigetdir(fpath)

if slider2Attribs.folderName ~= 0
    % Refreshes scrollbar/slider
    startSlider(handles, handles.slider2, handles.text3, handles.axes2, slider2Attribs);
    slider2Attribs.nameList = ans;
else
    % Resets to initial folder if none selected
    slider2Attribs.folderName = prevFolderName
end
end


% --- Checkbox for synchronizing scrolling between the two image sets
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
global scrollSync

% Checks the status of the checkbox and assigns scrollSync variable
% accordingly (if true, scroll synchronization enabled)
if (get(hObject,'Value') == get(hObject,'Max'))
	scrollSync = true
    set(handles.slider2, 'Enable', 'off')
else
	scrollSync = false
    set(handles.slider2, 'Enable', 'on')

end
end
