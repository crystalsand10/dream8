function NewData=RemoveInputEqOutput(OldData,Parameters)
% RemoveInputEqOutput removes data where output signals match stimuli or inhibitors
%
%   NewData=RemoveInputEqOutput(OldData,Parameters)
%--------------------------------------------------------------------------
% INPUTS:
% OlData = 5-dimensional data cube in the canonical form
%
% Parameters = structure of parameters (default value in parenthesis)
%     .Labels(required) = Labels to perform the match of names
%     .Replacement(NaN) = value to replace with. It can be
%                         * a number that multiplies the non-perturbation value,
%                         * the string 'mean', which takes the mean across
%                           other cues OR inhibitors when a match is found
%                         * the string 'meanAll', which takes the mean
%                           across BOTH cues AND inhibitors when a match is
%                           found
%     .CueDim(3)        = The dimension that corresponds to input cues
%                         (typically, stimulating cytokines)
%     .InhibitorDim(4)  = The dimension that corresponds to inhibitors
%     .SignalDim(5)     = The dimension that corresponds to the signals (outputs)
%     .SpecialInhibitors= Cell string of special inhibitors that are
%                         ignored (default is {'DMSO', 'NOINHIB'})
%     .CueNonPerturbed(1) = Index of non-perturbed cue condition
%     .InhibitorNonPerturbed(1) = Index of non-perturbed inhibitor condition
%
% OUTPUTS:
%
% NewData = 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
% Parameters.Labels=Data.data(1).Labels
% Data.data(cub+1).Value=RemoveInputEqOutput(Data.data(1).Value,Parameters)
%
%--------------------------------------------------------------------------
% TODO:
%
% - Correctly handle a simultaneous match in cues AND inhibitors (is this
%   relevant?)
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
%

NewData=OldData;
% Check labels
if ~isfield(Parameters, 'Labels') || isempty(Parameters.Labels)
    error('Labels is a required parameter.');
end
Labels=Parameters.Labels;

% Set other parameters to default values
DefaultParameters = struct(...
    'Labels', '', ...
    'Replacement', NaN, ...
    'CueDim', 3, ...
    'InhibitorDim', 4, ...
    'SignalDim', 5,...
    'SpecialInhibitors', {{'DMSO', 'NOINHIB','None'}},...
    'CueNonPerturbed', 1, ...
    'InhibitorNonPerturbed', 1);
Parameters = setParameters(DefaultParameters, Parameters);

dataNDims = ndims(OldData);
dataSize = size(OldData);
signalSize = size(OldData, Parameters.SignalDim);
if isempty(Parameters.CueDim)
    cueSize = [];
else
    cueSize = size(OldData, Parameters.CueDim);
end
if isempty(Parameters.InhibitorDim)
    inhibitorSize = [];
else
    inhibitorSize = size(OldData, Parameters.InhibitorDim);
