function [newArray, parameters] = joinArrays(arrays, parameters)
% joinArrays joins two arrays together
%
% [newArray, parameters] = joinArrays(arrays, parameters)
%
% Arrays are concatenated across the replicate dimension, if
% parameters.Concatenate is true. If parameters.Concatenate is false,
% data is added as the next available replicate.
%
% Notes:
% * Arrays must be consistent in the number of dimensions.
% * Each dimension's label must be of the same type (string or number) in
%   both arrays.
% * Numeric dimension vLabels will be sorted after joining.
% * Cellstr dimension vLabels will not be reordered.
%
%--------------------------------------------------------------------------
% INPUTS:
% arrays    = array of array structures
% parameters(default) = structure of parameters
%             .Concatenate(true) = True to concatenate along the
%                                  replicate dim
%             .ReplicateDim = name or index of replicate dimension (defaults to dimension
%                             with the name 'replicates', or adds a new dimension
%                             if none are found)
%
%
% OUTPUTS:
% newArray = new array of joined values
% parameters = same parameters as above, but with new Labels
%
%--------------------------------------------------------------------------
% EXAMPLE:
% [newArray, parameters] = joinArrays([array1 array2], ...
%      struct('Concatenate', false));
%
%--------------------------------------------------------------------------
% TODO:
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

%% Validate parameters
defaultParameters = struct('Concatenate',[],'ReplicateDim',[]);
parameters = setParameters(defaultParameters, parameters);
%% Empty parameters.Concatenate also defaults to true
if isempty(parameters.Concatenate)
    parameters.Concatenate = true;
end
%% Check arrays
nArrays = numel(arrays);
if nArrays < 2
    error('DataRail:joinCubes', 'At least two data cubes must be passed');
end
%% Check consistency of Labels
nDims = numel(arrays(1).Labels);
for i=2:nArrays
    if nDims ~= numel(arrays(i).Labels)
        error('DataRail:incompatibleData', 'The two data arrays have inconsistent dimensions.');
    end
end
for i=1:nDims
    for j=1:nArrays
        % Convert char to cellstr
        if ischar(arrays(j).Labels(i).Value)
            arrays(j).Labels(i).Value = cellstr(parameters.Labels(i).Value);
        end
        % all need to be vectors
        if ~isvector(arrays(j).Labels(i).Value)
            warning('DataRail:incompatibleData', ...
                'arrays(%d).Labels(%d).Value will be converted to a vector', j, i);
        end
    end
    for j=2:nArrays
        % Labels must be either numeric or cellstr
        if iscellstr(arrays(1).Labels(i).Value)
            if ~iscellstr(arrays(j).Labels(i).Value)
                error('DataRail:incompatibleData', ...
                    'arrays(1).Labels(%d).Value is a cellstr, arrays(%d).Labels(%d).Value is not.', i, j, i);
            end
        elseif isnumeric(arrays(1).Labels(i).Value)
            if ~isnumeric(arrays(j).Labels(i).Value)
                error('DataRail:incompatibleData', ...
                    'arrays(1).Labels(%d).Value is numeric, but arrays(%d).Labels(%d).Value is not.', i, j, i);
            end
        else
            % invalid label type
            error('DataRail:incompatibleData', ...
                'arrays(1).Labels(%d).Value is neither a cellstr nor a numeric vector.', i);
        end
    end
end
%% Create labels and check ReplicateDim
Labels = arrays(1).Labels;
iReplicate = parameters.ReplicateDim;
addedReplicateDim = false;
if ischar(iReplicate)
    repName = iReplicate;
    iReplicate = strmatch(repName, {Labels.Name});
    if isempty(iReplicate)
        warning('DataRail:DimensionLabelError', ...
            'Unable to find (replicate) dimension named %s', repName);
    end
end
if isempty(iReplicate)
    iReplicate = strmatch('replicates', lower({Labels.Name}));
    if isempty(iReplicate)
        iReplicate = numel(arrays(1).Labels) + 1;
        Labels(iReplicate).Name = 'replicates';
        Labels(iReplicate).Value = 1;
        for j=1:nArrays
            arrays(j).Labels(iReplicate) = Labels(iReplicate);
        end
        addedReplicateDim = true;
        nDims = nDims + 1;
    end
end
%% Adjust values of ReplicateDim, if necessary
if parameters.Concatenate
    maxNumReplicates = 0;
    for j=1:nArrays
        nRepJ = max(arrays(j).Labels(iReplicate).Value);
        arrays(j).Labels(iReplicate).Value = maxNumReplicates + arrays(j).Labels(iReplicate).Value;
        assert2( ...
            all(arrays(j).Labels(iReplicate).Value > maxNumReplicates & ...
                arrays(j).Labels(iReplicate).Value <= maxNumReplicates + nRepJ), ...
            'Replicate dimension labels are not numbered as expected.');
        maxNumReplicates = maxNumReplicates + nRepJ;
    end
