function varargout = GuiMain(varargin)
% GuiMain coordinates the rest of GUIS related to the DataFlow processing
%
% varargout = GuiMain(varargin)
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = optional project or compendium
%
%
% OUTPUTS:
%
% varargout = the created project
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  Project = GuiMain()
%
%--------------------------------------------------------------------------
% TODO:
%
% - Validate "data" structures when appending to same compendium
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
    'gui_OpeningFcn', @GuiMain_OpeningFcn, ...
    'gui_OutputFcn',  @GuiMain_OutputFcn, ...
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


%% --- Executes just before GuiMain is made visible.
function GuiMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiMain (see VARARGIN)


% Add new fields
handles.EmptyProjectName = '<No compendia exist>';
set(handles.ChooseCompendium,'String',{handles.EmptyProjectName},'Value',1);
handles.EmptyCompendiumName = '<No arrays exist>';
set(handles.ListOfCubes,'String',{handles.EmptyCompendiumName},'Value',1);
handles.CompInd =1;%[];
handles.Project=struct('Name','Project','Info','','Compendium',...
    struct('Name',{},'Info',{},'data',{}));
switch numel(varargin)
    case 0
    case 1
        data = varargin{1};
        if ~isstruct(data)
            error('Input argument must be a Project or Compendium')
        end
        if isfield(data, 'Compendium')
            % It's a project; use setParameters to set fields
            handles.Project = setParameters(handles.Project, data);
        elseif isfield(data, 'data')
            handles.Project.Compendium = setParameters(handles.Project.Compendium, data);
        else
            error('Input argument must be a Project or Compendium');
        end
        UpdateCompendiumList(handles);
    otherwise
        error('Unexpected number of input arguments')
end

% Choose default command line output for GuiMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GuiMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GuiMain_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if nargout>0
    handles.uiwait = true;
    guidata(hObject, handles);
    uiwait;
    handles = guidata(hObject);
    varargout{1} = handles.Project;
    delete(hObject);
else
    handles.uiwait = false;
    guidata(hObject, handles);
end
%%
function filename = getsomefile(fhandle,filter,titleText)
if ~exist('titleText','var')
    titleText = 'Pick a file';
end
oldDir = pwd;
% Restore data directory, if present
persistent dataDir
if ~isempty(dataDir)
    cd(dataDir);
end
[FileName,PathName,FilterIndex] = fhandle(filter,titleText);
if isnumeric(FileName) && FileName == 0
    % User cancelled
    filename = 0;
    return
end
filename=[PathName FileName];
dataDir = PathName;
cd(oldDir);
%%
function filename = getfile(varargin)
filename = getsomefile(@uigetfile,varargin{:});

%%

function filename = getnewfile(varargin)
filename = getsomefile(@uiputfile,varargin{:});

% --- Executes on button press in LoadFromWiki.
function LoadFromWiki_Callback(hObject, eventdata, handles)
Project = [];
Compendium = [];

UrlList='https://pipeline.med.harvard.edu/sandbox/index.php/Special:SBW_API?method=list_raw_data';
try
    fileName = GuiLoadDataFileWWW(UrlList);
catch
    errordlg(' Unable to download files from wiki.');
    return
end
if isempty(fileName)
    return
end
handles.SavedMIDASFileName=fileName;
Compendium=GuiMidasImporter(handles.SavedMIDASFileName);
LoadCompendium(hObject,handles,Project,Compendium)
%%
function CallImporter_Callback(hObject, eventdata, handles)
Project = [];
Compendium = [];

% Ask user for file to load
handles.FileName = getfile({'*.csv;*.xls;*.mat'}, ...
    'Select a MIDAS (.CSV) file, a BioPlex (.XLS) file, or a Matlab (.MAT) file.');
if isnumeric(handles.FileName) && handles.FileName == 0
    % User cancelled
    return
end
[filePath, fileName, fileExt] = fileparts(handles.FileName);
if strcmp(fileName(1:2),'MD') %switch lower(fileExt)
    %case {'.csv', '.xls'}
    %switch fileExt
    %case '.csv'
    % add DA time columns if DA:ALL exists in dataset
    oldfilename = handles.FileName;
    newfilename = ConvertDAALLtoMIDAS(oldfilename);
    % For now, assume CSV is a Midas file
    % Compendium=GuiMidasImporter(handles.FileName);
    Compendium=GuiMidasImporter(newfilename);
    %case '.xls'
