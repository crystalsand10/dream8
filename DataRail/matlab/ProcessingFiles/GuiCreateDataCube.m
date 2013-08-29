function varargout = GuiCreateDataCube(varargin)
% GuiCreateDataCube helps you to create a data cube applying a certain transformation to another cube
%
%   varargout = GuiCreateDataCube(varargin)
%
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = the Project and the index of the  input data cube
%
%
% OUTPUTS:
%
% varargout = the created  data cube  
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  NewProject = GuiCreateDataCube(Project, [IndexCube])
%
%--------------------------------------------------------------------------
% TODO:
%
% - Add more transforming functions
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
%% Check if first argument is a callback function
iscallback = false;
if nargin && ischar(varargin{1})
    callback = varargin{1};
    try
        fh = str2func(callback);
        fhinfo = functions(fh);
        if strcmp(fhinfo.type, 'scopedfunction')
            iscallback = true;
        end
    catch
    end
end

if ~iscallback
    %% Check nargout and assign default return value
    if nargout > 0
        varargout = cell(nargout,1);
        if nargout > 1
            errordlg('Only one output argument is returned.');
            return
        end
    end

    %% Check remaining arguments
    switch numel(varargin)
        case 0
            warndlg('Must pass a Compendium as the first argument (until GuiLoad is implemented).');
            return
            %load data
        case 1
            if isstruct(varargin{1})
                Project = varargin{1};
                IndexCube=1;
            else
                warndlg('you have to input a project as a structure');
                return
            end
        otherwise
            Project = varargin{1};
            IndexCube = varargin{2};
            % Check Project
            try
                NameList = {Project.data.Name};
            catch
                warndlg('you have to input a project as a structure');
                return
            end
            % Check IndexCube
            try
                thisData = Project.data(IndexCube);
                if numel(thisData) ~= 1
                    error('IndexCube must be a scalar');
                end
            catch
                warndlg('the second argument must be a scalar number choosing a cube ');
                return
            end
    end
    varargin(1:2) = {Project, IndexCube};
end

%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiCreateDataCube_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiCreateDataCube_OutputFcn, ...
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

function [] = defaultNotifier(hObject, eventdata, handles, output)
% Create a new variable in the workspace
whoList = evalin('base', 'who');
varName = genvarname('Compendium', whoList);
assignin('base',varName,output);
warning(['The variable ' varName ' has been created in the base workspace.'], '');


%% --- Executes just before GuiCreateDataCube is made visible.
function GuiCreateDataCube_OpeningFcn(hObject, eventdata, handles, Project, IndexCube, notifier)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiCreateDataCube (see VARARGIN)

% Choose default command line output for GuiCreateDataCube
handles.output = hObject;
% Keep track of DefaultCubeName
handles.DefaultCubeName = 'Choose a name';
set(handles.ChooseCubeName, 'String', handles.DefaultCubeName);
% Automatically name the cube, until the user changes it (see ChooseCubeName_Callback) 
handles.AutoNameCube = true;
handles.Compendium = Project;
handles.Parameters={};
handles.LastFunctionChosen = get(handles.ChooseFunction,'Value');
handles.PossibleFunctions=alphabeticalSort({'collapseDataCube','createSubcube','GetConcentrations',... %'NormalizeTotalProt',...                           
                           'RemoveInputEqOutput',...%'RemoveBasalLevel',...
                           'ExpandCubeto2D','GetTimeCompressed','GetRelative',...                           
                           'CreateCNAData','CreateCNOData',...'Booleanizer','CubicalizeCNAArray',...
                           'joinCubes','averageReplicates','centerAndScale','Normalize',...
                           'Discretize','Threshold','CustomMath'});
set(handles.ChooseFunction,'Value',6);% =>createSubcube
set(handles.ChooseFunction,'String',handles.PossibleFunctions);
set(handles.ChooseSourceData,'String',{handles.Compendium.data.Name});
set(handles.ChooseSourceData,'Value',IndexCube);
if ~exist('notifier', 'var')
    handles.notifier = GuiNotifier('notifyFunc', @defaultNotifier);
else
    handles.notifier = notifier;
end
guidata(hObject,handles);


%% --- Outputs from this function are returned to the command line.
function varargout = GuiCreateDataCube_OutputFcn(hObject, eventdata, handles) 

%%
function ChooseCubeName_Callback(hObject, eventdata, handles)
%handles.CubeName=get(hObject, 'String');
%set(handles.ChooseCubeName,'String',handles.CubeName);
%guidata(hObject,handles);

% No longer automatically name the cube
handles.AutoNameCube = false;
guidata(hObject,handles);

