function newfilename = ConvertDAALLtoMIDAS( oldfilename )
% ConvertDAALLtoMIDAS generates all needed time columns for the MIDAS file
% if measurement times are the same for all experiments and if a DA:ALL
% column exists.
%
%  varargout = ConvertDALLtoMIDAS(varargin)
%
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = 
%
%
% OUTPUTS:
%
% varargout = 
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  
%
%--------------------------------------------------------------------------
% TODO:
%
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
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe    Nickel Dittrich
%    SBPipeline.harvard.edu%




%% Ask user for file to load
% handles.FileName = getfile({'*.csv'}, ...
%     'Select a (.CSV) file.');
% if isnumeric(handles.FileName) && handles.FileName == 0
%     % User cancelled
%     return
% end
handles.FileName = oldfilename;
[filePath, fileName, fileExt] = fileparts(handles.FileName);
dataset = importdata(handles.FileName);
sizediff = size(dataset.textdata,2) - size(dataset.data,2);

% A. Goldsipe fix:
% If imported textdata has fewer rows than numeric data, expand it.
numDataRows = size(dataset.data,1);
if size(dataset.textdata,1) < numDataRows+1 % Add one for the header line
    dataset.textdata(1+numDataRows, :) = {[]};
end
% end fix

dataset.data = num2cell(dataset.data);

i=1;
j=0;
m=0;
while i <= size(dataset.textdata(1,:),2)            
    if strcmpi('DA:ALL',dataset.textdata(1,i))==1% where is the time column(no case sensitive)
        j = i;
    end
    if strmatch('DV:',dataset.textdata(1,i))==1  % how many DV columns are there?
        m = m+1;
    end
    i = i+1;
end
if j==0
    newfilename = handles.FileName;
    return
end
if m==0
    warning('No DV columns found');
    newfilename = handles.FileName;
    return
end

newdata.data = cell(size(dataset.data,1),(size(dataset.data,2)+m));
newdata.textdata = cell(size(dataset.textdata,1),(size(dataset.textdata,2)+m));
newdata.data(1:size(dataset.data,1),1:size(dataset.data,2)) = dataset.data;
newdata.textdata(1:size(dataset.textdata,1),1:size(dataset.textdata,2)) = dataset.textdata;
timecolumn = dataset.data(:,j-sizediff);

ntsize = size(newdata.textdata,2)-m;
ndsize = size(newdata.data,2)-m;

k=1;
while k<=m
    % copy time columns
    newdata.data(:,(ndsize+k)) = timecolumn;
    % copy titles and rename
    newdata.textdata(:,(ntsize+k)) = newdata.textdata(:,(ntsize+k-m));
    title = newdata.textdata{1,ntsize+k-m}(3:end);
    newdata.textdata{1,ntsize+k}(1:2) = ('DA');
    newdata.textdata{1,ntsize+k}(3:end) = title;
    k = k+1;
end

%delete DA:ALL column
newdata.textdata(:,j) = '';
tmp = size(newdata.textdata,2) - size(newdata.data,2) + 1;
newdata.data(:,j - tmp) = '';
%newdata.data(:,ndsize-m) = '';

% put everything in one matrix for export
newdata.combined = newdata.textdata;
newdata.combined(2:size(newdata.textdata,1),((ntsize-ndsize+1):ntsize-1+m)) = newdata.data(:,:);

%export to csv file
% if we prefix NEW we remove the syntax MD etc
newfilename2=fileName;%(1:3) = 'NEW';
%newfilename2(4:(3+size(fileName,2))) = fileName;

newfilename2(length(newfilename2)+1:length(newfilename2)+10) = '-DAexp.csv';
newfile = fullfile(filePath, newfilename2);
cell2csv(newfile,newdata.combined,',',2000);
questdlg('DA columns were generated and Dataset has been stored to a new file with the subfic DAexp. DataRail will automatically use the new file now.', newfilename2, 'OK', 'OK');

newfilename = newfile;



function cell2csv(datName,cellArray,seperator,excelVersion)
% Writes cell array content into a *.csv file.
% 
% CELL2CSV(datName,cellArray,seperator,excelVersion)
%
% datName      = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray    = Name of the Cell Array where the data is in
% seperator    = seperating sign, normally:',' (it's default)
% excelVersion = depending on the Excel Version, the cells are put into
%                quotes before added to the file (only numeric values)
%
%         by Sylvain Fiedler, KA, 2004
% updated by Sylvain Fiedler, Metz, 06
% fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler

if seperator ~= ''
    seperator = ',';
end

if excelVersion > 2000
    seperator = ';';
end

datei = fopen(datName,'w');

for z=1:size(cellArray,1)
    for s=1:size(cellArray,2)
        
        var = eval(['cellArray{z,s}']);
        
        if size(var,1) == 0
            var = '';
        end
        
        if isnumeric(var) == 1
            var = num2str(var);
        end
        
        if islogical(var) == 1
            if var == 1
                var = 'TRUE';
            else
                var = 'FALSE';
            end
        end
        
        if excelVersion > 2000
            var = ['"' var '"'];
        end
        fprintf(datei,var);
        
        if s ~= size(cellArray,2)
            fprintf(datei,seperator);
        end
    end
    fprintf(datei,'\n');
end
fclose(datei);

function filename = getsomefile(fhandle,filter,titleText)
if ~exist('titleText','var')
    titleText = 'Pick a file';
end
oldDir = pwd;
% Restore data directory, if present
persistent dataDir
if ~isempty(dataDir)
    cd(dataDir);
end
[FileName,PathName,FilterIndex] = fhandle(filter,titleText);
if isnumeric(FileName) && FileName == 0
    % User cancelled
    filename = 0;
    return
end
filename=[PathName FileName];
dataDir = PathName;
cd(oldDir);
%%
function filename = getfile(varargin)
filename = getsomefile(@uigetfile,varargin{:});

%%

function filename = getnewfile(varargin)
filename = getsomefile(@uiputfile,varargin{:});