elseif strcmp(fileName(1:2),'BD')
    % For now, assume XLS is a BioPlex file
    Message='You have selected a Bioplex File. Choose now a template file with the layout of the plate.';
    Que=questdlg(Message,'','OK','Cancel','OK');
    if strcmp(Que,'Cancel')
        return
    end
    handles.DescriptionFileName = getfile({'*.csv'}, 'Pick a BioPlex description file.');
    if isnumeric(handles.DescriptionFileName) && handles.DescriptionFileName == 0
        % User cancelled
        return
    end
    Message='Choose now a filename to save the MIDAS file';
    Que=questdlg(Message,'','OK','Cancel','OK');
    if strcmp(Que,'Cancel')
        return
    end
    handles.SavedMIDASFileName = getnewfile('*.csv', 'Choose a name to save your MIDAS file');
    
    if isnumeric(handles.SavedMIDASFileName) && handles.SavedMIDASFileName == 0
        % User cancelled
        return
    end
    bioplex2midas(handles.FileName, handles.DescriptionFileName, handles.SavedMIDASFileName);
    Compendium=GuiMidasImporter(handles.SavedMIDASFileName);
    %end
    if isempty(Compendium.data)
        return
    end
    % case '.mat'
elseif strcmp(fileExt,'.mat')
    % Load a MAT file
    [Project, Compendium] = loadMatFile(handles);
else % we try midas importer, if it does not work, we ask if it is a bioplex
    try
        oldfilename = handles.FileName;
        newfilename = ConvertDAALLtoMIDAS(oldfilename);
        Compendium=GuiMidasImporter(newfilename);
    catch
    Choice = questdlg('Which importer would you like to start?','Importer Question','MIDAS','BioPlex','MIDAS');
    switch Choice
        case 'MIDAS'
            oldfilename = handles.FileName;
            newfilename = ConvertDAALLtoMIDAS(oldfilename);
            Compendium=GuiMidasImporter(newfilename);
        case 'BioPlex'
            Message='Choose now a template file with the layout of the plate.';
            Que=questdlg(Message,'','OK','Cancel','OK');
            if strcmp(Que,'Cancel')
                return
            end
            handles.DescriptionFileName = getfile({'*.csv'}, 'Pick a description file.');
            if isnumeric(handles.DescriptionFileName) && handles.DescriptionFileName == 0
                % User cancelled
                return
            end
            Message='Choose now a filename to save the MIDAS file';
            Que=questdlg(Message,'','OK','Cancel','OK');
            if strcmp(Que,'Cancel')
                return
            end
            handles.SavedMIDASFileName = getnewfile('*.csv', 'Choose a name to save your MIDAS file');
            
            if isnumeric(handles.SavedMIDASFileName) && handles.SavedMIDASFileName == 0
                % User cancelled
                return
            end
            bioplex2midas(handles.FileName, handles.DescriptionFileName, handles.SavedMIDASFileName);
            Compendium=GuiMidasImporter(handles.SavedMIDASFileName);
            %end
            if isempty(Compendium.data)
                return
            end
    end
    end
end
%end
LoadCompendium(hObject,handles,Project,Compendium)

function LoadCompendium(hObject,handles,Project,Compendium)
% Load new data into handles and GUI
if ~isempty(Project) % Load project
    % Automatically load if Project is empty
    if numel(handles.Project.Compendium) == 1 && ...
            isempty(handles.Project.Compendium.data)
        choice='Replace';
    else
        choice = questdlg(...
            { 'Would you like to:',...
            'Replace the existing Project',...
            'Add the loaded Project''s Compendia to the existing Project' }, ...
            'Replace Project?', ...
            'Replace', 'Add to Project', 'Replace');
    end
   
    
    
    switch choice                
        case 'Replace'
            handles.Project = Project;
            set(handles.ChooseCompendium,'Value',1);
            handles.CompInd = 1;
        case 'Add to Project'
            nCompendia = numel(Project.Compendium);
            handles.Project.Compendium(end+1:end+nCompendia) = ...
                Project.Compendium;
        case 0
            return
        otherwise
            warning('Unexpected selection choice for Replace Compendium dialog.');
    end
