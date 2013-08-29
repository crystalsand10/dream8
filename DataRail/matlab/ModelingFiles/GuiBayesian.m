function varargout = GuiBayesian(varargin)
% GUIBAYESIAN M-file for GuiBayesian.fig
%      GUIBAYESIAN, by itself, creates a new GUIBAYESIAN or raises the existing
%      singleton*.
%
%      H = GUIBAYESIAN returns the handle to a new GUIBAYESIAN or the handle to
%      the existing singleton*.
%
%      GUIBAYESIAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIBAYESIAN.M with the given input arguments.
%
%      GUIBAYESIAN('Property','Value',...) creates a new GUIBAYESIAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiBayesian_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiBayesian_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

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
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe    Nickel Dittrich
%    SBPipeline.harvard.edu%

% Edit the above text to modify the response to help GuiBayesian

% Last Modified by GUIDE v2.5 27-May-2009 16:01:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiBayesian_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiBayesian_OutputFcn, ...
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


% --- Executes just before GuiBayesian is made visible.
function GuiBayesian_OpeningFcn(hObject, eventdata, handles, varargin)
%

% Choose default command line output for GuiBayesian
%handles.output = hObject;
if numel(varargin) >= 4
    handles.notifier = varargin{4};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end

if numel(varargin)>=2&& isnumeric(varargin{2})
    handles.ValComp = varargin{2};
else
    handles.ValComp = 1;
end

if numel(varargin)>=3 && isnumeric(varargin{3})
    ValCube = varargin{3};
else
    ValCube = 1;
end

handles.Project = varargin{1};    
handles.Compendium = varargin{1}.Compendium(handles.ValComp);
handles.output=handles.Project;

% Update handles structure
popDC = [];
for i = 1:length(handles.Compendium.data)
    popDC{i} = handles.Compendium.data(i).Name;
end
set(handles.popupDC,'String',popDC);
set(handles.popupDC,'Value',ValCube);
% set recommended values
sizeVec = [size(handles.Compendium.data(1).Value,1) ...
    size(handles.Compendium.data(1).Value,2) ...
    size(handles.Compendium.data(1).Value,3) ...
    size(handles.Compendium.data(1).Value,4) ...
    size(handles.Compendium.data(1).Value,5)];
rs2 = sizeVec(1) * sizeVec(2) * sizeVec(3) * sizeVec(4);
rs1 = sizeVec(5);
if size(handles.Compendium.data(1).Value,6)>1
    sizeVec = [sizeVec size(handles.Compendium.data(1).Value,6)];
    rs2 = rs2*sizeVec(6);
end
handles.rec.noparents =   3;
handles.rec.cutoff    = 0.85;

set(handles.editnoparents,'String',handles.rec.noparents);
set(handles.editpcutoff,'String',handles.rec.cutoff);

guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = GuiBayesian_OutputFcn(hObject, eventdata, handles) 

%varargout{1} = handles.output;


% --- Executes on selection change in popupDC.
function popupDC_Callback(hObject, eventdata, handles)

% set recommended values
choice = get(handles.popupDC,'Value');
sizeVec = [size(handles.Compendium.data(choice).Value,1) ...
    size(handles.Compendium.data(choice).Value,2) ...
    size(handles.Compendium.data(choice).Value,3) ...
    size(handles.Compendium.data(choice).Value,4) ...
    size(handles.Compendium.data(choice).Value,5)];
rs2 = sizeVec(1) * sizeVec(2) * sizeVec(3) * sizeVec(4);
rs1 = sizeVec(5);
if size(handles.Compendium.data(choice).Value,6)>1
    sizeVec = [sizeVec size(handles.Compendium.data(choice).Value,6)];
    rs2 = rs2*sizeVec(6);
end
handles.rec.noparents = 3;
handles.rec.cutoff = 0.85;
set(handles.editnoparents,'String',handles.rec.noparents);
set(handles.editpcutoff,'String',handles.rec.cutoff);


% --- Executes during object creation, after setting all properties.
function popupDC_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editnoparents_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editnoparents_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editnotrials_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editnotrials_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editnosamples_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editnosamples_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editburnin_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editburnin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editnodecomp_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editnodecomp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editpcutoff_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editpcutoff_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)

close


% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
parameters.Value.np = get(handles.editnoparents,'String');
parameters.Value.pc = get(handles.editpcutoff,'String');
parameters.Value.DC = get(handles.popupDC,'Value');
%DataCube = handles.Compendium.data(get(handles.popupDC,'Value')).Value;
Compendium = handles.Compendium;
%handles.notifier(parameters);
dataRailPaths = startDataRail;
dataRailBase = dataRailPaths{1};
%cd(fullfile(dataRailBase, 'BayesianInference'));
BayesNetInf = BayesianBNSL(Compendium,parameters.Value);
%% Save Weights in a new Array
SaveResults=questdlg('Save results in a data array?', 'save results?', 'Yes','No', 'Yes');
  
if strcmp(SaveResults,'Yes')
CubeName=inputdlg('Choose a name for the cube');

    handles.Compendium.data(end+1)= createDataCube(...
       'Name', CubeName{1}, ...
       'Info', 'results of BayesianInference',...
       'Code', 'GuiBayesian',...
       'Parameters',parameters.Value,...
       'Value', BayesNetInf);
end
guidata(hObject,handles);
handles.Project.Compendium(handles.ValComp)=handles.Compendium;
handles.notifier(handles.Project);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.notifier(handles.Project);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.notifier(handles.Project);
delete(hObject);
