function NewCube=ExpandCubeto2D(OldCube,OldParameters)
% ExpandCubeto2D converts a 5D data array into a 2D matrix for e.g. Multiple regression or PLSR
%
%  NewCube=ExpandCubeto2D(OldCube,Parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS (Syntax 1):
% OldCube  =  5-dimensional data cube in the canonical form
%
% % Parameters
%           .DimFixed=[1 1]
%           .dim2={'EGF,','TGF',...}
%           .dim3={'PI3Ki'} with or without i
%           .Metric can be 'none', 'mean', 'AUC', or 'Differential', 'slope', 'tim2', 'time3'

%           .Labels
%
% OUTPUTS:
% Compendium = new compendium
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  e.g.
%
%
%  Res:
%         Labels(1).Value:      {10x1 cell}
%         Labels(2).Value:      {7x1 cell}
%         Labels(4).Value:     {17x1 cell}
%         ScenarioNames: {1x88 cell}
%         Labels(1).Name = 'Cue';
%         Labels(1).Value=   {10x1 cell}
%         Labels(1).Name = 'Inhibitors';
%         Labels(1).Value=   {7x1 cell}
%         Labels(3).Name = 'CueInhibitors';
%         Labels(3).Value = {17x1 cell}
%         Labels(4).Name = 'Readouts';
%         Labels(4).Value =  {17x1 cell}
%
%         Matrices(1).Value:     [88x10 double]
%         Matrices(1).Name 'CueMatrix'
%         Matrices(2).Value:     [88x7 double]
%         Matrices(2).Name 'InhMatrix'
%         Matrices(3).Value:     [88x17 double]
%         Matrices(3).Name 'CueInhMatrix'
%         Matrices(4).Value:     [88x17 double]
%         Matrices(4).Name 'ReadoutsMatrix'
%
%
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


DefaultParameters = struct(...
    'DimFixed', [1 1],...
    'Metric', 'mean',...
    'PrintWarnings',false,...
    'dim2', {OldParameters.Labels(3).Value},...
    'dim3', {OldParameters.Labels(4).Value});
Parameters = setParameters(DefaultParameters, OldParameters);

Labels   =Parameters.Labels;

dim2=Parameters.dim2;
dim3=Parameters.dim3;

for cytok=1:numel(dim2)
    if strcmp(dim2{cytok},'ALL')==1
        warndlg('use of ALL to define use of all stimuli is not supported')
        return
    end
end
for inhib=1:numel(dim3)
    if strcmp(dim3{inhib},'ALL')==1
        warndlg('use of ALL to define use of all inhibitors is not supported')
        return
    end
end

%Labels
NewCube.Labels(1).Name = 'Cue';
NewCube.Labels(2).Name = 'Inhibitors';
NewCube.Labels(3).Name = 'CueInhibitors';
NewCube.Labels(4).Name = 'Readouts';
NewCube.Labels(1).Value   = dim2;
NewCube.Labels(2).Value    = dim3;
NewCube.Labels(3).Value = [dim2 ;dim3];
if strcmp(Parameters.Metric, 'none')
    strLabels = labels2cellstr(Labels);
    readouts = strLabels(5).Value;
    times = strLabels(2).Value;
    newLabels = {};
    for i=1:numel(readouts)
        for j=1:numel(times)
            newLabels{end+1} = sprintf('%s @ t=%s', readouts{i}, times{j});
        end
    end
    NewCube.Labels(4).Value = reshape(newLabels, [], 1);
else
    NewCube.Labels(4).Value= Labels(5).Value;
end

%Initialize matrices
NewCube.Matrices(1).Name= 'CueMatrix';
NewCube.Matrices(2).Name= 'InhMatrix';
NewCube.Matrices(3).Name= 'CueInhMatrix';
NewCube.Matrices(4).Name= 'ReadoutsMatrix';
NewCube.Matrices(1).Value    =[];
NewCube.Matrices(2).Value    =[];
NewCube.Matrices(4).Value    =[];

%Define Scenario Names and Matrices
NewCube.ScenarioNames=[];
if iscell(Parameters.Labels(2).Value)
    timecell=Parameters.Labels(2).Value;
    time0=[];
    for i=1:numel(timecell)
        time0=[time0 str2num(timecell{i})];
    end
elseif isnumeric(Parameters.Labels(2).Value)
    time0=Parameters.Labels(2).Value;
    
end

pos=1;
for cyt=1:numel(Labels(3).Value)
    for inh=1:numel(Labels(4).Value)
        NewCube.ScenarioNames{end+1}=[Labels(3).Value{cyt} '-'  Labels(4).Value{inh}];
        VecOut=[];
        for measu=1:numel(Labels(5).Value)
            %time=Labels(2).Value';
            x=OldCube(Parameters.DimFixed(2),:,cyt,inh,measu);
            % remove nan values iff we use one of the metrics
            if ~strcmp(Parameters.Metric,'none')
                notnans=~isnan(x);
                time=time0(notnans);
                x=x(notnans);
            end
            
            switch Parameters.Metric
                case 'none'
                    VecOut = [VecOut x];
                case 'mean'
                    VecOut=[VecOut nanmean(x)];
                case 'AUC'
                    NewVal=(time(2:end)*x(2:end)'-time(1:(end-1))*x(2:end)')/time(end);
                    VecOut=[VecOut  NewVal ];
                case 'Slope'
                    p = polyfit(time,x,1);
                    VecOut=[VecOut p(1)];   % 1st component is slope
                case 'Differential'
                    %VecOut=[VecOut x(2)-x(1)];
                    VecOut=[VecOut mean(x(2:end))-x(1)];
                    if numel(Labels(2).Value)>3
                        warning('The matrix differential is not very meaningful for more than 3 time points');
                    end
                case 'time2'
                    VecOut=[VecOut x(2)];
                case 'maxdiff'
                    VecOut=[VecOut max(x)-x(1)];
                case'time3'
                    VecOut=[VecOut x(3)];
            end
        end
        
        
        VecCue=zeros(1,numel(dim2));
        for cytok=1:numel(dim2)
            if isempty(strfind(NewCube.ScenarioNames{end},dim2{cytok}))~=1
                VecCue(cytok)=1;
            else
                VecCue(cytok)=0;
            end
        end
        
        VecInh=zeros(1,numel(dim3));
        for inhib=1:numel(dim3)
            if isempty(strfind(NewCube.ScenarioNames{end},dim3{inhib}))~=1
                VecInh(inhib)=1;
            else
                VecInh(inhib)=0;
            end
        end
        
        NewCube.Matrices(1).Value(pos,:)  =   VecCue;
        NewCube.Matrices(2).Value(pos,:)  =   VecInh;
        NewCube.Matrices(4).Value(pos,:)  =   VecOut;
        pos=pos+1;
    end
end

NewCube.Matrices(3).Value=[NewCube.Matrices(1).Value NewCube.Matrices(2).Value];




