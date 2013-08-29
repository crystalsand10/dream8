function PlotOneCue(Labels,PlotData,BoolData,RelatData,CellType,Cue,Parameters)

%
%--------------------------------------------------------------------------
%   function PlotOneCue(Labels,PlotData,BoolData,RelatData,CellType,Cue,Parameters)
%
%   03/26/07 J. Saez 
%   Function to plot in a set of subplots data coloured 
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
% figure;PlotOnecue(LeoData.data.Labels,LeoData.CubeNormBSA,[],[],CellType,Cue)
%
% Parameters.TimeScale=1 %real, [0 1 2] else  
% Parameters.MinYMax=500
% Parameters.ShowRed=1 %shows it


if max(size(BoolData))==0
    BoolData=zeros(size(PlotData));
end
if max(size(RelatData))==0
    RelatData=ones(size(PlotData));
end

try, Parameters.TimeScale
catch
  Parameters.TimeScale=0  ;
end
try, Parameters.MinYMax
catch
  Parameters.MinYMax=500  ;
end
try, Parameters.ShowRed
catch
  Parameters.ShowRed=1  ;
end

cell=1;
while strcmp(CellType,Labels(1).Value{cell})~=1  
    cell=cell+1;
end
cyt=1;
while strcmp(Cue,Labels(3).Value{cyt})~=1  
    cyt=cyt+1;
end



for measu=1:size(Labels(5).Value,2)
    for inh=1:size(Labels(4).Value,2)
        subplot(size(Labels(5).Value,2),size(Labels(4).Value,2),(measu-1)*8+inh),...     
        
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
                fill(timeplot,signalplot,[1 (1-RelatData(cell,2,cyt,inh,measu)) 1]);hold on
            else
                % no signal-grey-but check before if signal goes down and
                % then red
                if RelatData(cell,2,cyt,inh,measu)/RelatData(cell,1,cyt,inh,measu)<0.7&Parameters.ShowRed==1
                     fill(timeplot,signalplot,[1 0 0]);hold on                                     
                else 
                    fill(timeplot,signalplot,[(1-RelatData(cell,2,cyt,inh,measu)) (1-RelatData(cell,2,cyt,inh,measu)) (1-RelatData(cell,2,cyt,inh,measu))]);hold on                   
                end
            end
        end

        if inh==1
            ylabel([Labels(5).Value{measu}])
        else            
            set(gca,'YTickLabel',{});
        end
        if measu==size(Labels(5).Value,2)&inh==1&Parameters.TimeScale ==1
            xlabel('time(min)')
        else
            set(gca,'XTickLabel',{});            
        end
        if measu==1
            title(Labels(4).Value{inh})
        end        
        xlim([0 max(timeplot)])
        
        try
             MaxSig=max(max(max(max(PlotData(:,:,:  ,: ,measu)))));
             if Parameters.MinYMax>MaxSig
               ylim([0 Parameters.MinYMax])
             else
                  ylim([0 MaxSig])
             end                
        end   
    end
end
suptitle_withpatch([Labels(3).Value{cyt} '-' Labels(1).Value{cell}])%Global title
%set(gcf,'Position',[0  20   1000  1150])