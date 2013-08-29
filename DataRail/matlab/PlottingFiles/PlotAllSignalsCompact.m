function PlotAllSignalsCompact(Labels,PlotData,BoolData,RelatData,Parameters)
% PlotAllSignalsCompact plots a data cube in a set of subplots data
%
%   PlotAllSignalsCompact(Labels,PlotData,BoolData,RelatData,Parameters)
%
%  If BoolData is provided, the plots aare filled as follows
%
%   green  = sustained
%   yellow = transient
%   magenta= late
%   grey   = no significant signal
%
%  the intensity of the fill is relative to the strength of signal
%   (relative to others for the same measurement), as provided by
%  RelatData
%
%
%--------------------------------------------------------------------------
% INPUTS
%  Labels          =      labels to  use for labeling the plots
%  PlotData        =      data to plot
%  BoolData(zeros) =      discretize data to define colors for plotting
%  RelatData(ones) =      relative data to define intensity of color
%  Optional Parameters (default value in parenthesis)
%     .TimeScale(1)       = 1 real, [0 1 2] else
%     .MinYMax(25)        = Minimal value for the y axis to plot
%     .ShowRed(1)         =clolours red if signals goes down
%     .Redder(0.5);       = Threshold to plot in rot
%     .CouplePlots(1;     =All plots for a particular readout are scaled together
%     .OrderMeasu([1:size(PlotData,5)]); =to change the order of the dim 5 (tipically readout) in the plot
%     .ColorModus('max'); =colouring modus:
%                          'max'    intensity related to maximal value of signal
%                                   color defined by discretized data
%                                   (green sustained [0 1 1], yellow transient [0 1 0],
%                                   magenta late [0 0 1], grey no signal [0 0 0])
%                          'change' related to change
%                                   color defined by discretized data
%                                   (green sustained [0 1 1], yellow transient [0 1 0],
%                                    magenta late [0 0 1], grey no signal [0 0 0])
%                          'refmax' related to reference treatment(compare max values) for background,
%                                   to max value of signal for intensity
%                                   bigger than reference green, lower magenta
%                          'refAUC'   related to reference treatment (compare AUCs),
%                                    bigger than reference green,  lower magenta
%                          'cytok'  Colors blue whenever it goes up
%     .Dims2Exp([3 4 5]   =defines the 3 dimensions of the data cube to loop through
%     .DimFixed([1 1]     =defines dimension not looped through and chooses a value
%     .PlotPairsOfDrugs(1 =if you plot drugs pairwise the plots will be distributed accordingly and
%                          the background will be different for each element of the pair of drugs
%     .Reference=[1 NaN NaN NaN NaN] = if there is a notNaN, the
%                          corresponding conditions are used to plot a reference signal in black
%                          e.g. in this case always plot the same data for the second cell line;
%                          can also be e.g. [ 1 NaN 1 1 NaN] then it plots
%                          the 1st cell, the 1st treatment and the 1st inhibitor
%     .Background('n')    = if there is a reference plot, the background is coloured
%                          bluish if the (average of the ) data of interest is higher
%                          and redish if the reference is higher
%     .BackgDeactiv('noise') =condition used to define whether to plot background or not;
%                           'noise'  :if signal is below exerimental error (MinYMax) it will not be pllote
%                           'boolean':if Boolean is [ 0 0 0] it will not be plotted
%     .HeatMap('no')      =if yes, plots a heatmap in each subplot, either
%                          of the mean or a gradient through the time (see .PlotMean)
%     .PlotMean('no')     = if ploting heat map, defines whether to plot the mean or the time course
%     .PlotLumped('no')   = instead of each plot in one subfigures, it compresses all plots
%                           for different values of dim2 into a single plot
%     .Plot2D('no')       = put 2 dimenionses together, the same as PlotLumped but 2D instead ouf overlapped
%     .ErrorbarData([])   = data for errorbar plots
%
%  OUTPUTS
%
%  None
%
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  figure;PlotAllSignals(LeoData.data.Labels,LeoData.CubeNormBSA,[],[],Parameters)
%
%--------------------------------------------------------------------------
% TODO:
%
% -
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


%% Check Parameters and if they don't exist add default value
try,   Parameters.Plot2D;
catch, Parameters.Plot2D='no';
end

try,   Parameters.PlotLumped;
catch, Parameters.PlotLumped='no';
end

try,   Parameters.HeatMap;
catch, Parameters.HeatMap='no';
end

try,   Parameters.PlotMean;
catch, Parameters.PlotMean='no';
end

try,   Parameters.CouplePlots;
catch,   Parameters.CouplePlots=1;
end

Parameters.OrderMeasu=[14 1 15 2 8 11 7 6 13 4 5 10 16 3 12 9];

if size(PlotData,2)==1
    %error('You need more than 1 time point to plot the data')
    %return
    disp('only one time point in the data - the function will plot bars')
    %create values for a second time point to be able to do bars
    PlotData=cat(2,PlotData, PlotData);
    %the new time is zero so we can plot to two different times
    if Labels(2).Value~=0
        Labels(2).Value=[0 Labels(2).Value];
    else
        Labels(2).Value=[0 1];
    end
    RelatData=cat(2,zeros(size(RelatData)),RelatData);
    BoolData=cat(2,zeros(size(BoolData)),BoolData);
end

if max(size(BoolData))==0
    BoolData=zeros(size(PlotData));
end
if max(size(RelatData))==0
    RelatData=ones(size(PlotData))*0.3;
end

try,   Parameters.TimeScale;
catch, Parameters.TimeScale=0  ;
end
try,   Parameters.MinYMax;
catch, Parameters.MinYMax=500  ;
end
try,   Parameters.ShowRed;
catch, Parameters.ShowRed=1  ;
end
try,   Parameters.Dims2Exp;
catch, Parameters.Dims2Exp=[3 4 5]  ;
end
try,   Parameters.DimFixed;
catch, Parameters.DimFixed=[1 1]  ;
end
try,   Parameters.OrderMeasu;
catch, Parameters.OrderMeasu=[1:size(PlotData,5)];
end

try,   Parameters.TimeScale;
catch, Parameters.TimeScale=1;
end

try,   Parameters.ShowRed;
catch,   Parameters.ShowRed=1;
end

try,   Parameters.MinYMax;
catch, Parameters.MinYMax=25;
end

try,   Parameters.ColorModus;
catch, Parameters.ColorModus='max';
end

try,   Parameters.Redder;
catch, Parameters.Redder=0.5;
end

try,   Parameters.PlotPairsOfDrugs;
catch, Parameters.PlotPairsOfDrugs=2;
end

try, Parameters.Reference;
catch, Parameters.Reference=[NaN NaN NaN NaN NaN];
end
ref=Parameters.Reference;

try, Parameters.Background;
catch, Parameters.Background='n';
end
try,   Parameters.BackgDeactiv;
catch, Parameters.BackgDeactiv='noise';
end

try,   Parameters.ErrorbarData;
catch, Parameters.ErrorbarData=[];
end

try, Parameters.Marker;
catch, Parameters.Marker='None';
end

MarkerChosen=Parameters.Marker;
%MarkerChosen='+';


%later on, this shall go into the gui parameters
Parameters.FontSizeXlabel=5;
Parameters.FontSizeYlabel=6; 
Parameters.FontSizeZlabel=12;

if ~find(Parameters.OrderMeasu==sort(Parameters.OrderMeasu)==0)
    if  numel(Parameters.OrderMeasu) ~= size(PlotData,5) || Parameters.Dims2Exp(3) ~= 5
        warndlg('The Reordering of the signals can only be used if they are in the 5th dimension')
        return
    end
end

if numel(Labels)<5
    display('The cube must have 5 dimensions and be in the canonical form')
    return
end

if ~isempty(find(round(BoolData)~=BoolData))
    BoolData=round(BoolData);%for colouring
end
%% Check canonical form is being used
if~isnumeric(Labels(2).Value)
    error('You have to structure your cube in the canonical form with the time in the second dimension')
end
%if a dimension is empty it will be filled with a 'DummyValue'
for la=1:5
    if ~isnumeric(Labels(la).Value)
        if numel(Labels(la).Value)>1&&isempty(Labels(la).Value{1})
            if size(Labels(la).Name)>3
              Labels(la).Value{1}=['No' Labels(la).Name(1:4)];
            else
                 Labels(la).Value{1}=['No' Labels(la).Name];
            end
        elseif numel(Labels(la).Value)==1&&strcmp(Labels(la).Value,'DummyValue')
            Labels(la).Value='';
        end
    end
end

if ~isempty(find(size(PlotData)==size(BoolData)<1 , 1)) && size(PlotData,2)<4
    warning('Data cube to plot and of Boolean data are not of same size')
end
if  ~isempty(find(size(PlotData)==size(RelatData)<1, 1))
    warning('Data cube to plot and relative are not of same size')
end

%% Permute data in accordance to parameters
PlotData=permute(PlotData,  [Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);
RelatData=permute(RelatData,[Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);
BoolData=permute(BoolData,  [Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);

if numel(Parameters.OrderMeasu)~=size(PlotData,5)
    Parameters.OrderMeasu=[1:size(PlotData,5)];
end
%% Colors and markers for lumped plotting
MarkerList={'o','^','v','x','d','>','<','+'};
Colores=[0 0 0;   1 0 0    ; 0 1 0; 0 1 1;
    1 .2 .2; 0.5 0.5 1; 0 .1 .8; 0.3 .1 1];
if size(PlotData,4)>8
    Colores2=rand((size(PlotData,4)-8),3);
    Colores=[Colores; Colores2];
end
OldLabels=Labels;
Labels=labels2cellstr(OldLabels);
Labels(2)=OldLabels(2);
Dims2Exp=Parameters.Dims2Exp;
Parameters.Reference=Parameters.Reference([Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);

%% Preparing matrices for 2D plotting
if  strcmp(Parameters.Plot2D,'yes')
    Parameters.Lumped='yes';
    if isnumeric(Labels(2).Value)&&isnumeric(Labels(4).Value)
        [xx,yy]=meshgrid([Labels(2).Value],[Labels(Parameters.Dims2Exp(2)).Value]);
    else
        warning('X and Y are not numerical dimensions, using equally spaced value')
        [xx,yy]=meshgrid([1:1:numel(Labels(2).Value)],[1:1:numel(Labels(Parameters.Dims2Exp(2)).Value)]);
    end
end


%% Start loop
for dim3=1:size(PlotData,5)

    disp(['Plotting ' Labels(Dims2Exp(3)).Name ' = ' ...
        Labels(Dims2Exp(3)).Value{dim3} ' (' ...
        num2str(dim3) '/' num2str(size(PlotData,5)) ')'])
    for dim1=1:size(PlotData,3)
        for dim2=1:size(PlotData,4)
            if  strcmp(Parameters.PlotLumped,'yes')
                Fwidth= 1/ (size(PlotData,3)+size(PlotData,3)*0.15+3);
                Fheight= 1/(size(PlotData,5)+2);
                posx=((dim1-1)+dim1*0.15+1)*Fwidth;
                posy=(1-(dim3+1)*(Fheight));
            elseif Parameters.PlotPairsOfDrugs==1
                Fwidth= 1/ (size(PlotData,3)*size(PlotData,4)+size(PlotData,3)+3*size(PlotData,3));
                Fheight= 1/(size(PlotData,5)+6);
                posx=((dim1-1)*size(PlotData,4)+dim2+2*(dim1-1)...
                    +(dim1-1)+0.2*(floor((dim2-1)/2))...%to add space after each second
                    +5)...
                    *Fwidth;
                %add the floor(dim2/18) so that for 19(LDH) there is a gap
                posy=(1-(dim3+1)*(Fheight)-floor(dim3/18)*Fheight);
            else
                Fwidth= 1/ (size(PlotData,3)*size(PlotData,4)+size(PlotData,3)+7);
                Fheight= 1/(size(PlotData,5)+5);
                posx=((dim1-1)*size(PlotData,4)+dim2+dim1+3)*Fwidth;
                posy=(1-(dim3+1)*(Fheight));
            end

            pos=[posx posy Fwidth Fheight ];
%             subplot('Position',pos)
            axes('Position',pos)

            if  Parameters.TimeScale==1
                timeplot=Labels(2).Value';
            else
                timeplot=[0:1:(numel(Labels(2).Value)-1)];%
            end
            timeplot = reshape(timeplot, 1, []);
            timeplotLimits = [min(timeplot) max(timeplot)];
            signalplot=[PlotData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3))];

            if strcmpi(Parameters.HeatMap, 'no')
                timeplotor=[timeplot max(timeplot) min(timeplot)];
                idx=~isnan(signalplot);              
                timeplot=[timeplot(idx) max(timeplot(idx)) min(timeplot(idx))];
                %timeplotor=timeplot;
                if isempty(timeplot)
                    signalplot = zeros(1,0);                    
                else
                    signalplot=[signalplot(idx) 0 0];
                end                
            else

            end
            if isnan(Parameters.Reference(1))
                ref(1)=Parameters.DimFixed(2);
            else ref(1)=Parameters.Reference(1);
            end
            if isnan(Parameters.Reference(3))
                ref(3)=dim1;
            else ref(3)=Parameters.Reference(3);
            end
            if isnan(Parameters.Reference(4))
                ref(4)=dim2;
            else ref(4)=Parameters.Reference(4);
            end
            if isnan(Parameters.Reference(5))
                ref(5)=Parameters.OrderMeasu(dim3);
            else ref(5)=Parameters.Reference(5);
            end
            refplot  =[PlotData(ref(1),:,ref(3),ref(4),ref(5)) 0 0];

            if strcmp(Parameters.ColorModus,'refAUC')
                v=PlotData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3))./...
                    PlotData(ref(1),:,ref(3),ref(4),ref(5));
                r=Labels(2).Value;
                try
                    Relatio=(v*(r)'-v([2:end])*r([1:(end-1)])')/r(end);
                catch
                    Relatio=(v*(r)-v([2:end])*r([1:(end-1)]))/r(end);
                end
            else
                Relatio  =  log(max(signalplot)/max(refplot))+1;
            end

            %Use Fill with different color for different behavior

            %intensity max of all values for Parameters.ColorModus=1
            Intensidad=nanmax(RelatData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3)));
            if isnan(Intensidad)==1|Intensidad<0
                Intensidad=1;
                try % seems to be a problem here with rescaling; as for now we just wrap around in a try
                disp(strcat('Color Intensity not computable for: ', Labels(3).Value(dim1),...
                    '-',Labels(4).Value(dim2),'-',Labels(5).Value(dim3)));
                end
            end

            %% ------------Plot--------------------------------------------
            if isempty(signalplot)
                if isnumeric(Labels(Parameters.Dims2Exp(1)).Value)
                    Labels(Parameters.Dims2Exp(2)).Value=num2cell(Labels(Parameters.Dims2Exp(1)).Value);
                end
                if    size(Labels(Parameters.Dims2Exp(1)).Value)<2
                    Labels1=Labels(Parameters.Dims2Exp(1)).Value;
                else
                    Labels1=Labels(Parameters.Dims2Exp(1)).Value{dim1};
                end
                if isnumeric(Labels(Parameters.Dims2Exp(2)).Value)
                    Labels(Parameters.Dims2Exp(2)).Value=num2cell(Labels(Parameters.Dims2Exp(2)).Value);
                end
                if    size(Labels(Parameters.Dims2Exp(2)).Value)<2
                    Labels2=Labels(Parameters.Dims2Exp(2)).Value;
                else
                    Labels2=Labels(Parameters.Dims2Exp(2)).Value{dim2};
                end
                if isnumeric(Labels(Parameters.Dims2Exp(3)).Value)
                    Labels(Parameters.Dims2Exp(3)).Value=num2cell(Labels(Parameters.Dims2Exp(3)).Value);
                end
                if     size(Labels(Parameters.Dims2Exp(3)).Value)<2
                    Labels3=Labels(Parameters.Dims2Exp(3)).Value;
                else
                    Labels3=Labels(Parameters.Dims2Exp(3)).Value{dim3};
                end
                try                    
                   if iscell(Labels1)
                         disp(['No Data available for ' Labels1{1} '-' Labels2 '-' Labels3])
                   else                                       
                          disp(['No Data available for ' Labels1 '-' Labels2 '-' Labels3]);
                   end
                catch
                    % Create text version of labels if try block failed
                    tLabels1 = evalc('Labels1');
                    tLabels2 = evalc('Labels2');
                    tLabels3 = evalc('Labels3');
                    disp(['No Data available for ' tLabels1 '-' tLabels2 '-' tLabels3]);
                end

            elseif strcmp(Parameters.PlotLumped,'yes')
                if  strcmp(Parameters.Plot2D,'no')
                    for dim2=1:size(PlotData,4)
                        timeplot=timeplot(1:end-2);
                        signalplot=signalplot(2:end-1);                                         
                        plot(timeplot,signalplot,'Color',Colores(dim2,:),'MarkerSize',3,'Marker',MarkerList{dim2});
                        hold on
                    end
                else
                    if dim2==1%one time makes whole surface
                        zz=squeeze(PlotData(Parameters.DimFixed(2),:,dim1,:,Parameters.OrderMeasu(dim3)))';
                        surf(xx,yy,zz);
                    end
                    hold on
                end
                hold on
            elseif strcmp(Parameters.ColorModus,'refmax')|strcmp(Parameters.ColorModus,'refAUC')%Relative values to a reference treatment
                if Relatio>1.05    % bigger than reference=green
                    Intensidad=abs(Relatio-1);
                    if Intensidad>1
                        Intensidad=1;
                    elseif Intensidad<0
                        Intensidad=0;
                    end
                    fill(timeplot,signalplot,[(1-Intensidad) 1 (1-Intensidad)],'Marker',MarkerChosen);hold on
                elseif Relatio<0.95% lower than reference=magenta
                    fill(timeplot,signalplot,[1 (1-Intensidad) 1],'Marker',MarkerChosen);hold on
                else %rest-grey
                    fill(timeplot,signalplot,[0.8 0.8 0.8],'Marker',MarkerChosen);hold on
                end
            elseif strcmp(Parameters.ColorModus,'cytok')
                if    isempty(find(BoolData(Parameters.DimFixed(2),:,dim1,dim2,dim3)>0))
                    fill(timeplot,signalplot,[(1-Intensidad) (1-Intensidad) (1-Intensidad)],'Marker',MarkerChosen);hold on
                else
                    fill(timeplot,signalplot,[(1-Intensidad) (1-Intensidad) 1],'Marker',MarkerChosen);hold on
                end
            elseif  size(BoolData,2)==2 %2 time points, 4 cases
                if     BoolData(Parameters.DimFixed(2),1,dim1,dim2,dim3)==0
                    if BoolData(Parameters.DimFixed(2),2,dim1,dim2,Parameters.OrderMeasu(dim3))==1 %up=blue
                        fill(timeplot,signalplot,[(1-Intensidad)  (1-Intensidad) 1],'Marker',MarkerChosen);hold on
                    else% no signal-grey
                        fill(timeplot,signalplot,[(1-Intensidad) (1-Intensidad) (1-Intensidad)],'Marker',MarkerChosen);hold on
                    end
                else
                    if BoolData(Parameters.DimFixed(2),2,dim1,dim2,dim3)==1 %sustained=green
                        fill(timeplot,signalplot,[(1-Intensidad) 1 (1-Intensidad)],'Marker',MarkerChosen);hold on
                    else %goes down-red
                        if Parameters.ShowRed==1
                           fill(timeplot,signalplot,[Intensidad 0 0],'Marker',MarkerChosen);hold on
                        else
                           fill(timeplot,signalplot,[Intensidad Intensidad Intensidad],'Marker',MarkerChosen);hold on                        
                        end
                    end
                end
            elseif     BoolData(Parameters.DimFixed(2),1,dim1,dim2,Parameters.OrderMeasu(dim3))==0
                if     BoolData(Parameters.DimFixed(2),2,dim1,dim2,Parameters.OrderMeasu(dim3))==1
                    if BoolData(Parameters.DimFixed(2),3,dim1,dim2,Parameters.OrderMeasu(dim3))==1
                        %sustained=green
                        if strcmp(Parameters.ColorModus,'change')
                            Intensidad=mean(RelatData(Parameters.DimFixed(2),[2 3],dim1,dim2,Parameters.OrderMeasu(dim3)))-...
                                RelatData(Parameters.DimFixed(2),1,     dim1,dim2,Parameters.OrderMeasu(dim3));
                            if Intensidad<0
                                Intensidad=0.1;
                                warning('Color Intensity not computable')
                            end

                        end
                        fill(timeplot,signalplot,[(1-Intensidad) 1 (1-Intensidad)],'Marker',MarkerChosen);hold on
                    else%transient=yellow
                        if strcmp(Parameters.ColorModus,'change')
                            Intensidad=RelatData(Parameters.DimFixed(2),2,dim1,dim2,Parameters.OrderMeasu(dim3))-...
                                RelatData(Parameters.DimFixed(2),1,dim1,dim2,Parameters.OrderMeasu(dim3));
                            if Intensidad<0
                                Intensidad=0.1;
                                warning('Color Intensity not computable')
                            end
                        end
                        fill(timeplot,signalplot,[1 1 (1-Intensidad)],'Marker',MarkerChosen);hold on
                    end
                else
                    if BoolData(Parameters.DimFixed(2),3,dim1,dim2,Parameters.OrderMeasu(dim3))==1
                        %late=magenta
                        if strcmp(Parameters.ColorModus,'change')
                            Intensidad=RelatData(Parameters.DimFixed(2),3,dim1,dim2,Parameters.OrderMeasu(dim3))-...
                                RelatData(Parameters.DimFixed(2),1,dim1,dim2,Parameters.OrderMeasu(dim3));
                            if Intensidad<0
                                Intensidad=0.1;
                                warning('Color Intensity not computable')
                            end
                        end
                        fill(timeplot,signalplot,[1 (1-Intensidad) 1],'Marker',MarkerChosen);hold on
                    else
                        % no signal-grey-but check before if signal goes down and then red
                        if  (signalplot(1)-min(signalplot(1:end-2)))/signalplot(1) > Parameters.Redder && Parameters.ShowRed==1
                           %((RelatData(Parameters.DimFixed(2),2,dim1,dim2,Parameters.OrderMeasu(dim3))/...
                           %     RelatData(Parameters.DimFixed(2),1,dim1,dim2,Parameters.OrderMeasu(dim3))<Parameters.Redder&Parameters.ShowRed==1)|...
                           %     (RelatData(Parameters.DimFixed(2),3,dim1,dim2,Parameters.OrderMeasu(dim3))/...
                           %     RelatData(Parameters.DimFixed(2),2,dim1,dim2,Parameters.OrderMeasu(dim3))<Parameters.Redder&Parameters.ShowRed==1))
                            fill(timeplot,signalplot,[1 0 0],'Marker',MarkerChosen);hold on
                        else
                            fill(timeplot,signalplot,[(1-Intensidad) (1-Intensidad) (1-Intensidad)],'Marker',MarkerChosen);hold on
                        end
                    end
                end
            else %Here for t=0 Signal~=0 (=1); now sustained is [1 0 0], transient [1 0 1] upside downs, e.g. signal is inverse of model state
                if BoolData(Parameters.DimFixed(2),    2,dim1,dim2,Parameters.OrderMeasu(dim3))==0
                    if BoolData(Parameters.DimFixed(2),3,dim1,dim2,Parameters.OrderMeasu(dim3))==0
                        %sustained=green
                        if strcmp(Parameters.ColorModus,'change')
                            Intensidad=mean(RelatData(Parameters.DimFixed(2),[2 3],dim1,dim2,Parameters.OrderMeasu(dim3))-...
                                RelatData(Parameters.DimFixed(2),1,    dim1,dim2,Parameters.OrderMeasu(dim3)));
                        end
                        fill(timeplot,signalplot,[(1-Intensidad) 1 (1-Intensidad)],'Marker',MarkerChosen);hold on
                    else%transient=yellow
                        if strcmp(Parameters.ColorModus,'change')
                            Intensidad=+RelatData(Parameters.DimFixed(2),2,dim1,dim2,Parameters.OrderMeasu(dim3))-...
                                RelatData(Parameters.DimFixed(2),1,dim1,dim2,Parameters.OrderMeasu(dim3));
                        end
                        fill(timeplot,signalplot,[1 1 (1-Intensidad)],'Marker',MarkerChosen);hold on
                    end
                else
                    if BoolData(Parameters.DimFixed(2),3,dim1,dim2,Parameters.OrderMeasu(dim3))==0
                        %late=magenta
                        if strcmp(Parameters.ColorModus,'change')
                            Intensidad=RelatData(Parameters.DimFixed(2),3,dim1,dim2,Parameters.OrderMeasu(dim3))-...
                                RelatData(Parameters.DimFixed(2),1,dim1,dim2,Parameters.OrderMeasu(dim3));
                        end
                        fill(timeplot,signalplot,[1 (1-Intensidad) 1],'Marker',MarkerChosen);hold on
                    else% no signal-grey-but check before if signal goes down and then red
                        if ((RelatData(Parameters.DimFixed(2),2,dim1,dim2,Parameters.OrderMeasu(dim3))/...
                                RelatData(Parameters.DimFixed(2),1,dim1,dim2,Parameters.OrderMeasu(dim3))<Parameters.Redder&Parameters.ShowRed==1)|...
                                (RelatData(Parameters.DimFixed(2),3,dim1,dim2,Parameters.OrderMeasu(dim3))/...
                                RelatData(Parameters.DimFixed(2),2,dim1,dim2,Parameters.OrderMeasu(dim3))<Parameters.Redder&Parameters.ShowRed==1))
                            fill(timeplot,signalplot,[1 0 0],'Marker',MarkerChosen);hold on
                        else
                            fill(timeplot,signalplot,[(1-Intensidad) (1-Intensidad) (1-Intensidad)],'Marker',MarkerChosen);hold on
                        end
                    end
                end
            end

            if ~isempty(Parameters.ErrorbarData)&&~isempty(signalplot)
                errorval=Parameters.ErrorbarData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3));
                 errorval=errorval(idx); 
                while numel(errorval)<numel(signalplot)
                 errorval=[errorval 0];
                end
                plot(timeplot,signalplot+errorval,'LineStyle','none','Marker','+');
                plot(timeplot,signalplot-errorval,'LineStyle','none','Marker','+');
            end

            %% Plot Error bars
            %if ~isempty(Parameters.ErrorbarData)
            %    errorplot=Parameters.ErrorbarData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3));
            %    plot(timeplot(1:(end-2)),(signalplot(1:(end-2))+errorplot),'Marker','+','MarkerSize',2,'Color','k','LineStyle','none');hold on
            %    plot(timeplot(1:(end-2)),(signalplot(1:(end-2))- errorplot),'Marker','+','MarkerSize',2,'Color','k','LineStyle','none');hold on
            %    for i=1:numel(timeplot(1:(end-2)))
            %        line ([timeplot(i) timeplot(i)],[signalplot(i)-errorplot(i), signalplot(i)+errorplot(i)],'LineStyle',':','Color','k');hold on
            %    end
            %end

            %% Define limits in y axis---------------------------------------------
            try
                if Parameters.Dims2Exp(1)==5
                    MaxSig=max(max(max(max(PlotData(:,:,Parameters.OrderMeasu(dim1),:,:)))));
                elseif Parameters.Dims2Exp(2)==5
                    MaxSig=max(max(max(max(PlotData(:,:,:  ,Parameters.OrderMeasu(dim2),:)))));
                else
                    MaxSig=max(max(max(max(PlotData(:,:,:  ,: ,Parameters.OrderMeasu(dim3))))));
                end

                if Parameters.MinYMax>MaxSig
                    MaxYPlot=Parameters.MinYMax;
                else
                    MaxYPlot=MaxSig;
                end
            end
            if  strcmp(Parameters.Plot2D,'yes')
                xlim('auto')
            else
                xlim(timeplotLimits)
            end
            if strcmp(Parameters.Plot2D,'yes')
                ylim('auto')
                zlim([0 MaxYPlot*1.1])
            else
                if Parameters.CouplePlots==1
                    if MaxYPlot>0
                        ylim([0 MaxYPlot*1.1])
                    end
                else
                    try
                        MaxP=nanmax([PlotData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3)) 0 0]);
                        ylim([0 MaxP])
                        MaxYPlot=MaxP;
                    end
                end
            end
            %% Plot Heat Map
            if strcmp(Parameters.HeatMap,'yes')
                if strcmp(Parameters.PlotMean,'yes')
                    intensid=1-nanmean(signalplot)/MaxYPlot;
                    grad=hot(1001);
                    try%if there is a NaN it does no plot
                        PlottingCol=grad(round(intensid*1000)+1,:);
                        fill([0 0 max(timeplot) max(timeplot)],[0 MaxYPlot MaxYPlot 0],PlottingCol,'Marker',MarkerChosen);
                    end
                    hold on
                else
                    %pcolor plots values equally distributed in x axis, we have thus to interpolate
