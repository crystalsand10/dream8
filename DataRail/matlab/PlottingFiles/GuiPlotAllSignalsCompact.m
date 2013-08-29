function varargout = GuiPlotAllSignalsCompact(varargin)
set(0,'defaultuicontrolfontname','Sans Serif');
%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiPlotAllSignalsCompact_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiPlotAllSignalsCompact_OutputFcn, ...
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



%% --- Executes just before GuiPlotAllSignalsCompact is made visible.
function GuiPlotAllSignalsCompact_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiPlotAllSignalsCompact (see VARARGIN)

if numel(varargin) >= 1 && isstruct(varargin{1})
    handles.Project = varargin{1};  
    if numel(varargin) >= 2 && isa(varargin{2}, 'function_handle')
        handles.exporter = varargin{2};
    else
        handles.exporter = @DefaultExporter;
    end
else
    warndlg('you have to input a project as a structure');
   return
end

% default value for handles.figure is empty
handles.figure = [];
handles.Parameters = struct;
handles.SourceData = cell(3,1);

set(handles.PlotData,         'String',{ handles.Project.data(:).Name});
set(handles.PlotData,'Value',varargin{3});
set(handles.RelatData,        'String',{'No cube selected', handles.Project.data(:).Name});
set(handles.BoolData,        'String',{'No cube selected', handles.Project.data(:).Name});
set(handles.ChooseColorModus,'String',{'max','change','refmax','refAUC','cytok'});
set(handles.ChooseColorModus,'Value',1);


%% initialize parameters
index_selectedplot = get(handles.PlotData,'Value');
Labels=handles.Project.data(index_selectedplot).Labels;
Labels=labels2cellstr(Labels);%convert all to cells
set(handles.Dim12exp,'String',{Labels.Name});
set(handles.Dim12exp,'Value',3);
set(handles.Dim22exp,'String',{Labels.Name});
set(handles.Dim22exp,'Value',4);
set(handles.Dim32exp,'String',{Labels.Name});
set(handles.Dim32exp,'Value',5);
set(handles.Dim2Fix,'String',{Labels.Name});
set(handles.Dim2Fix,'Value',1);
set(handles.Dim2FixVal,'String',Labels(1).Value);
set(handles.Dim2FixVal,'Value',1);

set(handles.RefDim1,'String',{'No selected', Labels(1).Value{1:end}});
set(handles.RefDim2,'String',{'No selected', Labels(2).Value{1:end}});
set(handles.RefDim3,'String',{'No selected', Labels(3).Value{1:end}});
set(handles.RefDim4,'String',{'No selected', Labels(4).Value{1:end}});
set(handles.RefDim5,'String',{'No selected', Labels(5).Value{1:end}});
set(handles.RefDim1,'Value',1);
set(handles.RefDim2,'Value',1);
set(handles.RefDim3,'Value',1);
set(handles.RefDim4,'Value',1);
set(handles.RefDim5,'Value',1);

%'smart' default arrays for relative data and boolean based on code used
for i=1:numel(handles.Project.data)
    CodeUsed=handles.Project.data(i).Code;
    try 
        CodeUsed=func2str(CodeUsed);
    end
    if strcmp(CodeUsed,'MaxSignalRelativator')
        set(handles.RelatData,'Value',(i+1));
    elseif strcmp(CodeUsed,'Booleanizer')
        set(handles.BoolData,'Value',(i+1));
    end
end
%%
guidata(hObject, handles);



%% --- Outputs from this function are returned to the command line.
function varargout = GuiPlotAllSignalsCompact_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;



%% ---------Cubes-----
function PlotData_Callback(hObject, eventdata, handles)
% handles.selectedplot = get(handles.PlotData,'Value');
% guidata(hObject,handles);

index_selectedplot = get(handles.PlotData,'Value');
Labels=handles.Project.data(index_selectedplot).Labels;
Labels=labels2cellstr(Labels);%convert all to cells
set(handles.Dim12exp,'String',{Labels.Name});
set(handles.Dim12exp,'Value',3);
set(handles.Dim22exp,'String',{Labels.Name});
set(handles.Dim22exp,'Value',4);
set(handles.Dim32exp,'String',{Labels.Name});
set(handles.Dim32exp,'Value',5);
set(handles.Dim2Fix,'String',{Labels.Name});
set(handles.Dim2Fix,'Value',1);
set(handles.Dim2FixVal,'String',Labels(1).Value);
set(handles.Dim2FixVal,'Value',1);