end

    function replaceDataWithNonPerturbed(jSignal, Dim, DimValue)
        % replace data in SignalDim = jSignal & Dim = DimValue

        % idx1 contains left-hand-side indexes
        idx1 = cell(1,dataNDims);
        % idx2 contains right-hand-side indexes
        idx2 = cell(1,dataNDims);
        for j=1:dataNDims
            if j==Parameters.SignalDim
                idx1{j} = jSignal; % Modify only this signal
                idx2{j} = jSignal;
            elseif j==Dim
                idx1{j} = DimValue; % Modify only this cue/inhibitor
                if Dim==Parameters.CueDim
                    idx2{j} = Parameters.CueNonPerturbed;
                else
                    idx2{j} = Parameters.InhibitorNonPerturbed;
                end
            else
                idx1{j} = 1:dataSize(j); % keep all values of other dimensions
                idx2{j} = 1:dataSize(j); % keep all values of other dimensions
            end
        end
        % Do the actual replacement
        NewData(idx1{:}) = OldData(idx2{:})*Parameters.Replacement;
        if Dim == Parameters.CueDim
            disp(['  Replaced data for signal ' signalName ' & cue ' cueName ' with '  num2str(Parameters.Replacement) '.']);
        elseif Dim==Parameters.InhibitorDim
            disp(['  Replaced data for signal ' signalName ' & inhibitor ' inhibitorName ' with '  num2str(Parameters.Replacement) '.']);
        else
            error('  Unexpected value for Dim (%f)', Dim);
        end
    end

    function replaceDataWithMean(jSignal, Dim, DimValue)
        % replace data in SignalDim = jSignal & Dim = DimValue

        % Calculate mean across Dim EXCLUDING this cue/inhibitor
        if Dim==Parameters.CueDim
            DimSize = CueSize;
        else
            % Exclude this inhibitor from mean
            DimSize = InhibitorSize;
        end

        % idx1 contains left-hand-side indexes
        idx1 = cell(1,dataNDims);
        % idx2 contains right-hand-side indexes
        idx2 = cell(1,dataNDims);
        for j=1:dataNDims
            if j==Parameters.SignalDim
                idx1{j} = jSignal; % Modify only this signal
                idx2{j} = jSignal;
            elseif j==Dim
                idx1{j} = DimValue; % Modify only this cue/inhibitor
                % Exclude this cue/inhibitor from mean
                idx2{j} = setdiff(1:DimSize, DimValue);
            else
                idx1{j} = 1:dataSize(j); % keep all values of other dimensions
                idx2{j} = 1:dataSize(j); % keep all values of other dimensions
            end
        end
        % Replace with mean across all other values of Dim
        NewData(idx1{:}) = nanmean(OldData(idx2{:}), Dim);
        
        if Dim == Parameters.CueDim
            disp(['Replaced data for signal ' signalName ' & cue ' cueName ' with '  num2str(Parameters.Replacement) '.']);
        elseif Dim==Parameters.InhibitorDim
            disp(['Replaced data for signal ' signalName ' & inhibitor ' inhibitorName ' with '  num2str(Parameters.Replacement) '.']);
        else
            error('Unexpected value for Dim (%f)', Dim);
        end
    end

    function replaceDataWithMeanAll(jSignal, Dim, DimValue)
        % replace data in SignalDim = jSignal & Dim = DimValue

        % Calculate mean across all cues AND inhibitors EXCLUDING this cue/inhibitor
        if Dim==Parameters.CueDim
            DimSize = CueSize;
            OtherDim = Parameters.InhibitorDim;
            OtherDimSize = InhibitorSize;
        else
            % Exclude this inhibitor from mean
            DimSize = InhibitorSize;
            OtherDim = Parameters.CueDim;
            OtherDimSize = CueSize;
        end

        % idx1 contains left-hand-side indexes
        idx1 = cell(1,dataNDims);
        % idx2 contains right-hand-side indexes
        idx2 = cell(1,dataNDims);
        for j=1:dataNDims
            if j==Parameters.SignalDim
                idx1{j} = jSignal; % Modify only this signal
                idx2{j} = jSignal;
            elseif j==Dim
                idx1{j} = DimValue; % Modify only this cue/inhibitor
                % Exclude this cue/inhibitor from mean
                idx2{j} = setdiff(1:DimSize, DimValue);
            else
                idx1{j} = 1:dataSize(j); % keep all values of other dimensions
                idx2{j} = 1:dataSize(j); % keep all values of other dimensions
            end
        end
        % Calculate mean and replace values
        if isempty(OtherDim)
            % No OtherDim, so LHS and RHS have the same size
            meanData = nanmean(OldData(idx2{:}), Dim);
            NewData(idx1{:}) = meanData;
        else
            % Must assign each value of OtherDim separately
            meanData = nanmean(nanmean(OldData(idx2{:}), Dim), OtherDim);
            for j=1:OtherDimSize
                idx1{OtherDim} = j;
                NewData(idx1{:}) = meanData;
            end
        end
            
        if Dim == Parameters.CueDim
            disp(['Replaced data for signal ' signalName ' & cue ' cueName ' with '  num2str(Parameters.Replacement) '.']);
        elseif Dim==Parameters.InhibitorDim
            disp(['Replaced data for signal ' signalName ' & inhibitor ' inhibitorName ' with '  num2str(Parameters.Replacement) '.']);
        else
            error('Unexpected value for Dim (%f)', Dim);
        end
    end

