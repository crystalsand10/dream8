function varargout = GuiCollapseDataCube(varargin)
% GuiCollapseDataCube sets parameters for collapseDataCube
%
%  parameters = GuiMidasImporter(DataCube)
%  
%
%--------------------------------------------------------------------------
% INPUTS:
%
% DataCube = a cube structure
%
%
% OUTPUTS:
%
% parameters = structure of parameters (see collapseDataCube)
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  params = GuiCollapseDataCube(Project.Compendium(1).data(1))
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


%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiCollapseDataCube_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiCollapseDataCube_OutputFcn, ...
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


%% --- Executes just before GuiCollapseDataCube is made visible.
function GuiCollapseDataCube_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for GuiCollapseDataCube
try
    handles.Labels=varargin{1}.Labels;
    if numel(varargin) >= 2
        handles.notifier = varargin{2};
    else
        % Dummy notifier
        handles.notifier = @(x)[];
    end
    guidata(hObject, handles);
catch
    errordlg('The first argument to GuiCreateSubCube must be a valid DataCube structure.');
    delete(hObject);
    return
end
handles.Parameters = struct(...
    'Dims', {{}},...
    'NewDim', [],...
    'Labels', handles.Labels,...
    'NewDimName', {{}}, ...
    ...%'NewDimFormatter', @defaultFormatter,...
    'RemoveNaNs', logical(get(handles.RemoveNaNs, 'Value')));
guidata(hObject, handles);
update(hObject, handles);

%% --- Outputs from this function are returned to the command line.
function varargout = GuiCollapseDataCube_OutputFcn(hObject, eventdata, handles) 

% --- Executes on button press in go.
function Go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.notifier(handles.Parameters);
delete(hObject);

% --- Executes on selection change in ChooseDim.
function ChooseDim_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ChooseDim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ChooseDim
update(hObject, handles);

% --- Executes on button press in AddDim.
function AddDim_Callback(hObject, eventdata, handles)
% hObject    handle to AddDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nl = sprintf('\n');
prompt={['Enter the index of the new collapsed dimension:' nl],...
        ['Enter the name of the new collapsed dimension:' nl]};
name='Input for new collapsed dimension';
numlines=2;
nextDim = 1;
while ismember(nextDim, handles.Parameters.NewDim)
    nextDim = nextDim + 1;
end
nextDim = sprintf('%d', nextDim);
defaultanswer={nextDim, ['CollapsedDimension' nextDim]};
options.Resize='on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if numel(answer) ~= 2
    warndlg('New dimension was not created.');
    return
end
dimNum = sscanf(answer{1}, '%d');
if isempty(dimNum) || dimNum < 1
    warndlg('New dimension was not created.');
    return
end
handles.Parameters.Dims{end+1} = [];
handles.Parameters.NewDim(end+1) = dimNum;
handles.Parameters.NewDimName{end+1} = answer{2};
guidata(hObject, handles);
dimName = sprintf('%d: %s', dimNum, answer{2});
allDims = get(handles.ChooseDim, 'String');
if isempty(allDims)
    allDims = {dimName};
else
    allDims{end+1} = dimName;
end
set(handles.ChooseDim, 'String', allDims, 'Value', numel(allDims));
update(hObject, handles);


% --- Executes on button press in DeleteDim.
function DeleteDim_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allDims = get(handles.ChooseDim, 'String');
if isempty(allDims)
    return
end
value = get(handles.ChooseDim, 'Value');
allDims(value) = [];
handles.Parameters.Dims(value) = [];
handles.Parameters.NewDim(value) = [];
handles.Parameters.NewDimName(value) = [];
guidata(hObject, handles);
if isempty(allDims)
    allDims = char(zeros(1,0));
    value = 1;
elseif value > numel(allDims)
    value = numel(allDims);
end
set(handles.ChooseDim, 'String', allDims, 'Value', value);
update(hObject, handles);

% --- Executes on button press in RemoveNaNsHelp.
function RemoveNaNsHelp_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveNaNsHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg('Check "Remove NaNs" to delete slices that are all NaNs.');


% --- Executes on button press in RemoveNaNs.
function RemoveNaNs_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveNaNs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RemoveNaNs
handles.Parameters.RemoveNaNs = logical(get(hObject, 'Value'));
guidata(hObject, handles);

% --- Executes on button press in AddCollapsedDim.
function AddCollapsedDim_Callback(hObject, eventdata, handles)
% hObject    handle to AddCollapsedDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dimText = get(handles.UncollapsedDims, 'String');
value = get(handles.UncollapsedDims, 'Value');
newDimText = get(handles.ChooseDim, 'String');
newDimValue = get(handles.ChooseDim, 'Value');
if isempty(dimText) || isempty(newDimText)
    return;
end
dimNum = sscanf(dimText{value}, '%d');
newDimNum = sscanf(newDimText{newDimValue}, '%d:');
handles.Parameters.Dims{newDimValue}(1,end+1) = dimNum;
guidata(hObject, handles);
update(hObject, handles);

% --- Executes on button press in RemoveCollapsedDim.
function RemoveCollapsedDim_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveCollapsedDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dimText = get(handles.CollapsedDims, 'String');
value = get(handles.CollapsedDims, 'Value');
newDimText = get(handles.ChooseDim, 'String');
newDimValue = get(handles.ChooseDim, 'Value');
if isempty(dimText) || isempty(newDimText)
    return;
end
dimNum = sscanf(dimText{value}, '%d');
newDimNum = sscanf(newDimText{newDimValue}, '%d:');
idx = find(handles.Parameters.Dims{newDimNum}==dimNum);
handles.Parameters.Dims{newDimNum}(idx) = [];
guidata(hObject, handles);
update(hObject, handles);

function update(hObject, handles)
% Update UncollapsedDims and CollapsedDims lists using handles.Parameters
nDims = numel(handles.Labels);
dimText = cell(nDims,1);
for i=1:nDims
    dimText{i} = sprintf('%d: %s', i, handles.Labels(i).Name);
end
uncollapsedDims = setdiff(1:nDims, cat(2, handles.Parameters.Dims{:}));
n = numel(uncollapsedDims);
value = get(handles.UncollapsedDims, 'Value');
if value > n
    value = n;
end
if n == 0
    set(handles.UncollapsedDims, 'String', char(zeros(1,0)), 'Value', 1);
else
    set(handles.UncollapsedDims, 'String', dimText(uncollapsedDims), 'Value', value);
end
newDimText = get(handles.ChooseDim, 'String');
if isempty(newDimText)
    collapsedDims =  char(zeros(1,0));
    value = 1;
else
    newDimValue = get(handles.ChooseDim, 'Value');
    Dims = handles.Parameters.Dims{newDimValue};
    if isempty(Dims)
        collapsedDims = char(zeros(1,0));
        value = 1;
    else
        collapsedDims = dimText(Dims);
        value = get(handles.CollapsedDims, 'Value');
        if value > numel(collapsedDims)
            value = numel(collapsedDims);
        end
    end
end
set(handles.CollapsedDims, 'String', collapsedDims, 'Value', value);


% --- Executes on selection change in UncollapsedDims.
function UncollapsedDims_Callback(hObject, eventdata, handles)
% hObject    handle to UncollapsedDims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns UncollapsedDims contents as cell array
%        contents{get(hObject,'Value')} returns selected item from UncollapsedDims


% --- Executes on selection change in CollapsedDims.
function CollapsedDims_Callback(hObject, eventdata, handles)
% hObject    handle to CollapsedDims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CollapsedDims contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CollapsedDims


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


