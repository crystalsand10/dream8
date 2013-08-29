function varargout = MidasImporter(filename, varargin)
% MidasImporter reads a CSV file based on the Midas standard
%
% [dataCube, parameters] = MidasImporter(filename, parameters)
%
%  or
%
% [data, dimNames, dimValues] = MidasImporter(filename, ...
%             dimCols, timeCols, valueCols, parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS (Syntax 1):
% filename  = name of CSV file
% parameters = optional structure of parameters (default value in parenthesis)
%              .dimCols   = cell of cells containing column names or numbers for the
%                           columns comprising each dimension
%              .timeCols  = cells containing column names or numbers for the
%                           columns comprising the time dimension
%              .valueCols = cells containing column names or numbers for each "value" field
%              .IgnoreMissing(true) = true to ignore missing values, rather than
%                               treat them as NaN's
%              .BackgroundTreatment([]) = column name or number of
%                               background treatments, which are extracted
%                               from the data and stored in the parameters
%                               of output
%              .BackgroundProcessing([]) = processing
%                               function for background data (e.g.
%                               subtract); if empty, then no background
%                               processing is performed. To subtract
%                               background, pass the function 
%                               @(data, bkgd) data - nanmean(bkgd)
%                               First argument is a multidimensional array
%                               of data FOR A SINGLE SIGNAL; bkgd is a
%                               vector of background measurements FOR A
%                               SINGLE SIGNAL
%              .CompactNames(false) = When a dimension label only has a
%                               single type, setting this parameter to true
%                               will cause the values to only contain the
%                               level of the label; setting to false will
%                               cause the value of the label to include the
%                               name of the dimension in the actual value;
%                               e.g. CompactNames = false --> 'TR:EGF=1'
%                                    CompactNames = true  --> '1'
%
% INPUTS (Syntax 2):
% filename  = name of CSV file
% dimCols   = cell of cells containing column names or numbers for the
%             columns comprising each dimension
% timeCols  = cells containing column names or numbers for the
%             columns comprising the time dimension
% valueCols = cells containing column names or numbers for each "value" field
% parameters = optional structure of parameters (default value in parenthesis)
%              .IgnoreMissing(true) = true to ignore missing values, rather than
%                               treat them as NaN's
%              .BackgroundTreatment([]) = column name or number of
%                               background treatments, which are extracted
%                               from the data and stored in the parameters
%                               of output
%              .BackgroundProcessing([]) = processing
%                               function for background data (e.g.
%                               subtract); if empty, then no background
%                               processing is performed. To subtract
%                               background, pass the function 
%                               @(data, bkgd) = data - nanmean(bkgd)
%                               First argument is a multidimensional array
%                               of data FOR A SINGLE SIGNAL; bkgd is a
%                               vector of background measurements FOR A
%                               SINGLE SIGNAL
%
% OUTPUTS:
% data      = hypercube of data
% dimNames  = field names (labels) for each of the dimensions
% dimValues = values for each dimension
% dataCube  = data cube structure
% parameters
%
%--------------------------------------------------------------------------
% EXAMPLE:
% [data, names, values] = MidasImporter(filename, ...
%        {...% Column names or numbers for each dimension
%        {'TR:HepG2'},%dimension 1 = cells
%        {'TR:NO-CYTO','TR:EGF','TR:HER','TR:AMP','TR:TGF','TR:EGF-HER',...
%         'TR:HER-TGF','TR:AMP-EGF','TR:EPI-TGF','TR:TGF-EGF'},
%        {'TR:NO-DRUG','TR:PI3Ki'},
%         },...
%         {'DA:AKT','DA:ERK12'},...
%         {'DV:AKT','DV:ERK12'}...
%         );
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
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe    Nickel Dittrich
%    SBPipeline.harvard.edu%

%% Set user-definable parameters
if nargin == 2
    parameters = varargin{1};
    oldSyntax = false;
elseif nargin == 5
    oldSyntax = true;
    parameters = varargin{4};
    parameters.dimCols = varargin{1};
    parameters.timeCols = varargin{2};
    parameters.valueCols = varargin{3};
else
    error('Invalid number of input arguments');
end

defaultParameters = struct(...
    'dimCols', [],...
    'timeCols', [],...
    'valueCols', [],...
    'IgnoreMissing', false, ...
    'BackgroundTreatment', [], ...
    'BackgroundProcessing', [],...
    'BackgroundData', [], ...
    'CompactNames', false);

parameters = setParameters(defaultParameters, parameters);

%% Try opening file
fid = fopen(filename, 'r');
if fid == -1
    error('Unable to open file "%s".', filename);
end


%% Run importer
try
    if oldSyntax
        varargout = cell(3,1);
        [varargout{:}] = MidasImporterMain(fid, parameters);
    else
        [dataValues, dimNames, dimValues, parameters] = MidasImporterMain(fid, parameters);
        labels = struct('Name', dimNames, 'Value', dimValues);
        dataCube = createDataCube('Name', 'RawData', 'Info', 'Natively imported data', ...
            'Value', dataValues, 'Labels', labels, 'SourceData', filename, ...
            'Parameters', parameters);
        varargout{1} = dataCube;
        varargout{2} = parameters;
    end
catch
    % Always close file!
    fclose(fid);
    rethrow(lasterror);
end
fclose(fid);
end

%% Real importer function
function [data, allDimNames, allDimValues, parameters] = ...
    MidasImporterMain(fid, parameters)
dimCols = parameters.dimCols;
timeCols = parameters.timeCols; 
valueCols = parameters.valueCols;

%% Define parameter
joinChar = ',';
emptyDataVal = nan;

%% Read header and file
header = parseLine(fgetl(fid))';
header = removeEmptyFromEnd(header);
headerHash = makeHash(header);
numCols = numel(header);
formats = repmat({'%*q'}, 1, numCols);

%% Convert cell of column names/numbers to array of numbers
for i=1:numel(dimCols)
    dimCols{i} = colNamesToNumbers(dimCols{i}, headerHash);
    for j=1:numel(dimCols{i})
        formats{dimCols{i}(j)} = '%q'; % read treatments as quoted strings
    end
end
timeCols = colNamesToNumbers(timeCols, headerHash);
for i=1:numel(timeCols)
    formats{timeCols(i)} = '%f'; % read times as numbers
end
valueCols = colNamesToNumbers(valueCols, headerHash);
for i=1:numel(valueCols)
    formats{valueCols(i)} = '%f'; % read values as numbers
end
timeColsByValue = makeTimeColsByValue(header, timeCols, valueCols);
backgroundCols = colNamesToNumbers(parameters.BackgroundTreatment, headerHash);
for i=1:numel(backgroundCols)
    formats{backgroundCols(i)} = '%q'; % read background as text
end
%% Check for duplicate columns
dataCols = sort([dimCols{:},timeCols,valueCols,backgroundCols]);
if numel((dataCols)) ~= numel(dataCols)
    error('DataRail:MidasImporterError','The same column appears to have been specified multiple times');
end
%% Read in file
format = [formats{:}];
dataCell = textscanByLines(fid, format, 'Delimiter', ',\t');
%% Validate data
numItems = cellfun(@numel,dataCell);
numRows = numItems(1);
numItemsTest = numItems ~= numRows;
if any(numItemsTest)
    line = numItems(1) + 1;
    % Which data column?
    dataCol = find(numItemsTest, 1, 'first');
    % Which actual column?
    dataColCount = 1;
    for col=1:numCols
        if strcmp(formats{col}, '%*q')
            continue
        end
        % this is a dataCol
        dataColCount = dataColCount + 1;
        if dataColCount == dataCol
            break
        end
    end
    badDataCell = textscan(fid, '%s', 1, 'Delimiter', ',\t');
    if numel(badDataCell{1}) > 0
        error('DataRail:MidasImporterError', ...
            ['Invalid MIDAS file. Line %d, column %d ("%s") contained "%s"' ...
            ' instead of a number.'], line, col, header{col}, badDataCell{1}{1});
    else
        error('DataRail:MidasImporterError', ...
            ['Invalid MIDAS file. Line %d, column %d ("%s").' ], ...
            line, col, header{col});
    end
end
%% Create allCells
allCells = cell(numRows,numCols);
for i=1:numel(dataCols)
    col = dataCols(i);
    if iscell(dataCell{i})
        for row=1:numRows
            allCells{row,col} = dataCell{i}{row};
        end
    else
        for row=1:numRows
            allCells{row,col} = dataCell{i}(row);
        end
    end
end

%% Extract background data & delete from allCells
iBackground = any(~cellfun(@isempty, allCells(:,backgroundCols)),2);
backgroundCells = allCells(iBackground,:);
allCells(iBackground,:) = [];
numRows = size(allCells, 1);
parameters.BackgroundData = cell2mat(backgroundCells(:,valueCols));

%% Look for unique values of each dimension
numDimCols = numel(dimCols);
dimColLevels = cell(numDimCols,1);
dimColFields = cell(numDimCols,1);
dimColIdx = cell(numDimCols,1);
for i=1:numDimCols
    cols = dimCols{i};
    assert2(numel(cols) >= 1, 'Bad value for dimCols?');
    dimColFields{i} = allCells(:,cols);
    [levels, m, n] = uniquerows(dimColFields{i});
    % Now sort
    [dimColLevels{i}, iSort] = sortrows(levels, fliplr(1:size(levels,2)) );
    [temp, key] = sort(iSort);
    dimColIdx{i} = key(n);
end
% Want unique time values among all timeCols
emptyTimeValue = nan;
emptyTimeTest = @(x)(isnan(x));
timeLevels = nanunique(cell2mat(allCells(:,timeCols)));
% But must watch out for empty times
if any(emptyTimeTest(timeLevels))
    if ~parameters.IgnoreMissing
        warning(sprintf(['Some data acquisition steps are missing time values.\n' ...
            'Perhaps you meant to use the IgnoreMissing parameter?']));
    end
    timeLevels = timeLevels(~emptyTimeTest(timeLevels));
end
numTimes = numel(timeLevels);
timeHash = makeHash(timeLevels);

%% Read in data
szDimCols = cellfun('size', dimColLevels, 1);
numValues = numel(valueCols);
dimColIdxCell = cell(numRows,numDimCols);
% Identify treatment indexes
for i=1:numRows
    for j=1:numDimCols
        dimColIdxCell{i,j} = dimColIdx{j}(i);
    end
end
dims = [szDimCols; numTimes; numValues]';
% numDims = numel(dims);
dataCell = cell(dims);
warnedCols = false(size(header));
for i=1:numRows
    for j=1:numValues
        thisCol = valueCols(j);
        thisTimeCol = timeColsByValue(j);
        value = allCells{i, thisCol};
        time = allCells{i,thisTimeCol};
        if isnan(value) && parameters.IgnoreMissing
                continue % Skip
        end
        if isnan(time)
            continue
        end
        idx = {dimColIdxCell{i,:}, timeHash.get(time), j};
        oldValues = dataCell{idx{:}};
        repNum = numel(oldValues) + 1;
        dataCell{idx{:}}(repNum) = value;
    end
end
allReplicates = cellfun(@numel,dataCell);
uniqueReplicates = unique(allReplicates(:));
numReplicates = setdiff(uniqueReplicates,0);
if numel(numReplicates) > 1
    warning(['Number of replicates is not equal across conditions. ' ...
        'Padding missing replicates with NaN''s.']);
end
maxNumReplicates = max(numReplicates);
% Check memory requirement
bytesStorage = 8*prod(dims)*maxNumReplicates;
MBStorage = bytesStorage/2^20;
if MBStorage > 20
    msg = sprintf('This MIDAS file is large and could result in a matrix that requires %d MB of memory. Do you wish to load it?', MBStorage);
    warning('DataRail:MidasImporterWarning:LargeData', msg);
%     response = questdlg('Large data file', msg, 'Yes', 'No', 'No');
%     if ~strcmp('Yes', response)
%         error('DataRail:MidasImporterError', 'Canceling loading of large data file.');
%     end
end
data = nan([dims, maxNumReplicates]);
% Reshape for easy assignment
data = reshape(data,[],maxNumReplicates);
for i=1:size(data,1)
    values = dataCell{i};
    if ~isempty(values)
        thisData = dataCell{i};
        thisNumReplicates = numel(thisData);
        data(i,1:thisNumReplicates) = dataCell{i};
    end
end
data = reshape(data,[dims,maxNumReplicates]);
if nargin == 1
    return
end
%% BackgroundProcessing
if ~isempty(parameters.BackgroundProcessing)
    iValue = numel(dims); % index of value dim
    iDim = repmat({':'}, iValue+1);
    for i=1:numValues
        iDim{iValue} = i;
        thisBackground = parameters.BackgroundData(:,i);
        if all(isnan(thisBackground))
            warning('All background data for signal %s is missing. No processing will be applied to this signal.', ...
                header{valueCols(i)});
        else
            data(iDim{:}) = parameters.BackgroundProcessing(data(iDim{:}), thisBackground);
        end
    end
end

%% Create dimNames and dimValues
join = @(x)(joinCols(header(x),joinChar));
dimNames = cellfun(join, dimCols, 'UniformOutput', 0);
allDimNames = {dimNames{:}, 'time', 'signals', 'replicates'}';
dimValues = cell(numDimCols,1);
for i=1:numDimCols
    theseLevels = dimColLevels{i};
    theseCols = dimCols{i};
    numTheseCols = numel(theseCols);
    if parameters.CompactNames && numel(theseCols) == 1 && numel(theseLevels) > 1
        dimValues{i} = theseLevels;
    else
        dimValues{i} = cell(size(theseLevels,1),1);
        for j=1:size(theseLevels,1)
            fields = theseLevels(j,:);
            levelCell = {};
            for k=1:numel(fields)
                if ~isempty(fields{k})
                    % Use joinChar on everything after the first
                    if isempty(levelCell)
                        levelCell{1} = sprintf('%s=%s', ...
                            header{theseCols(k)}, ...
                            fields{k});
                    else
                        levelCell{end+1} = sprintf('%s%s=%s', ...
                            joinChar, header{theseCols(k)}, ...
                            num2str(fields{k}));
                    end
                end
            end
            dimValues{i}{j} = ['' levelCell{:}];
        end
    end
end
allDimValues = {dimValues{:}, timeLevels, header(valueCols), (1:maxNumReplicates)'}';
%% Remove replicate dimension if no real replicates are found
if maxNumReplicates == 1
    allDimValues(end) = [];
    allDimNames(end) = [];
end
%% Display Dimension Descriptions
% disp('Your DataCube has the following dimensions:')
% if length(allDimNames(1,1))>20
%     dimensions{1,1} = ['Dimension 1 :' allDimNames{1,1}(1:20)];
% else
%     dimensions{1,1} = ['Dimension 1 :' allDimNames{1,1}];
% end
% if length(allDimNames{2,1})>20
%     dimensions{2,1} = ['Dimension 2 :' allDimNames{2,1}(1:20)];
% else
%     dimensions{2,1} = ['Dimension 2 :' allDimNames{2,1}];
% end
% if length(allDimNames{3,1})>20
%     dimensions{3,1} = ['Dimension 3 :' allDimNames{3,1}(1:20)];
% else
%     dimensions{3,1} = ['Dimension 3 :' allDimNames{3,1}];
% end
% if length(allDimNames{4,1})>20
%     dimensions{4,1} = ['Dimension 4 :' allDimNames{4,1}(1:20)];
% else
%     dimensions{4,1} = ['Dimension 4 :' allDimNames{4,1}];
% end
% if length(allDimNames{5,1})>20
%     dimensions{5,1} = ['Dimension 5 :' allDimNames{5,1}(1:20)];
% else
%     dimensions{5,1} = ['Dimension 5 :' allDimNames{5,1}];
% end
% disp(dimensions)
end % function MidasImporter

%% joinCols
function result = joinCols(cols, joinChar)
if ischar(cols)
    result = cols;
elseif iscell(cols)
    if numel(cols) == 1
        result = cols{1};
    else
        result = [cols{1}, sprintf([joinChar '%s'], cols{2:end})];
    end
elseif isnumeric(cols)
else
    error(['Unsupported data type: ' class(cols)]);
end
end % function joinCols

%% unjoinCols
function result = unjoinCols(resultRows, joinChar)
% Remove the joining character
numUniqueRows = numel(resultRows);
result = cell(numUniqueRows,1);
for i=1:numUniqueRows
    if isempty(resultRows{i})
        c = {char(zeros(1,0))};
    else
        c = textscan(resultRows{i},'%s','Delimiter',joinChar)';
    end
    assert2(numel(c) == 1, 'Unexpected textscan result.');
    values = c{1};
    result(i,1:numel(values)) = values;
end
% Make sure all empty fields are empty strings
[j] = find(cellfun(@isempty,result(:)));
for i=j'
    result{i} = '';
end
end % function unjoinCols

%% makeHash
function hash = makeHash(values)
hash = java.util.HashMap;
if iscell(values)
    for i=1:numel(values);
        hash.put(values{i},i);
    end
elseif isnumeric(values)
    for i=1:numel(values);
        hash.put(values(i),i);
    end
else
    error('Expecting cell or numeric data');
end
end % function makeHash

%% makeHashByRows
function hash = makeHashByRows(values)
hash = java.util.HashMap;
for i=1:size(values,1);
    hash.put(values(i,:),i);
end
end % function makeHashByRows

%% colNamesToNumbers
function colNums = colNamesToNumbers(colNames, headerHash)
if isnumeric(colNames)
    colNums = colNames;
    return
end
colNums = zeros(size(colNames));
for i=1:numel(colNames)
    if isnumeric(colNames{i})
        colNums(i) = colNames{i};
    else
        try
            colNums(i) = headerHash.get(colNames{i});
        catch
            error('Unable to find column named %s', colNames{i})
        end
    end
end
end % function colNamesToNumbers

%% myInd2sub
function sub = myInd2sub(siz,ndx)
nout = max(nargout,1);
siz = double(siz);
n = length(siz);
k = [1 cumprod(siz(1:end-1))];
sub = cell(n,1);
for i = n:-1:1,
  vi = rem(ndx-1, k(i)) + 1;
  vj = (ndx - vi)/k(i) + 1;
  sub{i} = vj;
  ndx = vi; 
end
end % function myInd2sub


%% cellstr2mat
function mat = cellstr2mat(cellstr, emptyVal)
[numRows,numCols] = size(cellstr);
mat = zeros(numRows,numCols);
for i=1:numRows
    for j=1:numCols
        str = cellstr{i,j};
        if isempty(str)
            mat(i,j) = emptyVal;
        else
            num = sscanf(str, '%f');
            if numel(num) ~= 1
                error('Invalid MIDAS file. The cell containing "%s" should contain a single number.', str);
            end
            mat(i,j) = num;
        end
    end
end
end % function cellstr2mat

%% mysortrows
function [x0Sorted, iSort] = mysortrows(x0)
% sort with zeros ordered like NaN's
% EXCEPT all zeros remains unchanged
x = x0;
for i=1:size(x)
    if ~all(x(i,:)==0)
        j = find(x(i,:)==0);
        x(i,j) = nan;
    end
end
[xSorted, iSort] = sortrows(x);
x0Sorted = x0(iSort,:);
end % mysortrows

%% nanunique
function y = nanunique(x)
% a version of unique that treats nan's as identical
y = unique(x);
i = find(isnan(y));
if numel(i) > 1
    y(i(2:end)) = [];
end
end % nanunique

%% uniquerows
function [b3, m2, n2] = uniquerows(a)
% find unique rows of a cellstr
[b,m,n] = unique(a);
b1 = 1:numel(b);
a1 = reshape(b1(n),size(a));
[b2,m2,n2] = unique(a1, 'rows');
b3 = b(b2);
end % uniquerows

%% uniqueCellNum
function b = uniqueCellNum(a)
% find unique numbers in a cell of numbers, dropping nan's
b = [];
for i=1:numel(a)
    if ~isnan(a{i})
        b = a{i};
        break
    end
end
for j=i+1:numel(a);
    if ~any(b==a{j})
        b(end+1) = a{j};
    end
end
1;
end % uniqueCellNum

%% nanunique_cellstr2mat
function numList = nanunique_cellstr2mat(x, empty);
% converts cellstr to list of unique numbers
numList = nanunique(cellstr2mat(x, empty));
return
strSet = java.util.HashSet;
% Store unique strings
for i=1:numel(x)
    strSet.add(x{i});
end
% Then convert to unique list of numbers
numSet = java.util.HashSet;
iterator = strSet.iterator;
while iterator.hasNext
    str = iterator.next;
    num = sscanf(str, '%f');
    if numel(num) ~= 1
        error('Invalid MIDAS file. The cell containing "%s" should contain a single number.', str);
    end
    numSet.add(num);
end
n = numSet.size;
numList = zeros(n,1);
iterator = numSet.iterator;
for i=1:n
    numList(i) = iterator.next;
end
numList = sort(numList);
end % nanunique_cellstr2mat

%% makeTimeColsByValue
function timeColsByValue = makeTimeColsByValue(header, timeCols, valueCols);
% Creates a vector that maps the i'th valueCol to its corresponding timeCol
timeHash = java.util.HashMap;
% valueHash = java.util.HashMap;
nTimes = numel(timeCols);
nValues = numel(valueCols);
% Strip leading field (e.g. DA:) and store signal name (2nd field)
% for Time
for i=1:nTimes
    time = header{timeCols(i)};
    % Strip fields
    iSep = find(time==':',2,'first');
    switch numel(iSep)
        case 0
            % do nothing
        case 1
            time = time(iSep+1:end);
        case 2
            time = time(iSep(1)+1:iSep(2)-1);
        otherwise
            error('Unexpected condition; find should have return 0 to 2 values');
    end
    timeHash.put(time, timeCols(i));
end
% for Value
timeColsByValue = zeros(nValues, 1);
for i=1:nValues
    value = header{valueCols(i)};
    % Strip fields
    iSep = find(value==':',2,'first');
    switch numel(iSep)
        case 0
            % do nothing
        case 1
            value = value(iSep+1:end);
        case 2
            value = value(iSep(1)+1:iSep(2)-1);
        otherwise
            error('Unexpected condition; find should have return 0 to 2 values');
    end
    try
        timeColsByValue(i) = timeHash.get(value);
    catch
        warning('DataRail:MidasImporterError', 'No time column matching value column %s', header{valueCols(i)});
    end
%     valueHash.put(value, valueCols(i));
end
end % makeTimeColsByValue

%% removeEmptyFromEnd
function cText = removeEmptyFromEnd(cText)
lastGoodIndex = 0;
for i=numel(cText):-1:1
    if ~isempty(cText{i})
        lastGoodIndex = i;
        break
    end
end
cText = cText(1:lastGoodIndex);
end % function removeEmptyFromEnd

%% textscanByLines
function dataCell = textscanByLines(fid, format, varargin)
linesPerBatch = 1000;
% Creat an empty buffer of the appropriate size
fakeData = textscan(sprintf('\n'),format,varargin);
numCol = size(fakeData,2);
buffer = cell(0,numCol);
while ~feof(fid)
    % Read one batch of lines
    linesCell = textscan(fid, '%s', linesPerBatch, 'Delimiter', '');
    assert2(numel(linesCell)==1, 'Unexpected formatting in file %s; unable to identify lines.');
    lines = linesCell{1};
    % Parse each line
    i0 = size(buffer,1);
    for i=numel(lines):-1:1
        dataLine = textscan(lines{i}, format, 1, varargin{:});
        [buffer{i0+i,:}] = deal(dataLine{:}); % store fields in buffer
    end
end
% Replace empty buffer cells with NaN (can happen in final column)
iEmpty = cellfun(@isempty, buffer);
buffer(iEmpty) = {NaN};
% Join buffer columns
dataCell = cell(1,numCol);
for i=1:numCol
    dataCell{i} = cat(1,buffer{:,i});
end
end % function textscanByLines