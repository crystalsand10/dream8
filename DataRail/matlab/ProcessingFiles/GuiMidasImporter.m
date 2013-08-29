function varargout = GuiMidasImporter(varargin)
% GuiMidasImporter helps to load your MIDAS data into a Matlab n-dimensional data cube (n<=5)
%
%  varargout = GuiMidasImporter(varargin)
%  
% Results will be save as varargout in the workspace. 
%  You can also choose a mat file to save the  data cube
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = a MIDAS file (optional)
%
%
% OUTPUTS:
%
% varargout = the data structure
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  DataCube=GuiMidasImporter
%
%--------------------------------------------------------------------------
% TODO:
%
% - get Type/Well from data file instead of treatment file
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
    'gui_OpeningFcn', @GuiMidasImporter_OpeningFcn, ...
    'gui_OutputFcn',  @GuiMidasImporter_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
%% Check if first argument is a callback function
iscallback = false;
if nargin && ischar(varargin{1})
    callback = varargin{1};
    ws = warning('query','all');
    warning('off');
    try
        fh = str2func(callback);
        fhinfo = functions(fh);
        if strcmp(fhinfo.type, 'scopedfunction')
            iscallback = true;
        end
    catch
    end
    warning(ws);
end

if iscallback
% if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%% --- Executes just before GuiMidasImporter is made visible.
function GuiMidasImporter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiMidasImporter (see VARARGIN)

set(0,'defaultuicontrolfontsize',11);

handles.Compendium = struct('Name','','Info','','data',[]); % Default value is empty
handles.Parameters.Passt0Data   =false;
handles.Parameters.IgnoreMissing=false;
handles.Parameters.CanonicalForm=true;
handles.SavedFileExist=false;
handles.OldFileWithData = '';
handles.FileWithData = '';
handles.DAtoDVHash = java.util.HashMap;
%handles.DVtoDAHash = java.util.HashMap;
handles.BackgroundTreatment = [];
handles.BackgroundProcessing = [];
guidata(hObject, handles);
if numel(varargin) > 0
    guidata(hObject, handles);
    handles.FileWithData = varargin{1};
    [hObject, handles] = readFile(hObject, handles);
end

%% --- Outputs from this function are returned to the command line.
function varargout = GuiMidasImporter_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure

if nargout>0
    handles.uiwait = true;
    guidata(hObject, handles);
    uiwait;
    try
        handles = guidata(hObject);
        varargout{1} = handles.Compendium;
    catch
        varargout{1} = [];
    end
    if isempty(handles.Compendium.data)
        warndlg('Data cube could not be generated');        
    end
    delete(hObject);
else
    handles.uiwait = false;
    guidata(hObject, handles);
end

%% ------push button to choose the MIDAS file-----------------
function pushbutton1_Callback(hObject, eventdata, handles)


oldDir = pwd;
% Restore data directory, if present
persistent dataDir
if ~isempty(dataDir)
    cd(dataDir);
end

%CurrentDir=pwd;
[FileName,PathName,FilterIndex] = uigetfile('*.csv');
%[FileName,PathName,FilterIndex] = uigetfile('*.csv');
%cd(CurrentDir);

if isnumeric(FileName) && FileName == 0
    % User cancelled
    return
end

dataDir = PathName;
cd(oldDir);

handles.FileWithData=[PathName FileName];
guidata(hObject,handles);
[hObject, handles] = readFile(hObject, handles);

%% enableButtons
function handles = enableButtons(handles);
buttons = {'Treatments', ...
    'AddTreatment', 'RemoveTreatment', 'ChosenTreatments',...
    'AddTreatment2', 'RemoveTreatment2', 'ChosenTreatments2',...
    'AddTreatment3', 'RemoveTreatment3', 'ChosenTreatments3',...
    'Readouts', 'SelectAllReadouts', ...
    'AddReadout', 'RemoveReadout', 'ChosenReadouts'};
