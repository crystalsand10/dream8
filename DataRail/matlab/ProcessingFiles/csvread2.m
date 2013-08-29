function [data,colHeaders,rowHeaders,headerHeaders,textData,cells] = csvread2(filename, delimiter)
% CSVREAD2 reads in a CSV file that contains multipe header rows/columns
% [data, colHeaders, rowHeaders, headerHeaders] = mycsvread(filename, delimiter)
% filename = name of file
% delimiter = optional delimiter (defaults to ",")
%
% data = the numeric array in the csv file
% colHeaders = cell of strings 
% rowHeaders = cell of strings
% headerHeaders = any extra rows of text found before the data
% textData = contents of file as a cell string
% cells = contents of file as cell, fields converted to numbers whenever possible

if ~exist('delimiter', 'var') || isempty(delimiter)
    delimiter = ',';
end

[fid, msg] = fopen(filename, 'r');
if fid == -1
    error('Unable to read file %s. Message: %s', filename, msg);
end
result = textscan(fid,'%s','Delimiter','');
lines = result{1};
fclose(fid);

textData = {};
for i=1:numel(lines);
    result = textscan(lines{i},'%q','Delimiter',delimiter);
    textData(i,1:numel(result{1})) = result{1};
end

% Remove empty rows and and columns
for dim=1:2
    i=0;
    while i < size(i,dim)
        i = i + 1;
        if dim == 1
            chunk = textData(i,:);
        else
            chunk = textData(:,i);
        end
        empty = cellfun(@isempty, chunk);
        if all(empty)
            if dim == 1
                textData(i,:) = [];
            else
                textData(:,i) = [];
            end
            i = i - 1;
        end
    end
end
        

% Make sure empty cells are strings
for i=1:numel(textData)
    if isempty(textData{i}) && isnumeric(textData{i})
        textData{i} = '';
    end
end

% Create numeric version of cells
cells = textData;
for i=1:numel(cells)
    % Convert numeric cells to numbers
% Too slow!        
%         [number,status] = str2num(cells{i});
    [number, count] = sscanf(cells{i},'%g%s');
    if count == 1
        cells{i} = number;
    else % and strip text of leading/TRAILing quotes
        newString = regexprep(cells{i}, '^([''"])(.*)\1$', '$2');
        if ~strcmp(newString, cells{i})
            cells{i} = newString;
        end
    end
end

% Determine numeric/empty region
[rowEnd, colEnd] = size(cells);
test1 = cellfun(@isnumeric, cells);
test2 = cellfun(@isempty, cells);
test3 = test1 | test2;
test = false(size(test3));
%% A more robust test: look for largest "square"
for i=rowEnd:-1:1
    for j=colEnd:-1:1
        if i==rowEnd & j==colEnd
            test(i,j) = test3(i,j);
        elseif i==rowEnd
            test(i,j) = test3(i,j) & test(i,j+1);
        elseif j==colEnd
            test(i,j) = test3(i,j) & test(i+1,j);
        else
            test(i,j) = test3(i,j) & test(i+1,j) & test(i,j+1);
        end
    end
end
rowStart = 0;
colStart = 0;
for i=1:max(rowEnd,colEnd)
    for j=1:i
        if i <= rowEnd && j <= colEnd && test(i,j)
            rowStart = i;
            colStart = j;
            break
        elseif j <= rowEnd && i <= colEnd && test(j,i)
            rowStart = j;
            colStart = i;
            break
        end
    end
    if rowStart ~= 0
        break
    end
end
if rowStart == 0 || colStart == 0
    warning('csvread2:noNumericData', 'Unable to identify numeric data');
    data = [];
    colHeaders = [];
    rowHeaders = [];
    headerHeaders = textData;
    return
end
%% This approach doesn't always work:
% test = test1 | test2;
% while test(rowStart,colStart-1)
%     colStart = colStart - 1;
% end
% while test(rowStart-1,colStart)
%     rowStart = rowStart - 1;
% end

% Convert empty cells in numeric region to NaN
for i=rowStart:rowEnd
    for j=colStart:colEnd
        if isempty(cells{i,j})
            cells{i,j} = nan;
        end
    end
end

data = cell2mat(cells(rowStart:rowEnd, colStart:colEnd));
colHeaders = textData(1:rowStart-1,colStart:colEnd);
rowHeaders = textData(rowStart:rowEnd,1:colStart-1);
headerHeaders = textData(1:rowStart-1,1:colStart-1);