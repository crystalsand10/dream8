function Arrays=MaxSignalRelativatorCommonConditions(Arrays,Parameters)
% MaxSignalRelativatorCommon takes two arrays and normalize common treatments so that the peaks are the same
%
% Arrays=MaxSignalRelativatorCommonConditions(Arrays,Parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS:
%   Arrays = a structure with two data arrays(+metadata), Arrays{1} and Arrays{2}
%   Parameters 
%        .RefMetric('mean') = to renormalize everything with respect to the
%                             mean ('mean') or maximal value ('max')
%
% OUTPUTS:
%
% Arrays = arrays renormalized
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

dim1=dim{1};
dim2=dim{2};
dim3=dim{3};
dim4=dim{4};
dim5=dim{5};
Defaultpars=struct(...      
    'RefMetric','mean');

Parameters = setParameters(Defaultpars, Parameters);

%max values for t=2
if strcmp(Parameters.RefMetric,'max')
    RefArray1=max(max(max(max(Arrays{1}.Value(dim1.IdxArray1,...
        dim2.IdxArray1,dim3.IdxArray1,dim4.IdxArray1,dim5.IdxArray1)))));
    RefArray2=max(max(max(max(Arrays{2}.Value(dim1.IdxArray2,...
        dim2.IdxArray2,dim3.IdxArray2,dim4.IdxArray2,dim5.IdxArray2)))));
else
    RefArray1=mean(mean(mean(mean(Arrays{1}.Value(dim1.IdxArray1,...
        dim2.IdxArray1,dim3.IdxArray1,dim4.IdxArray1,dim5.IdxArray1)))));
    RefArray2=mean(mean(mean(mean(Arrays{2}.Value(dim1.IdxArray2,...
        dim2.IdxArray2,dim3.IdxArray2,dim4.IdxArray2,dim5.IdxArray2)))));
end
%NewArray1=Arrays{1}.Value;
NewArray2=Arrays{2}.Value;


% divide by old, multiple by new
for read=1:numel(RefArray1)
    FactorDiff=RefArray1(read)/RefArray2(read);
    NewArray2(:,:,:,:,dim5.IdxArray2(read))=...
        Arrays{2}.Value(:,:,:,:,dim5.IdxArray2(read))*FactorDiff;

end

%add metadata
Arrays{1}.SourceData=Arrays{1}.Name;
Arrays{2}.SourceData=Arrays{2}.Name;
Name1=[Arrays{1}.Name 'NormWith' Arrays{2}.Name];
Name2=[Arrays{2}.Name 'NormWith' Arrays{1}.Name];
Arrays{1}.Name=Name1;
Arrays{2}.Name=Name2;
%Arrays{1}.Value=NewArray1;
Arrays{2}.Value=NewArray2;
Arrays{1}.Code='MaxSignalRelativatorCommonConditions';
Arrays{2}.Code='MaxSignalRelativatorCommonConditions';
