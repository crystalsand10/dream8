function Parameters = setParameters(DefaultParameters, NewParameters)
% setParameters sets parameters based on default and explicit values
%
% Parameters = setParameters(DefaultParameters, NewParameters)
%
%--------------------------------------------------------------------------
% INPUTS:
% DefaultParameters  = structure containing default parameter values
% NewParameters      = structure containing new parameter values
%                               treat them as NaN's
%
% Note: NewParameters can be in one of two forms.
%  * In form 1 (the preferred form), each strucure field name is a
%    parameter name, and the field value is the parameter value
%  * In form 2 (deprecated), the structure is a vector containing two
%    fields, Name and Value, where Name is the parameter name and
%    Value is the parameter value.
%
% OUTPUTS:
% Parameters         = structure containing default and new parameter values
%
%--------------------------------------------------------------------------
% EXAMPLE:
% DefaultParameters = struct('MinX', 1, 'MinY', 1);
% Parameters = setParameters(DefaultParameters, NewParameters);
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

otherAllowedFields = {'Labels'}; % Don't generate warnings if these fields are passed

if ~isstruct(DefaultParameters)
    error('DefaultParameters must be a structure.')
end
if ~isempty(NewParameters) && ~isstruct(NewParameters)
    error('NewParameters must be a structure or an empty object.')
end
%% replace empty something with empty structure
if isempty(NewParameters)
    NewParameters=struct;
end
switch numel(DefaultParameters)
    case 1
        Parameters = repmat(DefaultParameters, size(NewParameters));
    case 0
        % Create structure of right size with empty fields
        fn = fieldnames(DefaultParameters);
        Parameters = cell2struct(cell([size(NewParameters), numel(fn)]), fn, ndims(NewParameters)+1);
    otherwise
        error('DefaultParameters must be a structure of length 0 or 1');
end

try
%% Convert to new style of parameters
    if numel(fieldnames(NewParameters)) == 2 && ...
            isfield(NewParameters, 'Name') && isfield(NewParameters, 'Value');
        NewParameters2 = NewParameters;
        NewParameters = struct;
        for i=1:numel(NewParameters2)
            Name = NewParameters2(i).Name;
            NewParameters.(Name) = NewParameters2(i).Value;
        end

    end

%% Override default parameters
    fields = fieldnames(NewParameters);
    for i=1:numel(fields)
        field = fields{i};
        if ~isfield(Parameters, field) && ~any(strmatch(field, otherAllowedFields, 'exact'))
            warning('setParameters:UnknownField', ...
                ['Field "%s" is not present in DefaultParameters. '...
                'Check field''s spelling and the documentation of the calling '...
                'function.'], field);
        end
        [Parameters.(field)] = deal(NewParameters.(field));
    end
catch
    le = lasterror;
    warning('setParameters:UknownError', 'Unable to parse NewParameters: %s', le.message);
end