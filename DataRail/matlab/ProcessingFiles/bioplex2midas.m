function [] = bioplex2midas(dataFile, treatmentFile, outputFile, parameters)
% BIOPLEX2MIDAS converts BioPlex data Files to the MIDAS format
%
% bioplex2midas(dataFile, treatmentFile, outputFile, parameters)
%
%--------------------------------------------------------------------------
% INPUTS: 
%  
% dataFile      = name of BioPlex data file (CSV or XLS)
% treatmentFile = name of the file describing the treatments and
%                 descriptions (only CSV is fully supported!)
% outputFile    = name of the output file
% parameters    = structure of optional parameters:
%           TreatmentSublabels(true) = true to include TR types as sublabels,
%                               e.g. TR:EGF:Cytokine
%           DataSublabels(true) = true to include signal type as sublabels
%                               e.g. DV:EGF:FI
%
% treatmentFile format: See Example_names_for_Bioplex.txt
%
% OUTPUTS:
%
% None
%
%--------------------------------------------------------------------------
% EXAMPLE:
% 
% bioplex2midas('../Data/Leo/1oHum_03hrs_pl02_17plex.txt', ...
%   'Example_names_for_Bioplex.txt', 'out.csv');
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

%% Handle parameters
defaultParameters = struct(...
    'TreatmentSublabels', true, ...
    'DataSublabels', true);
if ~exist('parameters', 'var')
    parameters = struct;
end
parameters = setParameters(defaultParameters, parameters);


[treatmentData, timeList, treatmentLabels, descriptionHash] = parseTreatmentFile(treatmentFile, parameters);
[signalData,descriptions,signalNames,typeData,wellData,signalType] = parseDataFile(dataFile, parameters);
createOutputFile(outputFile, ...
    treatmentData, timeList, treatmentLabels, descriptionHash, ...
    signalData, descriptions, signalNames, ...
    typeData,wellData,signalType, parameters);

%% str
function s = str(x)
% convert x to a string
if ~exist('x', 'var')
%     warning('No input supplied to function str.');
    s = '';
elseif ischar(x)
    s = x;
elseif isnumeric(x)
    s = num2str(x);
else
    warning('Trying to convert unknown class to a string.');
    try
        s = char(x);
    catch
        s = '';
    end
end

%% parseTreatmentFile
function [data, timeList, labels, descriptionHash] = parseTreatmentFile(treatmentFile, parameters)
% data is a cell of treatment data as strings; each column
%   corresponds to a label in treatmentLables; each row corresponds to a
%   different description
% labels is a cellstr vector of labels for treatmentData
% descriptionHash is a Hash that maps a description to a row number

specialSpeciesNames = {'ALL', 'BLANK', ''};
notInAllSpeciesNames = {'DMSO'}; % Species that are not included when "ALL" is used

treatmentStruct = myimportdata(treatmentFile);
treatmentText = treatmentStruct.textdata;
% Delete empty rows and cols
emptyData = cellfun(@isempty, treatmentText);
emptyRows = all(emptyData,2);
emptyCols = all(emptyData,1);
treatmentText(emptyRows,:) = [];
treatmentText(:,emptyCols) = [];
% Ignore headers and look for description field
rowStart = 1;
rowEnd = size(treatmentText,1);
while rowStart < rowEnd
    treatmentLabels = treatmentText(rowStart,:);
    iDescription = strmatch('Description', treatmentLabels, 'exact');
    if isempty(iDescription) % Also look for "Name"
        iDescription = strmatch('Name', treatmentLabels, 'exact');
        if ~isempty(iDescription)
            warning('"Name" field should be changed to "Description"');
        end
    end
    rowStart = rowStart + 1;
    if ~isempty(iDescription)
        break
    end
end
if isempty(iDescription)
    error('Unable to identify the name/description column.');
end
iTime = strmatch('Time', treatmentLabels, 'exact');
if isempty(iTime)
    error('Unable to identify the time column.');
end
descriptionList = treatmentText(rowStart:end,iDescription);
descriptionHash = java.util.HashMap;
for i=1:numel(descriptionList)
    descriptionHash.put(descriptionList{i},i);
end
timeList = treatmentText(rowStart:end,iTime);
% % Remove descriptions from treatment data
% colList = setdiff(1:numel(treatmentLabels), [iDescription iTime]);
% treatmentLabels = treatmentLabels(colList);
% treatmentData = treatmentText(rowStart:end,colList);
%% Parse data into a structure
dataStruct = struct('Time',{timeList},'Description',{descriptionList},...
    'Other',struct,'Treatment',struct);
