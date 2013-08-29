function [data, p] = collapseDataCube(data, OldParameters)
% collapseDataCube collapses dimensions and labels in a datacube
%
% [newData, Parameters] = collapseDataCube(oldData, Parameters)
%
% Collapse the requested dimensions of oldData & combine the corresponding
% labels.
%--------------------------------------------------------------------------
% INPUTS:
% oldData   = a data cube
% Parameters(default) = optional structure of Parameters
%     .Dims ([])      = Dimensions to collapse, or cell of sets of dimensions.
%     .Labels ([])    = structure containing Name and Value fields for
%                       dimension labels
%     .NewDim (1)     = Location(s) of the collapsed dimension in NewData
%     .NewDimName('CollapsedDimension') = name(s) of the new dimension
%     .NewDimFormatter(@defaultFormater) = 
%                       a handle to a function to format the Value
%                       string of the new dimension's labels. See the
%                       source code for the default formatter, which
%                       basically concatenates labels.
%     .RemoveNaNs(false) = if true, removed collapsed rows which are all NaNs.
%
% OUTPUTS:
% newData   = new datacube structure
% Parameters = structure of inputted Parameters AND
%   .Labels     = new Labels structure
%
%--------------------------------------------------------------------------
% EXAMPLE:
% newData = collapseDataCube(oldData, struct('Dims', [1 2 3]));
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
    'Dims', [],...
    'NewDim', [],...
    'Labels', [],...
    'NewDimName', [], ...
    'NewDimFormatter', @defaultFormatter,...
    'RemoveNaNs', false);

if nargin > 1
    p = setParameters(DefaultParameters, OldParameters);
else
    p = DefaultParameters;
end
% Make Dims and NewDimNames cells, if necessary
if ~iscell(p.Dims)
    p.Dims = {p.Dims};
end
if ~isempty(p.NewDimName) && ~iscell(p.NewDimName)
    p.NewDimName = {p.NewDimName};
end
% Validate arguments
nCollapse = numel(p.Dims);
if any(cellfun(@isempty,p.Dims))
    error('DataRail:collapseDataCube:invalidParameter', ...
        'The parameter Dim cannot contain an empty list of indices.');
end
for i=1:nCollapse
    p.Dims{i} = reshape(p.Dims{i},1,[]);
end
try
    allDims = cat(2,p.Dims{:});
    nAllDims = numel(allDims);
    if numel(unique(allDims)) ~= nAllDims
        error('DataRail:collapseDataCube:invalidParameter', ...
            'The parameter Dim must consist of uinque indicies.');
    end
catch
    error('DataRail:collapseDataCube:invalidParameter', ...
        'The parameter Dim must contain vectors of valid indexes.');
end
if isempty(p.NewDim)
    p.NewDim = 1:nCollapse;
elseif ~isnumeric(p.NewDim)
    error('DataRail:collapseDataCube:invalidParameter', ...
        'The parameter NewDim must contain be a numeric vector.');
elseif numel(p.NewDim) ~= nCollapse
    error('DataRail:collapseDataCube:invalidParameter', ...
        'The parameter NewDim must contain one value per collapse step.');
elseif numel(unique(p.NewDim)) ~= nCollapse
    error('DataRail:collapseDataCube:invalidParameter', ...
        'The parameter NewDim must contain unique indices.');
end
if isempty(p.NewDimName)
    p.NewDimName = cell(nCollapse,1);
    for i=1:nCollapse
        p.NewDimName{i} = sprintf('CollapsedDimension%d', p.NewDim(i));
    end
elseif ~iscellstr(p.NewDimName)
    error('DataRail:collapseDataCube:invalidParameter', ...
        'The parameter NewDimName must be a cell string.');
elseif numel(p.NewDimName) ~= nCollapse
    error('DataRail:collapseDataCube:invalidParameter', ...
        'The parameter NewDimName must contain one value per collapse step.');
end
% Run each collapse, creating new collapsed dim at end of cube
nDims = max(ndims(data), numel(p.Labels));
p1 = p;
for i=1:nCollapse
    p1.Dims = p.Dims{i};
    p1.NewDim = nDims+i;
    p1.NewDimName = p.NewDimName{i};
    [data, newLabels] = collapser(data, p1);
    p1.Labels = newLabels;
