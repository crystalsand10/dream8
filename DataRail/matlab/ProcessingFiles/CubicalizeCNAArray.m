function [NewData Labels]=CubicalizeCNAArray(CNAData,Parameters)
%  CubicalizeCNAArray takes an array from CNA computations and reconverts  it into a cube
%
%  CubicalizeCNAArray is very fragile
%  One thing assumed is that the model is fitted to steady state, ie t=0 is correct for the model. 
%
%  NewData=CubicalizeCNAArray(CNAData,Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
%
% CNAData = Structure obtained from running CNA e.g. scen_auto_Sbp
%
% %Parameters.ModelCube = Array Structure with Data with same structure, e.g. boolean 
%
%
% OUTPUTS:
%
% NewData = 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(2).Value=CubicalizeCNAArray(Data.data(1).Value,Parameters)
%
%--------------------------------------------------------------------------
% TODO:  
%
% -  Improve stability and test with different sets of data, the choice of
%    scenario may not always work 
%
% -  Assumes 3 times points-extend
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


NewData   =nan(size(Parameters.ModelCube.Value));
% We pass the t=0 data so as to get the negative ones inverted
% assuming model has same values as data for t=0!
NewData(:,1,:,:,:)=Parameters.ModelCube.Value(:,1,:,:,:);

Labels       =Parameters.ModelCube.Labels;
if isempty(Labels)
    MyWarning('No labels present, no possible to create a 5d array');
    return
end

%
%try
    Matrix       =CNAData.Results;
%catch
%      Matrix       =CNAData.Value.Results;
%end
MetNames=CNAData.MetaboliteNames;

%MyWarning(' CubicalizeCNAArray is very fragile, tested with few data');
%MyWarning(' One thing assumed is that the model is fitted to steady state, ie t=0 is correct for the model.')
NumTimeScales=numel(unique(CNAData.TimeScales));
if NumTimeScales~=size(Parameters.ModelCube.Value,2)-1
    disp(' ')
    disp(' *** ModelCube does not have a consistent number of timescales with the CNAData')
    disp(' *** Values for times not present in CNAData will be filled in with 0')
    disp(' *** for dimension 1, if more than 1 vlaue available, they will all be filled with the same value')
    disp(' ')
end
if NumTimeScales==2
    for cyt=1:size(NewData,3)
        for inh=1:size(NewData,4)
            scena=(cyt-1)*size(NewData,4)*(size(NewData,2)-1)+(inh-1)*(size(NewData,2)-1)+1;
            for meas=1:size(NewData,5)
                for met=1:size(MetNames,1)
                    MetName=lower(regexprep(MetNames(met,:),'_',''));
                    LabelName=regexprep(lower(Labels(5).Value{meas}),'_','');
                    CompMet=strfind(MetName,LabelName );
                    if  ~isempty(CompMet)
                        %strcmp(MetNames(met,:),Labels(5).Value{meas})
                        NewData(:,2,cyt,inh,meas)=Matrix(scena,met);
                        NewData(:,3,cyt,inh,meas)=Matrix(scena+1,met);
                    else
                        disp(['a']);
                    end
                end
            end
        end
    end
elseif NumTimeScales==1
    for cyt=1:size(NewData,3)
        for inh=1:size(NewData,4)
            scena=(cyt-1)*size(NewData,4)*NumTimeScales+(inh-1)*(size(NewData,2)-1)+1;
            for meas=1:size(NewData,5)
                for met=1:size(MetNames,1)                    
                    if  strcmpi(regexprep(MetNames(met,:),' ', ''), Labels(5).Value{meas})
                        NewData(:,2,cyt,inh,meas)=Matrix(scena,met);                          
                    end
                end
            end
        end
    end
else
    disp(' ** Only 2 or 3 timescales supported. Empty cube created')
end

for la=1:numel(Labels)
        if size(NewData,la)<numel(Labels(la).Value)
            Labels(la).Value=Labels(la).Value(1:size(NewData,la));
            disp([' Too many labels in dimension ' Labels(la).Name ', removing extra ones.'])
        end
end
disp( ' ')

