function varargout = GuiPLSR(varargin)
% GuiPLSR helps you to run PLSR analyses
%
%   varargout = GuiPLSR(varargin)
%
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = a Compendium
%
%
% OUTPUTS:
%
% varargout = an updated compendium with a new arrays for the scores and loadings
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  NewCompendium = GuiPLSR(Compendium)
%
%--------------------------------------------------------------------------
% TODO:
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
 

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiPLSR_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiPLSR_OutputFcn, ...
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


% --- Executes just before GuiPLSR is made visible.
function GuiPLSR_OpeningFcn(hObject, eventdata, handles, varargin)


handles.Project=varargin{1};
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end

set(handles.XCompendium, 'String', {handles.Project.Compendium.Name});
set(handles.XCompendium, 'Value', 1);
set(handles.ChooseXArray,'String',{handles.Project.Compendium(1).data.Name});
set(handles.ChooseXArray,'Value',1);
set(handles.YCompendium, 'String', {handles.Project.Compendium.Name});
set(handles.YCompendium, 'Value', 1);
set(handles.ChooseYArray,'String',{handles.Project.Compendium(1).data.Name});
set(handles.ChooseYArray,'Value',1);
set(handles.ResultsCompendium, 'String', {handles.Project.Compendium.Name});
set(handles.ResultsCompendium, 'Value', 1);

% Cubesin2D={'Cues','Inhibitors','Cues and Inhibitors','Readouts'};
% set(handles.ChooseXMatrix,'String',Cubesin2D);
% set(handles.ChooseXMatrix,'Value',4);
% set(handles.ChooseYMatrix,'String',Cubesin2D);
% set(handles.ChooseYMatrix,'Value',4);

handles.Parameters.PlotWeights=true;
handles.Parameters.PlotFit=false;
handles.Parameters.XScaling = [];
handles.Parameters.YScaling = [];

