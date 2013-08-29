function varargout = GuiBetweenThresh(varargin)
% GuiBetweenThresh loads the parameters for the function BetweenThreshold
%
% varargout = GuiBetweenThresh(varargin)
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
% ParametersBool=GuiBetweenThresh(Data.data(1));
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
%    SBPipeline.harvard.edu
%    Contributed by Melody Morris

set(0,'defaultuicontrolfontname','Sans Serif');
%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiBetweenThresh_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiBetweenThresh_OutputFcn, ...
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

%% --- Executes just before GuiBetweenThresh is made visible.
function GuiBetweenThresh_OpeningFcn(hObject, eventdata, handles, varargin)
handles.notifier = @(x)[];
handles.Parameters=struct('LowerThresh', 0,'UpperThresh', 0, 'LowReplaceVal', 0, 'UpReplaceVal', 0);
handles.uiwait = false;
guidata(hObject, handles);


%% --- Outputs from this function are returned to the command line.
function varargout = GuiBetweenThresh_OutputFcn(hObject, eventdata, handles) 
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
function LowerThresh_Callback(hObject, eventdata, handles)
handles.Parameters.LowerThresh=str2double(get(hObject, 'String'));
guidata(hObject,handles);

function LowerThresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% Help Dialogs
function HelpLowerThresh_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Values below this value will be replaced with the replacement Value.  If only and upper bound is desired, set this to negative infinity (-inf)'));


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



function LowerReplaceValue_Callback(hObject, eventdata, handles)
handles.Parameters.LowReplaceVal=str2num(get(hObject, 'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function LowerReplaceValue_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in HelpLowReplace.
function HelpLowReplace_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Value with which values below the lower threshold are replaced'));



function UpperThresh_Callback(hObject, eventdata, handles)
handles.Parameters.UpperThresh=str2double(get(hObject, 'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function UpperThresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HelpUpperThresh.
function HelpUpperThresh_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Values above this value will be replaced with the replacement Value.  If only and lower bound is desired, set this to infinity (inf)'));


% --- Executes on button press in HelpUpReplace.
function HelpUpReplace_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Value with which values above the upper threshold are replaced'));



function UpperReplaceValue_Callback(hObject, eventdata, handles)
handles.Parameters.UpReplaceVal=str2num(get(hObject, 'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function UpperReplaceValue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
