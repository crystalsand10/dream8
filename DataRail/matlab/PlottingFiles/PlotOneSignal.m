function PlotOneSignal(Labels,PlotData,BoolData,RelatData,CellType,Measurement,Parameters)

%
% --------------------------------------------------------------------------
%    function PlotOneSignal(Labels,PlotData,BoolData,CellType,Measurement)
%
%    03/26/07 J. Saez 
%    Function to plot in a set of subplots data coloured
% --------------------------------------------------------------------------  
%
%   green  = sustained
%   yellow = transient
%   magenta   = late
%   grey   = no significant signal
%
% intensity related to strength of signal (relative to others for the same measurement) 
%
% BoolData and RelatData are optional, e.g.
% figure;PlotOneSignal(LeoData.data.Labels,LeoData.CubeNormBSA,[],[],CellType,Measu)
%
% Parameters.TimeScale=1 %1 real, [0 1 2] else  
% Parameters.MinYMax=500
% Parameters.ShowRed=1 %shows it


if max(size(BoolData))==0 
   BoolData=zeros(size(PlotData));
end
if max(size(RelatData))==0
    RelatData=ones(size(PlotData));
end

if isempty(Parameters.TimeScale)==1
  Parameters.TimeScale=0  ;
end


cell=1;
while strcmp(CellType,Labels(1).Value{cell})~=1  
    cell=cell+1;
end
measu=1;
while strcmp(Measurement,Labels(5).Value{measu})~=1  
    measu=measu+1;
end


for cyt=1:size(Labels(3).Value,2)
    for inh=1:size(Labels(4).Value,2)
        subplot(size(Labels(3).Value,2),size(Labels(4).Value,2),(cyt-1)*8+inh),...     
         if Parameters.TimeScale==1 
          timeplot=[Labels(2).Value Labels(2).Value(end) 0];
         else
          timeplot=[0 1 2 2 0];
        end
        
        signalplot=[PlotData(cell,:,cyt,inh,measu) 0 0];
        %Use Fill with different color for different behavior
        if BoolData(cell,2,cyt,inh,measu)==1
            if BoolData(cell,3,cyt,inh,measu)==1
%               %sustained=green
                fill(timeplot,signalplot,[(1-RelatData(cell,2,cyt,inh,measu)) 1 (1-RelatData(cell,2,cyt,inh,measu))]);hold on
            else
                %transient=yellow
                fill(timeplot,signalplot,[1 1 (1-RelatData(cell,2,cyt,inh,measu))]);hold on
            end   
        else            
            if BoolData(cell,3,cyt,inh,measu)==1    
                %late=magenta
                fill(timeplot,signalplot,[(1-RelatData(cell,2,cyt,inh,measu)) (1-RelatData(cell,2,cyt,inh,measu)) 1]);hold on
            else
              % no signal-grey
                fill(timeplot,signalplot,[(1-RelatData(cell,2,cyt,inh,measu)) (1-RelatData(cell,2,cyt,inh,measu)) (1-RelatData(cell,2,cyt,inh,measu))]);hold on                   
            end
        end

        if inh==1
            ylabel([Labels(3).Value{cyt}])
        else            
            set(gca,'YTickLabel',{});
        end
        if cyt==size(Labels(3).Value,2)&Parameters.TimeScale ==1
              xlabel('time(min)')
        else
            set(gca,'XTickLabel',{});            
        end
        if cyt==1
            title(Labels(4).Value{inh})
        end        
        xlim([0 max(Labels(2).Value)])
        try%avoids error if all data is 0
            ylim([0 max(max(max(PlotData(cell,:,:  ,: ,measu))))])
        end
    end
end
suptitle_withpatch([Labels(5).Value{measu} '(au)'  '-' Labels(1).Value{cell} ])%Global title

%set(gcf,'Position',[0  20   1000  1150])Pr
