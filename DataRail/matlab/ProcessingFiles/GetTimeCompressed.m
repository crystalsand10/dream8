function [RedData Parameters] =GetTimeCompressed(QuantData,OldParameters)
% compresses data cube of n time points into 2 or 3 + 0 timepoing
%
% RedData =GetTimeCompressed(QuantData,Parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS: 
%
% QuantData = a canonical datacube
%
% Parameters 
%         .EarlyTimes(2)  = indices of time points lumped into early time point
%         .LateTimes(3)   = indices of time points lumped into late time points
%         .MidTimes()     = indices of time points lumped into middle time points
%                           if empty creates a 2 + t0 timepoints
%         .Criterion(max) ='max' for taking the 'maximun' for early events
%                           (to catch the peak)
%                           or 'mean' for the mean. For the rest is the
%                           mean
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Parameters.EarlyTimes=[ 1 2 3]
% Parameters.LateTimes=[4]
% Parameters.MidTimes=[];
%
% Data.data(4).Value=GetTimeCompressed(Data.data(3).Value,Parameters)
%
% OR
%
% Data.data(5) = createDataCube(...
%    'Name', 'BackgroundSComp', ...
%    'Info', 'data compressed into 2 time points', ...
%    'Labels', ChrisData.Labels, ...
%    'Code', @GetTimeCompressed,...
%    'Parameters',{'EarlyTimes',[2 3 4 5
%    6],'LateTimes',[7:10],'Criterion','max'},...    
%    'SourceData', Data.data(Data.v.RemovedInputEqOutput));   
%
%--------------------------------------------------------------------------
% TODO:
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
DefaultParameters = struct(...
    'EarlyTimes',2,...
    'LateTimes', 3,...
    'MidTimes',  [],...
    'Labels', [],...%struct('Name','Time','Value',[0 1 2])
    'Criterion','max');

Parameters = setParameters(DefaultParameters, OldParameters);

if any(Parameters.EarlyTimes == 1) || any(Parameters.LateTimes == 1) || ...
        any(Parameters.LateTimes == 1)
    warning('The initial time point (possibly t=0) has been included in one of the time sacles times.');
end

if isempty(Parameters.MidTimes)
    RedData=NaN(size(QuantData,1),3,size(QuantData,3),size(QuantData,4),size(QuantData,5));
    Parameters.Labels(2).Value=[0 1 2]';
else
    RedData=NaN(size(QuantData,1),4,size(QuantData,3),size(QuantData,4),size(QuantData,5));
    Parameters.Labels(2).Value=[0 1 2 3]';
end


for cell=1:size(QuantData,1)
    for measure=1:size(QuantData,5)
        for cyt=1:size(QuantData,3)
            for inh=1:size(QuantData,4)
                % Copying initial time data
                RedData(cell,1,cyt,inh,measure)=     QuantData(cell,1,cyt,inh,measure);
                if strcmp(Parameters.Criterion,'max')
                    RedData(cell,2,cyt,inh,measure)=max(QuantData(cell,Parameters.EarlyTimes,cyt,inh,measure));
                else
                    RedData(cell,2,cyt,inh,measure)=mean(QuantData(cell,Parameters.EarlyTimes,cyt,inh,measure));
                end
                if isempty(Parameters.MidTimes)
                    RedData(cell,3,cyt,inh,measure)=mean(QuantData(cell,Parameters.LateTimes,cyt,inh,measure));
                else
                    RedData(cell,3,cyt,inh,measure)=mean(QuantData(cell,Parameters.MidTimes,cyt,inh,measure));
                    RedData(cell,4,cyt,inh,measure)=mean(QuantData(cell,Parameters.LateTimes,cyt,inh,measure));
                end
            end
        end
    end
end

