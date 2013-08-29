function varargout = GuiMultipleReg(varargin)
% GuiMultipleReg helps you to run multiple regression analyses
%
%   varargout = GuiMultipleReg(varargin)
%
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = a Compendium
%
%
% OUTPUTS:
%
% varargout = an updated compendium with a new array for the weights
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  NewCompendium = GuiMultipleReg(Compendium)
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
 

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiMultipleReg_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiMultipleReg_OutputFcn, ...
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


% --- Executes just before GuiMultipleReg is made visible.
function GuiMultipleReg_OpeningFcn(hObject, eventdata, handles, varargin)

handles.Project=varargin{1};
if numel(varargin) >= 2
    handles.notifier = varargin{2};
else
    % Dummy notifier
    handles.notifier = @(x)[];
end
handles.output = handles.Project.Compendium(1);

handles.CompX=1;
handles.CompY=1;
set(handles.ChooseCompX,'String',{handles.Project.Compendium.Name});
set(handles.ChooseCompY,'String',{handles.Project.Compendium.Name});

set(handles.ChooseXArray,'String',{handles.Project.Compendium(1).data.Name});
set(handles.ChooseXArray,'Value',1);
set(handles.ChooseYArray,'String',{handles.Project.Compendium(1).data.Name});
set(handles.ChooseYArray,'Value',1);

Cubesin2D={'Cues','Inhibitors','Cues and Inhibitors','Readouts'};
set(handles.ChooseXMatrix,'String',Cubesin2D);
set(handles.ChooseXMatrix,'Value',4);
set(handles.ChooseYMatrix,'String',Cubesin2D);
set(handles.ChooseYMatrix,'Value',4);

handles.Parameters.PlotWeights=true;
handles.Parameters.PlotFit=false;
handles.Parameters.Export2Cytoscape=false;