set(handles.RefDim1,'String',{'No selected', Labels(1).Value{1:end}});
set(handles.RefDim2,'String',{'No selected', Labels(2).Value{1:end}});
set(handles.RefDim3,'String',{'No selected', Labels(3).Value{1:end}});
set(handles.RefDim4,'String',{'No selected', Labels(4).Value{1:end}});
set(handles.RefDim5,'String',{'No selected', Labels(5).Value{1:end}});
set(handles.RefDim1,'Value',1);
set(handles.RefDim2,'Value',1);
set(handles.RefDim3,'Value',1);
set(handles.RefDim4,'Value',1);
set(handles.RefDim5,'Value',1);

%'smart' default arrays for relative data and boolean based on code used
for i=1:numel(handles.Project.data)
    CodeUsed=handles.Project.data(i).Code;
    try 
        CodeUsed=func2str(CodeUsed);
    end
    if strcmp(CodeUsed,'MaxSignalRelativator')
        set(handles.RelatData,'Value',(i+1));
    elseif strcmp(CodeUsed,'Booleanizer')
        set(handles.BoolData,'Value',(i+1));
    end
end
guidata(hObject, handles);

function PlotData_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RelatData_Callback(hObject, eventdata, handles)
% handles.index_selectedrelat = get(handles.RelatData,'Value');
% guidata(hObject,handles);

function RelatData_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BoolData_Callback(hObject, eventdata, handles)
% handles.index_selectedbool = get(handles.BoolData,'Value');
% guidata(hObject,handles);

function BoolData_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% --- Executes on button press in PlotButton-----------------
function PlotButton_Callback(hObject, eventdata, handles)  

index_selectedplot = get(handles.PlotData,'Value');
index_selectedrelat = get(handles.RelatData,'Value') - 1;
index_selectedbool = get(handles.BoolData,'Value') - 1;

%Define cubes
if index_selectedplot == 0
     warndlg('Select a cube to be plotted') 
     return
end

PlotData = handles.Project.data(index_selectedplot).Value;
if isstruct(PlotData)
    % Should be a figure handle structure
    try
       handles.figure = struct2handle(PlotData, 0);
       guihandles(hObject, handles);
    catch
        warning('Unable to plot this cube.')
    end
    return
end
handles.SourceData{1} = handles.Project.data(index_selectedplot).Name;
Labels   = handles.Project.data(index_selectedplot).Labels;
warnmsg = {};

selectedButton = get(handles.ColorType, 'SelectedObject');
ColorType = get(selectedButton, 'String');
switch ColorType
    case 'None'
        BoolData=[];
        RelatData=[];
    case 'Automatic'        
        defaultParameters = struct;       
        % for automatic ploting, in general do not use limits of bioplex
        % (500 and 18000 for range of operation), as e.g. if relative data
        % is used it will not work
        ParaBool=defaultParameters;
        ParaBool.MinSignal=0;
        ParaBool.MaxSignal=10000;
        if size(PlotData,2)>3        %arbitrary choice of early and late
            ParC.EarlyTimes=[2:4];
            ParC.LateTimes=[5:size(PlotData,2)];
            CompressedData = GetTimeCompressed(PlotData,ParC);
            BoolData = Booleanizer(CompressedData, ParaBool);
        else
            BoolData = Booleanizer(PlotData, ParaBool);
        end
        RelatData = MaxSignalRelativator(PlotData, defaultParameters);
        
    case 'Custom'     
        if index_selectedbool == 0
            BoolData=[];
            handles.SourceData{2} = '';
        else
            BoolData = handles.Project.data(index_selectedbool).Value;
            % validate Boolean data
            if isnumeric(BoolData)
                handles.SourceData{2} = handles.Project.data(index_selectedbool).Name;
            else
                BoolData = [];
                warnmsg{end+1} = 'The Boolean data does not appear to be valid.';
            end
        end

        if index_selectedrelat == 0
            RelatData=[];
            RelatData = MaxSignalRelativator(PlotData, struct);
            handles.SourceData{3} = '';
        else
            RelatData = handles.Project.data(index_selectedrelat).Value;
            handles.SourceData{3} = handles.Project.data(index_selectedrelat).Name;
            if max(RelatData(:)) > 1
                warnmsg{end+1} = 'Relative data can not be bigger than 1.';
                warndlg('Relative data can not be bigger than 1');
                index_selectedrelat=0;
                set(handles.RelatData,'Value',1);
                guidata(hObject,handles);
                return
            end
        end
