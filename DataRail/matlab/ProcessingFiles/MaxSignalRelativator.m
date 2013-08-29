function NewData=MaxSignalRelativator(OldData,Parameters)
%  MaxSignalRelativator divides the data by the maximum for the corresponding signal for all conditions 
%
%  NewData=MaxSignalRelativator(OldData,Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
%
% OlData = 5-dimensional data cube in the canonical form
%
% Parameters = structure of parameters (default value in parenthesis)
%         .AcrossCells(yes) = to consider maximal value of all cell types
%         .ExpNoise(0)      =  value below which the signal is consider NaN
%
%
% OUTPUTS:
%
% NewData = 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(2).Value=MaxSignalRelativator(Data.data(1).Value,Parameters)
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
try,      Parameters.AcrossCells;
catch,    Parameters.AcrossCells='yes' ;
end

try,      Parameters.ExpNoise;
catch,    Parameters.ExpNoise=0;
end

NewData=NaN(size(OldData));

for cell=1:size(OldData,1)
    for measure=1:size(OldData,5)
       if max(max(max(max(OldData(:,:,:,:,measure)))))<Parameters.ExpNoise
             warning(['All signals below Experimental noise for s=' num2str(measure) ', converted to NaN']);
             NewData(cell,:,:,:,measure)=NaN;
       else       
        for cyt=1:size(OldData,3)
            for inh=1:size(OldData,4)
                %Compute relative signal (signal/max for this measurement)
                if max(max(max(OldData(cell,:,:  ,: ,measure))))>0
                    for i=1:size(OldData,2)
                        if strcmpi(Parameters.AcrossCells,'yes')
                            NewData(cell,i,cyt,inh,measure)=OldData(cell,i,cyt,inh,measure)/max(max(max(max(abs(OldData(:,:,:  ,: ,measure))))));
                        else
                            NewData(cell,i,cyt,inh,measure)=OldData(cell,i,cyt,inh,measure)/max(max(max(abs(OldData(cell,:,:  ,: ,measure)))));
                        end
                    end
                else
                    for i=1:size(OldData,2)
                        NewData(cell,i,cyt,inh,measure)=0;
                    end
                end
            end
        end
       end
    end
end

                
 