classdef drArray % < handle
% drArray('param1',value1,...) creates a dataCube structure
%
%  data = drArray(varargin)
%
%--------------------------------------------------------------------------
% INPUTS:
%
%
% No arguments are required. The following arguments are valid:
%
% Name        A string description of the data. If not supplied, it will be
%             generated automatically by combining SourceData and Code
%             arguments (if present)
%
% Info        A longer description of the data
%
% Labels      A structure array describing the dimensions of the cube.
%             The structure contains two fields:
%             Labels(i).Name is the name of the i'th dimension
%             Labels(i).Value is a cell string of the values of each level
%                             of the i'th dimesion
%             Note: if no labels are provided but a dataCube is provided in
%             SourceData, labels will be extracted from the cube.
%
% Value       The actual data values. If not supplied, automatically
%             generated using SourceData and Code (if present)
%
% SourceData  Another dataCube, or string (or cell of strings) naming
%             data cube(s) or file(s)
%
% Code        Function name (as a string) or a function handle, used to
%             dynamically generate the Value field.
%             The function must be of the form:
%                [newData, newLabels] = Code(oldData, Parameters)
%             where oldData is an array and Parameters a structure
%             newData is an array and newLabels is an OPTIONAL return
%             argument of new labels generated from an optional argument
%             Parameters.Labels
%
% CodeHashArray A CodeHashArray object that contains a snapshot of the
%             M-files used to generate the data.
%             ** If CodeHashArray is not supplied, a snapshot of Code and
%                all its dependent functions will be stored here **
%             ** If CodeHashArray is suplied, Code must also be supplied,
%                and this snapshot of Code (and its dependent functions)
%                will be used to dynamically generate the Value field.
%
% Parameters  This is the second argument to the Code function and is a
%             structure. For convenience, a cell of Name, Values can be
%             supplied, and the structure will be created dynamically.
%
% PrintWarnings If this parameter is passed and evaluates to false, then
%               no warnings are printed
%
% UserData    Field for arbitrary UserData
%
%--------------------------------------------------------------------------
% EXAMPLE:
% Example 1: Creating a dataCube by passing a function handle and a
% parameter structure
%
%    Parameters(1).Name='EarlyTimes'; Parameters(1).Value= [2];
%    Parameters(2).Name='LateTimes';  Parameters(2).Value= [3 4 5];
%    Data.data(v.TimeC) = drArray(...
%       'Name', 'BackgroundSCompressed', ...
%       'Code', @GetTimeCompressed, ...
%       'Parameters', Parameters, ...
%       'SourceData', Data.data(v.BackS));
%
%% Example 2: Creating a dataCube by passing a function handle and
% a cell of parameter values
%
%   Data.data(v.Bool) = drArray(...
%       'Name', 'Boolean', ...
%       'Info', 'data BsaNormalized converted in a {0 1} digital form', ...
%       'Code', @Booleanizer2, ...
%       'Parameters', {'SigniPeak', 0.72, ...
%                      'SigniDec', 0.82, ...
%                      'ThreshMax', 0.15, ...
%                      'MinSignal', 8, ...
%                      'NegatOnes', {'Ikb', 'GSK3'},...
%                      'LabelsSignals', Data.data(v.TimeC).Labels(5).Value}, ...
%       'SourceData', Data.data(v.TimeC) );
%
%% Example 3: Re-creating a dataCube by passing a CodeHashArray
%
%    Data.data(v.Relat) = drArray(...
%       'Name', 'RelativeMaxSignal', ...
%       'Info', 'BsaNormalized data where each measurement is relative to the maximal value for the same signal', ...
%       'Code', @MaxSignalRelativator, ...
%       'CodeHashArray',  Data.data(v.Relat).CodeHashArray,...
%       'SourceData', Data.data(v.BackS));
%--------------------------------------------------------------------------
% TODO:
%
% - Support Code functions that alter labels
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
%    SBPipeline.harvard.edu

    properties
        Name = ''
        Info = ''
        Labels = struct('Name', '', 'Value', []);
        Value
        SourceData = ''
        Code
        CodeHashArray
        Parameters = struct('Name', {'Dim1', 'Dim2'}, 'Value', {[], []});
        UserData
        ParentCompendium
    end % properties
    
    properties (SetAccess='private') %(Constant=true)
        Version = 0.1
    end

    methods

        function data = drArray(varargin)
            if nargin == 1
                if ~isa(varargin{1}, 'drArray')
                    error('DataRail:drArray:invalidCall', ...
                        'drArray constructor must be initialized with another drArray or with name/value pairs.');
                end
                data = varargin{1};
                return
            end
            %% Parse arguments
                % Default to print warnings
                PrintWarnings = true;
                % Check number of arguments
                if mod(nargin,2) ~= 0
                    error('Arguments must be supplied as parameter/value pairs.');
                end
                for i=1:2:nargin
                    param = varargin{i};
                    value = varargin{i+1};
                    % Check parameter
                    if ~ischar(param)
                        error('Parameter names must be supplied as strings');
                    end
                    % First, handle the CheckDataCube parameter
                    if strcmpi('PrintWarnings', param)
                        PrintWarnings = value;
                        continue
                    elseif ~isfield(data, param)
                        error('Invalid parameter name.')
                    end
                    % Assign value to dataIn
                    data.(param) = value;
                end

            %% Validate fields

            %Name
            if ~ischar(data.Name)
                error('Name must be a string.')
            end
            %Info
            if ~ischar(data.Info)
                error('Info must be a string.')
            end
            %Value
            if ~isnumeric(data.Value) && PrintWarnings
                warning('Value is not a numeric array.')
            end
            %Labels
            if ~isempty(data.Labels) && ( ~isstruct(data.Labels) || ...
                    ~all(isfield(data.Labels, {'Name', 'Value'})) )
                error('Labels must be a struture with Name and Value fields')
            end
            %SourceData: Must be a (cell) string name or another dataCube
            sourceData = '';
            if ~ischar(data.SourceData) && ~iscellstr(data.SourceData)
                % Could be another dataCube
                sourceData = data.SourceData;
                if ~isstruct(sourceData) || ~all(isfield(sourceData, {'Name','Value'}))
                    error('SourceData must be a string or a dataCube structure (Compendium.data(i)).');
                end
                data.SourceData = sourceData.Name;
                if isempty(data.Labels)
                    if isfield(sourceData, 'Labels')
                        data.Labels = sourceData.Labels;
                    elseif PrintWarnings
                        warning('Source data is an old-style data cube without a Labels strcture');
                    end
                end
            end
            %Parameters: Must be a structure or a cell of param, value pairs
            if ~isempty(data.Parameters)
                if isstruct(data.Parameters)
                    % No further processing needed
                elseif iscell(data.Parameters)
                    % Convert to a structure
                    parameters = data.Parameters;
                    data.Parameters = struct;
                    if mod(numel(parameters),2) ~= 0
                        error('Parameters must be supplied as name/value pairs.');
                    end
                    for i=1:2:numel(parameters)
                        name = parameters{i};
                        value = parameters{i+1};
                        data.Parameters.(name) = value;
                    end
                else
                    error('Parameters must be supplied as a cell of parameters/values or as a structure.');
                end
            end
            %Code and CodeHashArray
            if isempty(data.Code)
                % Case 1: No Code supplied
                if ~isempty(data.CodeHashArray)
                    error('Code parameter must be passed along with CodeHashArray');
                end
            else
                % Case 2: Code is supplied
                % Create a function handle
                code = data.Code;
                if ischar(code)
                    fhandle = str2func(code);
                elseif isa(code, 'function_handle')
                    fhandle = code;
                else
                    error('Code must be entered as a string or a function handle.');
                end
                if isempty(data.CodeHashArray)
                    % Case 2A: CodeHashArray is NOT supplied
                    % So create CodeHashArray
                    %        try
                    data.CodeHashArray = CodeHashArray(code);
                    if ischar(sourceData)
                        if PrintWarnings
                            warning('To dynamically generate Value, pass the SourceData argument as a dataCube');
                        end
                    elseif isempty(data.Value)
                        data = callFun(fhandle, sourceData, data);
                    elseif PrintWarnings
                        warning('drArray:ValueCodeConflict',...
                            'Value is present, so function %s will not be used to regenerate the data.', ...
                            func2str(fhandle));
                    end
                    %        catch
                    %            warning('Unable to call the function %s', func2str(fhandle));
                    %        end
                else
                    % Case 2B: CodeHashArray is supplied
                    % Use this snapshot to generate Value
                    % (create M-files in a temporary directory and run the code)
                    tempd = tempname;
                    mkdir(tempd);
                    addpath(tempd);
                    fhandle = dump(CodeHashArray,tempd);
                    data = callFun(fhandle, sourceData, data);
                    rmpath(tempd);
                    rmdir(tempd,'s');
                end
            end
            %Name: If necessary, create the name from SourceData and Code
            if isempty(data.Name) && ~isempty(data.Code)
                code = data.Code;
                if ischar(code)
                    fname = code;
                elseif isa(code, 'function_handle')
                    fname = func2str(code);
                else
                    error('Code must be entered as a string or a function handle.');
                end
                basename = data.SourceData;
                data.Name = [basename '_' fname];
            end
            %Check that the cube is valid
            if PrintWarnings
                checkDataCube(data);
            end

            function data = callFun(fhandle, sourceData, data)
                % Calls function in fhandle

                % Moved to a separate function so we can:
                % 1) Check the format of the function
                % 2) Expand the range of functions that are accepted

                % Add sourceData.Labels to Parameters, if not already supplied
                Parameters = data.Parameters;
                if ~isfield(Parameters, 'Labels')
                    Parameters.Labels = sourceData.Labels;
                end
                try
                    % Optionally assign generated labels
                    [data.Value, p] = fhandle(sourceData.Value, Parameters);
                    % Only assign Labels if not already present and Labels is valid
                    if ~isempty(data.Labels) && isstruct(p) && isfield(p, 'Labels') && ...
                            all(isfield(p.Labels, {'Name', 'Value'}))
                        data.Labels = p.Labels;
                    end
                catch
                    data.Value = fhandle(sourceData.Value, Parameters);
                end
            end % callFun
        end % drArray
        
        function tf = isstruct(obj)
            % Mask as a structure
            tf = true;
        end
        
        function tf = isfield(obj, c)
            tf = isfield(struct(obj), c);
        end
    end % methods

end % classdef