end

if ~isempty(warnmsg)
    warndlg(warnmsg);
end

try, handles.Project.Name;
catch, handles.Project.Name='';
end

handles.Parameters = getParameters(handles);
Parameters=handles.Parameters;
titlefig = ['Plot of ' handles.Project.Name  ' ' handles.Project.data(index_selectedplot).Name ...
           'array for ' Labels(Parameters.DimFixed(1)).Name '=' ...
           Labels(Parameters.DimFixed(1)).Value{Parameters.DimFixed(2)}];
%if isempty(handles.figure) || ~ishandle(handles.figure)
    handles.figure = figure('Name',titlefig ,'Toolbar','None','NumberTitle','off');
%end
guidata(hObject, handles);
if numel(Labels)<5
    warndlg('The cube must have 5 dimensions and be in the canonical form')
    return
end

if Parameters.Dims2Exp(1)==Parameters.Dims2Exp(2)||...
   Parameters.Dims2Exp(1)==Parameters.Dims2Exp(2)||...      
   Parameters.Dims2Exp(3)==Parameters.Dims2Exp(2)
   warndlg('The dimension chosen for the different layouts directions should be different.')
   return
end
if Parameters.Dims2Exp(1)==Parameters.DimFixed(1)||...
   Parameters.Dims2Exp(2)==Parameters.DimFixed(1)||...      
   Parameters.Dims2Exp(3)==Parameters.DimFixed(1)
   warndlg('The dimension chosen for the different layouts directions should be different.')
   return
end
guidata(hObject, handles);  
if (get(handles.SingleEmpty,'Value')  == get(handles.SingleEmpty,'Max'))
   RelatData=zeros(size(PlotData));    
end



handles.Parameters.Labels = Labels;
handles.Parameters.BoolData = BoolData;
handles.Parameters.RelatData = RelatData;
guidata(hObject, handles);
figure(handles.figure);
PlotSignals(PlotData,handles.Parameters);


%% ----Parameters
function Parameters = getParameters(handles)
if (get(handles.SingleFilled,'Value') == get(handles.SingleFilled,'Max'))||...
   (get(handles.SingleEmpty,'Value')  == get(handles.SingleEmpty,'Max'))
    Parameters.HeatMap='no';
    Parameters.PlotMean='no';
    Parameters.PlotLumped='no';
    Parameters.Plot2D='no';
end
if (get(handles.Lumped,'Value') == get(handles.Lumped,'Max'))
    Parameters.SingleFilled='no';
    Parameters.SingleEmpty='no';
    Parameters.HeatMap='no';
    Parameters.PlotMean='no';
    Parameters.PlotLumped='yes';
    Parameters.Plot2D='no';
end
if (get(handles.Plot2D,'Value') == get(handles.Plot2D,'Max'))
    Parameters.SingleFilled='no';
    Parameters.SingleEmpty='no';
    Parameters.HeatMap='no';
    Parameters.PlotMean='no';
    Parameters.PlotLumped='yes';
    Parameters.Plot2D='yes';
end
if (get(handles.HeatmapCourse,'Value') == get(handles.HeatmapCourse,'Max'))
    Parameters.HeatMap='yes';
    Parameters.PlotMean='no';
    Parameters.PlotLumped='no';
    Parameters.Plot2D='no';
end
if (get(handles.HeatmapMean,'Value') == get(handles.HeatmapMean,'Max'))
    Parameters.HeatMap='yes';
    Parameters.PlotMean='yes';
    Parameters.PlotLumped='no';
    Parameters.Plot2D='no';
end
if (get(handles.RealTimeScale,'Value') == get(handles.RealTimeScale,'Max'))
    Parameters.TimeScale=1;
else
    Parameters.TimeScale=2;
end
Parameters.MinYMax=str2num(get(handles.MinYMax, 'String'));
if (get(handles.ShowRed,'Value') == get(handles.ShowRed,'Max'))
    Parameters.ShowRed=1;
else
    Parameters.ShowRed=2;
end
Parameters.Redder=str2num(get(handles.Redder, 'String'));
if (get(handles.PlotPairsOfDrugs,'Value') == get(handles.PlotPairsOfDrugs,'Max'))
    Parameters.PlotPairsOfDrugs=1;