elseif ~isempty(Compendium) % Load compendium
    % Automatically overwrite if current Project is empty
    if isempty(handles.Project.Compendium)
        choiceRep='Replace';
    else
        % Now see if we need to overwrite or append the compendium
        choiceRep = 'Add';
        if ~isempty(handles.Project.Compendium(handles.CompInd).data)
            choiceRep=questdlg(...
                { 'A Compendium already exists. Would you like to:',...
                'Replace the existing Compendium',...
                'Add the new data?'}, ...
                'Replace Compendium?', ...
                'Replace', 'Add','?','?');
            
            if   strcmp(choiceRep, '?')
                message=[' In Datarail, a Project is a set of Compendia. '...
                    'You can add the Compendium you just loaded to the current'...
                    'Project as an independent Compendium or replace the existing one.'];
                
                choiceRep=questdlg(...
                    { [message ' So would you like to:',...
                    'Replace the existing Compendium'],...
                    'Add the new data?'}, ...
                    'Replace Compendium?', ...
                    'Replace', 'Add','Add');                
            end
            
        end
    end
    switch choiceRep
        case 'Replace'
            handles.Project.Compendium(handles.CompInd) = Compendium;
        case 'Add'
            if numel(Compendium.data) == 1
                % Allow appending only if there's a single data array
                choice = questdlg(...
                    { 'How exactly would you like to add the new data?',...
                    'Append to the first cube and refresh the Compendium',...
                    'Add the loaded Compendium''s data to the existing Compendium', ...
                    'Add the new Compendium to the Project' }, ...
                    'How to add?', ...
                    'Append', 'Add to Compendium', 'Add to Project', 'Add to Project');
            else
                choice = questdlg(...
                    { 'How exactly would you like to add the new data?',...
                    'Append to the first cube and refresh the Compendium',...
                    'Add the loaded Compendium''s data to the existing Compendium', ...
                    'Add the new Compendium to the Project' }, ...
                    'How to add?', ...
                    'Add to Compendium', 'Add to Project', 'Add to Project');
            end
            switch choice
                case  'Append'
                    % append
                    separateReps = questdlg( ...
                        { 'Would you like to keep replicates separate when joining the arrays?', ...
                        'If you select "Yes", replicates in the first array will not overlap' ...
                        'with replicates in the second array. If you select "No", new data ', ...
                        'will be added at the first available replicate.'}, ...
                        'Separate replicates?', ...
                        'Yes', 'No', 'Yes');
                    if isempty(separateReps) || strcmpi('Yes', separateReps)
                        concat = true;
                    else
                        concat = false;
                    end
                    joinParameters = struct('Concatenate', concat);
                    handles.Project.Compendium(handles.CompInd).data(1) = ...
                        joinArrays([handles.Project.Compendium(handles.CompInd).data(1) Compendium.data], ...
                        joinParameters);
                    refreshParameters = struct('useStoredFunctions', false);
                    handles.Project.Compendium(handles.CompInd) = ...
                        RefreshCompendium(handles.Project.Compendium(handles.CompInd), ...
                        refreshParameters);
                    % refresh
                case 'Add to Compendium'
                    nData = numel(Compendium.data);
                    handles.Project.Compendium(handles.CompInd).data(end+1:end+nData) = ...
                        Compendium.data;
                case 'Add to Project'
                    handles.Project.Compendium(end+1) = Compendium;
                    % Set current compendium to newly added compendium
                    handles.CompInd = numel(handles.Project.Compendium);
                    set(handles.ChooseCompendium, 'Value', handles.CompInd);
                case 0
                    return
                otherwise
                    warning('Unexpected selection choice for Replace Compendium dialog.');
            end
    end
else
    warning('No Project or Compendium was loaded.');
end
UpdateCompendiumList(handles);
guidata(hObject,handles);

%%
function CallPlotAllSignalsCompact_Callback(hObject, eventdata, handles)
% if ~isnumeric(handles.Project.Compendium(handles.CompInd).data(i).Labels(2).Value)
%     warndlg('The plotting function only works with data in the canonical form');
%     return
% end
GuiPlotAllSignalsCompact(handles.Project.Compendium(handles.CompInd), ...
    @(data)PlotExporter(hObject,handles,data),get(handles.ListOfCubes,'Value'));

