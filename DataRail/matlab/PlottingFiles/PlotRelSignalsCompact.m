function PlotRelSignalsCompact(Labels,PlotData,BoolData,RelatData,Parameters)

%
%--------------------------------------------------------------------------
%   function PlotAllSignalsCompact(Labels,PlotData,BoolData,RelatData,Parameters)
%
%   04/03/07 J. Saez
%   Function to plot in a set of subplots data coloured, compacted to save
%   space, no labels though
%--------------------------------------------------------------------------
%
%   green  = sustained
%   yellow = transient
%   magenta   = late
%   grey   = no significant signal
%
% intensity related to strength of signal (relative to others for the same measurement)
%
% BoolData and RelatData are optional, e.g.
% figure;PlotAllSignals(LeoData.data.Labels,LeoData.CubeNormBSA,[],[],Parameters)
%
% Optional parameters
%
% Parameters.TimeScale=1 % 1 real, [0 1 2] else  %(default 1)
% Parameters.MinYMax=500                      % default 25
% Parameters.ShowRed=1 %shows it              %default 1
% Parameters.OrderMeasu=[14 1 15 2 8 11 7 6 13 4 5 10 16 3 12 9 17];
% Parameters.Intensity=1 2    %1 related to max;2 related to change (Jeremy's suggestion)     %default 1
% Parameters.Dims2Exp=[3 4 5]
% Parameters.DimFixed=[1 1]
% Parameters.Redder=0.7;
% Parameters.CouplePlots=1;
% Parameters.Consistency=0.95;

try
    Parameters.Consistency
catch
    Parameters.Consistency=0.9;
end
try
    Parameters.CouplePlots;
catch
    Parameters.CouplePlots=1;
end

if max(size(BoolData))==0
    BoolData=zeros(size(PlotData));
end
if max(size(RelatData))==0
    RelatData=ones(size(PlotData));
end

try
    Parameters.TimeScale;
catch
    Parameters.TimeScale=0  ;
end
try
    Parameters.MinYMax;
catch
    Parameters.MinYMax=500  ;
end
try
    Parameters.ShowRed;
catch
    Parameters.ShowRed=1  ;
end
try, Parameters.Dims2Exp;
catch
    Parameters.Dims2Exp=[3 4 5]  ;
end
try
    Parameters.DimFixed;
catch
    Parameters.DimFixed=[1 1]  ;
end
try
    Parameters.OrderMeasu;
catch
    Parameters.OrderMeasu=[1:1:size(PlotData,5)];
end

try
    Parameters.TimeScale;
catch
    Parameters.TimeScale=1;
end

try
    Parameters.ShowRed;
catch
    Parameters.ShowRed=1;
end

try
    Parameters.MinYMax;
catch
    Parameters.MinYMax=25;
end

try
    Parameters.Intensity;
catch
    Parameters.Intensity=1;
end

try
    Parameters.Redder;
catch
    Parameters.Redder=0.7;
end

if  Parameters.OrderMeasu~=[1:1:size(PlotData,5)]&Parameters.Dims2Exp(3)~=5
    error('The Reordering of the signals can only be used if they are in the 5th dimension')
end

%Permute data in accordance to parameters
PlotData=permute(PlotData,  [Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);
RelatData=permute(RelatData,[Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);
BoolData=permute(BoolData,  [Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);

for dim3=1:size(PlotData,5)
    dim3    
    for dim1=1:size(PlotData,3)
        for dim2=1:size(PlotData,4)
            Fwidth= 1/ (size(PlotData,3)*size(PlotData,4)+size(PlotData,3)+7);
            posx=((dim1-1)*size(PlotData,4)+dim2+dim1+3)*Fwidth;
            Fheight= 1/(round(size(PlotData,5)*1.3)+7);
            posy=(1-(dim3*1.3+2)*(Fheight));
            
            pos=[posx posy Fwidth Fheight ];
            subplot('Position',pos),...

        if  Parameters.TimeScale==1
            timeplot=[Labels(2).Value Labels(2).Value(end) 0];
        else
            timeplot=[0:1:(max(size(Labels(2).Value))-1) (max(size(Labels(2).Value))-1) 0];%
        end
        signalplot=[PlotData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3)) 0 0];

        %Use Fill with different color for different behavior

        %intensity max of all values for Parameters.Intensity=1
        Intensidad=nanmax(abs(RelatData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3))));
        
        if isnan(Intensidad)==1|Intensidad<0
            Intensidad=[1 1 1];
            warning('Color Intensity not computable')
        end

        %Integrate over time the signal
        v=       PlotData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3));
        vabs=abs(PlotData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3)));
        r=Labels(2).Value;
        Senal=(v*(r)'-v([2:end])*r([1:(end-1)])')/Labels(2).Value(end);
        SenalAbs=(vabs*(r)'-vabs([2:end])*r([1:(end-1)])')/Labels(2).Value(end);               
        Consistencia=abs(Senal)/SenalAbs;

        
%% ------------Plot--------------------------------------------        
        if isempty(nonzeros(isnan(PlotData(Parameters.DimFixed(2), :,dim1,dim2,dim3))))==0
                    warning(['No Data available for ' Labels(Parameters.Dims2Exp(1)).Value{dim1} '-'...
                        Labels(Parameters.Dims2Exp(2)).Value{dim2} '-' Labels(Parameters.Dims2Exp(3)).Value{dim3}])
        elseif Senal>0&Consistencia>Parameters.Consistency% (min(signalplot(2:end))>0|min(signalplot(2:end))==0)&Consistencia>Parameters.Consistency
                    %Prim larger=green                   
                    fill(timeplot,signalplot,[(1-Intensidad) 1 (1-Intensidad)]);hold on
        elseif Senal<0&Consistencia>Parameters.Consistency%max(signalplot(2:end))<0|max(signalplot(2:end))==0&Consistencia>Parameters.Consistency
                    fill(timeplot,signalplot,[1 (1-Intensidad) 1]);hold on
        else            
                    %unclear yellow
                    fill(timeplot,signalplot,[1 1 (1-Intensidad)]);hold on
        end
          

