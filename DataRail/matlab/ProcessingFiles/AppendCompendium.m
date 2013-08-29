function [Compendium, Parameters] = AppendCompendium(filename,Parameters)
% AppendCompendium
%
% Compendium = AppendCompendium(filename, parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS (Syntax 1):
% filename  = name of CSV file (MIDAS)
% parameters =
%              .Compendium  = compendium in canonical form
%              .Passt0Data(false) = whether to pass t=0 data
%
% OUTPUTS:
% Compendium = new compendium
%
%--------------------------------------------------------------------------
% EXAMPLE:
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

try
    Parameters.Passt0Data;
catch
    Parameters.Passt0Data=false;
end

% Identify with canonical dimension corresponds to signals
iSignal = 5;
% Get old importer parameters
CompOld = Parameters.Compendium;
oldData = CompOld.data(1);
ImporterParameters = oldData.Parameters;
if numel(ImporterParameters) > 1
    warning(['Multiple importer parameters were found in the original Compendium.\n'...
        'The appended data will be imported using the FIRST set of parameters.']);
    ImporterParameters = ImporterParameters(1);
end
% Import all signals in new file
fields = parseHeader(filename);
ImporterParameters.timeCols = cellfun(@(x)(['DA:' x]), fields.DA.Value, ...
    'UniformOutput', false);
ImporterParameters.valueCols = cellfun(@(x)(['DV:' x]), fields.DV.Value, ...
    'UniformOutput', false);
% Import new raw data
newData = MidasImporter(filename, ImporterParameters);
newData.Labels = PolishLabels(newData.Labels);
newData = CanonicalForm(newData);
% Check labels in both cubes
oldLabels  = oldData.Labels;
newLabels  =  newData.Labels;
if numel(oldLabels)~=numel(newLabels)
    error(['New data has ' num2str(numel(newLabels)) ' dimensions and the old ' num2str(numel(oldLabels))])
end

for i=1:(numel(oldLabels)-1)
    if  isnumeric(oldLabels(i).Value)
        if any(oldLabels(i).Value~=newLabels(i).Value)
            error(['Dimensions of new data do not match those of previous compendium at dimension ' num2str(i) '='  newLabels(i).Name]);
        end
    elseif ~all(strcmp(oldLabels(i).Value,newLabels(i).Value))
        error(['Dimensions of new data do not match those of previous compendium at dimension ' num2str(i) ' = ' newLabels(i).Name]);
    end
end
%% Cat cubes along signal dimension
CompNew = CompOld;
oldSignals = oldData.Labels(iSignal).Value;
newSignals = newData.Labels(iSignal).Value;
% Gracefully handle one-signal labels, which are characters
if ischar(oldSignals)
    oldSignals = {oldSignals};
elseif ~iscell(oldSignals)
    error('The signal dimension (%d) must contain character labels', iSignal);
end
if ischar(newSignals)
    newSignals = {newSignals};
elseif ~iscell(newSignals)
    error('The signal dimension (%d) must contain character labels', iSignal);
end
allSignals = [oldSignals; newSignals];
CompNew.data(1).Labels(iSignal).Value = allSignals;
CompNew.data(1).Value = cat(iSignal, oldData.Value, newData.Value);
if ischar(oldData.SourceData)
    CompNew.data(1).SourceData = {oldData.SourceData; newData.SourceData};
elseif iscell(oldData.SourceData)
    CompNew.data(1).SourceData = [oldData.SourceData; {newData.SourceData}];
else
    warning('The source data for the original Compendium is invalid.');
end
CompNew.data(1).Parameters = [oldData.Parameters; newData.Parameters];

if Parameters.Passt0Data
    t0data = CompNew.data(1).Value(:,1,1,:,:);
    % Fill in t=0 data for other treatments
    for dim3=1:size(CompNew.data(1).Value,3)
        CompNew.data(1).Value(:,1,dim3,:,:)=t0data;
    end
    if ~isempty(find(isnan(CompNew.data(1).Value(:,:,1,:,:)), 1))
        Removet0dim=questdlg('The first value in the first dimension seems to have only the t=0 data; would you like to remove it (recommended)?', 'Remove value?', 'Yes','No', 'Yes')
        if strcmp(Removet0dim,'Yes')
            CompNew.data(1).Value=...
                CompNew.data(1).Value(:,:,2:size(CompNew.data(1).Value,3),:,:);
            CompNew.data(1).Labels(3).Value={CompNew.data(1).Labels(3).Value{2:end}}';
        end

    end
end

% refresh
Compendium=RefreshCompendium(CompNew,[]);
