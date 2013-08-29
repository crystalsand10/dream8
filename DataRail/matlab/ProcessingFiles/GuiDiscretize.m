function varargout = GuiDiscretize(varargin)
% GUIDISCRETIZE M-file for GuiDiscretize.fig
%      GUIDISCRETIZE, by itself, creates a new GUIDISCRETIZE or raises the existing
%      singleton*.
%
%      H = GUIDISCRETIZE returns the handle to a new GUIDISCRETIZE or the handle to
%      the existing singleton*.
%
%      GUIDISCRETIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDISCRETIZE.M with the given input arguments.
%
%      GUIDISCRETIZE('Property','Value',...) creates a new GUIDISCRETIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiDiscretize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiDiscretize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuiDiscretize

% Last Modified by GUIDE v2.5 17-Dec-2009 18:57:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiDiscretize_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiDiscretize_OutputFcn, ...
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


% --- Executes just before GuiDiscretize is made visible.
function GuiDiscretize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiDiscretize (see VARARGIN)

% Choose default command line output for GuiDiscretize
handles.output = hObject;
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
handles.SourceData = varargin{1};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GuiDiscretize wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuiDiscretize_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbcancel.
function pbcancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbcancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close


% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedButton = get(handles.uidisc,'SelectedObject');
DiscType = get(selectedButton,'Tag');
parameters = struct('Type',[],'Value',[]);
switch DiscType
    case 'rbquantdet'
        parameters.Type = 1;
    case 'rbintdet'
        parameters.Type = 2;
    case 'rbquantstoch'
        parameters.Type = 3;
    case 'rbintstoch'
        parameters.Type = 4;
    case 'rbBoolean'
        parameters.Type = 5;
        parameters.Value.SigniPeak = str2double(get(handles.SigniPeak,'String'));
        parameters.Value.SigniDec = str2double(get(handles.SigniDec,'String'));
        parameters.Value.ThreshMax = str2double(get(handles.ThreshMax,'String'));
        parameters.Value.MinSignal = str2double(get(handles.MinSignal,'String'));
        parameters.Value.NegatOnes = str2double(get(handles.NegatOnes,'String'));
        parameters.Value.Fuzzify = false; % for discretization only 0/1 values
   case 'rbkmeans'
        parameters.Type = 6;        
end
parameters.Value.Int = str2double(get(handles.EditInt,'String'));
parameters.Value.DiscLevel = str2double(get(handles.EditDiscLev,'String'));
if (get(handles.TMIcheckbox,'Value')) == (get(handles.TMIcheckbox,'Max'))
    parameters.Value.TMI = 1;
else
    parameters.Value.TMI = 0;
end
    
handles.notifier(parameters);
delete(handles.figure1);


% --- Executes on button press in rbquantdet.
function rbquantdet_Callback(hObject, eventdata, handles)
% hObject    handle to rbquantdet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text2,'Visible','On')
set(handles.EditDiscLev,'Visible','On')
set(handles.TMIcheckbox,'Visible','On')
set(handles.textD,'Visible','On')
set(handles.EditInt,'Visible','On')
set(handles.text3,'Visible','Off')
set(handles.text4,'Visible','Off')
set(handles.text5,'Visible','Off')
set(handles.text6,'Visible','Off')
set(handles.text7,'Visible','Off')
set(handles.text8,'Visible','Off')
set(handles.SigniPeak,'Visible','Off')
set(handles.SigniDec,'Visible','Off')
set(handles.ThreshMax,'Visible','Off')
set(handles.MinSignal,'Visible','Off')
set(handles.NegatOnes,'Visible','Off')
set(handles.HelpSigniPeak,'Visible','Off')
set(handles.HelpSigniDec,'Visible','Off')
set(handles.HelpThreshMax,'Visible','Off')
set(handles.HelpMinSignal,'Visible','Off')
set(handles.HelpNegatOnes,'Visible','Off')
% Hint: get(hObject,'Value') returns toggle state of rbquantdet


% --- Executes on button press in rbintdet.
function rbintdet_Callback(hObject, eventdata, handles)
% hObject    handle to rbintdet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text2,'Visible','On')
set(handles.EditDiscLev,'Visible','On')
set(handles.TMIcheckbox,'Visible','On')
set(handles.textD,'Visible','On')
set(handles.EditInt,'Visible','On')
set(handles.text3,'Visible','Off')
set(handles.text4,'Visible','Off')
set(handles.text5,'Visible','Off')
set(handles.text6,'Visible','Off')
set(handles.text7,'Visible','Off')
set(handles.text8,'Visible','Off')
set(handles.SigniPeak,'Visible','Off')
set(handles.SigniDec,'Visible','Off')
set(handles.ThreshMax,'Visible','Off')
set(handles.MinSignal,'Visible','Off')
set(handles.NegatOnes,'Visible','Off')
set(handles.HelpSigniPeak,'Visible','Off')
set(handles.HelpSigniDec,'Visible','Off')
set(handles.HelpThreshMax,'Visible','Off')
set(handles.HelpMinSignal,'Visible','Off')
set(handles.HelpNegatOnes,'Visible','Off')
% Hint: get(hObject,'Value') returns toggle state of rbintdet


