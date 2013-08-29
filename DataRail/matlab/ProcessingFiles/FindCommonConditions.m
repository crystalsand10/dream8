function Common=FindCommonConditions(Arrays,Parameters)
% FindCommonConditions finds conditions which are the same for two data arrays, based on the labels
%
% Common =FindCommonConditions(Arrays,Parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS:
%   Arrays = a structure with two data arrays(+metadata), Arrays{1} and Arrays{2}
%   Parameters = a dummy field
%
% OUTPUTS:
% Commmon = 4 structures in one structure, 
% Common{1} =
% Common{2} =
% Common{3} = structure with fields IdxArray1 = indeces of common values in Arrays{1}.Labels(3).Value
%                                  IdxArray2 = indeces of common values in Arrays{2}.Labels(3).Value
%                                  Value = the actual common labels
%              
% Common{4} = the same as above but for 4th dimension
% Common{5} = the same as above but for 5th dimension
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
Array1=Arrays{1};
Array2=Arrays{2};

Labels1=Array1.Labels;
Labels2=Array2.Labels;

% sometimes we have - sometimes _
for la=1:numel(Labels1)
    if isempty(find(isnumeric(Labels1(la).Value)))
        Labels1(la).Value=regexprep(Labels1(la).Value,'-','');
         Labels1(la).Value=regexprep(Labels1(la).Value,'_','');
    end
end
for la=1:numel(Labels2)
      if isempty(find(isnumeric(Labels1(la).Value)))
        Labels2(la).Value=regexprep(Labels2(la).Value,'-','');
        Labels2(la).Value=regexprep(Labels2(la).Value,'_','');
      end
end
%identify indexes in first array
Common1=[];
for la=1:numel(Labels1(1).Value)
    Common1=[Common1, find(strcmpi(Labels1(1).Value{la},Labels2(1).Value))];
end
Common2=[];
for la=1:numel(Labels1(2).Value)
    Common2=[Common2, find(Labels1(2).Value(la)==Labels2(2).Value)];
end
Common3=[];
for la=1:numel(Labels1(3).Value)
    Common3=[Common3, find(strcmpi(Labels1(3).Value{la},Labels2(3).Value))];
end
Common4=[];
for la=1:numel(Labels1(4).Value)
    Common4=[Common4, find(strcmpi(Labels1(4).Value{la},Labels2(4).Value))];
end
Common5=[];
for la=1:numel(Labels1(5).Value)
    Common5=[Common5, find(strcmpi(Labels1(5).Value{la},Labels2(5).Value))];
end

Common1=sort(Common1);
Common2=sort(Common2);
Common3=sort(Common3);
Common4=sort(Common4);
Common5=sort(Common5);

Common1D.IdxArray2=Common1;
Common2D.IdxArray2=Common2;
Common3D.IdxArray2=Common3;
Common4D.IdxArray2=Common4;
Common5D.IdxArray2=Common5;

%define names

Common1D.Value=Arrays{2}.Labels(1).Value(Common1);
Common2D.Value=Arrays{2}.Labels(2).Value(Common2);
Common3D.Value=Arrays{2}.Labels(3).Value(Common3);
Common4D.Value=Arrays{2}.Labels(4).Value(Common4);
Common5D.Value=Arrays{2}.Labels(5).Value(Common5);

% now indeces in 2nd array
Common1=[];
for la=1:numel(Labels2(1).Value)
    Common1=[Common1, find(strcmpi(Labels2(1).Value{la},Labels1(1).Value))];
end
Common2=[];
for la=1:numel(Labels2(2).Value)
    Common2=[Common2, find(Labels2(2).Value(la)==Labels1(2).Value)];
end
Common3=[];
for la=1:numel(Labels2(3).Value)
    Common3=[Common3, find(strcmpi(Labels2(3).Value{la},Labels1(3).Value))];
end
Common4=[];
for la=1:numel(Labels2(4).Value)
    Common4=[Common4, find(strcmpi(Labels2(4).Value{la},Labels1(4).Value))];
end
Common5=[];
for la=1:numel(Labels2(5).Value)
    Common5=[Common5, find(strcmpi(Labels2(5).Value{la},Labels1(5).Value))];
end

Common1=sort(Common1);
Common2=sort(Common2);
Common3=sort(Common3);
Common4=sort(Common4);
Common5=sort(Common5);

Common1D.IdxArray1=Common1;
Common2D.IdxArray1=Common2;
Common3D.IdxArray1=Common3;
Common4D.IdxArray1=Common4;
Common5D.IdxArray1=Common5;

Common{1}=Common1D;
Common{2}=Common2D;
Common{3}=Common3D;
Common{4}=Common4D;
Common{5}=Common5D;