function dataCube = CanonicalForm(dataCube)
% CanonicalForm  ensures that the 2nd dim is time and 5th is signal in a
% data cube
%  
%   dataStructure = CanonicalForm(dataStructure)
%  
%--------------------------------------------------------------------------
% INPUTS:
%
% dataStructure = data structure with a  5-dimensional data cube
%
% OUTPUTS:
%
% dataStructure = data structure with a 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(2)=CanonicalForm(Data.data(1))
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
labelNames = {dataCube.Labels.Name};

iTime = find(strcmpi('time', labelNames));
iSignal = find(strcmpi('signals', labelNames));

if isempty(iTime)
    error('Unable to locate time dimension.');
end
if isempty(iSignal)
    error('Unable to locate signal dimension.');
end

maxDim = max(ndims(dataCube.Value), 5);
otherDims = setdiff(1:maxDim, [iTime, iSignal]);
iReorder = [otherDims(1) iTime otherDims(2:3) iSignal otherDims(4:end)];
dataCube.Value = permute(dataCube.Value, iReorder);
% Add labels, if necessary
numLabels=numel(dataCube.Labels);
if numLabels < maxDim
    for i=(numLabels+1):maxDim  
        dataCube.Labels(i).Name = sprintf('DummyDimension%d',iReorder(i));
        dataCube.Labels(i).Value = {'DummyValue'};
    end
end
dataCube.Labels = dataCube.Labels(iReorder);