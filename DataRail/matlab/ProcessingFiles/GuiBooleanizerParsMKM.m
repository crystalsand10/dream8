function varargout = GuiBooleanizerParsMKM(varargin)
% GuiBooleanizerParsMKM loads the parameters for the function Booleanizer to discretize the data
%
% varargout = GuiBooleanizerParsMKM(varargin)
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
% ParametersBool=GuiBooleanizerParsMKM(Data.data(1));
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
                   'gui_OpeningFcn', @GuiBooleanizerParsMKM_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiBooleanizerParsMKM_OutputFcn, ...
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

%% --- Executes just before GuiBooleanizerParsMKM is made visible.
function GuiBooleanizerParsMKM_OpeningFcn(hObject, eventdata, handles, varargin)
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
    'DimWithControl', 2, 'EC50', 0.5, 'ChangeThresh', 0, ...
    'HillCoeff', 2, 'MinSignal', 0, 'MaxSignal', inf, ...
    'EC50Noise', 0.1);
handles.uiwait = false;
guidata(hObject, handles);


%% --- Outputs from this function are returned to the command line.
function varargout = GuiBooleanizerParsMKM_OutputFcn(hObject, eventdata, handles) 
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
function EC50Data_Callback(hObject, eventdata, handles)
handles.Parameters.EC50=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function EC50Data_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EC50Noise_Callback(hObject, eventdata, handles)
handles.Parameters.EC50Noise=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function EC50Noise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DimControl_Callback(hObject, eventdata, handles)
handles.Parameters.DimWithControl=str2num(get(hObject, 'String'));
guidata(hObject,handles);

function DimControl_CreateFcn(hObject, eventdata, handles)
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

%% Help Dialogs
function HelpEC50Data_Callback(hObject, eventdata, handles)
helpdlg(sprintf('EC_50 of data transformation'));

function HelpEC50NOise_Callback(hObject, eventdata, handles)
helpdlg(sprintf('EC50 of noise penalty transformation'));

function HelpDimWithControl_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Condition that contains the controls.  If it is time (time zero), this is 2.  If it is Stimuli (a no stimuli control), this is probably 3.  The control must be the first index of the dimension (to be sure, plot the data.  Time zero should be plotted first in each time series and the no stimuli control should be the first major condition.'));

%%
function Update_Callback(hObject, eventdata, handles)
if handles.uiwait
    handles.uiwait = false;
    guidata(hObject, handles);
    uiresume;
else
    close(handles.figure1);
end



% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.notifier(handles.Parameters);
delete(hObject);



function HillCoeff_Callback(hObject, eventdata, handles)
handles.Parameters.HillCoeff=str2num(get(hObject, 'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function HillCoeff_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HelpMinSignal.
function HelpMinSignal_Callback(hObject, eventdata, handles)
helpdlg('Minimum trusted Signal.  Values below this are replaced with NaNs');



function MaxSignal_Callback(hObject, eventdata, handles)
handles.Parameters.MaxSignal=str2num(get(hObject, 'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MaxSignal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HelpMaxSignal.
function HelpMaxSignal_Callback(hObject, eventdata, handles)
helpdlg('Maximum trusted Signal.  Values above this are replaced with NaNs');

function ChangeThreshold_Callback(hObject, eventdata, handles)
handles.Parameters.ChangeThresh=str2num(get(hObject, 'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ChangeThreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HelpChangeThresh.
function HelpChangeThresh_Callback(hObject, eventdata, handles)
helpdlg('Threshold of the degree of change necessary to be considerred signficant.  If you are going to threshold the values later, this should probably be zero.  In any case, it should not be that high unless the experiment was an absolute mess.');