function ChooseCubeName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%
function ChooseInformation_Callback(hObject, eventdata, handles)
%handles.CubeInformation=get(hObject, 'String');
%set(handles.ChooseInformation,'String',handles.CubeInformation);
%guidata(hObject,handles);

function ChooseInformation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function CreateCube_Callback(hObject, eventdata, handles)
if strmatch(get(handles.ChooseCubeName,'String'),handles.DefaultCubeName,'exact')
    warndlg('Please name the cube before you continue.');
    return
end
if strmatch(get(handles.ChooseCubeName,'String'),{handles.Compendium.data.Name},'exact')
    warndlg('The name is already used for another cube');
    return
end
IndexCube = get(handles.ChooseSourceData,'Value');
Parameters = handles.Parameters;
% Require parameters for certain functions
if isempty(Parameters) || ...
        ( isstruct(Parameters) && numel(fieldnames(Parameters))==0 )
    if strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'CreateCNAData')||...            
            strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'GetTimeCompressed')||...
            strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'RemoveInputEqOutput')||...
            strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'CubicalizeCNAArray')||...
            strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'Threshold')||...
            strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'ExpandCubeto2D')
        warndlg(sprintf('This function explicitly requires parameters. \n Press the Change Parameters button.'))
        return
    end
end


% Booleanizer
if strcmp(handles.PossibleFunctions{get(handles.ChooseFunction,'Value')},'Booleanizer')&&...
         size(handles.Compendium.data(IndexCube).Value,2)>3
    Question=['In the current implementation of Booleanizer, the data cube should have 2 or 3 time points. ',... 
              'Data values at the 4th time point and later will be replaced with NaNs.'...
              'You may want to compress the time dimensions so that there are 3 time points representing initial, early, and late responses.'...
              '\nCreate anyway?'];
    DoBool=questdlg(sprintf(Question),...
                    'Too many time poinst','Yes','No','No');
    if strcmp(DoBool,'No')
        return
    end
    
end


%% Create cube for different cases
% CreateCNAData/CreateCNOData-create 2 cubes, consider separately
%  adjust results from GuiCreateCNAData to CreateCNOData

% not using the CNAGui anymore, per MKMorris suggestion
%{ 
if strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'CreateCNOData')
    handles.Parameters.dim4=handles.Parameters.dim3;
    handles.Parameters.dim3=handles.Parameters.dim2;
    handles.Parameters=rmfield(handles.Parameters,'dim2');   
end
%}

if strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'CreateCNOData')&&isempty(Parameters)
   Parameters=GetParamsCNO(handles.Compendium.data(IndexCube).Labels);
end

if strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'CreateCNAData')&&isfield(handles.Parameters,'GenerateAll')||...
   strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'CreateCNOData')&&isfield(handles.Parameters,'GenerateAll')      
    if isfield(handles.Parameters,'GenerateAll')&& handles.Parameters.GenerateAll
        handles.Parameters = rmfield(handles.Parameters,'GenerateAll');
            for cell=1:numel(handles.Parameters.Labels(1).Value)
                Parameters.DimFixed=[1 cell];
                handles.Compendium.data(end+1)= createDataCube(...
                    'Name', [get(handles.ChooseCubeName,'String') '-' handles.Parameters.Labels(1).Value{cell}], ...
                    'Info', get(handles.ChooseInformation,'String'),...
                    'Code', handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},...                  
                    'Parameters', Parameters, ...
                     'PrintWarnings',false,...
                    'SourceData', handles.Compendium.data(IndexCube));
            end
    else
          handles.Parameters = rmfield(handles.Parameters,'GenerateAll');      
          handles.Compendium.data(end+1)= createDataCube(...
                    'Name', [get(handles.ChooseCubeName,'String') '-' handles.Parameters.Labels(1).Value{handles.Parameters.DimFixed(2)}], ...
                    'Info', get(handles.ChooseInformation,'String'),...
                    'Code', handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},...                  
                    'Parameters', handles.Parameters, ...
                     'PrintWarnings',false,...
                    'SourceData', handles.Compendium.data(IndexCube));        
    end
% General cases:
elseif isempty(Parameters) || ...
        ( isstruct(Parameters) && numel(fieldnames(Parameters))==0 )
    % Call without Parameters argument
    % gracefully handle change in order of field names
    cube = createDataCube(...
        'Name', get(handles.ChooseCubeName,'String'), ...
        'Info', get(handles.ChooseInformation,'String'),...
        'Code', handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},...
        'SourceData', handles.Compendium.data(IndexCube));
    handles.Compendium.data(end+1) = orderfields(cube, fieldnames(handles.Compendium.data(1)));