else
    maxNumReplicates = sum( arrayfun(@(x) numel(x.Labels(iReplicate).Value), arrays) );
end
%% Join vLabels and construct indices
indices = cell(nDims,nArrays);
vLabels = cell(nDims,1);
vLabelsJ = cell(nDims,nArrays);
nLabelsJ = zeros(1,nArrays);
for i=1:nDims
    for j=1:nArrays;
        vLabelsJ{i,j} = arrays(j).Labels(i).Value(:);
        nLabelsJ(j) = numel(vLabelsJ{i,j});
    end
    vLabels0 = cat(1, vLabelsJ{i,:});
    [vLabels{i},m,n] = unique(vLabels0,'first');
    vLabels{i} = reshape(vLabels{i},[],1);
    if iscellstr(vLabels{i})
        % Reorder
        [m2,im] = sort(m);
        vLabels{i} = vLabels{i}(im);
        for j=1:numel(vLabels0)
            n(j) = strmatch(vLabels0{j}, vLabels{i}, 'exact');
        end
    end
    idx = [0 cumsum(nLabelsJ)];
    for j=1:nArrays
        indices{i,j} = n(idx(j)+1:idx(j+1));
    end
end
[Labels.Value] = deal(vLabels{:});
%% Construct values
sz = cellfun(@numel, vLabels);
sz = reshape(sz,1,[]);
if parameters.Concatenate
    newValues = nan(sz);
    for j = 1:nArrays
        newValues(indices{:,j}) = arrays(j).Value;
    end
else
    % Pre-allocate enough room for max. number of replicates
    sz(iReplicate) = maxNumReplicates;
    newValues = nan(sz);
    % Copy array1 over
    newValues(indices{:,1}) = arrays(1).Value;
    % Now copy arrays 2:end over at appropriate replicate
    for j=2:nArrays
        sz2 = size(arrays(j).Value);
        sz2b = [sz2(1:iReplicate-1) sz(iReplicate+1:end)];
        [sub0b,sub2b] = deal(cell(numel(sz2b),1));
        realMaxNumReplicates = 0;
        iterator = subscriptIterator(sz2b);
        for i=1:prod(sz2b)
            % Calculate the index in array2
            [sub2b{:}] = iterator();%ind2sub(sz2b,i);
            % Calculate the index in the new array
            for k=1:numel(sub0b)
                sub0b{k} = indices{k,2}(sub2b{k});
            end
            % Grab the old data and see where replicates end
            data0 = newValues(sub0b{1:iReplicate-1},:,sub0b{iReplicate+1:end});
            iEnd0 = find(~isnan(data0),1,'last')+1;
            if isempty(iEnd0)
                iEnd0 = 1;
            end
            % Grab the new data and see where replicates end
            data2 = arrays(j).Value(sub2b{1:iReplicate-1},:,sub2b{iReplicate+1:end});
            iEnd2 = find(~isnan(data2),1,'last');
            if ~isempty(iEnd2)
                thisNumReplicates = iEnd2+iEnd0-1;
                newValues(sub0b{1:iReplicate-1}, iEnd0:thisNumReplicates, sub0b{iReplicate+1:end}) = data2(1:iEnd2);
                if thisNumReplicates > realMaxNumReplicates
                    realMaxNumReplicates = thisNumReplicates;
                end
            end
        end
    end
    % Delete empty replicates
    if realMaxNumReplicates < maxNumReplicates
        subs = repmat({':'}, ndims(newValues),1);
        subs{iReplicate} = (realMaxNumReplicates+1):maxNumReplicates;
        newValues(subs{:}) = [];
    end
end
%% Check replicates label
nReplicates = size(newValues, iReplicate);
if nReplicates == 1 && addedReplicateDim
    % Delete singleton replicate label
    Labels(iReplicate) = [];
elseif numel(Labels(iReplicate).Value) ~= nReplicates
    Labels(iReplicate).Value = 1:nReplicates;
end
%% Construct newArray
parameters.Name = {arrays.Name};
parameters.Info = {arrays.Info};
parameters.Parameters = {arrays.Parameters};
newArray = createDataCube('Value',newValues, 'Labels', Labels, ...
    'SourceData', {arrays.SourceData}, 'Parameters', parameters, ...
    'Name', arrays(1).Name, 'Code', @joinCubes);