guidata(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = GuiMultipleReg_OutputFcn(hObject, eventdata, handles) 

function ChooseXArray_Callback(hObject, eventdata, handles)


function ChooseXArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ChooseYArray_Callback(hObject, eventdata, handles)


function ChooseYArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function RunMultReg_Callback(hObject, eventdata, handles)
ChosenXArray=get(handles.ChooseXArray,'Value');
ChosenYArray=get(handles.ChooseYArray,'Value');

CodeX=handles.Project.Compendium(handles.CompX).data(ChosenXArray).Code;
CodeY=handles.Project.Compendium(handles.CompY).data(ChosenYArray).Code;

XData = handles.Project.Compendium(handles.CompX).data(ChosenXArray).Value;
if max(max(max(max(max(XData)))))>1
    messag =['The X Data your are passing does not seem to be normalized between 0 and 1. '...
        'You can still run the multiple linear regression analysis, but the meaning of the results may be misleading. '...
        'To normalize your data, go back to the main DataRail menu and create a new data array with the Normalize function, '...
        ' using the parameter to normalize to the maximal value, or choose from the list a cube that has been normalized.'];
    Answer=questdlg(messag,'Data is not normalized','Continue','Stop','Stop');
    if strcmp(Answer,'Stop')
        return
    end    
end
YData = handles.Project.Compendium(handles.CompY).data(ChosenYArray).Value;
if max(max(max(max(max(YData)))))>1
messag =['The Y Data your are passing does not seem to be normalized between 0 and 1. '...
        'You can still run the multiple linear regression analysis, but the meaning of the results may be misleading. '...
        'To normalize your data, go back to the main DataRail menu and create a new data array with the Normalize function, '...
        ' using the parameter to normalize to the maximal value, or choose from the list a cube that has been normalized.'];    
    Answer=questdlg(messag,'Data is not normalized','Continue','Stop','Stop');
    if strcmp(Answer,'Stop')
        return
    end    
end
%% passing already 2D matrices
if  ~isempty(CodeX)&&strcmp(CodeX,'ExpandCubeto2D')&&...
        ~isempty(CodeY)&&strcmp(CodeY,'ExpandCubeto2D')
    XArray=handles.Project.Compendium(handles.CompX).data(get(handles.ChooseXArray,'Value'));
    YArray=handles.Project.Compendium(handles.CompY).data(get(handles.ChooseYArray,'Value'));
    if ~isstruct(XArray.Value)||~isstruct(YArray.Value)
        warndlg('The input for the multiple regression has to be an array generated with ExpandCubeto2D. Select an appropriate array from  the list.')
        %    delete(hObject);
        return
    end
    if    get(handles.ChooseXMatrix,'Value')==get(handles.ChooseYMatrix,'Value')&&...
          get(handles.ChooseXArray,'Value') ==get(handles.ChooseYArray,'Value')  
        warndlg('Input and output matrices must be different')
        return;
    end
    XMatrix=XArray.Value.Matrices(get(handles.ChooseXMatrix,'Value')).Value;
    YMatrix=YArray.Value.Matrices(get(handles.ChooseYMatrix,'Value')).Value;

    %Compute weights
    WMatrix=XMatrix\YMatrix;
    %Other possible method
    % WM2=fsolve(@(WM2) GetOptimFun(XMatrix,YMatrix,WM2),WM0)
    LabelsX=XArray.Value.Labels(get(handles.ChooseXMatrix,'Value')).Value;
    LabelsY=YArray.Value.Labels(get(handles.ChooseYMatrix,'Value')).Value;
    if handles.Parameters.PlotFit
        figure('Name','Fit of multiple regression');PlotFitRegression(XMatrix,YMatrix,WMatrix,LabelsY);
    end
    if handles.Parameters.PlotWeights
        %check dimensions agree
        if ~size(WMatrix,1)==numel(LabelsX)
            WMatrix=WMatrix';
        end
        figure('Name','Weights of multiple regression');PlotWeights(WMatrix,LabelsX,LabelsY)
    end
    if handles.Parameters.Export2Cytoscape
        [handles.FileName, handles.PathName] = uiputfile({''},'Select a name to export data to Cytoscape');
        Param.OutputFile=[handles.PathName handles.FileName];
        Cube.W1=WMatrix;
        Cube.W2=[];
        Cube.Labels(1).Value=LabelsX;
        Cube.Labels(2).Value='';
        Cube.Labels(3).Value=LabelsY;
        ExportWeights2Cytoscape(Cube, Param);
    end
%% passing datacubes
else
    XArray=handles.Project.Compendium(handles.CompX).data(get(handles.ChooseXArray,'Value'));
    YArray=handles.Project.Compendium(handles.CompY).data(get(handles.ChooseYArray,'Value'));
    XeqY=false;
    
    if handles.CompX==handles.CompY&&...
           get(handles.ChooseXArray,'Value') ==get(handles.ChooseYArray,'Value')
       if     get(handles.ChooseXMatrix,'Value')~=get(handles.ChooseYMatrix,'Value')
            XeqY=true;       
       else
           warndlg('Input and output matrices must be different')
           return;
       end
    end    
    if ~XeqY
        Expand2DParamsX=GuiExpandCubeto2DPars(XArray.Labels);
        Expand2DParamsY=GuiExpandCubeto2DPars(YArray.Labels);
        ExpandedCubeX=ExpandCubeto2D(XArray.Value,Expand2DParamsX);
        ExpandedCubeY=ExpandCubeto2D(YArray.Value,Expand2DParamsY);       
        XMatrix=ExpandedCubeX.Matrices(get(handles.ChooseXMatrix,'Value')).Value;
        YMatrix=ExpandedCubeY.Matrices(get(handles.ChooseYMatrix,'Value')).Value;
        WMatrix.W1=XMatrix\YMatrix;
        WMatrix.Labels(1).Name='X';
        WMatrix.Labels(1).Value=ExpandedCubeX.Labels(get(handles.ChooseXMatrix,'Value')).Value;
        WMatrix.Labels(2).Name='Y';
        WMatrix.Labels(2).Value=ExpandedCubeY.Labels(get(handles.ChooseXMatrix,'Value')).Value;
    else
        WMatrix=ComputeWeightsMR(handles.Project.Compendium(handles.CompX).data(ChosenXArray),'');
        %XMatrix=[WMatrix.X1 WMatrix.X2];
        YMatrix=WMatrix.Y;
        LabelsX1=WMatrix.Labels(1).Value;
        LabelsX2=WMatrix.Labels(2).Value;
        LabelsY=WMatrix.Labels(3).Value;
    end   
    
    if handles.Parameters.PlotFit
        if   get(handles.ChooseXMatrix,'Value')==1||get(handles.ChooseXMatrix,'Value')==3
            figure('Name','Fit of multiple regression');PlotFitRegression(WMatrix.X1,WMatrix.Y,WMatrix.W1,LabelsY);
        end
        if   get(handles.ChooseXMatrix,'Value')==2||get(handles.ChooseXMatrix,'Value')==3
            figure('Name','Fit of multiple regression');PlotFitRegression(WMatrix.X2,WMatrix.Y,WMatrix.W2,LabelsY);

        end
    end
    if handles.Parameters.PlotWeights
        if   get(handles.ChooseXMatrix,'Value')==1||get(handles.ChooseXMatrix,'Value')==3
            figure('Name','Weights of MLR Cue-Response');
            PlotWeights(WMatrix.W1',LabelsY,LabelsX1)
        elseif  get(handles.ChooseXMatrix,'Value')==2||get(handles.ChooseXMatrix,'Value')==3
            figure('Name','Weights of MLR Inhibitor-Response');
            PlotWeights(WMatrix.W2',LabelsY,LabelsX2)
        else
            figure('Name','Weights of MLR two compendia');
            PlotWeights(WMatrix.W1,WMatrix.Labels(1).Value,WMatrix.Labels(2).Value)
        end
    end
    if handles.Parameters.Export2Cytoscape
        [handles.FileName, handles.PathName] = uiputfile({''},'Select a name to export data to Cytoscape');
        Param.OutputFile=[handles.PathName handles.FileName];
        ExportWeights2Cytoscape(WMatrix, Param);
    end
end
%% Compute R2
ypred = XMatrix*WMatrix.W1;
% compute SSE and SST for each variable
SSE=sum((YMatrix-ypred).^2,1);
SST=sum((YMatrix-nanmean(YMatrix(:))).^2,1);
Diffs = SSE./SST;
%compute R2 for each Y variable
%NumYs=numel(YArray.Labels(5).Value);
%TimeY=numel(YArray.Labels(2).Value);
%DiffVars=nan(NumYs,1);
%for var=1:NumYs
%    DiffVars(var)=nanmean(Diffs([1:TimeY]*var));
%end
WMatrix.R2Indiv=1-Diffs;
%global (total)
WMatrix.R2Global=1-nanmean(Diffs);

%% Save Weights in a new Array
SaveResults=questdlg('Save results in a data array?', 'save results?', 'Yes','No', 'Yes');
  
if strcmp(SaveResults,'Yes')
CubeName=inputdlg('Choose a name for the cube');

    handles.Project.Compendium(handles.CompY).data(end+1)= createDataCube(...
       'Name', CubeName{1}, ...
       'Info', 'Weights of multiple regression',...
       'Value', WMatrix);
   
        handles.Project.Compendium(handles.CompY).data(end).SourceData{1}=XArray.Name;
        handles.Project.Compendium(handles.CompY).data(end).SourceData{1}=YArray.Name;
end
guidata(hObject,handles);

function PlotWeights_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.PlotWeights=true;
else
    handles.Parameters.PlotWeights=false;
end
guidata(hObject,handles);


function PlotFit_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.PlotFit=true;
else
    handles.Parameters.PlotFit=false;
end
guidata(hObject,handles);
uiresume;

function ChooseXMatrix_Callback(hObject, eventdata, handles)


function ChooseXMatrix_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ChooseYMatrix_Callback(hObject, eventdata, handles)


function ChooseYMatrix_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%---Plotting functions------

function PlotFitRegression(XMatrix,YMatrix,WMatrix,LabelsY)
%   Function to plot the fit of a regression Cy=Ph*W

CompYMatrix=XMatrix*WMatrix ;

xelems=floor(sqrt(size(YMatrix,2)));
yelems = floor(size(YMatrix,2)/floor(sqrt(size(YMatrix,2))))+1;


for cyt=1:size(YMatrix,2)
        subplot(xelems,yelems,cyt),...
        plot(YMatrix(:,cyt),'b');hold on
        plot(CompYMatrix(:,cyt),'r');
        ylabel([LabelsY{cyt}]);
        set(gca,'XTickLabel',{});
        maxval=max([YMatrix(:,cyt); CompYMatrix(:,cyt) ]);
        ylim([0 maxval])

end


function PlotWeights(WMatrix,LabelsY,LabelsX)


for measu =  1:numel(LabelsY)             %output: 17 signals
    for cue =  1:numel(LabelsX)             %input: Cues
        ylim('manual');

        subwidth= 1./(numel(LabelsY) + 6);        %-Cytokine treatments
        subheight=1./(numel(LabelsX)+6)  ;     %-Cytokine Results
        subplot('Position',[0.07+(measu)*subwidth, 1-(0.02+cue*(subheight+0.01)), subwidth, subheight]);
        Y=[0;  WMatrix(measu,cue); 0];

        h = bar(Y);
        set(h(1),'facecolor','blue'); % use color name
%        set(h(2),'facecolor',[0 1 0]); % or use RGB triple

        xlim([1.5 2.5]);
        limits=[min(min([WMatrix])) 1.1*max(max([WMatrix]))];       
        if ~any(isnan(limits))&&min(limits)~=max(limits)
            ylim(limits);
        end

        %% - define X Label--------------------------------------
        if measu==1
            set(gca,'YTick',mean(ylim));
            set(gca,'YTickLabel',LabelsX{cue});%,'FontSize',12);
%            th=rotateticklabel(gca,90);
        else
            set(gca,'YTickLabel',{});
        end
        %% - define Y Label----------------------------------------
        if cue ==numel(LabelsX)
            set(gca,'XTick' ,mean(xlim)); %pon solo 1 tmeasuk, y en punto medio        
            set(gca,'XTickLabel',LabelsY{measu});
        else
            set(gca,'XTickLabel',{});
        end
    end
end
                                                                                                                                                                                                                                    

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in ExportCytoscape.
function ExportCytoscape_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.Parameters.Export2Cytoscape=true;
else
    handles.Parameters.Export2Cytoscape=false;
end
guidata(hObject,handles);


% --- Executes on selection change in ChooseCompX.
function ChooseCompX_Callback(hObject, eventdata, handles)
handles.CompX=get(handles.ChooseCompX,'Value');
guidata(hObject,handles);
UpdateCompendiumList(handles);


% --- Executes during object creation, after setting all properties.
function ChooseCompX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ChooseCompY.
function ChooseCompY_Callback(hObject, eventdata, handles)
handles.CompY=get(handles.ChooseCompY,'Value');
guidata(hObject,handles);
UpdateCompendiumList(handles);

% --- Executes during object creation, after setting all properties.
function ChooseCompY_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function UpdateCompendiumList(handles)
set(handles.ChooseXArray,'String',{handles.Project.Compendium(handles.CompX).data.Name});
set(handles.ChooseYArray,'String',{handles.Project.Compendium(handles.CompY).data.Name});
%guidata(hObject,handles);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.notifier(handles.Project);