%                     interv=timeplot(end-2)./10;
%                     vals=interp1(timeplot(1:(end-2)),signalplot(1:(end-2)),timeplot(1):interv:timeplot(end-2));
%                     hold off
%                     pcolor([vals; vals])
%                     shading interp

%                     % Arthur's pcolor approach:
                    xvals = [timeplot;timeplot];
                    yvals = repmat(ylim',1,size(xvals,2));
                    cvals = [signalplot; signalplot];
                    pcolor(xvals,yvals,cvals);
%                     colormap hot

                    hold on
                end
            end

            %% - define X Label--------------------------------------
            if dim3==size(PlotData,5)
                if strcmp(Parameters.PlotLumped,'yes')
                    if strcmp(Parameters.Plot2D,'yes')
                        if   Parameters.Dims2Exp(2)==5
                            set(gca,'YTickLabel',Labels(Parameters.Dims2Exp(2)).Value{Parameters.OrderMeasu},'FontSize',Parameters.FontSizeYlabel);
                        else
                            set(gca,'YTickLabel',Labels(Parameters.Dims2Exp(2)).Value,'FontSize',Parameters.FontSizeYlabel);
                        end
                    else
                        if size(timeplot)<4
                            set(gca,'XTick',     [0, max(timeplot)]);
                            set(gca,'XTickLabel',[0, max(timeplot)],'FontSize',Parameters.FontSizeXlabel);
                        elseif  size(timeplot)<6
                            set(gca,'XTick',     [0, round(max(timeplot)/2) max(timeplot)]);
                            set(gca,'XTickLabel',[0, round(max(timeplot)/2),max(timeplot)],'FontSize',Parameters.FontSizeXlabel);
                        elseif  size(timeplot)<8
                            set(gca,'XTick',     [0, round(max(timeplot)/3) round(max(timeplot)/3)*2, max(timeplot)]);
                            set(gca,'XTickLabel',[0, round(max(timeplot)/3),round(max(timeplot)/3)*2, max(timeplot)],'FontSize',Parameters.FontSizeXlabel);
                        else
                            set(gca,'XTick',     [0, round(max(timeplot)/4) round(max(timeplot)/4)*2, round(max(timeplot)/4)*3, max(timeplot)]);
                            set(gca,'XTickLabel',[0, round(max(timeplot)/4),round(max(timeplot)/4)*2, round(max(timeplot)/4)*3, max(timeplot)],...
                                'FontSize',Parameters.FontSizeXlabel);
                        end
                    end
                else
                    if strcmp(Parameters.HeatMap,'yes')
                        set(gca,'XTick',5);
                    else                
                            xlimits=get(gca,'xlim');
                            set(gca,'XTick',max(xlimits)./2);                                 
                    end
                    if   Parameters.Dims2Exp(2)==5
                        set(gca,'XTickLabel',Labels(Parameters.Dims2Exp(2)).Value{Parameters.OrderMeasu(dim2)},'FontSize',6);
                    elseif size(PlotData,4) ==1
                        set(gca,'XTickLabel',Labels(Parameters.Dims2Exp(2)).Value,'FontSize',6);
                    else
                        set(gca,'XTickLabel',Labels(Parameters.Dims2Exp(2)).Value{dim2},'FontSize',6);
                    end
                    th=rotateticklabel(gca,90);
                end
            else
                set(gca,'XTickLabel',{});
            end

            %% - define Y Label----------------------------------------
            if (dim1==1&dim2==1)|(dim1==1&strcmp(Parameters.PlotLumped,'yes'))
                if strcmp(Parameters.Plot2D,'yes')
                    set(gca,'ZTick' ,MaxYPlot./2); %only 1 tick in middle point            t
                    if Parameters.Dims2Exp(3)==5
                        set(gca,'ZTickLabel',[Labels(Parameters.Dims2Exp(3)).Value{Parameters.OrderMeasu(dim3)}],'FontSize',Parameters.FontSizeZlabel);
                    else
                        set(gca,'ZTickLabel',[Labels(Parameters.Dims2Exp(3)).Value{dim3}],'FontSize',Parameters.FontSizeZlabel);
                    end
                else
                    if strcmp(Parameters.PlotMean,'yes')|~strcmp(Parameters.HeatMap,'yes')
                        set(gca,'YTick' ,MaxYPlot./2); %only 1 tick in middle point
                    else%with the heat map the ylim is not the same as data's
                        set(gca,'YTick' ,(max(ylim)+min(ylim))./2); %only 1 tick in middle point
                    end
                    if Parameters.Dims2Exp(3)==5
                        set(gca,'YTickLabel',[Labels(Parameters.Dims2Exp(3)).Value{Parameters.OrderMeasu(dim3)}],'FontSize',Parameters.FontSizeZlabel);
                    else
                        set(gca,'YTickLabel',[Labels(Parameters.Dims2Exp(3)).Value{dim3}],'FontSize',Parameters.FontSizeZlabel);
                    end
                end
            elseif    dim1==size(PlotData,3)&dim2==size(PlotData,4)
                if Parameters.Dims2Exp(3)==5%only put max Signal on right if the signal is changed in lines otherwise makes no sense
                    if strcmp(Parameters.PlotMean,'yes')|~strcmp(Parameters.HeatMap,'yes')
                        set(gca,'YTick' ,MaxYPlot./2);
                    else
                        set(gca,'YTick' ,(max(ylim)+min(ylim))./2); %only 1 tick in middle point
                    end
                    if MaxYPlot>1000
                        set(gca,'YTickLabel',100*round(MaxYPlot./100.),'FontSize',10);
                    elseif MaxYPlot>100
                        set(gca,'YTickLabel',10*round(MaxYPlot./10.),'FontSize',10);
                    else
                        set(gca,'YTickLabel',round(MaxYPlot),'FontSize',10);
                    end
                    set(gca,'YAxisLocation','right');
                else
                    set(gca,'YTickLabel',{});
                end
            else
                if strcmp(Parameters.Plot2D,'yes')
                    set(gca,'ZTickLabel',{});
                end
                set(gca,'YTickLabel',{});
            end

            %% - define Title----------------------------------------
            if Parameters.Dims2Exp(1)~=5
                if dim3==1&dim2==floor(size(PlotData,4)/2+1)
                    if Parameters.Dims2Exp(3)==3
                        title(Labels(Parameters.Dims2Exp(1)).Value{Parameters.OrderMeasu(dim1)},'FontSize',12)
                    elseif size(PlotData,3) ==1
                        title(Labels(Parameters.Dims2Exp(1)).Value,'FontSize',12)
                    else
                        title(Labels(Parameters.Dims2Exp(1)).Value{dim1},'FontSize',12)
                    end
                end
            else
                if dim3==1&dim2==floor(size(PlotData,4)/2+1)
                    if Parameters.Dims2Exp(1)==5
                        if MaxYPlot>1000
                            Num=100*round(MaxYPlot./100.);
                        elseif MaxYPlot>100
                            Num=10*round(MaxYPlot./100.);
                        else
                            Num=round(MaxYPlot./100.);
                        end
                        NewTitle=[Labels(Parameters.Dims2Exp(1)).Value{dim1} '\n' num2str(Num)];
                        title(sprintf(NewTitle),'FontSize',12)
                    elseif size(PlotData,3) ==1
                        title(Labels(Parameters.Dims2Exp(1)).Value,'FontSize',12)
                    else
                        title(Labels(Parameters.Dims2Exp(1)).Value{dim1},'FontSize',12)
                    end
                end

            end

            if strcmp(Parameters.PlotMean,'yes')&&strcmp(Parameters.HeatMap,'no')
                xlim([0 max(timeplot)])
            end

            if Parameters.PlotPairsOfDrugs==1
                %background color for toxic drugs
                if floor((dim2-1)/2)~=(dim2-1)/2
                    set(gca,'Color',[.84 .84 1])
                end
            end
            % To add a line to all plots flat: Reference=.3;plot(timeplot,Reference*ones(size(timeplot)));hold on
            %% Plot Background color
            if  strcmp(Parameters.BackgDeactiv,'boolean')
                Switcher=isempty(find(BoolData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3))))~=1;
            elseif strcmp(Parameters.BackgDeactiv,'noise')
                Switcher=max([refplot signalplot])>Parameters.MinYMax;
            end

            if ~isempty(find(~isnan(Parameters.Reference)))&&strcmp(Parameters.Background,'y')&&Switcher==1
                if Relatio<1% Red if Ref>Signal
                    if Relatio<0
                        ColorBack=[1 0.4 0.4];
                    else
                        ColorBack=[1 Relatio Relatio];
                    end
                    backplot=[refplot(1:end-2) MaxYPlot MaxYPlot];
                elseif Relatio>1 %blue if Ref<Signal
                    Relatio=1/Relatio;
                    if Relatio<0
                        ColorBack=[ 0.4 0.4 1];
                    elseif Relatio>1
                        ColorBack=[1 0.4 0.4];
                    else
                        ColorBack=[Relatio Relatio 1];
                    end
                end
                backplot=[signalplot(1:end-2) MaxYPlot*1.1 MaxYPlot*1.1];
                if isnan(Relatio)
                    ColorBack=[1 1 1];%white background
                end
                if Relatio~=1
                    fill(timeplot,backplot,ColorBack,'Marker',MarkerChosen);hold on
                end
            end           
            
            
            %% Plot reference treatment
            if isempty(find(~isnan(Parameters.Reference)))~=1 && ~isempty(signalplot)
                idx=~isnan(refplot);                
                timeplotref=[timeplotor(idx) max(timeplotor(idx)) min(timeplotor(idx))];
                if isempty(timeplotref)
                    refplot = zeros(1,0);                    
                else
                    refplot=[refplot(idx) 0 0];
                end                
                plot(timeplotref,refplot,'Color','k','LineStyle','-')
                hold on
            end
        end
        %% - Make Big X if ALL NaN-Not working, disabled-----------------------------------------
        %{
        if numel(nonzeros(isnan(PlotData(Parameters.DimFixed(2), :,dim1,dim2,dim3))))==numel(PlotData(Parameters.DimFixed(2), :,dim1,dim2,dim3))
            plot([0 max(timeplot)],[0 MaxYPlot],'Color',[1 0 0],'LineWidth',2);hold on
            plot([0 max(timeplot)],[MaxYPlot 0],'Color',[1 0 0],'LineWidth',2);hold on
            set(gca,'XTickLabel',{}); set(gca,'YTickLabel',{});
            xlim(timeplotLimits)
%             warning(['No Data available for ' Labels(Parameters.Dims2Exp(1)).Value{dim1} '-'...
%                 Labels(Parameters.Dims2Exp(2)).Value{dim2} '-' Labels(Parameters.Dims2Exp(3)).Value{dim3}])
            disp(['No Data available for ' Labels(Parameters.Dims2Exp(1)).Value{dim1} '-'...
                Labels(Parameters.Dims2Exp(2)).Value{dim2} '-' Labels(Parameters.Dims2Exp(3)).Value{dim3}])

            %% -
        end
        %}
        hold on
    end
end

%% legend for lumped plotting
if strcmp(Parameters.PlotLumped,'yes')&&strcmp(Parameters.Plot2D,'no')
    legend(Labels(Parameters.Dims2Exp(2)).Value,'Location','EastOutside')
end

