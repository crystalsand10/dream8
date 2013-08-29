function varargout = GuiPlotWeights(varargin)
% GUIPLOTWEIGHTS M-file for GuiPlotWeights.fig
%      GUIPLOTWEIGHTS, by itself, creates a new GUIPLOTWEIGHTS or raises the existing
%      singleton*.
%
%      H = GUIPLOTWEIGHTS returns the handle to a new GUIPLOTWEIGHTS or the handle to
%      the existing singleton*.
%
%      GUIPLOTWEIGHTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIPLOTWEIGHTS.M with the given input arguments.
%
%      GUIPLOTWEIGHTS('Property','Value',...) creates a new GUIPLOTWEIGHTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiPlotWeights_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiPlotWeights_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuiPlotWeights

% Last Modified by GUIDE v2.5 16-Jul-2008 23:22:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiPlotWeights_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiPlotWeights_OutputFcn, ...
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

% --- Executes just before GuiPlotWeights is made visible.
function GuiPlotWeights_OpeningFcn(hObject, eventdata, handles, factors, labels, figName)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiPlotWeights (see VARARGIN)

% Choose default command line output for GuiPlotWeights
handles.output = hObject;
if ~exist('figName') || isempty(figName)
    figName = 'Plot PLSR/PCS Factors';
end
set(handles.figure1, 'Name', figName);
nFactors = size(factors{1}, 2);
factorStrings = arrayfun(@num2str, 1:nFactors, 'uni', 0);
set(handles.dim1, 'String', factorStrings);
set(handles.dim2, 'String', [{'---'}, factorStrings]);
set(handles.pc, 'String', {labels.Name});
if nFactors > 1
    set(handles.dim2, 'Value', 3);
end
handles.factors = factors;
handles.labels = labels;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GuiPlotWeights.
pushbutton1_Callback(hObject, eventdata, handles);

% UIWAIT makes GuiPlotWeights wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuiPlotWeights_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dim1 = get(handles.dim1, 'Value');
dim2 = get(handles.dim2, 'Value')-1;
pc = get(handles.pc, 'Value');
pcNames = get(handles.pc, 'String');
if dim2==0
    plot1(handles,dim1,pc);
else
    plot2(handles,dim1,dim2,pc);
end
title([ get(handles.figure1, 'Name') ': ' pcNames{pc}]);

function plot1(handles,dim1,pc)
axes(handles.axes1);
cla;
bar(handles.factors{pc}(:,dim1));
xlabel(['Component ' num2str(dim1)]);
set(gca, 'XTick', 1:numel(handles.labels(pc).Value), 'XTickLabel', handles.labels(pc).Value);
rotateticklabel(gca,90);

function plot2(handles,dim1,dim2,pc)
axes(handles.axes1);
cla;
plot(handles.factors{pc}(:,dim1),handles.factors{pc}(:,dim2),'.');
xlabel(['Component ' num2str(dim1)]);
ylabel(['Component ' num2str(dim2)]);
value = handles.labels(pc).Value;
if isnumeric(value)
    value = arrayfun(@num2str, value, 'uni', 0);
end
for i=1:size(handles.factors{pc},1)
    text(handles.factors{pc}(i,dim1),handles.factors{pc}(i,dim2),[' ' value{i}]);
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in dim1.
function dim1_Callback(hObject, eventdata, handles)
% hObject    handle to dim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dim1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dim1


% --- Executes during object creation, after setting all properties.
function dim1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

% set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on selection change in dim2.
function dim2_Callback(hObject, eventdata, handles)
% hObject    handle to dim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dim2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dim2


% --- Executes during object creation, after setting all properties.
function dim2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pc.
function pc_Callback(hObject, eventdata, handles)
% hObject    handle to pc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pc


% --- Executes during object creation, after setting all properties.
function pc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uiputfile('*.fig','Save figure as:','FactorPlot.fig');
if ~isequal(FileName, 0)
    f = figure('Visible', 'on');
    copyobj(handles.axes1, f);
    saveas(f, fullfile(PathName,FileName), 'fig');
    delete(f);
end