for i=1:numel(buttons);
    set(handles.(buttons{i}), 'Enable', 'on');
end

%% Load treatments
function Treatments_Callback(hObject, eventdata, handles)

function Treatments_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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

function RemoveTreatment_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'ChosenTreatments','Treatments',handles)

function Dim1Name_Callback(hObject, eventdata, handles)

function Dim1Name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ---------------- 1st Dimension------------------------------
function ChosenTreatments_Callback(hObject, eventdata, handles)

function ChosenTreatments_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AddTreatment_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'Treatments','ChosenTreatments',handles)

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


%% ---Choose readouts--------------------------------
function Readouts_Callback(hObject, eventdata, handles)

function Readouts_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ChosenReadouts_Callback(hObject, eventdata, handles)

function ChosenReadouts_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AddReadout_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'Readouts','ChosenReadouts',handles)

function RemoveReadout_Callback(hObject, eventdata, handles)
MoveCondition(hObject,'ChosenReadouts','Readouts',handles)

function SelectAllReadouts_Callback(hObject, eventdata, handles)
AllReadouts=get(handles.Readouts,'String');
ChosenReadouts=get(handles.ChosenReadouts,'String');
Readouts={};
if iscell(ChosenReadouts)
    Readouts=ChosenReadouts;
end
if  iscell(AllReadouts)
    Readouts={Readouts{:} AllReadouts{:}};
end

set(handles.ChosenReadouts,'String',Readouts,'Value',1);
set(handles.Readouts,'String',{},'Value',[]);
guidata(hObject,handles);

%% Options&Helps
function CanonicalForm_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.CanonicalForm=true;
else
    handles.Parameters.CanonicalForm=false;
end
guidata(hObject,handles);

function IgnoreMissing_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.IgnoreMissing=true;
else
    handles.Parameters.IgnoreMissing=false;
end
guidata(hObject,handles);

function HelpCanonicalForm_Callback(hObject, eventdata, handles)
helpdlg(sprintf('The canonical form is a 5-D structure is mostly used for the analysis and plotting routines: \n dim(1)=treatment (typically cell types) \n dim(2)=time\n dim(3)=treatments (tipycally stimuli),\n dim(4)=treatments (typically inhibitors/RNAi,\n dim(5)=readouts \n'));

function HelpIgnoreMissing_Callback(hObject, eventdata, handles)
helpdlg(sprintf('Enabling this option will compress the data by ignoring missing values.\nIf the option is not enabled, missing values result in NaNs.\n'));

function ChooseCompendiumName_Callback(hObject, eventdata, handles)
NewCompendiumName = get(hObject, 'String');
set(handles.ChooseCompendiumName,'String',NewCompendiumName);
guidata(hObject,handles)

function ChooseCompendiumName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CompendiumInfo_Callback(hObject, eventdata, handles)
CompendiumInfo = get(hObject, 'String');
set(handles.CompendiumInfo,'String',CompendiumInfo);
guidata(hObject,handles)

function CompendiumInfo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SaveToFile_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.SavedFileExist=true;
    [handles.SavedFile.Name, handles.SavedFile.PathName, handles.SavedFile.FilterIndex] = uiputfile('*.mat', 'Choose a file name to save your data');
    % Outputs are numeric 0's if the user cancels
    if ischar(handles.SavedFile.Name)
        set(handles.FiletoSave,'String',handles.SavedFile.Name);
        guidata(hObject,handles);
    else
        set(hObject,'Value',get(hObject,'Min'));
    end
end


function Passt0Data_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.Passt0Data=true;
else
    handles.Parameters.Passt0Data=false;
end
guidata(hObject,handles);

function HelpPasst0Data_Callback(hObject, eventdata, handles)
helpdlg(sprintf('In some experimental designs, the measurements at t=0 are not repeated for the different stimuli as they ar all under the same conditions (for each particular inhibitor). \n Check this box to copy the t=0 for the first experimental conditions (typically no stimuli) to the rest. '));

