function varargout = GuiCreateCNADataPars(varargin)
% GuiCreateCNADataPars loads the parameters for the function CreateCNADAta, to create data for CellNetAnalyzer
%
% varargout = GuiCreateCNADataPars(varargin)
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
% Parameters=GuiCreateCNADataPars(SourceData.Labels);
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
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe    Nickel Dittrich
%    SBPipeline.harvard.edu%



set(0,'defaultuicontrolfontname','Sans Serif');
%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GuiCreateCNADataPars_OpeningFcn, ...
    'gui_OutputFcn',  @GuiCreateCNADataPars_OutputFcn, ...
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


%% --- Executes just before GuiCreateCNADataPars is made visible.
function GuiCreateCNADataPars_OpeningFcn(hObject, eventdata, handles, varargin)

set(0,'defaultuicontrolfontsize',11);
%handles.Parameters=[];
handles.Labels=varargin{1};
handles.uiwait = false;
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
handles.Parameters.Labels=handles.Labels;
guidata(hObject, handles);
dim2tr=[];dim2no=[];
for tr=2:numel(handles.Labels(3).Value)
    CommasPos=findstr(',',handles.Labels(3).Value{tr});
    if isempty(find(CommasPos))
        dim2tr=[dim2tr tr];        
    else        
        dim2no=[dim2no tr];
    end
end
IdentifiedTreatments=handles.Labels(3).Value(dim2tr);
for tr=2:numel(handles.Labels(3).Value)
    Text=handles.Labels(3).Value{tr};
    CommasPos=findstr(',',Text);
    if ~isempty(CommasPos)
        IdentifiedTreatments{end+1}=Text(1:CommasPos(1)-1);
        if numel(CommasPos)==1
            IdentifiedTreatments{end+1}=Text(CommasPos+1:end);
        elseif numel(CommasPos)==2
             IdentifiedTreatments{end+1}=Text(CommasPos(1)+1:CommasPos(2)-1);
             IdentifiedTreatments{end+1}=Text(CommasPos(2)+1:end);
        elseif numel(CommasPos)==3
             IdentifiedTreatments{end+1}=Text(CommasPos(1)+1:CommasPos(2)-1);
             IdentifiedTreatments{end+1}=Text(CommasPos(2)+1:CommasPos(3)-1);
             IdentifiedTreatments{end+1}=Text(CommasPos(3)+1:end);
        else
        %only supported up to 4 commas-it should grab from examples with two commas 
        % also for more than 2 total commas
             IdentifiedTreatments{end+1}=Text(CommasPos(1)+1:CommasPos(2)-1);
             IdentifiedTreatments{end+1}=Text(CommasPos(2)+1:CommasPos(3)-1);
             IdentifiedTreatments{end+1}=Text(CommasPos(3)+1:CommasPos(4)-1);
             IdentifiedTreatments{end+1}=Text(CommasPos(4)+1:end);        
        end
    end
end
set(handles.ChosenTreatments2,'String',unique(IdentifiedTreatments));
dim3tr=[];dim3no=[];
for tr=2:numel(handles.Labels(4).Value)
    if isempty(find(findstr(',',handles.Labels(4).Value{tr})))
        dim3tr=[dim3tr tr];   
    else
        dim3no=[dim3no tr];
    end
end
set(handles.ChosenTreatments3,'String',handles.Labels(4).Value(dim3tr));

if isnumeric(handles.Labels(4).Value)==1
    warndlg('cube is not in canonical form-reconvert it.')
    [varargout{1:nargout}] = deal([]);
    delete(hObject);
    return
end
TotalTreatments={handles.Labels(3).Value{1} handles.Labels(4).Value{1}...
                 handles.Labels(3).Value{dim2no} handles.Labels(4).Value{dim3no}};
set(handles.Treatments,'String',TotalTreatments)
set(handles.FixedDim,'String',handles.Labels(1).Value);
guidata(hObject, handles);



%% --- Outputs from this function are returned to the command line.
function varargout = GuiCreateCNADataPars_OutputFcn(hObject, eventdata, handles)
if nargout > 0
    handles.uiwait = true;
    guidata(hObject, handles);
    uiwait;
    varargout{1} = getParameters(hObject, handles);
    delete(handles.figure1);
end

%% General function to move conditions
function MoveCondition(hObject,inhandle,outhandle,handles)
list_entries  =get(handles.(inhandle),'String');
index_selected=get(handles.(inhandle),'Value');
AlreadyChosen =get(handles.(outhandle),'String');

if numel(list_entries)==0|numel(index_selected)==0
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

function Dim2Fix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function HelpDimFixed_Callback(hObject, eventdata, handles)
%helpdlg(sprintf('[dim val] dim: dimension of the data cube which is kept fixed \n val: chosen value'))
helpdlg(sprintf('Choose for which value of the dimension (tipically a cell) the data is generated. By clicking generate for all, it will generate multiple matrices for all of them.'))


function LoadData_Callback(hObject, eventdata, handles)
% handles.Parameters.dim2=get(handles.ChosenTreatments2,'String');
% handles.Parameters.dim3=get(handles.ChosenTreatments3,'String');
Parameters = getParameters(hObject, handles);
if isempty(Parameters.dim2)&&isempty(Parameters.dim3)
  warndlg('Choose at least one treatment for dim 2 or 3')    
  return
end
%if isempty(handles.Parameters.dim3)
%  warndlg('Choose at least one treatment for dim 3')    
%  return
%end
guidata(hObject,handles);
if handles.uiwait
    handles.uiwait = false;
    guidata(hObject, handles);
    uiresume;
else
    delete(handles.figure1);
end

function pushbutton20_Callback(hObject, eventdata, handles)
message=['DataRail needs to know what are the actual treatments to create the matrix for CNA.\n'...
         'It will automatically try to guess from the labels, but you should double check it'...
         ' here as it may not be perfect.'];
helpdlg(sprintf(message));


function GenerateAll_Callback(hObject, eventdata, handles)
guidata(hObject,handles);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if isempty(handles.Parameters.dim2)
%   warndlg('Choose at least one treatment for dim 2')    
%   return
% end
% if isempty(handles.Parameters.dim3)
%   warndlg('Choose at least one treatment for dim 3')    
%   return
% end
handles.notifier(getParameters(hObject, handles));
delete(hObject);

function Parameters = getParameters(hObject, handles)
handles.Parameters.dim2=get(handles.ChosenTreatments2,'String');
handles.Parameters.dim3=get(handles.ChosenTreatments3,'String');
handles.Parameters.DimFixed =[1 1];
handles.Parameters.DimFixed(2)=get(handles.FixedDim,'Value');
if (get(handles.GenerateAll,'Value') == get(handles.GenerateAll,'Max'))
    handles.Parameters.GenerateAll=true;
else
    handles.Parameters.GenerateAll=false;
end
guidata(hObject, handles);
Parameters = handles.Parameters;

function FixedDim_Callback(hObject, eventdata, handles)
handles.Parameters.DimFixed=[1 1];
handles.Parameters.DimFixed(2)=get(handles.FixedDim,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function FixedDim_CreateFcn(hObject, eventdata, handles)
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
