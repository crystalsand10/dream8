function NewData=RemoveBasalLevel(OldData,Parameters)
%  RemoveBasalLevel substract to every signal the value for t=0
%
%  NewData=RemoveBasalLevel(OldData,Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
%
% OlData = 5-dimensional data cube in the canonical form
%
% Parameters = empty%
%
% OUTPUTS:
%
% NewData = 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(2).Value=RemoveBasalLevel(Data.data(1).Value,'')
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

NewData=NaN(size(OldData));

for cell=1:size(OldData,1)
    for measure=1:size(OldData,5)        
        for cyt=1:size(OldData,3)
            for inh=1:size(OldData,4)
                NewData(cell,:,cyt,inh,measure)=OldData(cell,:,cyt,inh,measure)-OldData(cell,1,cyt,inh,measure);
            end
        end
       end
    end
end

                
 