else
    Parameters.PlotPairsOfDrugs=2;    
end
if (get(handles.CouplePlots,'Value') == get(handles.CouplePlots,'Max'))
    Parameters.CouplePlots=1;
else
    Parameters.CouplePlots=2;
end
%Parameters.Intensity=str2num(get(handles.Intensity, 'String'));
Parameters.Dims2Exp(1)=get(handles.Dim12exp,'Value');%str2num(Dims2Exp);
Parameters.Dims2Exp(2)=get(handles.Dim22exp,'Value');
Parameters.Dims2Exp(3)=get(handles.Dim32exp,'Value');

index_selectedplot = get(handles.PlotData, 'Value');
if index_selectedplot > 0
    numString = get(handles.OrderMeasu, 'String');
    % Replace "end" with the number of measurements
    numSignals = numel(handles.Project.data(index_selectedplot).Labels(Parameters.Dims2Exp(end)).Value);
    numList = regexprep(numString, 'end', num2str(numSignals));
    Parameters.OrderMeasu=str2num(numList);
end

Parameters.DimFixed(1)=get(handles.Dim2Fix,'Value');
Parameters.DimFixed(2)=get(handles.Dim2FixVal,'Value');

Parameters.Reference(1)=get(handles.RefDim1,'Value')-1;
Parameters.Reference(2)=get(handles.RefDim2,'Value')-1;
Parameters.Reference(3)=get(handles.RefDim3,'Value')-1;
Parameters.Reference(4)=get(handles.RefDim4,'Value')-1;
Parameters.Reference(5)=get(handles.RefDim5,'Value')-1;
for i=1:5
    if Parameters.Reference(i)==0
        Parameters.Reference(i)=NaN;
    end
end

Colors=get(handles.ChooseColorModus, 'String');
Parameters.ColorModus=Colors{get(handles.ChooseColorModus,'Value')};
if (get(handles.ColorBackg,'Value') == get(handles.ColorBackg,'Max'))
    Parameters.Background='y';
else
    Parameters.Background='n';
end

function RealTimeScale_Callback(hObject, eventdata, handles)
% if (get(hObject,'Value') == get(hObject,'Max'))
%     handles.Parameters.TimeScale=1;
% else
%     handles.Parameters.TimeScale=2;
% end
% guidata(hObject,handles);

function RealTimeScale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(handles.RealTimeScale,'Value','Max')%default on
guidata(hObject,handles);

function MinYMax_Callback(hObject, eventdata, handles)
% handles.Parameters.MinYMax=str2num(get(hObject, 'String'));
% guidata(hObject,handles);

function MinYMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ShowRed_Callback(hObject, eventdata, handles)
% if (get(hObject,'Value') == get(hObject,'Max'))
%     handles.Parameters.ShowRed=1;
% else
%     handles.Parameters.ShowRed=2;
% end
% guidata(hObject,handles);

function ShowRed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Redder_Callback(hObject, eventdata, handles)
% handles.Parameters.Redder=str2num(get(hObject, 'String'));
% guidata(hObject,handles);

function Redder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PlotPairsOfDrugs_Callback(hObject, eventdata, handles)
% if (get(hObject,'Value') == get(hObject,'Max'))
%     handles.Parameters.PlotPairsOfDrugs=1;
% else
%     handles.Parameters.PlotPairsOfDrugs=2;    
% end
% guidata(hObject,handles);

function CouplePlots_Callback(hObject, eventdata, handles)
% if (get(hObject,'Value') == get(hObject,'Max'))
%     handles.Parameters.CouplePlots=1;
% else
%     handles.Parameters.CouplePlots=2;
%  end
% guidata(hObject,handles);

function CouplePlots_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function OrderMeasu_Callback(hObject, eventdata, handles)
% handles.Parameters.OrderMeasu=str2num(get(hObject, 'String'));
% guidata(hObject,handles);

function OrderMeasu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Intensity_Callback(hObject, eventdata, handles)
% handles.Parameters.Intensity=str2num(get(hObject, 'String'));
% guidata(hObject,handles);

function Intensity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Dim2Exp_Callback(hObject, eventdata, handles)
% Dims2Exp=get(hObject, 'String');
% handles.Parameters.Dims2Exp=str2num(Dims2Exp);
% guidata(hObject,handles);

function Dim2Exp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DimFixed_Callback(hObject, eventdata, handles)
% DimFixed=get(hObject, 'String');
% handles.Parameters.DimFixed=str2num(DimFixed);
% guidata(hObject,handles);

