function PlotRefSignalsCompact(Labels,PlotData,BoolData,RelatData,Parameters)

%
%--------------------------------------------------------------------------
%   function PlotRefSignalsCompact(Labels,PlotData,BoolData,RelatData,Parameters)
%
%   04/03/07 J. Saez
%   Function to plot on top of PlotAllSignalsCompact two reference lines
%
%%--------------------------------------------------------------------------
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
% Parameters.Reference=[vector1;vector2]
% Parameters.VersionPlot=2
% Parameters.XTransform            % function handle to a transformation to apply to X values
% Parameters.YTransform            % function handle to a transformation to apply to Y values

try,   Parameters.VersionPlot;
catch, Parameters.VersionPlot=2;
end

if max(size(BoolData))==0
    BoolData=zeros(size(PlotData));
end
if max(size(RelatData))==0
    RelatData=ones(size(PlotData));
end

%try,    Parameters.Reference catch,    Parameters.Reference=[1 1; 1 1];end

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

try,    Parameters.XTransform;
catch,  Parameters.XTransform = [];
end

try,    Parameters.YTransform;
catch,  Parameters.YTransform = [];
end

if  Parameters.OrderMeasu~=[1:1:size(PlotData,5)]&Parameters.Dims2Exp(3)~=5
    error('The Reordering of the signals can only be used if they are in the 5th dimension')
end




%Permute data in accordance to parameters
PlotData=permute(PlotData,  [Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);
RelatData=permute(RelatData,[Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);
BoolData=permute(BoolData,  [Parameters.DimFixed(1) 2 Parameters.Dims2Exp]);

%% Define the x-data
xData = Labels(2).Value;
xDataZero = 0;
% Transform data, if necessary
if ~isempty(Parameters.XTransform)
    xData = Parameters.XTransform(xData);
    xDataZero = Parameters.XTransform(xDataZero);
end
if ~isempty(Parameters.YTransform)
    PlotData = Parameters.YTransform(PlotData);
end

for dim3=1:size(PlotData,5)
    dim3    
    for dim1=1:size(PlotData,3)
        for dim2=1:size(PlotData,4)
            %boxes must agree with main plot
            if Parameters.VersionPlot==2
                Fwidth= 1/ (size(PlotData,3)*size(PlotData,4)+size(PlotData,3)+7);
                Fheight= 1/(round(size(PlotData,5)*1.3)+7);
                posx=((dim1-1)*size(PlotData,4)+dim2+dim1+3)*Fwidth;
                posy=(1-(dim3*1.3+2)*(Fheight));
            elseif Parameters.VersionPlot==1
                Fwidth= 1/ (size(PlotData,3)*size(PlotData,4)+size(PlotData,3)+7);
                Fheight= 1/(size(PlotData,5)+5);%Labels(Parameters.Dims2Exp(3)).Value,2)+5));
                posx=((dim1-1)*size(PlotData,4)+dim2+dim1+3)*Fwidth;
                posy=(1-(dim3+1)*(Fheight));
            end

            pos=[posx posy Fwidth Fheight ];
            subplot('Position',pos),...

        if  Parameters.TimeScale==1
            timeplot=[xData xData(end) 0];
        else
            timeplot=[0:1:(max(size(xData))-1) (max(size(xData))-1) 0];%
        end        

        signalplot=[Parameters.Reference(1,:,:,:,dim3) 0 0];
        plot(timeplot,signalplot,'Color','k','LineStyle','-','LineWidth',2)
        hold on
        if size(Parameters.Reference,1)==2
            signalplot=[Parameters.Reference(2,:,:,:,dim3) 0 0 ];
            plot(timeplot,signalplot,'Color','k','LineStyle','-.','LineWidth',2)
            hold on                  
        end

        end
        hold on    
        end
    end
end