end
% Permute NewDims to the correct place:
iOld = 1:nDims;
iMoved = allDims;
iUnmoved = setdiff(iOld, iMoved);
iNew = nDims + (1:nCollapse);

iPermute = zeros(nDims+nCollapse,1);
iPermute(p.NewDim) = iNew;
iPermute(~iPermute) = [iUnmoved allDims];
data = permute(data, iPermute);

% Permute newLabels to correct place
if ~isempty(newLabels)
    newLabels = newLabels(iPermute(1:(nDims+nCollapse-nAllDims)));
end
p.Labels = newLabels;

% Implement as a subfunction
function [newData, newLabels] = collapser(newData, p)
%% Permute Dims to NewDim, NewDim+1, etc.
oldShape = size(newData);
nd = ndims(newData);
nDims = numel(p.Dims);
iPermute = 1:(nDims+p.NewDim-1);
idx = p.NewDim -1 + (1:nDims);
iPermute(p.Dims) = idx;
iPermute(idx) = p.Dims;
newData = permute(newData, iPermute);
%% Collapse the dimensions
% Make sure to pad extra ones to the shape if necessary
DimsShape = ones(1, numel(1,p.Dims));
i = p.Dims <= nd;
DimsShape(i) = oldShape(p.Dims(i));
DimsProduct = prod(DimsShape);
shape = size(newData);
newShape = ones(1, p.NewDim);
newShape( 1:(p.NewDim-1) ) = shape( 1:(p.NewDim-1) );
newShape(end) = DimsProduct;
newData = reshape(newData, newShape);
%% Remove NaNs
iRemoved = [];
if p.RemoveNaNs
    idx = repmat({':'},ndims(newData),1);
    for i=size(newData, p.NewDim):-1:1
        idx{p.NewDim} = i;
        thisSlice = newData(idx{:});
        if all(isnan(thisSlice(:)))
            % Delete slice
            newData(idx{:}) = [];
            iRemoved(end+1) = i;
        end
    end
end
%% Create new labels
if nargout < 2 || isempty(p.Labels);
    % No labels needed
    newLabels = [];
    return
end
newLabels = p.Labels;
newLabels(p.Dims) = struct('Name', 'Deleted', 'Value', 'Deleted');
newLabels(p.NewDim).Name = p.NewDimName;
newLabels(p.NewDim).Value = cell(size(newData,p.NewDim), 1);
iDims = ones(nDims, 1);
iDims(1) = 0;
theseLabels = cell(nDims,1);
k = 0;
for i=1:DimsProduct
    % Determine next index
    for j=1:nDims
        % Increment this index
        iDims(j) = iDims(j) + 1;
        if iDims(j) > DimsShape(j)
            % This index gets reset to 1
            iDims(j) = 1;
            % Now increment next index
        else
            % This index is valid, so break
            break
        end
    end
    if any(i==iRemoved)
        % Skip this label
        continue
    end
    % Construct list of labels
    for j=1:nDims
        if iscell(p.Labels(p.Dims(j)).Value)
            theseLabels(j) = p.Labels(p.Dims(j)).Value(iDims(j));
        else
            theseLabels{j} = p.Labels(p.Dims(j)).Value(iDims(j));
        end
    end
    % Create new label
    k = k + 1;
    newLabels(p.NewDim).Value{k} = p.NewDimFormatter(theseLabels{:});
end

%% Function defaultFormatter
function str = defaultFormatter(varargin)
c = cell(nargin,1);
for i=1:nargin
    arg = varargin{i};
    if ischar(arg)
        c{i} = arg;
    elseif isnumeric(arg)
        c{i} = sprintf('%g', arg);
    else
        warning('collapseDataCube:defaultFormatter:unknownType', ...
            'Unexpected class for label value; using "char" to convert.');
        c{i} = char(arg);
    end
end
str = sprintf('%s;', c{:});
str(end) = []; % delete last ";"