%% ------------------Load Data------------------------------------
function [data, names, values]=LoadData_Callback(hObject, eventdata, handles)

Treatments1=get(handles.ChosenTreatments,'String');
for i=1:size(Treatments1,1)
    TR1{i}=['TR:' Treatments1{i}];
end
if numel(Treatments1)==0
    warndlg('Choose at least 1 set of treatments for the 1st dimension');
    return
end

Treatments2=get(handles.ChosenTreatments2,'String');
for i=1:numel(Treatments2)
    TR2{i}=['TR:' Treatments2{i}];
end

Treatments3=get(handles.ChosenTreatments3,'String');
for i=1:numel(Treatments3)
    TR3{i}=['TR:' Treatments3{i}];
end

Readouts=   get(handles.ChosenReadouts,'String');
DA = {};
DV = {};
for i=1:numel(Readouts)
    thisDA = Readouts{i};
    DA{i}=['DA:' thisDA];
    thisDV = handles.DAtoDVHash.get(thisDA);
    % Note: Multiple matches are stored as Java string arrays
    if isa(thisDV,'java.lang.String[]') % Multiple matches        
        for j=1:numel(thisDV);
            % This converts the java string array to a Matlab string
            thisDV2 = char(thisDV(j));
            DV{end+1} = ['DV:' thisDV2];
        end
    elseif ischar(thisDV) % One match
        DV{end+1}=['DV:' thisDV];
    else
        errormsg = 'Unexpected value for this DV field.';
        errordlg(errormsg);
    end
end
% for i=1:numel(Readouts)
%     thisDV = Readouts{i};
%     DV{i}=['DV:' thisDV];
%     thisDA = handles.DVtoDAHash.get(thisDV);
%     % Note: Multiple matches are stored as Java string arrays
%     if isa(thisDA,'java.lang.String[]') % Multiple matches        
%         for j=1:numel(thisDA);
%             % This converts the java string array to a Matlab string
%             thisDA2 = char(thisDA(j));
%             DA{end+1} = ['DV:' thisDA2];
%         end
%     elseif ischar(thisDV) % One match
%         DV{end+1}=['DV:' thisDV];
%     else
%         errormsg = 'Unexpected value for this DV field.';
%         errordlg(errormsg);
%     end
% end
if numel(Readouts)==0
    warndlg('Choose at least 1 readout');
    return
end
if numel(Treatments2)==0
    AllTreatments={TR1};
    numTreatments = 1;
elseif numel(Treatments3)==0
    AllTreatments={TR1,TR2};
    numTreatments = 2;
else
    AllTreatments={TR1,TR2,TR3};
    numTreatments = 3;
end

handles.Parameters.Importer = struct(...
    'dimCols', {AllTreatments},...
    'timeCols', {DA},...
    'valueCols', {DV},...
    'IgnoreMissing', {handles.Parameters.IgnoreMissing}, ...
    'BackgroundTreatment', {handles.BackgroundTreatment}, ...
    'BackgroundProcessing', {handles.BackgroundProcessing});
[handles.Compendium.data] =...
    MidasImporter(handles.FileWithData,handles.Parameters.Importer);
handles.Compendium.Info=get(handles.CompendiumInfo,'String');
guidata(hObject,handles);

%% ------------PostProcessData---------------------------

CompendiumName=get(handles.ChooseCompendiumName,'String');
if isvarname(CompendiumName)==0
    warndlg({ [CompendiumName ' is not a valid Matlab variable name.'], ...
        'It is recommended that the Compendium name is also a valid variable name.'});
end
handles.Compendium.Name = CompendiumName;
% Clean up labels
for i=1:numTreatments
    field = sprintf('Dim%dName', i);
    dimName = get(handles.(field),'String');
    handles.Compendium.data.Labels(i).Name = dimName;
    % Remove dimName from Values
    handles.Compendium.data.Labels(i).Value = ...
        strrep(handles.Compendium.data.Labels(i).Value, ...
        [ ':' dimName ], '');
