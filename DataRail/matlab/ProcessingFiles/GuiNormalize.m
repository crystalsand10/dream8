function varargout = GuiNormalize(varargin)
% GUINORMALIZE M-file for GuiNormalize.fig
%      GUINORMALIZE, by itself, creates a new GUINORMALIZE or raises the existing
%      singleton*.
%
%      H = GUINORMALIZE returns the handle to a new GUINORMALIZE or the handle to
%      the existing singleton*.
%
%      GUINORMALIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUINORMALIZE.M with the given input arguments.
%
%      GUINORMALIZE('Property','valuerb',...) creates a new GUINORMALIZE or raises the
%      existing singleton*.  Starting from the left, property valuerb pairs are
%      applied to the GUI before GuiNormalize_OpeningFcn gets called.  An
%      unrecognized property name or invalid valuerb makes property application
%      stop.  All inputs are passed to GuiNormalize_OpeningFcn via varargin.
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

% Edit the above text to modify the response to help GuiNormalize

% Last Modified by GUIDE v2.5 27-Sep-2010 12:38:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiNormalize_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiNormalize_OutputFcn, ...
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


% --- Executes just before GuiNormalize is made visible.
function GuiNormalize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiNormalize (see VARARGIN)

% Choose default command line output for GuiNormalize
handles.output = hObject;
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
% Update handles structure
guidata(hObject, handles);
% popIstr = ['Inhibitor'];
% for i = 1:length(varargin{1}.Labels(4,1).Value)
%     popIstr = [popIstr varargin{1}.Labels(4,1).Value(i)];
% end
% set(handles.popupInhib,'String', popIstr);
% popCstr = ['Condition'];
% for i = 1:length(varargin{1}.Labels(3,1).Value)
%     popCstr = [popCstr varargin{1}.Labels(3,1).Value(i)];
% end
% set(handles.popupCyto,'String', popCstr);
popCT = ['CellType'];
for i = 1:length(varargin{1}.Labels(1,1).Value)
    popCT = [popCT varargin{1}.Labels(1,1).Value(i)];
end
set(handles.popupCT,'String', popCT);
handles.compendium = varargin(1);

% UIWAIT makes GuiNormalize wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuiNormalize_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedButton = get(handles.NormType,'SelectedObject');
NormType = get(selectedButton,'Tag');
parameters = struct('Type', [],'Value',[]);
switch NormType
    case 'intipo'   % initial time point
        parameters.Type = 1;
    case 'maxtc'    % maximum for each tc
        parameters.Type = 2;
    case 'valuerb'  % value entered
        parameters.Type = 3;
        parameters.Value.Divider = str2num(get(handles.valueinput,'String'));
    case 'revact'   % respective value
        parameters.Type = 4;
%         if get(handles.popupInhib,'Value') > 1
%             parameters.Value.Inhib = get(handles.popupInhib,'Value') - 1;
%         else
%             warndlg('You have to choose an Inhibitor! Click Change Parameters again to do so!','No Inhibitor selected');
%         end
%         if get(handles.popupCyto,'Value') > 1
%             parameters.Value.Treat = get(handles.popupCyto,'Value') - 1;
%         else
%             warndlg('You have to choose a Condition! Click Change Parameters again to do so!','No Condition selected');
%         end
        if get(handles.popupCT,'Value') > 1
            parameters.Value.CellType = get(handles.popupCT,'Value') - 1;
        else
            warndlg('You have to choose a Cell Type! Click Change Parameters again to do so!','No Condition selected');
        end
    case 'totalprot'    % total protein
        parameters.Type = 5;
        warndlg(' The function to normalize to total protein is obsolete. Drop us a line if you would like it to be implemented.');        
    case 'rbaverage'    % average for each treatment condition
        parameters.Type = 6;
    case 'forCNO'
        parameters.Type = 7;
    case 'BooleanizerMKM'
        parameters.Type = 8;
    case 'UntreatedControl'
        parameters.Type = 9;
    case 'RelUntreatedControl'
        parameters.Type = 10;
    case 'RelatTimeZero'
        parameters.Type = 11;
end

if parameters.Type~=5
    handles.notifier(parameters);
    delete(handles.figure1);
end


function valueinput_Callback(hObject, eventdata, handles)
% hObject    handle to valueinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valueinput as text
%        str2double(get(hObject,'String')) returns contents of valueinput as a double