guidata(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = GuiPLSR_OutputFcn(hObject, eventdata, handles) 

function ChooseXArray_Callback(hObject, eventdata, handles)
set(handles.XScaling, 'Value', get(handles.XScaling, 'Min'));

function ChooseXArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ChooseYArray_Callback(hObject, eventdata, handles)
set(handles.YScaling, 'Value', get(handles.YScaling, 'Min'));


function ChooseYArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function RunPLSR_Callback(hObject, eventdata, handles)
selectedButton = get(handles.ModelType, 'SelectedObject');
modelType = get(selectedButton, 'String');
switch modelType
    case 'PCA'
        runPca(hObject, handles);
    case 'PLSR'
        runPlsr(hObject, handles);
end

function runPlsr(hObject, handles)
XCompendium = handles.Project.Compendium(get(handles.XCompendium,'Value'));
XArray=XCompendium.data(get(handles.ChooseXArray,'Value'));
YCompendium = handles.Project.Compendium(get(handles.YCompendium,'Value'));
YArray=YCompendium.data(get(handles.ChooseYArray,'Value'));
XMatrix=XArray.Value;
YMatrix=YArray.Value;
ndX = ndims(XMatrix);
ndY = ndims(YMatrix);

if isstruct(XMatrix)
    warndlg('The X input must be a data array.')
end

if isstruct(YMatrix)
    warndlg('The X input must be a data array.')
end

if size(XMatrix,1) ~= size(YMatrix,1)
    warndlg('X array and Y array must have the same number of observations in the first dimension.');
    return
end

show = nan;
FacMax = min([size(XMatrix) 5]);
[nGroups,significanceCutoff,seed] = deal([]);
processing = struct('Cent', {zeros(1,ndX), zeros(1,ndY)}, ...
    'Scal', {handles.Parameters.XScaling, handles.Parameters.YScaling});
% Always center across observations
processing(1).Cent(1) = 1;
processing(2).Cent(1) = 1;
Fac = str2double(get(handles.NumComp, 'String'));

set(handles.figure1, 'Pointer', 'watch');
drawnow expose;
try
    if get(handles.AutoComp, 'Value') == get(handles.AutoComp, 'Max')
        % Use C.V. to determine components
        r = npls_cross_validation(XMatrix,YMatrix,show,nGroups,significanceCutoff,seed,processing,FacMax);
    else
        r = npls(XMatrix,YMatrix,Fac,show,processing);
    end
catch
    set(handles.figure1, 'Pointer', 'arrow');
    err = lasterror;
    errordlg(['The following error was encountered while trying to analyze the data:' err.message]);
    return
end
set(handles.figure1, 'Pointer', 'arrow');
drawnow expose;
r.XLabels = XArray.Labels;
r.YLabels = YArray.Labels;
if handles.Parameters.PlotFit
    PlotFitRegression(XArray, YArray, r);
end
if handles.Parameters.PlotWeights
    PlotWeights(XArray, YArray, r)
end

if get(handles.SaveResults, 'Value')
    CubeName=inputdlg('Choose a name for the cube');
    if isempty(CubeName)
        return;
    end
    handles.Project.Compendium(get(handles.ResultsCompendium, 'Value')).data(end+1)...
        = createDataCube(...
       'Name', CubeName{1}, ...
       'Info', 'Results of PLSR',...
       'Code', 'GuiPLSR', ...
       'Value', [], ...
       'PrintWarnings', false);
   handles.Project.Compendium(get(handles.ResultsCompendium, 'Value')).data(end).Value = r;
   handles.Project.Compendium(get(handles.ResultsCompendium, 'Value')).data(end).SourceData{1}=XArray.Name;
   handles.Project.Compendium(get(handles.ResultsCompendium, 'Value')).data(end).SourceData{2}=YArray.Name;
end
guidata(hObject,handles);

function runPca(hObject, handles)
XCompendium = handles.Project.Compendium(get(handles.XCompendium,'Value'));
XArray=XCompendium.data(get(handles.ChooseXArray,'Value'));
XMatrix=XArray.Value;
ndX = ndims(XMatrix);

if isstruct(XMatrix)
    warndlg('The X input must be a data array.')
end

show = nan;
FacMax = min([size(XMatrix) 5]);
[maxR,nGroups] = deal([]);
processing = struct('Cent', {zeros(1,ndX)}, ...
    'Scal', {handles.Parameters.XScaling});
% Always center across observations
processing(1).Cent(1) = 1;
Fac = str2double(get(handles.NumComp, 'String'));

set(handles.figure1, 'Pointer', 'watch');
drawnow expose;
try
    if ~isempty(processing.Scal)
        warndlg('Scaling is not currently implement for PCA.');
    end
    
    options = zeros(1,6);
    options(5) = show;
    if get(handles.AutoComp, 'Value') == get(handles.AutoComp, 'Max')
        % Use C.V. to determine components
        [r.FacOpt,r.R,r.Xfactors,r.it,r.err,r.corcondia]=pfcv(XMatrix,FacMax,maxR,nGroups,options);
    else
        [r.Xfactors,r.it,r.err,r.corcondia,r.PercentExpl]=parafac(XMatrix,Fac,options);
    end
catch
    set(handles.figure1, 'Pointer', 'arrow');
    err = lasterror;
    errordlg(['The following error was encountered while trying to analyze the data:' err.message]);
    return
end
set(handles.figure1, 'Pointer', 'arrow');
drawnow expose;
r.XLabels = XArray.Labels;
if handles.Parameters.PlotFit
    PlotFitRegression(XArray, [], r);
end
if handles.Parameters.PlotWeights
    PlotWeights(XArray, [], r)
end

if get(handles.SaveResults, 'Value')
    CubeName=inputdlg('Choose a name for the cube');
    if isempty(CubeName)
        return;
    end
    handles.Project.Compendium(get(handles.ResultsCompendium, 'Value')).data(end+1)...
        = createDataCube(...
       'Name', CubeName{1}, ...
       'Info', 'Results of PLSR',...
       'Code', 'GuiPLSR', ...
       'Value', [], ...
       'PrintWarnings', false);
   handles.Project.Compendium(get(handles.ResultsCompendium, 'Value')).data(end).Value = r;
   handles.Project.Compendium(get(handles.ResultsCompendium, 'Value')).data(end).SourceData{1}=XArray.Name;
end
guidata(hObject,handles);

function PlotWeights_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.PlotWeights=true;
else
    handles.Parameters.PlotWeights=false;
end
guidata(hObject,handles);


function PlotFit_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.PlotFit=true;
else
    handles.Parameters.PlotFit=false;
end
guidata(hObject,handles);

function ChooseXMatrix_Callback(hObject, eventdata, handles)
set(handles.XScaling, 'Value', get(handles.XScaling, 'Min'));


function ChooseXMatrix_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ChooseYMatrix_Callback(hObject, eventdata, handles)
set(handles.YScaling, 'Value', get(handles.YScaling, 'Min'));


function ChooseYMatrix_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%---Plotting functions------

function PlotFitRegression(XArray, YArray, r)
%   Function to plot the fit of a regression

function PlotWeights(XArray, YArray, r)
GuiPlotWeights(r.Xfactors, r.XLabels, 'X-Factors')
if ~isempty(YArray)
    GuiPlotWeights(r.Yfactors, r.YLabels, 'Y-Factors')
end
1;
                                                                                                                                                                                                                                    


% --- Executes on selection change in XCompendium.
function XCompendium_Callback(hObject, eventdata, handles)
% hObject    handle to XCompendium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns XCompendium contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XCompendium
set(handles.ChooseXArray,'String',{handles.Project.Compendium(get(handles.XCompendium, 'Value')).data.Name});
set(handles.ChooseXArray,'Value',1);


% --- Executes during object creation, after setting all properties.
function XCompendium_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XCompendium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YCompendium.
function YCompendium_Callback(hObject, eventdata, handles)
% hObject    handle to YCompendium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns YCompendium contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YCompendium
set(handles.ChooseYArray,'String',{handles.Project.Compendium(get(handles.YCompendium, 'Value')).data.Name});
set(handles.ChooseYArray,'Value',1);


% --- Executes during object creation, after setting all properties.
function YCompendium_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YCompendium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveResults.
function SaveResults_Callback(hObject, eventdata, handles)
% hObject    handle to SaveResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveResults


% --- Executes on selection change in ResultsCompendium.
function ResultsCompendium_Callback(hObject, eventdata, handles)
% hObject    handle to ResultsCompendium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ResultsCompendium contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ResultsCompendium


% --- Executes during object creation, after setting all properties.
function ResultsCompendium_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ResultsCompendium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.notifier(handles.Project);


% --- Executes when selected object is changed in ModelType.
function ModelType_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ModelType 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
button = get(eventdata.NewValue, 'String');
if strcmpi(button, 'PCA')
    set(get(handles.YPanel, 'Children'), 'Enable', 'off');
    set(handles.YScaling, 'Enable', 'off');
else
    set(get(handles.YPanel, 'Children'), 'Enable', 'on');
    set(handles.YScaling, 'Enable', 'on');
end


% --- Executes on button press in AutoComp.
function AutoComp_Callback(hObject, eventdata, handles)
% hObject    handle to AutoComp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoComp
if get(hObject, 'Value') == get(hObject, 'Max')
    % Automatically determine components; disable editbox
    set(handles.NumComp, 'Enable', 'off');
else
    set(handles.NumComp, 'Enable', 'on');
end


function NumComp_Callback(hObject, eventdata, handles)
% hObject    handle to NumComp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumComp as text
%        str2double(get(hObject,'String')) returns contents of NumComp as a double
val = str2double(get(hObject,'String'));
if isnan(val) || val < 1 || floor(val) ~= val
    set(hObject, 'String', 3);
    warndlg('Invalid value.');
end

% --- Executes during object creation, after setting all properties.
function NumComp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumComp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in XScaling.
function XScaling_Callback(hObject, eventdata, handles)
% hObject    handle to XScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == get(hObject, 'Max')
    % Ask for scaling
    XCompendium = handles.Project.Compendium(get(handles.XCompendium,'Value'));
    XArray=XCompendium.data(get(handles.ChooseXArray,'Value'));
    handles.Parameters.XScaling = getScaling(XArray);
else
    % Reset to no scaling
    handles.Parameters.XScaling = [];
end
guidata(hObject, handles);

% --- Executes on button press in YScaling.
function YScaling_Callback(hObject, eventdata, handles)
% hObject    handle to YScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == get(hObject, 'Max')
    YCompendium = handles.Project.Compendium(get(handles.YCompendium,'Value'));
    YArray=YCompendium.data(get(handles.ChooseYArray,'Value'));
    handles.Parameters.YScaling = getScaling(YArray);
else
    % Reset to no scaling
    handles.Parameters.YScaling = [];
end
guidata(hObject, handles);

function scaling = getScaling(Array)
scaling = [];
try
    dimensionNames = {Array.Labels.Name};
    dimensionNames{1} = [dimensionNames{1} ' [Not recommended]'];
    [selection, ok] = listdlg('ListString', dimensionNames, ...
        'PromptString',     ['Select the dimensions to scale WITHIN to unit variance.' ...
    'Note: The recommended approach is to scale WITHIN the 2nd dimension or later.'], ...
        'InitialValue', 2, ...
        'Name', 'Select scaling',...
        'ListSize', [200 150]);
    if ~ok
        return
    end
    scaling = zeros(1, numel(dimensionNames));
    scaling(selection) = 1;
catch
    warndlg('Unable to set scaling.');
end