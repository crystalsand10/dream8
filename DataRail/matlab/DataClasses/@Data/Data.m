function d = Data(name,varargin)
% DATA Constructor function for Data class
% d = Data(name, 'Key',value, ...)
% name is a (short, one-word) description of the Data object
% Key/value pairs are:
% Info - a longer description
% Values - the actual data
% Dimensions - a HashArray describing the name and levels of each dimension
%    of values
% SourceData - a string describing the source of the data
% Code - a HashArray containing the Mfiles to generate the data
% Parameters - a HashArray containing the Parameters used to generate the
%    data

if nargin == 1 && isa(varargin{1}, 'Data')
    % HashArrays must be copied!
    d = copy(varargin{1});
    return
end
if nargin < 1
    name = '';
end
% Default values:
info = '';
values0 = [];
dimensions = [];
sourceData = '';
code = [];
parameters = [];

% Parse parameters
if mod(numel(varargin),2) == 1
    error('Optional arguments must come in Key/Value pairs.');
end
for i=1:2:numel(varargin)
    key = varargin{i};
    value = varargin{i+1};
    switch lower(key)
        case 'info'
            info = value;
        case 'values'
            if isnumeric(value) || iscell(value)
                values0 = value;
            else
                error('Values must be an array or cell');
            end
        case 'dimensions'
            if isa(value,'HashArray')
                dimensions = HashArray(value);
            elseif iscell(value) && numel(value) == 2
                dimensions = HashArray(value{:});
            elseif isempty(value)
                continue
            else
                error('Invalid Dimensions');
            end
        case 'sourcedata'
            sourcedata = value;
        case 'code'
            if isa(value,'HashArray')
                code = HashArray(value);
            elseif iscell(value) && numel(value) == 2
                code = HashArray(value{:});
            elseif isempty(value)
                continue
            else
                error('Invalid Code');
            end
        case 'parameters'
            if isa(value,'HashArray')
                parameters = HashArray(value);
            elseif iscell(value) && numel(value) == 2
                parameters = HashArray(value{:});
            elseif isempty(value)
                continue
            else
                error('Invalid Parameters');
            end
    end % switch
end % for

% Check consistency with values' dimensions
if ~isempty(values0) && ~isempty(dimensions)
    vSize = size(values0);
    dSize = cellfun(@numel,values(dimensions));
    if numel(vSize) ~= numel(dSize) || any(vSize ~= dSize)
        error('Dimension labels are inconsistent with data values.');
    end
end

% Construct object
d = struct('name',name,'info',info,'values',values0,'dimensions',dimensions,...
    'sourceData',sourceData,'code',code,'parameters',parameters);
d = class(d,'Data');

function dimensions = defaultDimensions(values0)
nd = ndims(values0);
dimNames = cell(1,nd);
dimLevels = cell(1,nd);
for i=1:ndims(values0)
    dimNames{i} = sprintf('Dim%d',i);
    sz = size(values0,i);
    dimLevels{i} = num2cell(1:sz);
end
dimensions = HashArray(dimNames, dimLevels);
