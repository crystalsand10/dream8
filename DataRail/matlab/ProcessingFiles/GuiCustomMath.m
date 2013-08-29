function varargout = GuiCustomMath(varargin)
% GUICUSTOMMATH M-file for GuiCustomMath.fig
%      GUICUSTOMMATH, by itself, creates a new GUICUSTOMMATH or raises the existing
%      singleton*.
%
%      H = GUICUSTOMMATH returns the handle to a new GUICUSTOMMATH or the handle to
%      the existing singleton*.
%
%      GUICUSTOMMATH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUICUSTOMMATH.M with the given input arguments.
%
%      GUICUSTOMMATH('Property','Value',...) creates a new GUICUSTOMMATH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiCustomMath_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiCustomMath_OpeningFcn via varargin.
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

% Edit the above text to modify the response to help GuiCustomMath

% Last Modified by GUIDE v2.5 04-Jun-2009 11:36:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiCustomMath_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiCustomMath_OutputFcn, ...
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


% --- Executes just before GuiCustomMath is made visible.
function GuiCustomMath_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiCustomMath (see VARARGIN)

% Choose default command line output for GuiCustomMath
handles.output = hObject;
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
% Update handles structure
guidata(hObject, handles);
set(handles.popupCube1,'String', get(varargin{3}.ChooseSourceData,'String'));
set(handles.popupCube2,'String', get(varargin{3}.ChooseSourceData,'String'));
popCT = [];
for i = 1:length(varargin{1}.Labels(1,1).Value)
    popCT = [popCT varargin{1}.Labels(1,1).Value(i)];
end
set(handles.popupCCell,'String',popCT);
popT = [];
for i = 1:length(varargin{1}.Labels(2,1).Value)
    popT = [popT varargin{1}.Labels(2,1).Value(i)];
end
set(handles.popupCTime,'String',popT);
popCond = [];
for i = 1:length(varargin{1}.Labels(3,1).Value)
    popCond = [popCond varargin{1}.Labels(3,1).Value(i)];
end
set(handles.popupCCond,'String',popCond);
popInh = [];
for i = 1:length(varargin{1}.Labels(4,1).Value)
    popInh = [popInh varargin{1}.Labels(4,1).Value(i)];
end
set(handles.popupCInh,'String',popInh);
popSign = [];
for i = 1:length(varargin{1}.Labels(5,1).Value)
    popSign = [popSign varargin{1}.Labels(5,1).Value(i)];
end
set(handles.popupCSign,'String',popSign);
popApply = [];
popApply{1} = 'Whole Dataset';
for i = 1:5
    popApply{i+1} = [varargin{1}.Labels(i,1).Name];
end
set(handles.popupApply,'String',popApply);

% UIWAIT makes GuiCustomMath wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuiCustomMath_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close


% --- Executes on button press in buttonOK.
function buttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to buttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedButton = get(handles.uicmath,'SelectedObject');
mathtype = get(selectedButton,'Tag');
switch mathtype
    case 'rb1'
        parameters.Type = 1;
        parameters.Value.Command = get(handles.editcommand,'String');
        parameters.Value.ApplyTo = get(handles.popupApply,'Value');
        switch parameters.Value.ApplyTo
            case 2
                parameters.Value.SubCube = get(handles.popupCCell,'Value');
            case 3
                parameters.Value.SubCube = get(handles.popupCTime,'Value');
            case 4
                parameters.Value.SubCube = get(handles.popupCCond,'Value');
            case 5
                parameters.Value.SubCube = get(handles.popupCInh,'Value');
            case 6
                parameters.Value.SubCube = get(handles.popupCSign,'Value');
        end
    case 'rb2'
        parameters.Type = 2;
        parameters.Value.Cube1 = get(handles.popupCube1,'Value');
        parameters.Value.Cube2 = get(handles.popupCube2,'Value');
        parameters.Value.Operator = get(handles.popupoperator,'Value');
end
handles.notifier(parameters);
delete(handles.figure1);



function editcommand_Callback(hObject, eventdata, handles)
% hObject    handle to editcommand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editcommand as text
%        str2double(get(hObject,'String')) returns contents of editcommand as a double
if exist(get(handles.editcommand,'String')) ~= 5
    errordlg('Check your spelling. This MATLAB command was not found', 'Function name not found');
