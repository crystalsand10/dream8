function [] = exportDataCubeToMidas(data, Parameters)
% exportDataCubeToMidas exports data to a MIDAS text file
%
% exportDataCubeToMidas(data, Parameters)
%--------------------------------------------------------------------------
% INPUTS:
% data          = data cube
% Parameters
%   .OutputFile = required output file name
%   .Labels     = required labels structure
%   .Delimiter(',') = optional column delimiter, e.g. "," or "\t"
%
% OUTPUTS: None
%
% Note: Assumes canonical form
%--------------------------------------------------------------------------
% EXAMPLE:
% exportDataCubeToMidas(Compendium.data(1).Value, ...
%    struct('OutputFile', 'MID-1111-data.csv', ...
%           'Labels',     Compendium.data(1).Labels));
%
%--------------------------------------------------------------------------
% TODO:
%
% - Handle combination treatments (e.g. multiple cytokines)
% - Handle (multiple) concentrations (e.g. TNF=1, TNF=2)
% - Handle non-canonical inputs


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

%% Check parameters
DefaultParameters = struct(...
    'OutputFile', [], ...
    'Labels', [], ...
    'Delimiter', ',');
Parameters = setParameters(DefaultParameters, Parameters);
if isempty(Parameters.OutputFile) || ~ischar(Parameters.OutputFile)
    error('Required parameter OutputFile was not specified.');
end
labels = Parameters.Labels;
if isempty(labels) || ~isstruct(labels) || ~all(isfield(labels, {'Name', 'Value'}))
    error('Required parameter Labels was not correctly specified.');
end

dlm = sprintf(Parameters.Delimiter);
nl = sprintf('\n');
%% Identify dimensions (assumes canonical)
treatmentDims = [1 3 4];
timeDim = 2;
signalDim = 5;
sz = size(data);
% %% Identify treatments
% nTreatment = sum( cellfun(@numel, {labels(treatmentDims).Value}) );
%% open file
fid = fopen(Parameters.OutputFile, 'w');
try
%% Reshape cube
    [newData, newLabels] = collapseDataCube(data, ...
        struct('Dims', treatmentDims, 'Labels', labels));
%% Print header
%     trHash = java.util.HashMap;
%     trCount = 0;
    for j=treatmentDims
        trName = labels(j).Name;
        trValues = labels(j).Value;
        if ischar(trValues)
            trValues = {trValues};
            labels(j).Value = trValues;
        elseif isnumeric(trValues)
            warning('Labels of treatment dimension %d should contain text instead of numbers', j);
            trValues = arrayfun(@num2str, trValues, 'UniformOutput', 0);
            labels(j).Value = trValues;
        end
        for k=1:numel(trValues);
            % Skip empty treatments
            if isempty(trValues{k})
                continue
            end
            % take out ',' of Values
            for m=1:length(trValues{k})
                if strcmp(trValues{k}(m),',')
                    trValues{k}(m) = '/';
                end
            end
            fprintf(fid,['TR:%s:%s' dlm], trValues{k}, trName);
%             if ~isempty(trHash.get(trValues{k}))
%                 warning('Treatment %s appears in multiple dimensions.', trValues{k});
%             else
%                 trCount = trCount + 1;
%                 trHash.put(trValues{k}, [trCount j k]);
%             end
        end
    end
    % Handle special case of single string label.value
    if sz(signalDim) == 1 && ischar(labels(signalDim).Value)
        labels(signalDim).Value = {labels(signalDim).Value};
    end
    fprintf(fid,['DA:%s' dlm], labels(signalDim).Value{:});
    fprintf(fid,['DV:%s' dlm], labels(signalDim).Value{1:sz(signalDim)-1});
    % Print newline, not comma, at end of line
    fprintf(fid, ['DV:%s\n'], labels(signalDim).Value{sz(signalDim)});
%% Print each row of data
    idx = cell(1,numel(treatmentDims));
    for i=1:size(newData,1)        
        [idx{:}] = ind2sub(sz(treatmentDims), i);
        tr = cell(1, numel(treatmentDims));
        for ij=1:numel(treatmentDims)
            j = treatmentDims(ij);
            trValues = labels(j).Value;
            for k=1:sz(treatmentDims(ij))
                if isempty(trValues{k})
                    continue
                end
                if k==idx{ij}
                    tr{ij}{k} = ['1' dlm];
                else
                    tr{ij}{k} = dlm;
                end
            end
            tr{ij} = [tr{ij}{:}];
        end
        tr = [tr{:}];
        for k=1:sz(timeDim)
            for m=1:size(newData,4)
                % Skip line if all data are NaN's
                if all(isnan(newData(i,k,:,m)))
                    continue
                end
                fprintf(fid, tr);
                da = cell(1,sz(signalDim));
                dv = cell(1,sz(signalDim));
                for j=1:sz(signalDim)-1
                    val = newData(i,k,j,m);
                    if ~isnan(val)
                        da{j} = sprintf(['%f' dlm], labels(timeDim).Value(k));
                        dv{j} = sprintf(['%f' dlm], newData(i,k,j,m));
                    else
                        da{j} = dlm;
                        dv{j} = dlm;
                    end
                end
                % Print newline, not comma, at end of line
                j = sz(signalDim);
                val = newData(i,k,j,m);
                if ~isnan(val)
                    da{j} = sprintf(['%f' dlm], labels(timeDim).Value(k));
                    dv{j} = sprintf(['%f' nl], newData(i,k,j,m));
                else
                    da{j} = dlm;
                    dv{j} = nl;
                end
                da = [da{:}];
                dv = [dv{:}];
                fprintf(fid, da);
                fprintf(fid, dv);
            end
        end
    end
catch
%% Close file
    fclose(fid);
    rethrow(lasterror);
end
fclose(fid);