dataNamesStruct = struct('Other',struct,'Treatment',struct,'TRNames',struct);
speciesHash = java.util.HashMap; %Map of species to treatments (to check for duplicates)
warnedSpeciesStruct = struct;
% Create treatment fields
for j=1:numel(treatmentLabels)
    if j==iTime || j==iDescription
        continue
    end
    treatmentName = treatmentLabels{j};
    treatmentField = genvarname(treatmentName);
    % Background treatments
    if strmatch('TR:Background', treatmentName)
        dataStruct.Treatment.(treatmentField) = struct;
        dataNamesStruct.TRNames.(treatmentField) = 'Background';
        speciesName = 'Background';
        speciesField = 'Background';
        dataNamesStruct.Treatment.(treatmentField).(speciesField) = speciesName;
        for i0=rowStart:size(treatmentText,1)
            i1 = i0 - rowStart + 1;
            % Parse values
            value = treatmentText{i0,j};
            dataStruct.Treatment.(treatmentField)(i1).(speciesField) = value;
        end
    elseif strmatch('TR:',treatmentName)
        % Store name
        dataNamesStruct.TRNames.(treatmentField) = treatmentName(4:end);
        % Treatment field hash
%         hash = java.util.HashMap;
%         hash.put('TRName',treatmentName);
%     	treatmentNames{end+1} = {treatmentName};
        dataStruct.Treatment.(treatmentField) = struct;
        dataNamesStruct.Treatment.(treatmentField) = struct;
        for i0=rowStart:size(treatmentText,1)
            i1 = i0 - rowStart + 1; % New index
            % Parse values
            value = treatmentText{i0,j};
            [speciesList,concList] = parseValue(value);
            for k=1:numel(speciesList)
                species = speciesList{k};
                % Skip BLANK species
                if strcmpi(species, 'BLNK')
                    warning('Please change BLNK to BLANK');
                    species = 'BLANK';
                end
%                 if any(strcmpi(species, {'BLANK', ''}))
%                     % Add empty struct by eadding an empty ALL field; other
%                     % fields are also empty
%                     dataStruct.Treatment.(treatmentField)(i1).ALL = [];
%                     if ~isfield(dataNamesStruct.Treatment.(treatmentField), 'ALL')
%                         dataNamesStruct.Treatment.(treatmentField).ALL = 'ALL';
%                     end
%                     continue
%                 end
                % Check for species name in other treatments
                storedTreatmentName = speciesHash.get(species);
                speciesField = genvarname(upper(species));
                if isempty(storedTreatmentName)
                    speciesHash.put(species, treatmentName);
                elseif ~any(strcmpi(species, specialSpeciesNames)) && ...
                        ~strcmp(storedTreatmentName, treatmentName) && ...
                        ~isfield(warnedSpeciesStruct, speciesField)
                    warning(['Multiple treatments appear to use the same species: "' species '"']);
                    warnedSpeciesStruct.(speciesField) = 1; % Keep track, so we don't repeat the same message
                end
                dataStruct.Treatment.(treatmentField)(i1).(speciesField) = concList{k};
                if ~isfield(dataNamesStruct.Treatment.(treatmentField), speciesField)
                    dataNamesStruct.Treatment.(treatmentField).(speciesField) = species;
                end
            end
        end
    else
        % Other field
        if ~isfield(dataNamesStruct.Other, treatmentField)
            dataNamesStruct.Other.(treatmentField) = treatmentName;
        end
        for i0=rowStart:size(treatmentText,1)
            i1 = i0 - rowStart + 1;
            % Parse values
            value = treatmentText{i0,j};
            dataStruct.Other(i1).(treatmentField) = value;
        end
    end
end
%% Construct data and labels
labels = {};
otherFields = fieldnames(dataNamesStruct.Other);
for i=1:numel(otherFields)
    field = otherFields{i};
    name = dataNamesStruct.Other.(field);
    labels{end+1} = name;
end
treatmentFields = fieldnames(dataNamesStruct.Treatment);
for j=1:numel(treatmentFields)
    treatment = treatmentFields{j};
    TRName = dataNamesStruct.TRNames.(treatment);
    speciesFields = fieldnames(dataNamesStruct.Treatment.(treatment));
    for i=1:numel(speciesFields)
        field = speciesFields{i};
        name = dataNamesStruct.Treatment.(treatment).(field);
        if any(strcmpi(name, specialSpeciesNames))
            continue
        end
        if parameters.TreatmentSublabels && ~strcmpi(name, 'Background')
            labels{end+1} = ['TR:' name ':' TRName];
        else
            labels{end+1} = ['TR:' name];
        end
    end
