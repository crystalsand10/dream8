function varargout = GuiExpandCubeto2DPars(varargin)
% GuiExpandCubeto2DPars loads the parameters for the function CreateCNADAta, to create data for CellNetAnalyzer
%
% varargout = GuiExpandCubeto2DPars(varargin)
%  
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = Labels of Data Cube
%
%
% OUTPUTS:
%
% varargout = the structure of parameters for CreateCNAData
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Parameters=GuiExpandCubeto2DPars(SourceData.Labels);
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
    'gui_OpeningFcn', @GuiExpandCubeto2DPars_OpeningFcn, ...
    'gui_OutputFcn',  @GuiExpandCubeto2DPars_OutputFcn, ...
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


%% --- Executes just before GuiExpandCubeto2DPars is made visible.
function GuiExpandCubeto2DPars_OpeningFcn(hObject, eventdata, handles, varargin)

set(0,'defaultuicontrolfontsize',11);
%handles.Parameters=[];
handles.Labels=labels2cellstr(varargin{1});
handles.uiwait = false;
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
set(handles.ChosenTreatments2,'String',handles.Labels(3).Value(2:end));
set(handles.ChosenTreatments3,'String',handles.Labels(4).Value(2:end));
handles.MetricsAvailable={'none', 'mean', 'AUC', 'Differential', 'slope', 'time2', 'time3'};
set(handles.ChooseMetric,'String',handles.MetricsAvailable);
set(handles.ChooseMetric,'Value',1);
% if isnumeric(handles.Labels(4).Value)==1
%     warndlg('cube is not in canonical form-reconvert it.')
%     [varargout{1:nargout}] = deal([]);
%     delete(hObject);
%     return
% end
TotalTreatments={handles.Labels(3).Value{1} handles.Labels(4).Value{1}};
set(handles.Treatments,'String',TotalTreatments)
set(handles.FixedDim,'String',handles.Labels(1).Value);
guidata(hObject, handles);



%% --- Outputs from this function are returned to the command line.
function varargout = GuiExpandCubeto2DPars_OutputFcn(hObject, eventdata, handles)
% If output is requested, also delete the figure
if nargout > 0
    handles.uiwait = true;
    guidata(hObject, handles);
    uiwait;
    guidata(hObject, handles);
    varargout{1} = getParameters(hObject);
    delete(hObject);
end

%% General function to move conditions
function MoveCondition(hObject,inhandle,outhandle,handles)
list_entries  =get(handles.(inhandle),'String');
index_selected=get(handles.(inhandle),'Value');
AlreadyChosen =get(handles.(outhandle),'String');

if numel(list_entries)==0||numel(index_selected)==0
    return
%elseif numel(index_selected)>1     warndlg('Selection of multiple objects not implemented');
end
%add to dim1
Treatments=AlreadyChosen;
Treatments{(size(AlreadyChosen,1)+1)}=list_entries{index_selected};
if numel(Treatments)==1
    set(handles.(outhandle),'Value',1,'String',Treatments);    
else
    set(handles.(outhandle),'String',Treatments);
end

%remove from possibles to avoid multiple choosing
if size(list_entries,1)==1
    Reduced={};
    set(handles.(inhandle),'Value',[]);
else
    if index_selected==1
        KeptValues= [2:size(list_entries,1)]  ;
        set(handles.(inhandle),'Value',1);
    elseif index_selected==(size(list_entries,1))
        KeptValues=[1:(size(list_entries,1)-1)];
        set(handles.(inhandle),'Value',(index_selected-1)); 
    else
        KeptValues=[1:(index_selected-1) (index_selected+1):size(list_entries,1)];
        set(handles.(inhandle),'Value',index_selected);
    end

    for i=1:size(KeptValues,2)
        Reduced{i}=list_entries{KeptValues(i)};
    end
end

set(handles.(inhandle),'String',Reduced);
guidata(hObject,handles);


%% ---------------- 2nd Dimension------------------------------
function ChosenTreatments2_Callback(hObject, eventdata, handles)

function ChosenTreatments2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AddTreatment2_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'Treatments','ChosenTreatments2',handles)

function RemoveTreatment2_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'ChosenTreatments2','Treatments',handles)

function Dim2Name_Callback(hObject, eventdata, handles)

function Dim2Name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ---------------- 3rd Dimension------------------------------
function ChosenTreatments3_Callback(hObject, eventdata, handles)

function ChosenTreatments3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AddTreatment3_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'Treatments','ChosenTreatments3',handles)

function RemoveTreatment3_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'ChosenTreatments3','Treatments',handles)

function Dim3Name_Callback(hObject, eventdata, handles)

function Dim3Name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function Treatments_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Treatments_Callback(hObject, eventdata, handles)

%%
function Dim2Fix_Callback(hObject, eventdata, handles)
% DimFixed=get(hObject, 'String');
% handles.Parameters.DimFixed=str2num(DimFixed);
guidata(hObject,handles);

function Dim2Fix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function HelpDimFixed_Callback(hObject, eventdata, handles)
helpdlg({'[dim val]', 'dim: dimension of the data cube which is kept fixed', ...
    'val: chosen value'})


function LoadData_Callback(hObject, eventdata, handles)
% Muse use CLOSE and not DELETE to keep handles available for OutputFcn
close(handles.figure1);

%%
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if handles.uiwait
    uiresume;
else
    delete(hObject);
end

function ChooseMetric_Callback(hObject, eventdata, handles)


function ChooseMetric_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.Parameters.dim2=get(handles.ChosenTreatments2,'String');
% handles.Parameters.dim3=get(handles.ChosenTreatments3,'String');
% if isempty(handles.Parameters.dim2)
%   warndlg('Choose at least one treatment for dim 2')    
%   return
% end
% if isempty(handles.Parameters.dim3)
%   warndlg('Choose at least one treatment for dim 3')    
%   return
% end
% handles.Parameters.Metric=handles.MetricsAvailable{get(handles.ChooseMetr
% ic,'Value')};
handles.notifier(getParameters(hObject));

function p = getParameters(hObject)
% Put all the parameter-setting logic in one function
handles = guidata(hObject);
p.Labels = handles.Labels;
p.PrintWarnings = false;
p.DimFixed=[1 1];
p.DimFixed(2)=get(handles.FixedDim,'Value');
p.dim2=get(handles.ChosenTreatments2,'String');
p.dim3=get(handles.ChosenTreatments3,'String');
p.Metric=handles.MetricsAvailable{get(handles.ChooseMetric,'Value')};




function FixedDim_Callback(hObject, eventdata, handles)
handles.Parameters.DimFixed=[1 1];
handles.Parameters.DimFixed(2)=get(handles.FixedDim,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function FixedDim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FixedDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