%% Define limits in y axis---------------------------------------------
        try
            if Parameters.Dims2Exp(1)==5
                MaxSig=max(max(max(max(abs(PlotData(:,:,Parameters.OrderMeasu(dim1),:,:))))));
            elseif Parameters.Dims2Exp(2)==5
                MaxSig=max(max(max(max(abs(PlotData(:,:,:  ,Parameters.OrderMeasu(dim2),:))))));
            else
                MaxSig=max(max(max(max(abs(PlotData(:,:,:  ,: ,Parameters.OrderMeasu(dim3)))))));
            end

            if Parameters.MinYMax>MaxSig
                MaxYPlot=Parameters.MinYMax;
            else
                MaxYPlot=MaxSig;
            end
        end
        if Parameters.CouplePlots==1
            ylim([-MaxYPlot MaxYPlot]) 
        else
            try
                MaxP=nanmax([abs(PlotData(Parameters.DimFixed(2),:,dim1,dim2,Parameters.OrderMeasu(dim3))) 0 0]);
                ylim([-MaxP MaxP]);
                MaxYPlot=MaxP;
             end
        end
        %set(gca,'FontSize',5);
        
%% - define X Label--------------------------------------
        if dim3==size(PlotData,5)
            set(gca,'XTick',max(timeplot)./2);
            if   Parameters.Dims2Exp(2)==3
                set(gca,'XTickLabel',Labels(Parameters.Dims2Exp(2)).Value{Parameters.OrderMeasu(dim2)},'FontSize',6);
            elseif size(PlotData,4) ==1
                set(gca,'XTickLabel',Labels(Parameters.Dims2Exp(2)).Value,'FontSize',6);
            else
                set(gca,'XTickLabel',Labels(Parameters.Dims2Exp(2)).Value{dim2},'FontSize',6);
            end
            th=rotateticklabel(gca,90);
        else
            set(gca,'XTickLabel',{});
        end
%% - define Y Label----------------------------------------
        if dim1==1&dim2==1
            set(gca,'YTick' ,MaxYPlot./2); %pon solo 1 tick, y en punto medio
            if Parameters.Dims2Exp(3)==5                
                set(gca,'YTickLabel',[Labels(Parameters.Dims2Exp(3)).Value{Parameters.OrderMeasu(dim3)}],'FontSize',12);
            else                
                set(gca,'YTickLabel',[Labels(Parameters.Dims2Exp(3)).Value{dim3}],'FontSize',12);
            end

        elseif    dim1==size(PlotData,3)&dim2==size(PlotData,4)
            if Parameters.Dims2Exp(3)==5%only put max Signal on right if the signal is changed in lines otherwise makes no sense
                set(gca,'YTick' ,MaxYPlot./2);
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
                    NewTitle=[Labels(Parameters.Dims2Exp(1)).Value{Parameters.OrderMeasu(dim1)} '\n' num2str(Num)];
                    title(sprintf(NewTitle),'FontSize',12)
                elseif size(PlotData,3) ==1
                    title(Labels(Parameters.Dims2Exp(1)).Value,'FontSize',12)
                else
                    title(Labels(Parameters.Dims2Exp(1)).Value{dim1},'FontSize',12)
                end
            end

        end


        xlim([0 max(timeplot)])
        
        
%% - Make Big X if ALL NaN------------------------------------------     
        if numel(nonzeros(isnan(PlotData(Parameters.DimFixed(2), :,dim1,dim2,dim3))))==numel(PlotData(Parameters.DimFixed(2), :,dim1,dim2,dim3))            
                    plot([0 max(timeplot)],[-MaxYPlot MaxYPlot],'Color',[1 0 0],'LineWidth',2);hold on
                    plot([0 max(timeplot)],[MaxYPlot MaxYPlot],'Color',[1 0 0],'LineWidth',2);hold on
                    set(gca,'XTickLabel',{}); set(gca,'YTickLabel',{});
                    xlim([0 max(timeplot)])
                    warning(['No Data available for ' Labels(Parameters.Dims2Exp(1)).Value{dim1} '-'...
                        Labels(Parameters.Dims2Exp(2)).Value{dim2} '-' Labels(Parameters.Dims2Exp(3)).Value{dim3}])
         
%        elseif isempty(nonzeros(isnan(PlotData(Parameters.DimFixed(2), :,dim1,dim2,Parameters.OrderMeasu(dim3)))))==0
%            plot([0 max(timeplot)],[0 MaxYPlot],'Color',[1 0 0],'LineWidth',2);hold on
%            plot([0 max(timeplot)],[MaxYPlot 0],'Color',[1 0 0],'LineWidth',2);hold on
%            disp(['No Data available for ' Labels(3).Value{dim1} '-' Labels(4).Value(dim2) '-' Labels(5).Value{dim3}])
%% -
        end
        hold on    
        plot([0 max(timeplot)],[0 0],'Color',[0 0 0],'LineWidth',2);hold on
        end
    end
end