if isnumeric(Parameters.Replacement) && isscalar(Parameters.Replacement)
    replaceData = @replaceDataWithNonPerturbed;
elseif strcmp(Parameters.Replacement, 'mean')
    replaceData = @replaceDataWithMean;
elseif strcmp(Parameters.Replacement, 'meanAll')
    replaceData = @replaceDataWithMeanAll;
else
    disp('Improper Parameters.Replace value given. No replacing will be performed.');
    return
end

for iSignal=1:signalSize
    if signalSize == 1
        signalName = Labels(Parameters.SignalDim).Value;
    else
        signalName = Labels(Parameters.SignalDim).Value{iSignal};
    end
    
    % Compare signals to cues
    for iCue=1:cueSize
        if cueSize == 1
            cueName = Labels(Parameters.CueDim).Value;
        else
            cueName = Labels(Parameters.CueDim).Value{iCue};
        end
        if strcmpi(signalName, cueName)
            % Signal matches cue
            replaceData(iSignal, Parameters.CueDim, iCue);
        end
    end
    
    % Compare signals to inhibitors
    for iInhibitor=1:inhibitorSize
        if isnumeric(Labels(Parameters.InhibitorDim).Value)
            inhibitorName = Labels(Parameters.InhibitorDim).Name;
        elseif inhibitorSize == 1
            if iscell(Labels(Parameters.InhibitorDim).Value)
                inhibitorName = Labels(Parameters.InhibitorDim).Value{1};
            elseif ischar(Labels(Parameters.InhibitorDim).Value)
                inhibitorName = Labels(Parameters.InhibitorDim).Value;
            end
        else
            inhibitorName = Labels(Parameters.InhibitorDim).Value{iInhibitor};
        end
        % Validate inhibitor name: PROTEIN + "i" + optional "-Free text"
        % First, remove any free text
        iFind = strfind(inhibitorName, '-');
        if ~isempty(iFind)
            try
            inhibitorName = inhibitorName(1:iFind(1)-1);
            end
        end
        % Inhibitor must end in "i", unless it's a special inhibitor name
        if any(strcmpi(inhibitorName, Parameters.SpecialInhibitors))
            % Skip this special inhibitor
            continue
        end
        if ~isempty(inhibitorName)&&~strcmpi(inhibitorName(end),'i')&&length(inhibitorName)>1
                if ~strcmpi(inhibitorName(1:2),'NO')
                    display(['improper syntax for the inhibitor ' inhibitorName '. No matching will be performed'])
                    continue
                end               
        end
        % Compare signal and inhibited-for the case of one inhibitor no comma
        if  isempty(strfind(inhibitorName,','))&&strcmpi(signalName, inhibitorName(1:end-1))
            % Signal matches inhibitor
            replaceData(iSignal, Parameters.InhibitorDim, iInhibitor);
        elseif numel(strfind(inhibitorName,','))==1
            inhibitor{1}=inhibitorName(1:strfind(inhibitorName,',')-2);
            inhibitor{2}=inhibitorName(strfind(inhibitorName,',')+1:end-1);
            if  strcmpi(signalName, inhibitor{1})|| strcmpi(signalName, inhibitor{2})
                replaceData(iSignal, Parameters.InhibitorDim, iInhibitor);
            end
        elseif numel(strfind(inhibitorName,','))==2
             PosComas=strfind(inhibitorName,',');
            inhibitor{1}=inhibitorName(1:PosComas(1)-2);
            inhibitor{2}=inhibitorName(PosComas(1)+1:PosComas(2)-2);
            inhibitor{3}=inhibitorName(PosComas(2)+1:end-1);
            if  strcmpi(signalName, inhibitor{1})|| strcmpi(signalName, inhibitor{2}) || strcmpi(signalName, inhibitor{3})
                replaceData(iSignal, Parameters.InhibitorDim, iInhibitor);
            end
           
        end
    end    
end

end % function