end
numCols = numel(labels);
numRows = numel(dataStruct.Time);
data = cell(numRows, numCols);
for row=1:numRows
    col = 1;
%     % Time
%     time = dataStruct.Time{row};
%     data{row,col} = time;
%     col = col + 1;
    % Other fields
    otherFields = fieldnames(dataNamesStruct.Other);
    for j=1:numel(otherFields)
        field = otherFields{j};
        value = dataStruct.Other(row).(field);
        data{row,col} = value;
        col = col + 1;
    end
    % Treatment fields
    for j=1:numel(treatmentFields)
        allFlag = false;
        treatment = treatmentFields{j};
        speciesFields = fieldnames(dataStruct.Treatment.(treatment));
        try
            if ~isempty(dataStruct.Treatment.(treatment)(row).ALL)
                allFlag = true;
            end
        catch
        end
        for k=1:numel(speciesFields)
            field = speciesFields{k};
            name = dataNamesStruct.Treatment.(treatment).(field);
            if any(strcmpi(name, specialSpeciesNames))
                continue
            end
            if allFlag
                if ~any(strcmpi(name, notInAllSpeciesNames))
                    value = '1';
                end
            else
                value = dataStruct.Treatment.(treatment)(row).(field);
            end
            data{row,col} = value;
            col = col + 1;
        end
    end
end

%% parseValue
function [speciesList,concList] = parseValue(value)
% Convert value string into list of species and concentrations

%split on underscores
items = splitString(value, '_');
numItems = numel(items);
speciesList = cell(numItems,1);
concList = cell(numItems,1);
for i=1:numel(items)
    item = items{i};
    % Then split on "="
    splitAt = find(item=='=');
    switch numel(splitAt == 0)
        case 0
            thisSpecies = item;
            thisConc = '1';
        case 1
            thisSpecies = item(1:(splitAt-1));
            thisConc = item((splitAt+1):end);
        otherwise
            error('Unexpected number of "=" in field.')
    end
    speciesList{i} = thisSpecies;
    concList{i} = thisConc;
end

%% parseDataFile
function [data,descriptions,signalNames,typeData,wellData,signalType] = parseDataFile(dataFile, parameters)
dataStruct = myimportdata(dataFile);
% Grab headers: Look for description
for startRow=1:size(dataStruct.textdata,1)
    iDescription = strmatch('Description', dataStruct.textdata(startRow,:), 'exact');
    iType = strmatch('Type', dataStruct.textdata(startRow,:), 'exact');
    iWell = strmatch('Well', dataStruct.textdata(startRow,:), 'exact');
    if ~isempty(iDescription)
        break
    end
end
% End row is just before first empty row
for endDataRow=startRow+1:size(dataStruct.textdata,1)
    if all(cellfun(@isempty,dataStruct.textdata(endDataRow,:)))
        endDataRow = endDataRow - 1;
        break
    end
end
if numel(iDescription) ~= 1
    error('Unable to identify header row');
end
% Identify signal columns
signalColumns = 1:size(dataStruct.textdata,2);
% Remove the following descriptions:
removeDescriptions = {'', 'Type', 'Well'};
i=0;
while i < numel(signalColumns)
    i = i + 1;
    if signalColumns(i) == iDescription
        signalColumns(i) = [];
        i = i - 1;
    elseif any(strmatch(dataStruct.textdata{startRow,signalColumns(i)}, removeDescriptions, 'exact'))
        signalColumns(i) = [];
        i = i - 1;
    end
end
if startRow > 1
    % BioPlex files are supposed to have signal names on the line above
    % row with "Description" and other headers (usually "FI")
    signalNames = dataStruct.textdata(startRow-1,signalColumns);
    signalType = dataStruct.textdata(startRow,signalColumns);
%     if numel(unique(signalType)) == 1
%         signalType = signalType{1};
%     end
else
    warning('File does not follow conventional BioPlex format. Converter will attempt to read signal names from description line.');
    signalNames = dataStruct.textdata(startRow,signalColumns);
    signalType = {};
end
startDataRow = startRow + 1;
measurements = dataStruct.textdata(startDataRow,signalColumns);
numCols = numel(signalNames);
assert2( ~any( cellfun(@isempty, signalNames) ), ...
    'No name found for some signals.');
% Grab descriptions
descriptions = dataStruct.textdata(startDataRow:endDataRow,iDescription);
typeData = dataStruct.textdata(startDataRow:endDataRow,iType);
wellData = dataStruct.textdata(startDataRow:endDataRow,iWell);
for i=1:numel(descriptions)
    if ~ischar(descriptions{i})
        descriptions{i} = str(descriptions{i});
    end