elseif strcmp(handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},'CustomMath')
    handles.Compendium.data(end+1)= createDataCube(...
        'Name', get(handles.ChooseCubeName,'String'), ...
        'Info', get(handles.ChooseInformation,'String'),...
        'Code', handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},...
        'Parameters', Parameters, ...
        'SourceData', handles.Compendium.data(IndexCube),...
        handles.Compendium);
else
    % Call with Parameters argument
    handles.Compendium.data(end+1)= createDataCube(...
        'Name', get(handles.ChooseCubeName,'String'), ...
        'Info', get(handles.ChooseInformation,'String'),...
        'Code', handles.PossibleFunctions{ get(handles.ChooseFunction,'Value')},...
        'Parameters', Parameters, ...
        'SourceData', handles.Compendium.data(IndexCube));
end
guidata(hObject,handles);
delete(handles.figure1);

%%
function ChooseFunction_Callback(hObject, eventdata, handles)
FunctionChosen=get(handles.ChooseFunction, 'Value');
handles.FunctionName=handles.PossibleFunctions{FunctionChosen};
% Also need to reset parameters, if function changes
if handles.LastFunctionChosen ~= FunctionChosen
    handles.LastFunctionChosen = FunctionChosen;
    handles.Parameters = {};
end

if handles.AutoNameCube
    % Automatically rename cube
    newCubeName = handles.DefaultCubeName;
    switch handles.FunctionName
        case 'CreateCNAData'
            newCubeName = 'CNAData';
        case 'CreateCNOData'
            newCubeName = 'CNOData';     
        case 'Booleanizer'
            newCubeName = 'Boolean';
        case 'GetRelative'
            newCubeName = 'Relat';
        case 'MaxSignalRelativator'
            newCubeName = 'RelatMax';
        case 'GetTimeCompressed'
            newCubeName = 'TimeC';
        case 'Normalize'
            newCubeName = 'Norm';
        case 'Discretize'
            newCubeName = 'Disc';
        case 'CustomMath'
            newCubeName = 'CMath';
        case 'Threshold'
            newCubeName = 'Thresh';
    end
    set(handles.ChooseCubeName, 'String', newCubeName);
end

guidata(hObject,handles);

function ChooseFunction_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function ChooseSourceData_Callback(hObject, eventdata, handles)

% SourceChosen=get(hObject, 'Value');
% handles.SourceData=handles.Compendium.data(SourceChosen);
% guidata(hObject,handles);

function ChooseSourceData_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function ChangeParameters_Callback(hObject, eventdata, handles)
FunctionList = get(handles.ChooseFunction,'String');
IndexFunction = get(handles.ChooseFunction,'Value');
FunctionName = FunctionList{IndexFunction};

SourceChosen=get(handles.ChooseSourceData, 'Value');
SourceData=handles.Compendium.data(SourceChosen);
% Note: this hides the GUI!
% If the parameter function doesn't accept notifiers, be sure to notify manually!
notifier = GuiNotifier('figure', hObject, ...
    'handlesField', 'Parameters');
switch FunctionName
    case 'joinCubes'
        GuiJoinCubesPars(handles.Compendium, SourceChosen, notifier);
%     case 'NormalizeTotalProt'
%         Preg='Choose MIDAS file with total protein data';
%         [filename,pathname, filterindex] = uigetfile({'*.csv'},Preg);
%         handles.Parameters.filename=fullfile(pathname,filename);
%         handles.Parameters.ImporterParameters=SourceData.Parameters;
%         handles.Parameters.Labels=SourceData.Labels;
%         notify(notifier); % Unhide GUI
    case 'collapseDataCube'
        GuiCollapseDataCube(SourceData, notifier);
    case 'createSubcube'
        GuiCreateSubCube(SourceData, notifier);
    case 'ExpandCubeto2D'
        GuiExpandCubeto2DPars(SourceData.Labels, notifier);
    case 'CreateCNOData'
        handles.Parameters=GetParamsCNO(SourceData.Labels);
    case 'CreateCNAData'
        GuiCreateCNADataPars(SourceData.Labels, notifier);
    case 'RemoveInputEqOutput'
        handles.Parameters.Labels=SourceData.Labels;
        Replacement=questdlg('What do you want to replace the data with, when the input is equal the output?',...
            'Replace?','NaN','Zeros','mean','NaN');
        if strcmp(Replacement,'Zeros')
            handles.Parameters.Replacement=0;
        elseif strcmp(Replacement,'NaN')   
             handles.Parameters.Replacement=NaN;
        else
             handles.Parameters.Replacement=Replacement;
        end
        notify(notifier); % Unhide GUI
     case 'CubicalizeCNAArray'
         notify(notifier); % Unhide GUI
         if strcmp(func2str(SourceData.Code),'CreateCNAData')
             if ~isfield(SourceData.Value,'Results')
                 warndlg('The cube has no CNA results. Choose a different array.')
                 return
             end
             ModelCubeN=inputdlg('Choose a Model Cube');
             if ~isempty(ModelCubeN)
                 handles.Parameters.ModelCube=handles.Compendium.data(str2num(ModelCubeN{1}));
             else
                 return
             end
         else
             warndlg('The source Code has to be created with CreateCNAData. Choose a different array.')
             return
         end
    case 'Booleanizer'
        GuiBooleanizerPars(SourceData, notifier);
    case 'GetRelative'
        handles.Parameters.RefValue=inputdlg('Choose reference Condition');
        notify(notifier); % Unhide GUI
    case 'GetConcentrations'
        warndlg(sprintf('The parameters for GetConcentrations are the calibration curves \n So far only 1 set implemented (saved in calibration_params_cytos.mat)'));
        notify(notifier); % Unhide GUI
    case 'GetTimeCompressed'
        handles.Parameters=GuiChooseTimes(SourceData.Labels, notifier);