function DimFixed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ColorBackg_Callback(hObject, eventdata, handles)


function GetReference_Callback(hObject, eventdata, handles)


function GetReference_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ChooseColorModus_Callback(hObject, eventdata, handles)


function ChooseColorModus_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SingleFilled_Callback(hObject, eventdata, handles)
if (get(handles.SingleFilled,'Value') == get(handles.SingleFilled,'Max'))
    set(handles.SingleEmpty,'Value',get(handles.SingleEmpty,'Min'))
    set(handles.Lumped,'Value',get(handles.Lumped,'Min'))
    set(handles.Plot2D,'Value',get(handles.Lumped,'Min'))
    set(handles.HeatmapMean,'Value',get(handles.HeatmapMean,'Min'))
    set(handles.HeatmapCourse,'Value',get(handles.HeatmapCourse,'Min'))
    guidata(hObject,handles);
end

function SingleEmpty_Callback(hObject, eventdata, handles)
if (get(handles.SingleEmpty,'Value') == get(handles.SingleEmpty,'Max'))
    set(handles.SingleFilled,'Value',get(handles.SingleFilled,'Min'))
    set(handles.Lumped,'Value',get(handles.Lumped,'Min'))
    set(handles.Plot2D,'Value',get(handles.Lumped,'Min'))
    set(handles.HeatmapMean,'Value',get(handles.HeatmapMean,'Min'))
    set(handles.HeatmapCourse,'Value',get(handles.HeatmapCourse,'Min'))
    set(handles.Lumped,'Value',get(handles.Lumped,'Min'))
    guidata(hObject,handles);
end


function Lumped_Callback(hObject, eventdata, handles)
if (get(handles.Lumped,'Value') == get(handles.Lumped,'Max'))
    set(handles.SingleEmpty,'Value',get(handles.SingleEmpty,'Min')) 
    set(handles.Plot2D,'Value',get(handles.Lumped,'Min'))
    set(handles.SingleFilled,'Value',get(handles.SingleFilled,'Min'))
    set(handles.HeatmapMean,'Value',get(handles.HeatmapMean,'Min'))
    set(handles.HeatmapCourse,'Value',get(handles.HeatmapCourse,'Min'))
    guidata(hObject,handles);
end

function HeatmapCourse_Callback(hObject, eventdata, handles)
if (get(handles.HeatmapCourse,'Value') == get(handles.HeatmapCourse,'Max'))
    set(handles.SingleEmpty,'Value',get(handles.SingleEmpty,'Min')) 
    set(handles.Plot2D,'Value',get(handles.Lumped,'Min'))
    set(handles.SingleFilled,'Value',get(handles.SingleFilled,'Min'))
    set(handles.HeatmapMean,'Value',get(handles.HeatmapMean,'Min'))
    set(handles.Lumped,'Value',get(handles.Lumped,'Min'))
    guidata(hObject,handles);
end

function HeatmapMean_Callback(hObject, eventdata, handles)
if (get(handles.HeatmapMean,'Value') == get(handles.HeatmapMean,'Max'))
    set(handles.SingleEmpty,'Value',get(handles.SingleEmpty,'Min')) 
    set(handles.Plot2D,'Value',get(handles.Lumped,'Min'))
    set(handles.SingleFilled,'Value',get(handles.SingleFilled,'Min'))
    set(handles.Lumped,'Value',get(handles.Lumped,'Min'))
    set(handles.HeatmapCourse,'Value',get(handles.HeatmapCourse,'Min'))
    guidata(hObject,handles);
end

function Plot2D_Callback(hObject, eventdata, handles)
if (get(handles.Plot2D,'Value') == get(handles.HeatmapMean,'Max'))
    set(handles.SingleEmpty,'Value',get(handles.SingleEmpty,'Min')) 
    set(handles.HeatmapMean,'Value',get(handles.HeatmapMean,'Min'))
    set(handles.SingleFilled,'Value',get(handles.SingleFilled,'Min'))
    set(handles.Lumped,'Value',get(handles.Lumped,'Min'))
    set(handles.HeatmapCourse,'Value',get(handles.HeatmapCourse,'Min'))
    guidata(hObject,handles);
end



%% Help Dialogs
function SingleEmptyHelp_Callback(hObject, eventdata, handles)
helpdlg('like single filled plots but no filling in the plots.')

