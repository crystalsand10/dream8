function [newValues, parameters] = joinCubes(values, parameters)
% joinCubes joins two cubes together
%
% [newValues, parameters] = joinCubes(values, parameters)
%
% Cubes are concatenated across the replicate dimension, if
% parameters.Concatenate is true. If parameters.Concatenate is false,
% data in parameters.cube is added as the next available replicate.
%
% Notes:
% * Cubes must be consistent in the number of dimensions.
% * Each dimension's label must be of the same type (string or number) in
%   both cubes.
% * Numeric dimension vLabels will be sorted after joining.
% * Cellstr dimension vLabels will not be reordered.
%
%--------------------------------------------------------------------------
% INPUTS:
% values    = hypercube of values for first cube
% parameters(default) = structure of parameters
%             .Labels = Labels structure of first cube
%             .data   = data structure of second cube
%                       (function uses Value and Labels fields)
%             .Concatenate(true) = True to concatenate along the
%                                  replicate dim
%             .ReplicateDim = name or index of replicate dimension (defaults to dimension
%                             with the name 'replicates', or adds a new dimension
%                             if none are found)
%
%
% OUTPUTS:
% newValues = hypercube of joined values
% parameters = same parameters as above, but with new Labels
%
%--------------------------------------------------------------------------
% EXAMPLE:
% [newValues, parameters] = joinCubes(data(1).Value, ...
%      struct('Labels', {data(1).Labels}, 'data2', {data(2)}));
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
defaultParameters = struct('Labels',[],'data',[],'Concatenate',[],'ReplicateDim',[]);
parameters = setParameters(defaultParameters, parameters);
if isempty(parameters.Labels)
    error('DataRail:missingRequiredParameter', 'Labels parameter is required');
elseif ~isstruct(parameters.Labels) || ~all(isfield(parameters.Labels, {'Name','Value'}))
    error('DataRail:invalidParameter', 'Labels parameter is not valid.');
elseif isempty(parameters.data)
    error('DataRail:missingRequiredParameter', 'data parameter is required');
elseif ~isstruct(parameters.Labels) || ~all(isfield(parameters.data, {'Labels','Value'}))
    error('DataRail:invalidParameter', 'data parameter is not valid.');
elseif isempty(parameters.data.Labels)
    error('DataRail:missingRequiredParameter', 'parameters.data.Labels is missing');
elseif ~isstruct(parameters.data.Labels) || ~all(isfield(parameters.data.Labels, {'Name','Value'}))
    error('DataRail:invalidParameter', 'parameters.data.Labels is not valid.');
elseif isempty(parameters.data.Value)
    error('DataRail:missingRequiredParameter', 'parameters.data.Value is missing');
end
%% Empty parameters.Concatenate also defaults to true
if isempty(parameters.Concatenate)
    parameters.Concatenate = true;
end
%% Check consistency of Labels
nDims = numel(parameters.Labels);
if nDims ~= numel(parameters.data.Labels)
    error('DataRail:incompatibleData', 'The two data cubes have inconsistent dimensions.');
end
Labels = struct('Name',{},'Value',{});
for i=1:nDims
    % Convert char to cellstr
    if ischar(parameters.Labels(i).Value)
        parameters.Labels(i).Value = cellstr(parameters.Labels(i).Value);
    end
    if ischar(parameters.data.Labels(i).Value)
        parameters.data.Labels(i).Value = cellstr(parameters.data.Labels(i).Value);
    end
    % both vLabels must be either numeric or cellstr
    if iscellstr(parameters.Labels(i).Value) 
        if ~iscellstr(parameters.data.Labels(i).Value)
            error('DataRail:incompatibleData', ...
                'parameters.Labels(%d).Value is a cellstr, but parameters.data.Labels(%d).Value is not.', i, i);
        end
    elseif isnumeric(parameters.Labels(i).Value) 
        if ~isnumeric(parameters.data.Labels(i).Value)
            error('DataRail:incompatibleData', ...
                'parameters.Labels(%d).Value is numeric, but parameters.data.Labels(%d).Value is not.', i, i);
        end
    else
        % invalid label type
        error('DataRail:incompatibleData', ...
            'parameters.Labels(%d).Value is neither a cellstr nor a numeric vector.', i, i);
    end
    % both need to be vectors
    if ~isvector(parameters.Labels(i).Value)
        warning('DataRail:incompatibleData', ...
            'parameters.Labels(%d).Value will be converted to a vector', i, i);
    end
    if ~isvector(parameters.data.Labels(i).Value)
        warning('DataRail:incompatibleData', ...
            'parameters.data.Labels(%d).Value will be converted to a vector', i, i);
    end