%        TimeScales=inputdlg('How many time scales?');
%        NumberTimeScales=str2num(TimeScales{1});
%        for i=1:NumberTimeScales
%            handles.Parameters(i).Name =...
%                inputdlg(sprintf(['Name for time scale t=' num2str(i) '? \n e.g. Early']));
%            Num=inputdlg(sprintf(['Times involved in time scale t=' num2str(i) '? \n e.g. [1 2]']));
%            handles.Parameters(i).Value=str2num(Num{1});
%        end
%{
         question=['This function will collapse the time values \n into 2 (early and late) or 3 (early/mid/late)',...
                   'time ranges. \n \n Select first the times involved in the early events (e.g. 2 or [2 3]'];
         answer=inputdlg(sprintf(question));
         handles.Parameters.EarlyTimes=str2num(answer{1});
         %
         question=['Select now the times for the middle time scale. \n',... 
                   'If you are not considering more than two time scales type []'];
         answer=inputdlg(sprintf(question));
         handles.Parameters.MidTimes=str2num(answer{1});
         %
         question='Finally, select the late time values, e.g. [3 4]';
         answer=inputdlg(sprintf(question));
         handles.Parameters.LateTimes=str2num(answer{1});
%}
    case 'MaxSignalRelativator'
         handles.Parameters.AcrossCells= ...
         questdlg('Relative to all cells types (dim1)?','Choose parameter','Yes','No','Yes');
        notify(notifier); % Unhide GUI
    case 'RemoveBasalLev1el'
        notify(notifier); % Unhide GUI
    case 'averageReplicates'
        handles.Parameters = GuiAverageReplicates(SourceData.Labels, notifier);
    case 'centerAndScale'
        handles.Parameters = GuiCenterAndScale(SourceData.Labels, notifier);
    case 'Normalize'
        handles.Parameters = GuiNormalize(SourceData, notifier, handles);
    case 'Discretize'
        handles.Parameters = GuiDiscretize(SourceData.Labels, notifier, handles);
    case 'CustomMath'
        handles.Parameters = GuiCustomMath(SourceData, notifier, handles);
    case 'Threshold'
        handles.Parameters = GuiBetweenThresh;
    otherwise
         warndlg('Choose first a function to create the cube');
        notify(notifier); % Unhide GUI
end
guidata(hObject,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    handles.notifier(handles.Compendium)
catch
    try
        handles.notifier([]);
    catch
    end
end

function s = alphabeticalSort(s)
s1 = lower(s);
[s1, iSort] = sort(s1);
s = s(iSort);


function  Parameters=GetParamsCNO(Labels)

 Parameters.Labels=Labels;
    Question = 'Create Cube for which conditions?';
    CellTypes= Labels(1).Value;
    %WhichOnes=questdlg(Question,'Create data for which?',{'HepG2','Focus'},'all','all');
    [WhichOnes isok]=listdlg('PromptString',Question,'ListString',CellTypes);
    Parameters.DimFixed=[1 1];
    if numel(WhichOnes)==1
        Parameters.DimFixed(2)=WhichOnes;
    elseif numel(WhichOnes)==numel(CellTypes)
        Parameters.GenerateAll=true;
    else
        warndlg('Please choose one or all');
        [WhichOnes isok]=listdlg('PromptString',Question,'ListString',CellTypes);
        Parameters.DimFixed=[1 1];
        if numel(WhichOnes)==1
            Parameters.DimFixed(2)=WhichOnes;
        elseif numel(WhichOnes)==numel(CellTypes)
            Parameters.GenerateAll=true;
        end
    end