function PlotExporter(hObject, handles, data)
% Function to add plot pseudo-arrays from GuiPlotAllSignalsCompact
handles.Project.Compendium(handles.CompInd).data(end+1) = data;
guidata(hObject, handles);
UpdateCompendiumList(handles);
%%

function CallCreateCube_Callback(hObject, eventdata, handles)
warnmsg = '';%'GuiCreateCube failed to return data.';
notifier = GuiNotifier('figure', hObject, ...
    'notifyFunc', @(ho,e,h,ou) NotifyFunc(ho,e,h,ou,warnmsg));
GuiCreateDataCube(handles.Project.Compendium(handles.CompInd),...
    get(handles.ListOfCubes,'Value'), notifier);

%%
function DeleteCube_Callback(hObject, eventdata, handles)
Cube2delete=get(handles.ListOfCubes,'Value');
TakeIt=questdlg(...
    sprintf(['Delete Cube ' handles.Project.Compendium(handles.CompInd).data(Cube2delete).Name '? \n This may lead to consistency problems if other cubes depend on this one.']),...
    'Delete Cube? ',    'Yes','No','No');
if strcmp(TakeIt,'Yes')
    if numel(handles.Project.Compendium(handles.CompInd).data)==1
        % delete Compendium
        handles.Project.Compendium(handles.CompInd) = [];
    else
        handles.Project.Compendium(handles.CompInd).data(Cube2delete) = [];
    end
    UpdateCompendiumList(handles);
    guidata(hObject,handles);
else
    return
end
%%
function ExploreData_Callback(hObject, eventdata, handles)
try
    % Create a new variable in the workspace
    whoList = evalin('base', 'who');
    varName = genvarname('Compendium', whoList);
    assignin('base',varName,handles.Project.Compendium(handles.CompInd));
    f = warning(['The displayed variable ' varName ' has been created in the base workspace.'], '');
    evalin('base',['openvar ' varName]);
    PlotCubesStructure(handles.Project.Compendium(handles.CompInd));
catch
    warndlg('No data cube loaded');
end

%%
function ListOfCubes_Callback(hObject, eventdata,handles)

function ListOfCubes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SaveData_Callback(hObject, eventdata, handles)
choice=questdlg('Do you wish to save the entire Project or the selected Compendium?. The Compendium is the set of Arrays you are working on now. The Project is a set of Compendia.',...
    'Select save type','Project', 'Compendium', 'Project');
if choice == 0
    return
end
[handles.SavedFile.Name, handles.SavedFile.PathName, handles.SavedFile.FilterIndex]=...
    uiputfile('*.mat', 'Choose a file name to save your data');
if handles.SavedFile.Name == 0
    % user cancelled
    return
end
switch choice
    case 'Compendium'
        Compendium=handles.Project.Compendium(handles.CompInd);
        save(fullfile(handles.SavedFile.PathName,handles.SavedFile.Name), 'Compendium');
    case 'Project'
        Project = handles.Project;
        save(fullfile(handles.SavedFile.PathName,handles.SavedFile.Name), 'Project');
end


%% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if handles.uiwait
        uiresume;
    else
        delete(hObject);
    end
catch
    delete(hObject);
end


function MultRegression_Callback(hObject, eventdata, handles)
notifier = GuiNotifier('figure', hObject, 'notifyFunc', @MlrPlsrNotifier);
GuiMultipleReg(handles.Project, notifier);

function PLSR_Callback(hObject, eventdata, handles)
notifier = GuiNotifier('figure', hObject, 'notifyFunc', @MlrPlsrNotifier);
GuiPLSR(handles.Project, notifier);

function MlrPlsrNotifier(hObject, eventdata, handles, output)
handles.Project=output;
guidata(hObject,handles);
UpdateCompendiumList(handles);

function ChooseCompendium_Callback(hObject, eventdata, handles)
handles.CompInd=get(handles.ChooseCompendium,'Value');
guidata(hObject,handles);
UpdateCompendiumList(handles);

function ChooseCompendium_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ExportData_Callback(hObject, eventdata, handles)
CubeNumber=get(handles.ListOfCubes,'Value');
ListCubes=get(handles.ListOfCubes,'String');
if numel(ListCubes)==1
    CubeName=ListCubes;
else
    CubeName=ListCubes{CubeNumber};