% --- Executes during object creation, after setting all properties.
function valueinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valueinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inhibedit_Callback(hObject, eventdata, handles)
% hObject    handle to inhibedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inhibedit as text
%        str2double(get(hObject,'String')) returns contents of inhibedit as a double


% --- Executes during object creation, after setting all properties.
function inhibedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inhibedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close



function treatedit_Callback(hObject, eventdata, handles)
% hObject    handle to treatedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of treatedit as text
%        str2double(get(hObject,'String')) returns contents of treatedit as a double


% --- Executes during object creation, after setting all properties.
function treatedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to treatedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupInhib.
function popupInhib_Callback(hObject, eventdata, handles)
% hObject    handle to popupInhib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupInhib contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupInhib


% --- Executes during object creation, after setting all properties.
function popupInhib_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupInhib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCyto.
function popupCyto_Callback(hObject, eventdata, handles)
% hObject    handle to popupCyto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCyto contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCyto


% --- Executes during object creation, after setting all properties.
function popupCyto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCyto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCT.
function popupCT_Callback(hObject, eventdata, handles)
% hObject    handle to popupCT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCT contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCT


% --- Executes during object creation, after setting all properties.
function popupCT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in helpinit.
function helpinit_Callback(hObject, eventdata, handles)
% hObject    handle to helpinit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Divides the values of each condition by it`s respective initial time point.'));


% --- Executes on button press in helpmax.
function helpmax_Callback(hObject, eventdata, handles)
% hObject    handle to helpmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Divides the values of each condition by it`s respective largest value where a condition is a treatment of the same stimuli, and inhibitor (different cell types are pooled to determine the maximum).  If the maximum of a cell type is less than or equal to zero, this function makes the new value a zero.'));


% --- Executes on button press in helpaverage.
function helpaverage_Callback(hObject, eventdata, handles)
% hObject    handle to helpaverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Divides the values of each condition by it`s respective average value where a condition is a treatment of the same cell type, stimuli, and inhibitor.'));


% --- Executes on button press in helpvalue.
function helpvalue_Callback(hObject, eventdata, handles)
% hObject    handle to helpvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Divides each value in the array by the value entered by the user.'));


% --- Executes on button press in helpcelltype.
function helpcelltype_Callback(hObject, eventdata, handles)
% hObject    handle to helpcelltype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Divides the whole array by the respective values of the selected Cell Type.'));


% --- Executes on button press in helpprotein.
function helpprotein_Callback(hObject, eventdata, handles)
% hObject    handle to helpprotein (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Uses a protein data file given by the user to normalize the array. This Does not work! Contact the developers if you need this functionality!'));


% --- Executes on button press in helpforCNO.
function helpforCNO_Callback(hObject, eventdata, handles)
% hObject    handle to helpforCNO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
messag = ['Normalizes data between 0 and 1 using several user-defined thresholds.'...
          ' This is used for logic modeling in CellNetOptimizer, and is described in '... 
          'Saez-Rodriguez et al. Mol. Syst. Biol. 2009) '];
      
helpdlg(sprintf(messag));


% --- Executes on button press in HelpBoolMKM.
function HelpBoolMKM_Callback(hObject, eventdata, handles)
messag = ['Normalizes data between 0 and 1 using several user-defined thresholds.'...
          ' This is used for logic modeling in CellNetOptimizer, and is described in '... 
          'Saez-Rodriguez et al. Mol. Syst. Biol. 2009).  It was re-implemented by'...
          'M Morris to take more than one time point and also allow normalization to the no'...
          'cytokine control.  Note that the re-implementation was subltely different than the'...
          'orignal such that running Booleanizer and running BooleanizerMKM do no result in the same values'];
      
helpdlg(sprintf(messag));


% --- Executes on button press in HelpUntreatedControl.
function HelpUntreatedControl_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Uses the untreated control (assumed to be the first index of the third dimension) to normalize the array.'));


% --- Executes on button press in HelpRelUntreatedControl.
function HelpRelUntreatedControl_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Uses difference in the untreated control (assumed to be the first index of the third dimension) to normalize the array.  This is equivalent to the fold change minus one.'));


% --- Executes on button press in HelpRelateTimeZero.
function HelpRelateTimeZero_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Uses difference in the initial time (assumed to be the first index of the second dimension) to normalize the array.  This is equivalent to the fold change minus one.'));
