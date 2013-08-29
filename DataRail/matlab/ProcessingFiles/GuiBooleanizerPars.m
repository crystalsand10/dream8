function varargout = GuiBooleanizerPars(varargin)
% GuiBooleanizerPars loads the parameters for the function Booleanizer to discretize the data
%
% varargout = GuiBooleanizerPars(varargin)
%  
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = a Cube Structure (Values + Labels)
%
%
% OUTPUTS:
%
% varargout = the structure of parameters for Booleanizer
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% ParametersBool=GuiBooleanizerPars(Data.data(1));
%
%--------------------------------------------------------------------------
% TODO:
%
%   
%

%--------------------------------------------------------------------------
% Copyright 2007 President and Fellow of Harvard College
%
%
%  This file is part of SBPipeline.
%
%    SBPipeline is free software; you can redistribute it and/or modify
%    it under the terms of the GNU Lesser General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or
%    (at your option) any later version.
%
%    SBPipeline is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Lesser General Public License for more details.
% 
%    You should have received a copy of the GNU Lesser General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe
%    SBPipeline.harvard.edu%

set(0,'defaultuicontrolfontname','Sans Serif');
%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiBooleanizerPars_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiBooleanizerPars_OutputFcn, ...
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

%% --- Executes just before GuiBooleanizerPars is made visible.
function GuiBooleanizerPars_OpeningFcn(hObject, eventdata, handles, varargin)
try
    varargin{1}.Labels;
    if numel(varargin) >= 2
        handles.notifier = varargin{2};
    else
        % Dummy notifier
        handles.notifier = @(x)[];
    end
catch
    warndlg('Please give a proper Project Name');
    return
end
%disp(' ')
%disp('** This function assumes a canonical form of the data cube')
%disp(' ')
handles.Parameters=struct(...
    'SigniPeak', 0.5, 'SigniDec', 0.5, 'ThreshMax', 0.15, ...
    'MinSignal', 0, 'NegatOnes', {{'',''}}, ...
    'Fuzzify',true,...
    'LabelsSignals', {varargin{1}.Labels(5).Value});
handles.uiwait = false;
guidata(hObject, handles);


%% --- Outputs from this function are returned to the command line.
function varargout = GuiBooleanizerPars_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargout > 0
    handles.uiwait = true;
    guidata(hObject, handles);
    uiwait;
    guihandles;
    handles = guidata(hObject);
    varargout{1} = handles.Parameters;
    delete(hObject);
end


%% ----Parameters
function SigniPeak_Callback(hObject, eventdata, handles)
handles.Parameters.SigniPeak=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function SigniPeak_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SigniDec_Callback(hObject, eventdata, handles)
handles.Parameters.SigniDec=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function SigniDec_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ThreshMax_Callback(hObject, eventdata, handles)
handles.Parameters.ThreshMax=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function ThreshMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MinSignal_Callback(hObject, eventdata, handles)
handles.Parameters.MinSignal=str2num(get(hObject, 'String'));
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
handles.Parameters.LabelsSignals=get(hObject, 'String');
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
helpdlg('These states are 1 at t=0');

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


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.notifier(handles.Parameters);
delete(hObject);



function HillCoeff_Callback(hObject, eventdata, handles)
handles.Parameters.hillcoeff=str2num(get(hObject, 'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function HillCoeff_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HelpHillCoeff.
function HelpHillCoeff_Callback(hObject, eventdata, handles)
helpdlg('Hill coefficient of the data normalization function');