end
%% Check ReplicateDim
iReplicate = parameters.ReplicateDim;
addedReplicateDim = false;
if ischar(iReplicate)
    repName = iReplicate;
    iReplicate = strmatch(repName, {parameters.Labels.Name});
    if isempty(iReplicate)
        warning('DataRail:DimensionLabelError', ...
            'Unable to find (replicate) dimension named %s', repName);
    end
end
if isempty(iReplicate)
    iReplicate = strmatch('replicates', lower({parameters.Labels.Name}));
    if isempty(iReplicate)
        iReplicate = numel(parameters.Labels) + 1;
        parameters.Labels(iReplicate).Name = 'replicates';
        parameters.Labels(iReplicate).Value = 1;
        parameters.data.Labels(iReplicate) = parameters.Labels(iReplicate);
        addedReplicateDim = true;
        nDims = nDims + 1;
    end
end
%% Adjust values of ReplicateDim, if necessary
if parameters.Concatenate
    nRep1 = max(parameters.Labels(iReplicate).Value);
    parameters.data.Labels(iReplicate).Value = nRep1 + parameters.data.Labels(iReplicate).Value;
    assert2( ...
        isempty(intersect( ...
            parameters.Labels(iReplicate).Value, ...
            parameters.data.Labels(iReplicate).Value)), ...
        'Replicate dimension labels overlap. Check that the are numbered consecutively from 1.');
end
%% Join vLabels and construct indices
indices = cell(nDims,2);
[vLabels,vLabels1,vLabels2] = deal(cell(nDims,1));
for i=1:nDims
    vLabels1{i} = parameters.Labels(i).Value(:);
    n1 = numel(vLabels1{i});
    vLabels2{i} = parameters.data.Labels(i).Value(:);
%     n2 = numel(vLabels2);
    vLabels0 = [vLabels1{i}; vLabels2{i}];
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
    indices{i,1} = n(1:n1);
    indices{i,2} = n(n1+1:end);
end
[parameters.Labels.Value] = deal(vLabels{:});
%% Construct newValues
sz = cellfun(@numel, vLabels);
sz = reshape(sz,1,[]);
if parameters.Concatenate
    newValues = nan(sz);
    newValues(indices{:,1}) = values;
    newValues(indices{:,2}) = parameters.data.Value;
else
    % Pre-allocate enough room for max. number of replicates
    maxNumReplicates = numel(vLabels1{iReplicate}) + ...
        numel(vLabels2{iReplicate});
    sz(iReplicate) = maxNumReplicates;
    newValues = nan(sz);
    % Copy cube1 over
    newValues(indices{:,1}) = values;
    % Now copy cube2 over at appropriate replicate
    sz2 = cellfun(@numel, {parameters.data.Labels.Value});%size(parameters.data.Value);
    sz2b = [sz2(1:iReplicate-1) sz(iReplicate+1:end)];
    [sub0b,sub2b] = deal(cell(numel(sz2b),1));
    realMaxNumReplicates = 0;
    iterator = subscriptIterator(sz2b);
    for i=1:prod(sz2b)
        % Calculate the index in cube2
        [sub2b{:}] = iterator();%ind2sub(sz2b,i);
        % Calculate the index in the new cube
        for j=1:numel(sub0b)
            sub0b{j} = indices{j,2}(sub2b{j});
        end
        % Grab the old data and see where replicates end
        data0 = newValues(sub0b{1:iReplicate-1},:,sub0b{iReplicate+1:end});
        iEnd0 = find(~isnan(data0),1,'last')+1;
        if isempty(iEnd0)
            iEnd0 = 1;
        end
        % Grab the new data and see where replicates end
        data2 = parameters.data.Value(sub2b{1:iReplicate-1},:,sub2b{iReplicate+1:end});
        iEnd2 = find(~isnan(data2),1,'last');
        if ~isempty(iEnd2)
            thisNumReplicates = iEnd2+iEnd0-1;
            data0(iEnd0:thisNumReplicates) = data2(1:iEnd2);
            if thisNumReplicates > realMaxNumReplicates
                realMaxNumReplicates = thisNumReplicates;
            end
        end
        newValues(sub0b{1:iReplicate-1},:,sub0b{iReplicate+1:end}) = data0;
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
    parameters.Labels(iReplicate) = [];
elseif numel(parameters.Labels(iReplicate).Value) ~= nReplicates
    parameters.Labels(iReplicate).Value = 1:nReplicates;
end