% --- Executes during object creation, after setting all properties.
function EditInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function EditDiscLev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDiscLev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TMIcheckbox.
function TMIcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to TMIcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.EditInt, 'Enable','on');
% Hint: get(hObject,'Value') returns toggle state of TMIcheckbox


% --- Executes on button press in rbBoolean.
function rbBoolean_Callback(hObject, eventdata, handles)
% hObject    handle to rbBoolean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text2,'Visible','Off')
set(handles.EditDiscLev,'Visible','Off')
set(handles.TMIcheckbox,'Visible','Off')
set(handles.textD,'Visible','Off')
set(handles.EditInt,'Visible','Off')
set(handles.text3,'Visible','On')
set(handles.text4,'Visible','On')
set(handles.text5,'Visible','On')
set(handles.text6,'Visible','On')
set(handles.text7,'Visible','On')
set(handles.text8,'Visible','On')
set(handles.SigniPeak,'Visible','On')
set(handles.SigniDec,'Visible','On')
set(handles.ThreshMax,'Visible','On')
set(handles.MinSignal,'Visible','On')
set(handles.NegatOnes,'Visible','On')
set(handles.HelpSigniPeak,'Visible','On')
set(handles.HelpSigniDec,'Visible','On')
set(handles.HelpThreshMax,'Visible','On')
set(handles.HelpMinSignal,'Visible','On')
set(handles.HelpNegatOnes,'Visible','On')
% Hint: get(hObject,'Value') returns toggle state of rbBoolean


% --- Executes on button press in rbquantstoch.
function rbquantstoch_Callback(hObject, eventdata, handles)
% hObject    handle to rbquantstoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text2,'Visible','On')
set(handles.EditDiscLev,'Visible','On')
set(handles.TMIcheckbox,'Visible','On')
set(handles.textD,'Visible','On')
set(handles.EditInt,'Visible','On')
set(handles.text3,'Visible','Off')
set(handles.text4,'Visible','Off')
set(handles.text5,'Visible','Off')
set(handles.text6,'Visible','Off')
set(handles.text7,'Visible','Off')
set(handles.text8,'Visible','Off')
set(handles.SigniPeak,'Visible','Off')
set(handles.SigniDec,'Visible','Off')
set(handles.ThreshMax,'Visible','Off')
set(handles.MinSignal,'Visible','Off')
set(handles.NegatOnes,'Visible','Off')
set(handles.HelpSigniPeak,'Visible','Off')
set(handles.HelpSigniDec,'Visible','Off')
set(handles.HelpThreshMax,'Visible','Off')
set(handles.HelpMinSignal,'Visible','Off')
set(handles.HelpNegatOnes,'Visible','Off')
% Hint: get(hObject,'Value') returns toggle state of rbquantstoch


% --- Executes on button press in rbintstoch.
function rbintstoch_Callback(hObject, eventdata, handles)
% hObject    handle to rbintstoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text2,'Visible','On')
set(handles.EditDiscLev,'Visible','On')
set(handles.TMIcheckbox,'Visible','On')
set(handles.textD,'Visible','On')
set(handles.EditInt,'Visible','On')
set(handles.text3,'Visible','Off')
set(handles.text4,'Visible','Off')
set(handles.text5,'Visible','Off')
set(handles.text6,'Visible','Off')
set(handles.text7,'Visible','Off')
set(handles.text8,'Visible','Off')
set(handles.SigniPeak,'Visible','Off')
set(handles.SigniDec,'Visible','Off')
set(handles.ThreshMax,'Visible','Off')
set(handles.MinSignal,'Visible','Off')
set(handles.NegatOnes,'Visible','Off')
set(handles.HelpSigniPeak,'Visible','Off')
set(handles.HelpSigniDec,'Visible','Off')
set(handles.HelpThreshMax,'Visible','Off')
set(handles.HelpMinSignal,'Visible','Off')
set(handles.HelpNegatOnes,'Visible','Off')
% Hint: get(hObject,'Value') returns toggle state of rbintstoch



%% ----Parameters
function SigniPeak_Callback(hObject, eventdata, handles)
handles.parameters.Value.SigniPeak=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function SigniPeak_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SigniDec_Callback(hObject, eventdata, handles)
handles.parameters.Value.SigniDec=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function SigniDec_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ThreshMax_Callback(hObject, eventdata, handles)
handles.parameters.Value.ThreshMax=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function ThreshMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MinSignal_Callback(hObject, eventdata, handles)
handles.parameters.Value.MinSignal=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function MinSignal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NegatOnes_Callback(hObject, eventdata, handles)
Neg=get(hObject, 'String');
try    
 Neg2=eval(Neg);
 if ~iscell(Neg2)
     error('Problems');
 end 
