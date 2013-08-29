function NewData=NormalizeToT0(OldData,Parameters)
%  NormalizeToT0 divides the data by the inital value at t=0 for each condition 
%
%  NewData=NormalizeToT0(OldData,Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
%
% OlData = 5-dimensional data cube in the canonical form
%
% Parameters = structure of parameters (default value in parenthesis)
%       
%
%
% OUTPUTS:
%
% NewData = 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(2).Value=NormalizeToT0(Data.data(1).Value,Parameters)
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
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe    Nickel Dittrich
%    SBPipeline.harvard.edu%


NewData=NaN(size(OldData));

for i=1:size(NewData,5)
    for j=1:size(NewData,4)
        for k=1:size(NewData,3)
            if OldData(1,1,1,j,i)~=0
                NewData(:,:,k,j,i) = OldData(:,:,k,j,i) / OldData(1,1,1,j,i);
            else
                Newdata(:,:,k,j,i) = OldData(:,:,k,j,i)
            end
        end
    end
end

                
 