end
numRows = numel(descriptions);
% Grab data
data = dataStruct.textdata(startDataRow:endDataRow, signalColumns);
for i=1:numel(data)
    if isempty(data{i})
        data{i} = nan;
    else
        val = sscanf(data{i}, '%g');
        switch numel(val)
            case 0
                warning(['The text "%s" was found in file "%s" in a cell that should be numeric.'...
                    'This cell''s value will be converted to NaN.'], data{i}, dataFile);
                data{i} = nan;
            case 1
                data{i} = val;
            otherwise
                warning(['Multiple numbers (%s) were found in a cell in file "%s".'...
                    'This cell''s value will be converted to NaN.'], data{i}, dataFile);
                data{i} = nan;
        end
    end
end
data = cell2mat(data);
% But delete any empty columns or rows and check size
emptyData = isnan(data);
emptyRows = all(emptyData,2);
emptyCols = all(emptyData,1);
data(emptyRows,:) = [];
data(:,emptyCols) = [];
assert2( size(data,1) == numRows && size(data,2) == numCols,...
    ['Numeric data array has a size that is inconsistent with '...
    'the number of signals and descriptions.']);

%% createOutputFile
function [] = createOutputFile(outputFile, ...
    treatmentData, timeList, treatmentLabels, descriptionHash, ...
    signalData, descriptions, signalNames, ...
    typeData,wellData,signalType, parameters)
[fid, msg] = fopen(outputFile, 'w');
if fid == -1
    error('Unable to create file %s. Message: %s', outputFile, msg);
end
% Check for background data
backgroundData = strcmp(typeData, 'B');
if any(backgroundData)
    backgroundFound = true;
    if ~isempty(cell2mat(strfind(signalType, 'Bkgd')))
        warning('Background data is included in the output, but it appears to have been subtracted already.');
    end
else
    backgroundFound = false;
end
% Extract background, type, and well data from treatmentData, if present
iBackground = strmatch('TR:Background', treatmentLabels);
if backgroundFound && ~isempty(iBackground)
    otherBackgroundData = treatmentData(:,iBackground);
    treatmentData(:,iBackground) = [];
    treatmentLabels(iBackground) = [];
    warning('Background information from treatment file will be ignored.');
else
    otherBackgroundData = {};
end
iType = strmatch('Type', treatmentLabels);
if ~isempty(iType)
    otherTypeData = treatmentData(:,iType);
    treatmentData(:,iType) = [];
    treatmentLabels(iType) = [];
else
    otherTypeData = {};
end
iWell = strmatch('Well', treatmentLabels);
if ~isempty(iWell)
    otherWellData = treatmentData(:,iWell);
    treatmentData(:,iWell) = [];
    treatmentLabels(iWell) = [];
else
    otherWellData = {};
end

% Write header line
fprintf(fid, 'Description,Type,Well');
if backgroundFound
    fprintf(fid, ',TR:Background');
end
    
for i=1:numel(treatmentLabels)
    fprintf(fid, ',%s', treatmentLabels{i});
end
for i=1:numel(signalNames)
    fprintf(fid, ',DA:%s', signalNames{i});
end
for i=1:numel(signalNames)
    if parameters.DataSublabels && ~isempty(signalType)
        fprintf(fid, ',DV:%s:%s', signalNames{i}, signalType{i});
    else
        fprintf(fid, ',DV:%s', signalNames{i});
    end
end
fprintf(fid, '\n');
% Write data lines
for i=1:numel(descriptions);
    description = descriptions{i};
    fprintf(fid, '%s', ...
        str(description));
    iTreatment = descriptionHash.get(description);
    if isempty(iTreatment)
        warning(['Unable to find a treatment for description ' str(description)]);
    end
    if ~isempty(typeData)
        fprintf(fid, ',%s', typeData{i});
        if ~isempty(otherTypeData) && ~isempty(iTreatment) && ~strcmp(typeData{i}, otherTypeData{iTreatment})
            warning('Type in BioPlex data file (%s) does not match type data in treatment file (%s)', ...
                typeData{i}, otherTypeData{iTreatment});
        end
    end
    if ~isempty(wellData)
        fprintf(fid, '%s', wellData{i});
        if ~isempty(otherWellData) && ~isempty(iTreatment) && ~strcmp(wellData{i}, otherWellData{iTreatment})
            warning('Well in BioPlex data file (%s) does not match well data in treatment file (%s)', ...
                wellData{i}, otherWellData{iTreatment});
        end
    end
    if backgroundFound
        if backgroundData(i)
            fprintf(fid, ',1');
        else
            fprintf(fid, ',');
        end
    end
    for j=1:numel(treatmentLabels)
        fprintf(fid, ',%s', str(treatmentData{iTreatment,j}));
    end
    %DA (time)
    for j=1:numel(signalNames)
        fprintf(fid, ',%s', str(timeList{iTreatment}));
    end
    %DV (value)
    for j=1:numel(signalNames)
        fprintf(fid, ',%s', str(signalData(i,j)));
    end
    fprintf(fid,'\n');
