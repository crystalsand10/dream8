function varargout = GuiJoinCubesPars(varargin)
% GUIJOINCUBESPARS M-file for GuiJoinCubesPars.fig
%      GUIJOINCUBESPARS, by itself, creates a new GUIJOINCUBESPARS or raises the existing
%      singleton*.
%
%      H = GUIJOINCUBESPARS returns the handle to a new GUIJOINCUBESPARS or the handle to
%      the existing singleton*.
%
%      GUIJOINCUBESPARS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIJOINCUBESPARS.M with the given input arguments.
%
%      GUIJOINCUBESPARS('Property','Value',...) creates a new GUIJOINCUBESPARS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiJoinCubesPars_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiJoinCubesPars_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuiJoinCubesPars

% Last Modified by GUIDE v2.5 30-May-2009 16:16:02

set(0,'defaultuicontrolfontname','Sans Serif');
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiJoinCubesPars_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiJoinCubesPars_OutputFcn, ...
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


% --- Executes just before GuiJoinCubesPars is made visible.
function GuiJoinCubesPars_OpeningFcn(hObject, eventdata, handles, varargin)
set(0,'defaultuicontrolfontsize',11);
handles.Parameters = struct('data',[],'Concatenate',true);
handles.Compendium = varargin{1};
handles.Source1 = varargin{2};
if numel(varargin) >= 3
    handles.notifier = varargin{3};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
handles.ArrayNames = {handles.Compendium.data(...
    [1:handles.Source1-1, handles.Source1+1:numel(handles.Compendium.data)]).Name};
set(handles.ArrayListbox, 'String', handles.ArrayNames, 'Value', 1);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GuiJoinCubesPars_OutputFcn(hObject, eventdata, handles) 

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on selection change in ArrayListbox.
function ArrayListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ArrayListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ArrayListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ArrayListbox


% --- Executes during object creation, after setting all properties.
function ArrayListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ArrayListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ConcatenateCheckbox.
function ConcatenateCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to ConcatenateCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ConcatenateCheckbox


% --- Executes on button press in OkayButton.
function OkayButton_Callback(hObject, eventdata, handles)
% hObject    handle to OkayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
thisArray = get(handles.ArrayListbox, 'Value');
thisArrayName = handles.ArrayNames{thisArray};
thisArrayIndex = strmatch(thisArrayName, {handles.Compendium.data.Name}, 'exact');
concatenate = logical( get(handles.ConcatenateCheckbox, 'Value') );
parameters = struct('data', handles.Compendium.data(thisArrayIndex), ...
    'Concatenate', concatenate);
handles.notifier(parameters);
delete(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(handles.figure1);


% --- Executes on button press in QuestConcat.
function QuestConcat_Callback(hObject, eventdata, handles)
helpdlg(['Defaultwise data cubes are concatenated across the replicate dimension. If you do not choose this option,'...
 'data in the second cube is added as the next available replicate.'])
% hObject    handle to QuestConcat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


