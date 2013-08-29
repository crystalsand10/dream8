function varargout = GuiChooseTimes(varargin)
% 
set(0,'defaultuicontrolfontsize',11);
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiChooseTimes_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiChooseTimes_OutputFcn, ...
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


% --- Executes just before GuiChooseTimes is made visible.
function GuiChooseTimes_OpeningFcn(hObject, eventdata, handles, varargin)
%handles.Parameters=[];
handles.Labels=varargin{1};
if numel(varargin) >= 2
    handles.notifier=varargin{2};
else
    handles.notifier = @(x) []; % dummy notifier
end
handles.Parameters.Labels=handles.Labels;
guidata(hObject, handles);
dim2tr=[];dim2no=[];
for tr=2:numel(handles.Labels(3).Value)
    if isempty(find(findstr(',',handles.Labels(3).Value{tr})))
        dim2tr=[dim2tr tr];        
    else
        dim2no=[dim2no tr];
    end
end
Vals=handles.Labels(2).Value;
set(handles.InitialTimeBox, 'String', num2str(Vals(1)));
Vals=Vals(2:end);
set(handles.TimeValues,'String',cellstr(num2str(Vals)));
set(handles.EarlyTimes,'String','');
set(handles.MidTimes,'String','');
set(handles.LateTimes,'String','');
if ~isnumeric(handles.Labels(2).Value)==1
    warndlg('cube is not in canonical form-reconvert it.')
    [varargout{1:nargout}] = deal([]);
    delete(hObject);
    return
end
handles.output.EarlyTimes=[];%handles.Parameters.Labels(2).Value;
handles.output.LateTimes=[];
guidata(hObject, handles);

function varargout = GuiChooseTimes_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%%
function TimeValues_Callback(hObject, eventdata, handles)

function TimeValues_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EarlyTimes_Callback(hObject, eventdata, handles)

function EarlyTimes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MidTimes_Callback(hObject, eventdata, handles)

function MidTimes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LateTimes_Callback(hObject, eventdata, handles)

function LateTimes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AddToEarly_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'TimeValues','EarlyTimes',handles)

function RemFromEarly_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'EarlyTimes','TimeValues',handles)

function AddToMid_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'TimeValues','MidTimes',handles)

function RemFromMid_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'MidTimes','TimeValues',handles)

function AddToLate_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'TimeValues','LateTimes',handles)

function RemFromLate_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'LateTimes','TimeValues',handles)


function Finish_Callback(hObject, eventdata, handles)
EarlyTimesVal=str2num(char(get(handles.EarlyTimes,'String')));
MidTimesVal  =str2num(char(get(handles.MidTimes,'String')));
LateTimesVal =str2num(char(get(handles.LateTimes,'String')));
Times=handles.Labels(2).Value;
handles.output.EarlyTimes=[];
handles.output.MidTimes=[];
handles.output.LateTimes=[];
for val=1:numel(Times)
    if find(Times(val)==EarlyTimesVal,1);
        handles.output.EarlyTimes=[handles.output.EarlyTimes val];
    elseif find(Times(val)==MidTimesVal,1);
        handles.output.MidTimes=[handles.output.MidTimes val];
    else
        handles.output.LateTimes=[handles.output.LateTimes val];
    end
end

  
guidata(hObject,handles);
delete(handles.figure1);


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
        KeptValues= 2:size(list_entries,1);
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

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% Create this function via Guide!
handles.notifier(handles.output);
delete(hObject);


% --- Executes on selection change in InitialTimeBox.
function InitialTimeBox_Callback(hObject, eventdata, handles)
% hObject    handle to InitialTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns InitialTimeBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InitialTimeBox


% --- Executes during object creation, after setting all properties.
function InitialTimeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InitialTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