end    
fclose(fid);
%% myimportdata
function data = myimportdata(filename, varargin)
[pathstr, name, ext, versn] = fileparts(filename);
% Use importdata for spreadsheets
if ~isempty(strmatch(lower(ext), {'.xls', '.wk1'}, 'exact'))
    try
        % data = importdata(filename, varargin{:});
        [num, txt, raw] = xlsread(filename);
        data = struct('data', {num}, 'textdata', {txt}, 'raw', {raw});
    catch
        warning('Problems using importdata to read file %s', filename);
        rethrow(lasterr);
    end
    % Split text data as well
    if ~isstruct(data)
        error('Unexpected result from importdata while reading file %s', filename);
    end
    changed = false;
    if isfield(data, 'textdata')
        textdata = data.textdata;
        if isstruct(textdata)
            fn = fieldnames(textdata);
            if numel(fn) > 1
                error(['The file %s contains multiple worksheets. '...
                    'Importing requires a spreadsheet with only one worksheet.'], filename)
            else
                textdata = textdata.(fn{1});
                changed = true;
            end
        end
        [numRow, numCol] = size(textdata);
        % Uncomment if cells need to be split
%         for i=1:numRow
%             for j=1:numCol-1
%                 if ~isempty(textdata{i,j}) && isempty(textdata{i,j+1})
%                     for delimiter=sprintf('\t,');
%                         test = textdata{i,j} == delimiter;
%                         if any(test)
%                             % Split on first delimiter
%                             findList = find(test);
%                             k = findList(1);
%                             text = textdata{i,j};
%                             textdata{i,j} = text(1:k-1);
%                             textdata{i,j+1} = text(k+1:end);
%                             changed = true;
%                             break
%                         end
%                     end
%                 end
%             end
%         end
        % Remove quoted fields
        [numRow, numCol] = size(textdata);
        for i=1:numRow
            for j=1:numCol
                thisText = textdata{i,j};
                if ~isempty(thisText) && ...
                        ~isempty(regexp(thisText, '^([''"]).*\1$')) % start and end with ' or "
                    textdata{i,j} = thisText(2:end-1);
                    changed = true;
                end
            end
        end
    end
    % Store changed text, if necessary
    if changed
        data.textdata = textdata;
    end
    % Also look for multiple sheets in data.data
    if isstruct(data.data)
        fn = fieldnames(data.data);
        if numel(fn) > 1
            error(['The spreadsheet %s contains multiple worksheets. ', ...
                'Importing requires a spreadsheet with only one worksheet.'], filename)
        else
            data.data = data.data.(fn{1});
        end
    end
else
    % Use csvread2 for .txt and .csv files
    if isempty(strmatch(lower(ext), {'.txt', '.csv'}, 'exact'))
        % Don't know what to do with other file types
        rethrow(lasterr);
    end
    % Try comma delimited
    oldWarnState = warning('query', 'csvread2:noNumericData');
    warning('off', 'csvread2:noNumericData');
    [data,colData,rowData,headerData,textdata] = csvread2(filename);
    if size(textdata,2) == 1
        % Try tab delimited
        [data,colData,rowData,textdata] = csvread2(filename, '\t');
        if size(textdata,2) == 1
            error('Unknown format for filename');
        end
    end
    warning(oldWarnState);
    data = struct('data',{data},'textdata',{textdata});
end
%Collate textdata and data into textdata
% See where we can overlay the data
success = false;
[maxJ, maxK] = size(data.data);
offset = size(data.textdata,2) - maxK;
for i=0:size(data.textdata,1)-maxJ
    success = true;
    for k=1:maxK
        for j=1:maxJ
            if isnan(data.data(j,k))
                continue
            end
            if ~isempty(data.textdata{i+j,offset+k})
                success = false;
                break
            end
        end
        if ~success
            break
        end
    end
    if success
        break
    end
end
if success
    for j=1:maxJ
        for k=1:maxK
            %                 % Copy over numbers into empty cells
            %                 if isempty(data.textdata{i+j,offset+k})
            % Copy over numbers
            if ~isnan(data.data(j,k))
                data.textdata{i+j,offset+k} = str(data.data(j,k));
            end
        end
    end
end