end


%% The 'canonical form' has to be 5-D: TR1,time,TR2,TR3,DV
if handles.Parameters.CanonicalForm==true
    handles.Compendium.data = CanonicalForm(handles.Compendium.data);
end

%% extract null treatment, t=0 data
if handles.Parameters.Passt0Data
    try
        handles.Compendium.data = passt0Data(handles.Compendium.data);
    catch
        le = lasterror;
        warning('Unable to pass t=0 data: %s', le.message);
    end
end

%% Polish Labels
handles.Compendium.data.Labels = PolishLabels(handles.Compendium.data.Labels);

%% Check for replicates
ReplicatesDim=strmatch('replicate',{handles.Compendium.data.Labels.Name});
if ~isempty(ReplicatesDim)
    SignalsDim=strmatch('signals',{handles.Compendium.data.Labels.Name});
    % Re-order so that 1st dim is replicates and 2nd dim is signals
    replicateData = permute(handles.Compendium.data.Value, ...
        [ReplicatesDim, SignalsDim, ...
        setdiff(1:max(ReplicatesDim,SignalsDim), [ReplicatesDim, SignalsDim])]);
    % Create a 2D array of the last replicates, 1st dim is signals, 2nd is
    % treatments
    lastReplicateData = squeeze(replicateData(end,:,:));
    % Count # of conditions with replicates
    totalNum = sum(~isnan(lastReplicateData(:)));
    condNum = sum(any(~isnan(lastReplicateData), 1));
    numReplicates = size(replicateData, 1);
    sz = size(lastReplicateData);
    numSignals = sz(1);
    numConditions = sz(2);
    numMeasures = prod(sz);
    
    warnMessage = sprintf(['Replicates were found.\nThe maximum number of replicates '...
        'is %d.\n%d out of %d measurements\n(%d out of %d conditions)\n'...
        'have the maximum number of replicates.\n'...
        '\nWould you like to create an additional cube with their average?'],...
        numReplicates, totalNum, numMeasures, condNum, numConditions);
    DoMeanReplicates=questdlg(warnMessage, 'Replicates Found', 'Yes','No', 'Yes');
    if strcmp(DoMeanReplicates,'Yes')
        handles.Compendium.data(2)=createDataCube(...
            'Name',['AverageOfReplicates' handles.Compendium.data(1).Name],...
            'Info','cube with the average through all replicates of the raw data',...
            'SourceData',handles.Compendium.data(1),...
            'Parameters', {'ReplicatesDim', ReplicatesDim, 'CanonicalForm', handles.Parameters.CanonicalForm},...
            'Code',@averageReplicates);
    end
end

% %% extract null treatment, t=0 data
% if handles.Parameters.Passt0Data
%     try
%         handles.Compendium.data = passt0Data(handles.Compendium.data);
%     catch
%         le = lasterror;
%         warning('Unable to pass t=0 data: %s', le.message);
%     end
% end

%% Save
if handles.SavedFileExist==true
    % Use a structure to keep from overwriting function variables
    output = struct(CompendiumName, handles.Compendium);
    save([handles.SavedFile.PathName handles.SavedFile.Name ], '-struct','output');
end
guidata(hObject,handles);
% msgbox('Data imported succesfully. Close the importer window to continue.');
if ~exist('TR1')
    TR1 = cell(1,1);
    TR1{1} = 'dummy dimension';
end
if ~exist('TR2')
    TR2 = cell(1,1);
    TR2{1} = 'dummy dimension';
end
if ~exist('TR3')
    TR3 = cell(1,1);
    TR3{1} = 'dummy dimension';
end

button = questdlg(['Data imported succesfully.' '     Dimension 1:' TR1 ...
    '     Dimension 2:' 'time' '     Dimension 3:' TR2 '     Dimension 4:' TR3 ...
    '     Dimension 5:' 'Signals'], 'Import successful', 'OK', 'OK');