end

Question=['You have selected the cube ', CubeName, ' . In which format would you like to save it?'];
ExportType=questdlg(Question,'Format?','MIDAS','PottersWheel','CellNetAnalyzer','MIDAS');
switch ExportType
    case 'MIDAS'
        Parameters.Delimiter=',';
        Parameters.OutputFile=getnewfile('*.csv', 'Choose a name to save your MIDAS file');
        Parameters.Labels=handles.Project.Compendium(handles.CompInd).data(CubeNumber).Labels;
        exportDataCubeToMidas(handles.Project.Compendium(handles.CompInd).data(CubeNumber).Value, Parameters);
    case 'PottersWheel'
        Parameters.Delimiter='\t';
        Parameters.OutputFile=getnewfile('*.csv', 'Choose a name to save your PottersWheel file');
        Parameters.Labels=handles.Project.Compendium(handles.CompInd).data(CubeNumber).Labels;
        exportDataCubeToPottersWheel(handles.Project.Compendium(handles.CompInd).data(CubeNumber).Value, Parameters);
    case 'CellNetAnalyzer'
        Compendium=handles.Project.Compendium(handles.CompInd);
        %check for CNA cube
        CNACubes=[];
        for i=1:numel(Compendium.data)
            Code=Compendium.data(i).Code;
            if ~isempty(Code)&&~isstr(Code)
                Code=func2str(Code);
            end
            if ~isempty(Code)&&strcmp(Code,'CreateCNAData')
                CNACubes=[CNACubes i];
            end
        end
        if isempty(CNACubes)
            Question=['The compendium has no CNA Data Cube, create one?'];
            CreateC=questdlg(Question,'Create Cube?','Yes','No','Yes');
            if strcmp(CreateC,'Yes')
                handles.Project.Compendium(handles.CompInd)=GuiCreateDataCube(handles.Project.Compendium(handles.CompInd),get(handles.ListOfCubes,'Value'));
                set(handles.ListOfCubes,'String',{handles.Project.Compendium(handles.CompInd).data.Name})
                guidata(hObject,handles);
            else
                return
            end
        else
            if   ~isempty(find(CubeNumber==CNACubes))
                CNACub=  handles.Project.Compendium(handles.CompInd).data(CubeNumber);
                [SavedFile.Name, SavedFile.PathName, SavedFile.FilterIndex]=...
                    uiputfile('*.mat', 'Choose a file name to save your CNA data');
                if SavedFile.Name == 0
                    % user cancelled
                    return
                end
                %Compendium=handles.Project.Compendium(handles.CompInd);
                save(fullfile(SavedFile.PathName,SavedFile.Name), 'CNACub');
            else
                CubeNames='';
                for i=1:numel(CNACubes)
                    CubeNames=[CubeNames ' \n ' Compendium.data(CNACubes(i)).Name];
                end
                %a=questdlg([ num2str(numel(CNACubes)) ' cubes with data were found. The whole compendium will be save in a mat file'],'','OK','Cancel','OK');
                messag=[ num2str(numel(CNACubes)) ' cubes with data in CNA format were found: \n ' CubeNames...
                    '\n  However, you have not selected any of them. Select one of them before pressing the export button']
                a=warndlg(sprintf(messag));
                if strcmp(a,'OK')
                    return
                end
            end
        end
end

function UpdateCompendiumList(handles)
if isempty(handles.Project.Compendium)
    set(handles.ChooseCompendium,'String',{handles.EmptyProjectName},'Value',1);
    set(handles.ListOfCubes,'String',{handles.EmptyProjectName},'Value',1);
    disableControls(handles);
else
    set(handles.ChooseCompendium,'String',{handles.Project.Compendium.Name});
    set(handles.ListOfCubes,'String',{handles.Project.Compendium(handles.CompInd).data.Name});
    enableControls(handles);
    nCubes = numel(handles.Project.Compendium(handles.CompInd).data);
    iCube = get(handles.ListOfCubes, 'Value');
    if iCube > nCubes
        set(handles.ListOfCubes, 'Value', nCubes);
    end
end