function HelpPlot2D_Callback(hObject, eventdata, handles)
helpdlg('Use the rows and X subcoordinates to define a 2D plot.')

function HelpTimeScale_Callback(hObject, eventdata, handles)
helpdlg('to use real values in x axis, otherwise uses equally distributed values.')

function HelpShowRed_Callback(hObject, eventdata, handles)
helpdlg('Mark it to color in Red a plot if the signal decreases')

function HelpThresRed_Callback(hObject, eventdata, handles)
helpdlg('threshold 0<ThresRed<1 to define when the decay of a signal is significant and thus will be coloured in red')

function HelpCouplePlots_Callback(hObject, eventdata, handles)
helpdlg('To plot all the subplots in the same row with the same maximal value in the y axis')

function HelpOrderMeasu_Callback(hObject, eventdata, handles)
helpdlg('vector of the form [2 3  5]... to change the order in which the readouts are plotted')

function HelpColorModus_Callback(hObject, eventdata, handles)
message=['Choose a criterion to define the color plots are filled with: \n '...
    'max = intensity related to maximal value, color defined by discretized data \n '... 
    '(green sustained [0 1 1], yellow transient [0 1 0],  magenta late [0 0 1], grey no signal [0 0 0]) \n '...
     'change = intensity related to change from t=1 to t=0, color defined by discretized data  \n refmax = '...
     'color determined by relation to reference treatment (compare max values), bigger than reference green,'...
     'lower magenta \n refAUC = color determined by relation to reference treatment (compare AUCs)   bigger'...
     'than reference green, lower magenta. \n cytok to use only color blue when the signal is signifcant, grey otherwise.'];
helpdlg(sprintf(message));

function HelpDims2Exp_Callback(hObject, eventdata, handles)
message=['3 dimensions of the data cube to be span through the plots. \n',...
         'Assign one dimension to each coordinate. Default values are given. \n',...
         'You also have to fix another dimension to a particular value; only 3 dimensions can be spanned through the plots.'];
helpdlg(sprintf(message));



function HelpMinYMax_Callback(hObject, eventdata, handles)
helpdlg('define a minimal value for the maximal value in the y axis. Used to avoid plotting as relevant unrelevant signals (e.g. below noise threshold)')

function HelpPlotPairsOfDrugs_Callback(hObject, eventdata, handles)
helpdlg('if you plot drugs pairwise the plots will be distributed accordingly and the background will be different for each element of the pair of drugs');

function HelpRefConditions_Callback(hObject, eventdata, handles)
message=['Choose a reference condition which will be plotted as a solid line \n',...
         'with all plots in the single filled plots option.',...
         'It may be defined for one or more dimensions, \n',...
         'e.g.refer each plot to the same experiment with aparticular stimuli \n',...
         ' or refer all plots to a single experimnent.'];
helpdlg(sprintf(message))
%helpdlg(sprintf('if there is a notNaN, the corresponding conditions are used to plot a reference signal in black. \n E.g. [2 NaN NaN NaN NaN] always plots the corresponding data for the second cell line. \n It can also be e.g. [ 1 NaN 1 1 NaN] then it plots the 1st cell, the 1st treatment and the 1st inhibitor'));

function HelpColorBackg_Callback(hObject, eventdata, handles)
helpdlg('if there is a reference plot, the background is coloured blueish if the (average of the ) data of interest is higher and redish if the reference is higher');


function HelpHeatmapMean_Callback(hObject, eventdata, handles)
helpdlg('Plot in each subplot a heatmap coloured according to the mean value through all time points')

function HelpPlotLumped_Callback(hObject, eventdata, handles)
helpdlg('Plot in each subplot a number of time courses corresponding to all the variants of a particular dimension')

function HelpPlotFilled_Callback(hObject, eventdata, handles)
helpdlg('Plot in each subplot a heatmap coloured according to the mean value through all time points')

function HelpHeatmapCourse_Callback(hObject, eventdata, handles)
helpdlg('Plot in each subplot a heatmap coloured according to the time-course of the signal')


function Export_CreateFcn(hObject, eventdata, handles)
function Export_Callback(hObject, eventdata, handles)
% Vaidate figure
if isempty(handles.figure) || ~ishandle(handles.figure)
    warndlg('There is currently no plot available for export. First, create a plot.');
    return