if ischar(button) && strcmp(button, 'OK');
    figure1_CloseRequestFcn(handles.figure1, '', handles);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
try
    if handles.uiwait
        uiresume;
    else
        if ~isstruct(handles.Compendium.data)
            warndlg('Data cube could not be generated');
        end
        delete(hObject);
    end
catch
    if ~isstruct(handles.Compendium.data)
        warndlg('Data cube could not be generated');
    end
    delete(hObject);
end

%% readFile
function [hObject, handles] = readFile(hObject, handles)
oldDAtoDVHash = handles.DAtoDVHash;
try   
    fields = parseHeader(handles.FileWithData);
    TR = fields.TR;
    % Check for Background
    iBackground = strmatch('Background', TR.Value);
    handles.BackgroundTreatment = cell(1,numel(iBackground));
    for i=1:numel(iBackground)
        handles.BackgroundTreatment{i} = ['TR:' TR.Value{iBackground(i)}];
    end
    RemoveBackground = 'No';
    if ~isempty(handles.BackgroundTreatment)
        if ~isempty(cell2mat(strfind(fields.DV.Type, 'Bkgd')))
            msg = sprintf(['Background appears to have ALREADY been subtracted from the data.\n' ...
                'Would you like to subtract background again (NOT RECOMMENDED)?']);
            warning(msg);
        else
            msg = sprintf(['This MIDAS file appears to include background measurements.\n'...
            'Would you like to subtract the background from the measurements?\n' ...
            'Note: Please ensure that background data were not already subtracted.']);
        end
        RemoveBackground=questdlg(msg, 'Subtract background data?', 'Yes','No', 'Yes');
        if isempty(RemoveBackground)
            RemoveBackground = 'No';
        end
    end
    handles.DAtoDVHash = fields.DAtoDVHash;
    if strcmp(RemoveBackground, 'Yes')
        handles.BackgroundProcessing = @(data, bkgd)(data - bkgd);
    else
        handles.BackgroundProcessing = [];
    end
    if ~isempty(iBackground)
        % Delete background treatment from list
        TR.Value(iBackground) = [];
        TR.Type(iBackground) = [];
    end
    TRTypes = unique(TR.Type);
    nTRTypes = numel(TRTypes);
    if nTRTypes  >=2 && nTRTypes  <= 3
        set(handles.Treatments,'String',[]);
        try
            set(handles.ChosenTreatments,'String',[]);
            set(handles.ChosenTreatments2,'String',[]);
            set(handles.ChosenTreatments3,'String',[]);

            i = strmatch(TRTypes{1}, TR.Type);
            set(handles.ChosenTreatments,'String', TR.Value(i));
            set(handles.Dim1Name,'String',TRTypes{1});

            i = strmatch(TRTypes{2}, TR.Type);
            set(handles.ChosenTreatments2,'String', TR.Value(i));
            set(handles.Dim2Name,'String',TRTypes{2});

            i = strmatch(TRTypes{3}, TR.Type);
            set(handles.ChosenTreatments3,'String', TR.Value(i));
            set(handles.Dim3Name,'String',TRTypes{3});

        catch
        end
    else
        set(handles.Treatments,'String',TR.Value);
        set(handles.ChosenTreatments,'String',[]);
        set(handles.ChosenTreatments2,'String',[]);
        set(handles.ChosenTreatments3,'String',[]);
    end
    set(handles.Readouts,'String',[]);
%    set(handles.Readouts,'String',fields.DV.Value);
    set(handles.ChosenReadouts,'String',fields.DA.Value);
    guidata(hObject,handles);
    enableButtons(handles);
catch
    errordlg(['Problems loading file ' handles.FileWithData]);
    handles.SavedFileExist = false;
    handles.FileWithData = handles.OldFileWithData;
    handles.DAtoDVHash = oldDAtoDVHash;
end
guidata(hObject, handles);