function [] = enableControls(handles)
set(handles.ListOfCubes,'Enable','on');
set(handles.CallCreateCube, 'Enable', 'on');
set(handles.DeleteCompendium, 'Enable', 'on');
set(handles.RenameCompendium, 'Enable', 'on');
set(handles.DeleteCube, 'Enable', 'on');
set(handles.RenameCube, 'Enable', 'on');
set(handles.SaveData, 'Enable', 'on');
set(handles.ExportData, 'Enable', 'on');
set(handles.ExploreData, 'Enable', 'on');
set(handles.CallPlotAllSignalsCompact, 'Enable', 'on');
set(handles.MultRegression, 'Enable', 'on');
set(handles.RunCNI, 'Enable', 'on');
set(handles.PLSR, 'Enable', 'on');
set(handles.Bayesian, 'Enable','on');

function [] = disableControls(handles)
set(handles.ListOfCubes,'Enable','off');
set(handles.CallCreateCube, 'Enable', 'off');
set(handles.DeleteCompendium, 'Enable', 'off');
set(handles.RenameCompendium, 'Enable', 'off');
set(handles.RenameCube, 'Enable', 'off');
set(handles.DeleteCube, 'Enable', 'off');
set(handles.SaveData, 'Enable', 'off');
set(handles.ExportData, 'Enable', 'off');
set(handles.ExploreData, 'Enable', 'off');
set(handles.CallPlotAllSignalsCompact, 'Enable', 'off');
set(handles.MultRegression, 'Enable', 'off');
set(handles.RunCNI, 'Enable', 'off');
set(handles.PLSR, 'Enable', 'off');
set(handles.Bayesian, 'Enable','off');


function [Project, Compendium] = loadMatFile(handles)
Project = [];
Compendium = [];
loaded = load(handles.FileName);
varNames = fieldnames(loaded);
projectFields = fieldnames(handles.Project);
numProjectFields = numel(projectFields);
compendiumFields = fieldnames(handles.Project.Compendium);
numCompendiumFields = numel(compendiumFields);
CompendiumProjectList = {};
for i=1:numel(varNames)
    varName = varNames{i};
    var = loaded.(varName);
    % Look for a structure with a data field
    if isstruct(var)
        varFields = fieldnames(var);
        numVarFields = numel(varFields);
        if numVarFields == numCompendiumFields && ...
                all(strcmp(compendiumFields, varFields))
            CompendiumProjectList{end+1} = [ varName ' (Compendium)' ];
        elseif numVarFields == numProjectFields && ...
                all(strcmp(projectFields, varFields))
            CompendiumProjectList{end+1} = [ varName ' (Project)' ];
        elseif isfield(var, 'data')
            % MAT file may contain a variant of a Compendium structure
            % Replace with consistent structure
            warning(['Variable %s appears to be a variant of a Compendium.\n'...
                'Extra fields will be ignored.'], varName);
            loaded.(varName) = copyFields(var, compendiumFields);
            % order data fields
            emptyCube = createDataCube;
            loaded.(varName).data = orderfields(loaded.(varName).data, emptyCube);
            CompendiumProjectList{end+1} = [ varName ' (Compendium)' ];
        elseif isfield(var, 'Compendium')
            % MAT file may contain a variant of a Project structure
            % Replace with consistent structure
            warning(['Variable %s appears to be a variant of a Project.\n'...
                'Extra fields will be ignored.'], varName);
            loaded.(varName) = copyFields(var, projectFields);
            % order data fields
            emptyCube = createDataCube;
            for j=1:numel(loaded.(varName).Compendium)
                loaded.(varName).Compendium(j).data = orderfields(loaded.(varName).Compendium(j).data, emptyCube);
            end
            CompendiumProjectList{end+1} = [ varName ' (Project)' ];
        end
    end
end
% Automatically select variable if there's only one Compendium/Project in the file
if numel(CompendiumProjectList) == 0
    warndlg('No valid Projects or Compendia were found in this file.');
    return
elseif numel(CompendiumProjectList) == 1
    item = CompendiumProjectList{1};
else
    selection = listdlg('ListString', CompendiumProjectList, ...
        'PromptString', 'Select the Compendium or Project you would like to load.', ...
        'SelectionMode', 'Single', ...
        'Name', 'Select a Compendium or Project',...
        'ListSize', [320 100]);
    if isempty(varName) || isempty(selection)
        % User cancelled
        return
    end
    item = CompendiumProjectList{selection};