end
% Convert figure to a struct variable
hgS = handle2struct(handles.figure);
% Query user for Name & Info fields
answer = inputdlg(...
    {'Enter plot Name (a short label):','Enter plot Info (a longer description):'}, ...
    'Enter information for a plot', 1, {'PlotName','Plot description'});
name = answer{1};
info = answer{2};
% Create data cube / array
data = createDataCube(...
    'Value', hgS, ...
    'Name', name, ...
    'Info', info, ...
    'Labels', handles.Parameters.Labels, ...
    'SourceData', handles.SourceData, ...
    'Code', @PlotSignals, ...
    'Parameters', handles.Parameters, ...
    'PrintWarnings', false);
% Run exporter
handles.exporter(data)

function DefaultExporter(data)
% export to base workspace
exclusions = evalin('base', 'who');
varName = genvarname('dataPlot', exclusions);
assignin('base', varName, data);

%%

function edit26_Callback(hObject, eventdata, handles)
function edit26_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit27_Callback(hObject, eventdata, handles)
function edit27_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit28_Callback(hObject, eventdata, handles)
function edit28_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit29_Callback(hObject, eventdata, handles)
function edit29_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton31_Callback(hObject, eventdata, handles)


function pushbutton32_Callback(hObject, eventdata, handles)


function pushbutton33_Callback(hObject, eventdata, handles)


function pushbutton34_Callback(hObject, eventdata, handles)


function pushbutton35_Callback(hObject, eventdata, handles)


function pushbutton36_Callback(hObject, eventdata, handles)


function pushbutton37_Callback(hObject, eventdata, handles)


function pushbutton38_Callback(hObject, eventdata, handles)


function edit30_Callback(hObject, eventdata, handles)


function edit30_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox16_Callback(hObject, eventdata, handles)


function checkbox17_Callback(hObject, eventdata, handles)


function pushbutton39_Callback(hObject, eventdata, handles)


function checkbox18_Callback(hObject, eventdata, handles)


function checkbox19_Callback(hObject, eventdata, handles)


function pushbutton40_Callback(hObject, eventdata, handles)


function pushbutton41_Callback(hObject, eventdata, handles)


function pushbutton42_Callback(hObject, eventdata, handles)


function checkbox20_Callback(hObject, eventdata, handles)

function edit31_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Dim12exp_Callback(hObject, eventdata, handles)

function Dim12exp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Dim22exp_Callback(hObject, eventdata, handles)

function Dim22exp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Dim32exp_Callback(hObject, eventdata, handles)

function Dim32exp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Dim2Fix_Callback(hObject, eventdata, handles)
Dim=get(handles.Dim2Fix,'Value');
index_selectedplot = get(handles.PlotData,'Value');
Labels=handles.Project.data(index_selectedplot).Labels;
Labels=labels2cellstr(Labels);
set(handles.Dim2FixVal,'String',Labels(Dim).Value);
set(handles.Dim2FixVal,'Value',1);
guidata(hObject, handles);

function Dim2Fix_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Dim2FixVal_Callback(hObject, eventdata, handles)


function Dim2FixVal_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton58_Callback(hObject, eventdata, handles)


function RefDim1_Callback(hObject, eventdata, handles)


function RefDim1_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RefDim2_Callback(hObject, eventdata, handles)


function RefDim2_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RefDim3_Callback(hObject, eventdata, handles)


function RefDim3_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RefDim4_Callback(hObject, eventdata, handles)


function RefDim4_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RefDim5_Callback(hObject, eventdata, handles)


function RefDim5_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton59_Callback(hObject, eventdata, handles)


function HelpColorCodeBi_Callback(hObject, eventdata, handles)


function ColorCodeBi_Callback(hObject, eventdata, handles)


% --- Executes on button press in ColorNone.
function ColorNone_Callback(hObject, eventdata, handles)

% --- Executes on button press in ColorAutomatic.
function ColorAutomatic_Callback(hObject, eventdata, handles)

% --- Executes on button press in ColorCustom.
function ColorCustom_Callback(hObject, eventdata, handles)


% --- Executes when selected object is changed in ColorType.
function ColorType_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ColorType 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button = get(eventdata.NewValue, 'String');
if isempty(handles)
    handles = guihandles(hObject);
end
fieldsToToggle = [handles.RelatData, handles.BoolData];
if strcmpi(button, 'None') || strcmpi(button, 'Automatic')
    set(fieldsToToggle, 'Enable', 'off');
else
    set(fieldsToToggle, 'Enable', 'on');
end



