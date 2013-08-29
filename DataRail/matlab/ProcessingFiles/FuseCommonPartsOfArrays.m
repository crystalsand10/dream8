function [NewArray ArraysRenorm]=FuseCommonParsOfArrays(Arrays,Parameters)
% FuseCommonParsOfArrays uses joinCubes to create an array  with the common parts of two arrays
% 
% NewArray=FuseCommonParsOfArrays(Arrays,Parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS:
%   Arrays = a structure with two data arrays(+metadata), Arrays{1} and Arrays{2}
%   Parameters 
%           dummy field as for now
%
% OUTPUTS:
%
% NewArray = arrays renormalized
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%
%
%--------------------------------------------------------------------------
% TODO:
%
%
%
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
% Parameters = structure of parameters (default value in parenthesis)
%         .AcrossCells(yes) = to consider maximal value of all cell types
%         .ExpNoise(500) =  value below which the signal is consider NaN
%

dim=FindCommonConditions(Arrays,'');

ParC1.Keep={dim{1}.IdxArray1,...
    dim{2}.IdxArray1,dim{3}.IdxArray1,dim{4}.IdxArray1,dim{5}.IdxArray1};
ParC1.Labels=Arrays{1}.Labels;
[ArrayC1.Value PS1]=createSubcube(Arrays{1}.Value,ParC1);
ArrayC1.Labels=PS1.Labels;
ParC2.Keep={dim{1}.IdxArray2,...
    dim{2}.IdxArray2,dim{3}.IdxArray2,dim{4}.IdxArray2,dim{5}.IdxArray2};
ParC2.Labels=Arrays{2}.Labels;
[ArrayC2.Value PS2]=createSubcube(Arrays{2}.Value,ParC2);
ArrayC2.Labels=PS2.Labels;

CutLabels1=PS1.Labels;
CutLabels2=PS2.Labels;

Labels1=PS1.Labels;
% sometimes we have - sometimes _
for la=1:numel(Labels1)
    if isempty(find(isnumeric(Labels1(la).Value)))
        Labels1(la).Value=regexprep(Labels1(la).Value,'-','_');
    end
end
%change names of cells so we can put them on same dimension
for ce=1:numel(Labels1(1).Value)
    Labels1(1).Value{ce}=['1ar-' Labels1(1).Value{ce}];
end

PS1.Labels=Labels1;

Labels2=ArrayC2.Labels;
for la=1:numel(Labels2)
      if isempty(find(isnumeric(Labels2(la).Value)))
        Labels2(la).Value=regexprep(Labels2(la).Value,'-','_');
      end
end
%change names of cells so we can put them on same dimension
for ce=1:numel(Labels2(1).Value)
    Labels2(1).Value{ce}=['2ar-' Labels2(1).Value{ce}];
end
ArrayC2.Labels=Labels2;


ParJo.data=ArrayC2;
ParJo.Labels=PS1.Labels;
ParJo.Concatenate=false;

[NewArray.Value PS1]=joinCubes(ArrayC1.Value,ParJo);
NewArray.Labels=PS1.Labels;

ArraysCommon{1}=ArrayC1;
ArraysCommon{2}=ArrayC2;
ArraysCommon{1}.Name=[Arrays{1}.Name 'Common'];
ArraysCommon{2}.Name=[Arrays{2}.Name 'Common'];
ArraysCommon{1}.Labels=CutLabels1;
ArraysCommon{2}.Labels=CutLabels2;

ArraysRenorm=MaxSignalRelativatorCommonConditions(ArraysCommon,'');