end


% --- Executes during object creation, after setting all properties.
function editcommand_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editcommand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupApply.
function popupApply_Callback(hObject, eventdata, handles)
% hObject    handle to popupApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupApply contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupApply
selectedApply = get(handles.popupApply,'Value');
switch selectedApply
    case 1
        set(handles.popupCCell,'Visible','Off')
        set(handles.popupCTime,'Visible','Off')
        set(handles.popupCCond,'Visible','Off')
        set(handles.popupCInh,'Visible','Off')
        set(handles.popupCSign,'Visible','Off')
    case 2
        set(handles.popupCCell,'Visible','On')
        set(handles.popupCTime,'Visible','Off')
        set(handles.popupCCond,'Visible','Off')
        set(handles.popupCInh,'Visible','Off')
        set(handles.popupCSign,'Visible','Off')
    case 3
        set(handles.popupCCell,'Visible','Off')
        set(handles.popupCTime,'Visible','On')
        set(handles.popupCCond,'Visible','Off')
        set(handles.popupCInh,'Visible','Off')
        set(handles.popupCSign,'Visible','Off')
    case 4
        set(handles.popupCCell,'Visible','Off')
        set(handles.popupCTime,'Visible','Off')
        set(handles.popupCCond,'Visible','On')
        set(handles.popupCInh,'Visible','Off')
        set(handles.popupCSign,'Visible','Off')
    case 5
        set(handles.popupCCell,'Visible','Off')
        set(handles.popupCTime,'Visible','Off')
        set(handles.popupCCond,'Visible','Off')
        set(handles.popupCInh,'Visible','On')
        set(handles.popupCSign,'Visible','Off')
    case 6
        set(handles.popupCCell,'Visible','Off')
        set(handles.popupCTime,'Visible','Off')
        set(handles.popupCCond,'Visible','Off')
        set(handles.popupCInh,'Visible','Off')
        set(handles.popupCSign,'Visible','On')
end


% --- Executes during object creation, after setting all properties.
function popupApply_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCCell.
function popupCCell_Callback(hObject, eventdata, handles)
% hObject    handle to popupCCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCCell contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCCell


% --- Executes during object creation, after setting all properties.
function popupCCell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCube1.
function popupCube1_Callback(hObject, eventdata, handles)
% hObject    handle to popupCube1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCube1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCube1


% --- Executes during object creation, after setting all properties.
function popupCube1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCube1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupoperator.
function popupoperator_Callback(hObject, eventdata, handles)
% hObject    handle to popupoperator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupoperator contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupoperator


% --- Executes during object creation, after setting all properties.
function popupoperator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupoperator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCube2.
function popupCube2_Callback(hObject, eventdata, handles)
% hObject    handle to popupCube2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCube2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCube2


% --- Executes during object creation, after setting all properties.
function popupCube2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCube2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCTime.
function popupCTime_Callback(hObject, eventdata, handles)
% hObject    handle to popupCTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCTime contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCTime


% --- Executes during object creation, after setting all properties.
function popupCTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCCond.
function popupCCond_Callback(hObject, eventdata, handles)
% hObject    handle to popupCCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCCond contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCCond


% --- Executes during object creation, after setting all properties.
function popupCCond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCInh.
function popupCInh_Callback(hObject, eventdata, handles)
% hObject    handle to popupCInh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCInh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCInh


% --- Executes during object creation, after setting all properties.
function popupCInh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCInh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCSign.
function popupCSign_Callback(hObject, eventdata, handles)
% hObject    handle to popupCSign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCSign contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCSign


% --- Executes during object creation, after setting all properties.
function popupCSign_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCSign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in help1.
function help1_Callback(hObject, eventdata, handles)
% hObject    handle to help1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Applies the entered MATLAB function to the selected array and \n creates a new array where the value v(i,j) is the same for all i rows and j columns.'));


% --- Executes on button press in help2.
function help2_Callback(hObject, eventdata, handles)
% hObject    handle to help2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Fuses the to selected arrays with the selected operator to a new array.'));
