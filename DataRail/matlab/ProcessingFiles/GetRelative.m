function NewData=GetRelative(OldData,Parameters)
% GetRelative normalizes a datacube with respect to a particular treatment
%
% function NewData=GetRelative(OldData,Parameters)
%
%  
%--------------------------------------------------------------------------
% INPUTS:
%
% OlData = 5-dimensional data cube in the canonical form
%
% Parameters = structure of parameters (default value in parenthesis)
%         .RefDim(3)   = dimension to normalize over
%         .RefValue(1) = value in that dimension which is the reference
%
% OUTPUTS:
%
% NewData = 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(2).Value=GetRelative(Data.data(1).Value,Parameters)
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
DefaultParameters.RefValue = 1;
DefaultParameters.RefDim   = 3;
Parameters = setParameters(DefaultParameters, Parameters);

NewData=OldData;

Ind=cell(1,5);
for dim1=1:size(OldData,1)
    Ind{1}=dim1;
    for dim2=1:size(OldData,2)
        Ind{2}=dim2;
        for dim3=1:size(OldData,3)
            Ind{3}=dim3;
            for dim4=1:size(OldData,4)
                Ind{4}=dim4;
                for dim5=1:size(OldData,5)
                    Ind{5}=dim5;
                    Ind1=Ind;
                    Ind1{Parameters.RefDim} = Parameters.RefValue;
                    NewData(Ind{:})=OldData(Ind{:})/...
                        OldData(Ind1{:});
                end
            end
        end
    end
end