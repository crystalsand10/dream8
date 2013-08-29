function varargout = GuiCreateSubCube(varargin)
% GuiCreateSubCube helps to create a data cube out of a larger data cube
%
%  varargout = GuiMidasImporter(varargin)
%  
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = a cube structure
%
%
% OUTPUTS:
%
% varargout = the cube structure
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  LeoData.data(3).Value=GuiMidasImporter(LeoData.data(2).Value)
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
                   'gui_OpeningFcn', @GuiCreateSubCube_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiCreateSubCube_OutputFcn, ...
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


%% --- Executes just before GuiCreateSubCube is made visible.
function GuiCreateSubCube_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for GuiCreateSubCube
handles.output = hObject;

handles.Parameters.Labels=varargin{1}.Labels;
handles.OrigCube=varargin{1};
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
set(handles.ChooseDimension,'String',{handles.OrigCube.Labels.Name});
set(handles.ChooseDimension,'Value',1);
nd = numel(handles.OrigCube.Labels);
handles.Parameters.Keep   = cell(nd,1);
handles.Remove = cell(nd,1);

handles.Labels=handles.Parameters.Labels;
sz = cellfun(@numel, {handles.Labels.Value});

for i=1:nd
    handles.Parameters.Keep{i} = 1:sz(i);
    if isnumeric(handles.Labels(i).Value)        
        handles.Labels(i).Value=arrayfun(@num2str, handles.Labels(i).Value, ...
        'UniformOutput', 0);
    end
end
set(handles.KeptValues,'String',handles.Labels(1).Value)
set(handles.RemovedValues,'String',{},'Value',[])
guidata(hObject, handles);

%% --- Outputs from this function are returned to the command line.
function varargout = GuiCreateSubCube_OutputFcn(hObject, eventdata, handles) 

%%
function ChooseDimension_Callback(hObject, eventdata, handles)
CurrDim=get(handles.ChooseDimension,'Value');
set(handles.KeptValues,'String',...
handles.Labels(CurrDim).Value(handles.Parameters.Keep{CurrDim}));
set(handles.RemovedValues,'String',...
handles.Labels(CurrDim).Value(handles.Remove{CurrDim}));
guidata(hObject, handles);

function ChooseDimension_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function KeptValues_Callback(hObject, eventdata, handles)

function KeptValues_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RemovedValues_Callback(hObject, eventdata, handles)

function RemovedValues_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RemoveOne_Callback(hObject, eventdata, handles)
CurrDim=get(handles.ChooseDimension,'Value');

if numel(handles.Parameters.Keep{CurrDim})>1
    ChosenVal=handles.Parameters.Keep{CurrDim}(get(handles.KeptValues,'Value'));
    handles.Remove{CurrDim}(end+1)=ChosenVal;
    handles.Parameters.Keep{CurrDim}(get(handles.KeptValues,'Value'))=[];
    MoveCondition(hObject,'KeptValues','RemovedValues',handles);  
end

guidata(hObject, handles);

function ReAddOne_Callback(hObject, eventdata, handles)
CurrDim=get(handles.ChooseDimension,'Value');
if numel(handles.Remove{CurrDim})>0
    ChosenVal=handles.Remove{CurrDim}(get(handles.RemovedValues,'Value'));      
    handles.Parameters.Keep{CurrDim}(end+1)=ChosenVal;
    handles.Remove{CurrDim}(get(handles.RemovedValues,'Value'))=[];
    MoveCondition(hObject,'RemovedValues','KeptValues',handles)   
end
       
guidata(hObject, handles);

function RemoveAll_Callback(hObject, eventdata, handles)
KeptValues=get(handles.KeptValues,'String');
ChosenValues=get(handles.RemovedValues,'String');
Values={};
if iscell(ChosenValues)
    Readouts=ChosenValues;
end
if  iscell(AllValues)
    Readouts={Values{:} AllValues{:}};
end

set(handles.ChosenValues,'String',Values,'Value',1);
set(handles.Values,'String',{},'Value',[]);
guidata(hObject,handles);

%%
function GO_Callback(hObject, eventdata, handles)
delete(handles.figure1);

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


function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.notifier(handles.Parameters);


