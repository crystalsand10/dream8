function [fields, parameters] = parseHeader(filename, parameters)
% parseHeader parses the header fields in a (Midas) file
%
% [fields, parameters] = parseHeader(filename, parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
% filename   = name of CSV file
% parameters(default) = optional structure of parameters
%             (no parameters are currently used)
%
% OUTPUTS:
% fields     = structure of field names by type (TR, DA, DV)
% parameters = structure of parameters
%    .warnings = list of warnings generated
%
%--------------------------------------------------------------------------
% EXAMPLE:
% fields = parseHeader('MD-LGA-11112-EGFInh17phFI-BLK.csv');
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

defaultParameters = struct('Warnings', {{}});
if ~exist('parameters', 'var')
    parameters = struct;
end
parameters = setParameters(defaultParameters, parameters);

%% Read in the file
fid = fopen(filename);
if fid == -1
    error(['Unable to open file ' filename]);
end
rem=fgets(fid);
line1 = fscanf(fid,'%s\n');
fclose(fid);
try
    header = parseLine(rem);
catch
    error('Unable to find the header, empty line in MIDAS file?')
end
[TR,DA,DV] = deal(struct('num',0,'vars',{{}}));
for i=1:numel(header)
    if numel(header{i})>2
        switch header{i}(1:2)
            case 'TR'
                TR.num=TR.num+1;
                TR.vars{TR.num}=header{i}(4:end);
            case 'DA'
                DA.num=DA.num+1;
                DA.vars{DA.num}=header{i}(4:end);
            case 'DV'
                DV.num=DV.num+1;
                DV.vars{DV.num}=header{i}(4:end);
        end
    end
end
% DA.num
% DA.vars
% if DA.vars{1}=='ALL'
%     DA.vars = DV.vars;
% end
% Map each DA to one or more DV's
hash = java.util.HashMap;
i=0;
% if DA.vars{1}~='ALL'
while i < DA.num
    i=i+1;
    thisDA = DA.vars{i};
    %thisDV = DV.vars{i};
    % First, try exact match
    iMatch = strmatch(thisDA, DV.vars, 'exact');
    %iMatch = strmatch(thisDA, DA.vars, 'exact');
    switch numel(iMatch)
        case 1
            % Exact match
            hash.put(thisDA,thisDA);
            %hash.put(thisDV,thisDV);
        case 0
            % No exact matches, look for inexact matches
            iMatch = strmatch(thisDA, DV.vars);
            %iMatch = strmatch(thisDV, DA.vars);
            if numel(iMatch) == 0
                warnmsg = ['No corresponding DV: field was found for DA:' thisDA];
                %warnmsg = ['No corresponding DA: field was found for DV:' thisDV];
                %                 warndlg(warnmsg);
                warning(warnmsg);
                parameters.Warnings(end+1) = warnmsg;
                % Delete this DA from list
                DA.vars(i) = [];
                %DV.vars(i) = [];
                DA.num = DA.num - 1;
                %DV.num = DV.num-1;
                i = i - 1;
            end
            hash.put(thisDA,DV.vars(iMatch));
            %hash.put(thisDV,DA.vars(iMatch));
        otherwise
            % Multiple exact matches!
            warnmsg = ['Multiple fields were found with the name DV:' thisDA ];
            %warnmsg = ['Multiple fields were found with the name DA:' thisDV ];
            warning(warnmsg);
            parameters.Warnings(end+1) = warnmsg;
            %             warndlg(warnmsg);
    end
end
% else
%     DA.vars = DV.vars
%     %hash.put(thisDA,thisDA);
% end
fields = struct(...
    'TR', struct('Name', 'TR', 'Value', {TR.vars}, 'Type', {repmat({''},1,numel(TR.vars))}), ... {{}}), ... 
    'DA', struct('Name', 'DA', 'Value', {DA.vars}, 'Type', {repmat({''},1,numel(TR.vars))}), ... {{}}), ... 
    'DV', struct('Name', 'DV', 'Value', {DV.vars}, 'Type', {repmat({''},1,numel(TR.vars))}), ... {{}}), ... 
    'DAtoDVHash', hash);
    %'DVtoDAHash', hash);

fn = {'TR', 'DA', 'DV'};
for i=1:numel(fn)
    fields.(fn{i}) = splitFields(fields.(fn{i}));
end

function s = splitFields(s1)
s = s1;
%% Look for fields that contain colons (:)
iMatch = strfind(s1.Value, ':');
iCount = cellfun(@numel, iMatch);
groups = java.util.HashMap;
nGroups = 1;
for i=find(iCount)
%     thisValue = s1.Value{i}(1:iMatch{i}(1)-1);
%     s(1).Value{i} = thisValue;
    thisType = s1.Value{i}(iMatch{i}(1)+1:end);
    s(1).Type{i} = thisType;
end