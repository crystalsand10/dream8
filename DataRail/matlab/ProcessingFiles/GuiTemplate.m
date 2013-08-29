function varargout = GuiTemplate(varargin)
% Template for GUIs that exchange data b/w GUIs w/o using uiwait
%
% The "Parent" GUI must:
% 1) Create a GuiNotifier object, passing the figure handle and a
%    notifyFunc (function) or HG handle/property pairs to set
% 2) Pass the GuiNotifier object as a 'Notifier' parameter to the Child GUI
%
% The Child GUI must:
% 1) Store the 'Notifier' parameter
% 2) Call the 'Notifier' parameter in the DeleteFcn callback, passing the
%    desired output
%
%
% GUITEMPLATE M-file for GuiTemplate.fig
%      GUITEMPLATE, by itself, creates a new GUITEMPLATE or raises the existing
%      singleton*.
%
%      H = GUITEMPLATE returns the handle to a new GUITEMPLATE or the handle to
%      the existing singleton*.
%
%      GUITEMPLATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUITEMPLATE.M with the given input arguments.
%
%      GUITEMPLATE('Property','Value',...) creates a new GUITEMPLATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiTemplate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiTemplate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuiTemplate

% Last Modified by GUIDE v2.5 03-Mar-2008 09:57:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiTemplate_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiTemplate_OutputFcn, ...
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


% --- Executes just before GuiTemplate is made visible.
function GuiTemplate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiTemplate (see VARARGIN)

% Update handles structure
try
    handles.Notifier = varargin{1}.Notifier;
catch
    handles.Notifier = [];
end
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes GuiTemplate wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuiTemplate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% GuiNotifier appraoch
notifier = GuiNotifier('figure', handles.figure1, ...
    'setOnNotify', {handles.edit1, 'String'});
GuiTemplate(struct('Notifier', notifier));
% % "Manual" approach
% set(handles.figure1, 'Visible', 'off');
% receiver = @(output) update(hObject, eventdata, handles, output);
% params = struct('Notifier', receiver);
% GuiTemplate(params);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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

function handles = update(hObject, eventdata, handles, output)
set(handles.figure1, 'Visible', 'on');
if exist('output', 'var')
    set(handles.edit1, 'String', output);
else
    output = get(handles.edit1, 'String');
end
handles.output = output;
guidata(hObject, handles);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update(hObject, eventdata, handles);
try
    handles.Notifier(handles.output);
catch
end