end
% Split selection into varName and type (compendium or project)
tokens = regexp(item, '^(.*?) \((.*?)\)$', 'tokens');
[varName, varType] = deal(tokens{1}{:});

switch varType
    case 'Compendium'
        Compendium = loaded.(varName);
    case 'Project'
        Project = loaded.(varName);
    otherwise
        warning('Unexpected variable type');
end




function [] = NotifyFunc(hObject, eventdata, handles, output, warnmsg)
if isempty(output)
    if exist('warnmsg', 'var') && ~isempty(warnmsg)
        warndlg(warnmsg)
    end
    return
end
handles.Project.Compendium(handles.CompInd)=output;
guidata(hObject,handles);
UpdateCompendiumList(handles);


% --- Executes on button press in RenameCube.
function RenameCube_Callback(hObject, eventdata, handles)
% hObject    handle to RenameCube (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cubeIndex = get(handles.ListOfCubes,'Value');
oldName = handles.Project.Compendium(handles.CompInd).data(cubeIndex).Name;
newNameCell = inputdlg(...
    sprintf('Enter a new name for the array '),...
    'Rename array', 1, {oldName});
if ~isempty(newNameCell) && ~isempty(newNameCell{1})
    newName = newNameCell{1};
    handles.Project.Compendium(handles.CompInd).data(cubeIndex).Name = newName;
    guidata(hObject,handles);
    UpdateCompendiumList(handles);
    guidata(hObject,handles);
end


% --- Executes on button press in DeleteCompendium.
function DeleteCompendium_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteCompendium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TakeIt=questdlg(...
    sprintf(['Delete Compendium ' handles.Project.Compendium(handles.CompInd).Name '? \n This may lead to consistency problems if other cubes depend on this one.']),...
    'Delete Compendium? ',    'Yes','No','No');
if strcmp(TakeIt,'Yes')
    handles.Project.Compendium(handles.CompInd) = [];
    if handles.CompInd > numel(handles.Project.Compendium)
        handles.CompInd = numel(handles.Project.Compendium);
        set(handles.ChooseCompendium,'Value', handles.CompInd);
    end
    UpdateCompendiumList(handles);
    guidata(hObject,handles);
else
    return
end

% --- Executes on button press in RenameCompendium.
function RenameCompendium_Callback(hObject, eventdata, handles)
% hObject    handle to RenameCompendium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

oldName = handles.Project.Compendium(handles.CompInd).Name;
if isempty(oldName)
    oldName = '';
end
newNameCell = inputdlg(...
    sprintf('Enter a new name for the compendium.'),...
    'Rename compendium', 1, {oldName});
if ~isempty(newNameCell) && ~isempty(newNameCell{1})
    newName = newNameCell{1};
    handles.Project.Compendium(handles.CompInd).Name = newName;
    guidata(hObject,handles);
    UpdateCompendiumList(handles);
    guidata(hObject,handles);
end

% --- Executes on button press in RunCNI.
function RunCNI_Callback(hObject, eventdata, handles)
warnmsg = '';%'CNI failed to return data.';
try
    notifier = GuiNotifier('figure', hObject, ...
        'notifyFunc', @(ho,e,h,ou) NotifyFunc(ho,e,h,ou,warnmsg));
    GuiBooleanAnalysis(handles.Project.Compendium(handles.CompInd),notifier);
catch
    try
        GuiBooleanAnalysis(handles.Project.Compendium(handles.CompInd), notifier);
    catch
        try
            savedPwd = pwd;
            dataRailPaths = startDataRail;
            dataRailBase = dataRailPaths{1};
            cd(fullfile(dataRailBase, 'CNO'));
            startCNO;
            cd(savedPwd);
            GuiBooleanAnalysis(handles.Project.Compendium(handles.CompInd), notifier);
        catch
            cd(savedPwd);
            warndlg(' You do not seem to have CellNetOptimizer. Please go to http://www.cdpcenter.org/resources/software/cellnetoptimizer/ to download it. ')
            return
        end
    end
end

% --- Executes on button press in Bayesian.
function Bayesian_Callback(hObject, eventdata, handles)

notifier = GuiNotifier('figure', hObject, 'notifyFunc', @MlrPlsrNotifier);
GuiBayesian(handles.Project,handles.CompInd, get(handles.ListOfCubes,'Value'), notifier);
