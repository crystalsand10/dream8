function varargout = GuiAverageReplicates(varargin)
% GUIAVERAGEREPLICATES M-file for GuiAverageReplicates.fig
%      GUIAVERAGEREPLICATES, by itself, creates a new GUIAVERAGEREPLICATES or raises the existing
%      singleton*.
%
%      H = GUIAVERAGEREPLICATES returns the handle to a new GUIAVERAGEREPLICATES or the handle to
%      the existing singleton*.
%
%      GUIAVERAGEREPLICATES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIAVERAGEREPLICATES.M with the given input arguments.
%
%      GUIAVERAGEREPLICATES('Property','Value',...) creates a new GUIAVERAGEREPLICATES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiAverageReplicates_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiAverageReplicates_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuiAverageReplicates

% Last Modified by GUIDE v2.5 15-Jul-2008 17:13:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiAverageReplicates_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiAverageReplicates_OutputFcn, ...
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


% --- Executes just before GuiAverageReplicates is made visible.
function GuiAverageReplicates_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiAverageReplicates (see VARARGIN)

% Choose default command line output for GuiAverageReplicates
handles.output = hObject;
handles.Labels = varargin{1};
dimensionNames = {handles.Labels.Name};
initialReplicatesDim = strmatch('replicate', lower(dimensionNames));
switch numel(initialReplicatesDim)
    case 0
        initialReplicatesDim = 1;
    case 1
    otherwise
        initialReplicatesDim = initialReplicatesDim(1);
end
set(handles.ReplicatesDim, 'String', dimensionNames, 'Value', initialReplicatesDim);
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
guidata(hObject, handles);

% UIWAIT makes GuiAverageReplicates wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuiAverageReplicates_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in CanonicalForm.
function CanonicalForm_Callback(hObject, eventdata, handles)
% hObject    handle to CanonicalForm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CanonicalForm


% --- Executes on selection change in ReplicatesDim.
function ReplicatesDim_Callback(hObject, eventdata, handles)
% hObject    handle to ReplicatesDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ReplicatesDim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ReplicatesDim


% --- Executes during object creation, after setting all properties.
function ReplicatesDim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReplicatesDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters = struct('Labels', handles.Labels, ...
    'ReplicatesDim', get(handles.ReplicatesDim, 'Value'), ...
    'CanonicalForm', get(handles.CanonicalForm, 'Value'));
handles.notifier(parameters);
delete(hObject);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

