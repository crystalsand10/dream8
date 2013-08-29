function messages = checkDataCube(data)
% checkDataCube checks that the fields of a data cube are consistent
%
% messages = checkDataCube(data)
%
%--------------------------------------------------------------------------
% INPUTS:
% data      = data cube to check
%
% OUTPUTS:
% messages  = list of warning messages; and empty cell if no warnings were
%             issued
%
% Note: To disable the printing of warnings, use the command
%       warnings('off', 'checkDataCube:InvalidField')
%
%--------------------------------------------------------------------------
% EXAMPLE:
% messages = checkDataCube(data)
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

messages = {};
%% Check Name
if ~isfield(data, 'Name')
    messages{end+1} = 'The data cube does not contain a Name field.';
elseif ~ischar(data.Name) && ~isempty(data.Name)
    messages{end+1} = 'Name must be a string.';
end
%% Check Info
if ~isfield(data, 'Info')
    messages{end+1} = 'The data cube does not contain an Info field.';
elseif ~ischar(data.Info) && ~isempty(data.Info)
    messages{end+1} = 'Info must be a string.';
end
%% Check Value
if ~isfield(data, 'Value')
    messages{end+1} = 'The data cube does not contain a Value field.';
    szValue = [];
else
    szValue = size(data.Value);
    if ~isnumeric(data.Value)
        messages{end+1} = 'Value must be an array.';
    end
end
%% Check Labels
if ~isfield(data, 'Labels')
    messages{end+1} = 'The data cube does not contain a Labels field.';
elseif ~all(isfield(data.Labels, {'Name', 'Value'}))
    % Note: isfield also returns false if data.Labels is not a structure
    messages{end+1} = 'Labels must be a structure containing Name and Value fields.';
elseif ~isempty(szValue) % Check labels only if there is some data
    szLabels = cellfun(@numel, {data.Labels.Value});
    if numel(szValue) > numel(szLabels)
        messages{end+1} = 'Labels should contain one element per dimension of Value.';
    else
        for i=1:numel(szValue)
            if ~ischar(data.Labels(i).Name) && ~isempty(data.Labels(i).Name)
                messages{end+1} = sprintf('Labels(%d).Name must be a string.', i);
            end
            % Allow Value to be a string only for singleton dimensions
            if ischar(data.Labels(i).Value)
                if  szValue(i) ~= 1
                    messages{end+1} = sprintf('Labels(%d).Value can only be a string if dimension %d has size 1.', i, i);
                end

            %% Use this test if cells must be cell strings
            %elseif ~iscellstr(data.Labels(i).Value) && ~isnumeric(data.Labels(i).Value) || szValue(i) ~= szLabels(i)
            %    messages{end+1} = sprintf('Labels(%d).Value must be a cell string or vector of size %d.', i, szValue(i));
            
            %% Use this test if any kind of cell is acceptable
            elseif ~iscell(data.Labels(i).Value) && ~isnumeric(data.Labels(i).Value) || szValue(i) ~= szLabels(i)
                messages{end+1} = sprintf('Labels(%d).Value must be a cell or vector of size %d.', i, szValue(i));
            end
        end
        if any(szLabels(numel(szValue)+1:end)~=1)
            messages{end+1} = 'Labels should contain one element per dimension of Value.';
        end
    end
end
%% Check SourceData
if ~isfield(data, 'SourceData')
    messages{end+1} = 'The data cube does not contain a SourceData field.';
elseif ~ischar(data.SourceData) && ~iscellstr(data.SourceData) && ~isempty(data.SourceData)
    messages{end+1} = 'SourceData must be a string.';
end
%% Check Code
if ~isfield(data, 'Code')
    messages{end+1} = 'The data cube does not contain a Code field.';
elseif ~(ischar(data.Code) || isa(data.Code, 'function_handle') || isempty(data.Code))
    messages{end+1} = 'Code must be a string or function handle.';
end
%% Check CodeHashArray
if ~isfield(data, 'CodeHashArray')
    messages{end+1} = 'The data cube does not contain a CodeHashArray field.';
elseif ~(isempty(data.CodeHashArray) || ...
        isa(data.CodeHashArray, 'CodeHashArray') || isempty(data.CodeHashArray))
    messages{end+1} = 'CodeHashArray is not valid CodeHashArray.';
end
%% Check Parameters
if ~isfield(data, 'Parameters')
    messages{end+1} = 'The data cube does not contain a Parameters field.';
elseif ~isstruct(data.Parameters) && ~isempty(data.Parameters)
    messages{end+1} = 'Parameters must be a structure.';
end
%% Output warnings
for i=1:numel(messages)
    warning('checkDataCube:InvalidField', messages{i});
end