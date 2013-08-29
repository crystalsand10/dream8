function [newData, p] = createSubcube(data, Parameters)
% createSubcube creates the requested subcube and corresponding labels
%
% [data, newLabels] = createSubcube(data, Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
% data       = Hypercube of data
% Parameters = Structure of parameters
%   .Labels  = Optional list of dimension labels
%   .Keep    = Cell listing elements (by array index) to keep for each dimension.
%              A missing/empty value in the cell means to keep all values
%              of the corresponding dimension.
%
% OUTPUTS:
% newData    = new sub-hypercube of data
% Parameters = structure of inputted Parameters AND
%   .Labels     = new Labels structure
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Parameters.Keep = {[1 3], [2]};
% Parameters.Labels = labels;
% [newData, Parameters] = createSubcube(data, Parameters)
%
% % This command creates a subcube consisting of the 1st and 3rd rows (the
% % 1st dimension; the 2nd column (the 2nd dimension); and all subsequent
% % dimensions.
%
%--------------------------------------------------------------------------
% TODO:
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

DefaultParameters = struct(...
    'Labels', [],...
    'Keep', {{}});

p = setParameters(DefaultParameters, Parameters);

nd = max(ndims(data), numel(p.Labels));
idx = cell(nd,1);

% Check p.Keep
nKeep = numel(p.Keep);
if ~iscell(p.Keep) || nKeep > nd
    error('The keep parameter must be a cell with up to one value per data dimension.')
end

for i=1:nKeep
    if isempty(p.Keep{i})
        idx{i} = ':';
    else
        idx{i} = p.Keep{i};
    end
end
for i=nKeep+1:nd
    idx{i} = ':';
end
% Grab subcube
try
    newData = data(idx{:});
catch
    le = lasterror;
    error('Unable to create subcube. Check that indexes are valid. Matlab error:\n%s', le.message);
end 

if isempty(p.Labels)
    return
end

newLabels = p.Labels;
for i=1:nd
    newLabels(i).Value = newLabels(i).Value(idx{i});
end

p.Labels = newLabels;