handles.Parameters.NegatOnes=Neg2;
catch
    warndlg('This parameter must be a cell string');
end
guidata(hObject,handles);

function NegatOnes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LabelsSignals_Callback(hObject, eventdata, handles)
handles.parameters.Value.LabelsSignals=get(hObject, 'String');
guidata(hObject,handles);

function LabelsSignals_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Help Dialogs
function HelpSigniPeak_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Condition for the signal at t=1 (early events) to be considered significantly higher than at t=0: \n Signal(t=0)< Signal(t=1) multiplied by this factor'));

function HelpSigniDec_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Condition for the signal at t=2 to be considered significantly lowever than at t=1: \n Signal(t=2)< Signal(t=1) multiplied by this factor'));

function HelpThreshMax_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Condition for the signal at t=1 to be considered significantly higher than at t=1: \n Signal(t=1)> max(Signal(t=1)) multiplied by this factor'));

function HelpMinSignal_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Condition for the signal at t=1 to be considered significantly higher than at t=1: \n Signal(t=1)> this factor(=Experimental noise)'));

function HelpNegatOnes_Callback(hObject, eventdata, handles)
helpdlg(' In some cases, the level of an state is 1 at t=0 and may change to 0 at different times. Type in here the states that have this property, if any');

function HelpLabelsSignals_Callback(hObject, eventdata, handles)
helpdlg('Labels to identify the states that ar 1 at t=0');

%%
function Update_Callback(hObject, eventdata, handles)
if handles.uiwait
    handles.uiwait = false;
    guidata(hObject, handles);
    uiresume;
else
    close(handles.figure1);
end


function FuzzifyData_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.Fuzzify=true;
else
    handles.Parameters.Fuzzify=false;
end
guidata(hObject,handles);


% --- Executes on button press in HelpQantDet.
function HelpQantDet_Callback(hObject, eventdata, handles)
% hObject    handle to HelpQantDet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('An equal number of observations is placed in each of the Discretization Levels. \n Each observation is assigned to a single Discretization Level.'));


% --- Executes on button press in HelpQuantStoch.
function HelpQuantStoch_Callback(hObject, eventdata, handles)
% hObject    handle to HelpQuantStoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('An equal number of observations is placed in each of the Discretization Levels. \n Each observation is spread stochasticaly over each of the possible Discretization Levels.'));


% --- Executes on button press in HelpIntDet.
function HelpIntDet_Callback(hObject, eventdata, handles)
% hObject    handle to HelpIntDet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('The Observation space is devided into equally-sized Discretization Levels. \n Each observation is assigned to a single Discretization Level.'));


% --- Executes on button press in HelpIntStoch.
function HelpIntStoch_Callback(hObject, eventdata, handles)
% hObject    handle to HelpIntStoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('The Observation space is devided into equally-sized Discretization Levels. \n Each observation is spread stochasticaly over each of the possible Discretization Levels.'));


% --- Executes on button press in HelpBoolean.
function HelpBoolean_Callback(hObject, eventdata, handles)
% hObject    handle to HelpBoolean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Discretize Dataset applying thresholds defined by user as explain the DataRail publication Saez-Rodriguez et al. 2008 Bioinformatics.  \n See Command Window for more info.'));
help Booleanizer



function EditDiscLev_Callback(hObject, eventdata, handles)
% hObject    handle to EditDiscLev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDiscLev as text
%        str2double(get(hObject,'String')) returns contents of EditDiscLev as a double



function EditInt_Callback(hObject, eventdata, handles)
% hObject    handle to EditInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditInt as text
%        str2double(get(hObject,'String')) returns contents of EditInt as a double


% --- Executes on button press in Helpkmeans.
function Helpkmeans_Callback(hObject, eventdata, handles)
helpdlg(sprintf('The Observation space is devided into levels based on a kmeans algorithm.'));


% --- Executes on button press in rbkmeans.
function rbkmeans_Callback(hObject, eventdata, handles)
set(handles.text2,'Visible','On')
set(handles.EditDiscLev,'Visible','On')
set(handles.TMIcheckbox,'Visible','Off')
set(handles.textD,'Visible','Off')
set(handles.EditInt,'Visible','Off')
set(handles.text3,'Visible','Off')
set(handles.text4,'Visible','Off')
set(handles.text5,'Visible','Off')
set(handles.text6,'Visible','Off')
set(handles.text7,'Visible','Off')
set(handles.text8,'Visible','Off')
set(handles.SigniPeak,'Visible','Off')
set(handles.SigniDec,'Visible','Off')
set(handles.ThreshMax,'Visible','Off')
set(handles.MinSignal,'Visible','Off')
set(handles.NegatOnes,'Visible','Off')
set(handles.HelpSigniPeak,'Visible','Off')
set(handles.HelpSigniDec,'Visible','Off')
set(handles.HelpThreshMax,'Visible','Off')
set(handles.HelpMinSignal,'Visible','Off')
set(handles.HelpNegatOnes,'Visible','Off')
