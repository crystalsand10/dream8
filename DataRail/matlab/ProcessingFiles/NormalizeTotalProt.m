function [NewCube NewLabels] = NormalizeTotalProt(Cube,Parameters)
% Normalizetotalprot normalized data with respect to the total amount of protein
%
% NewCube = NormalizeTotalProt(filename,Parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS (Syntax 1):
% DataCube  = 
% Parameters =
%              .filename= name of CSV file (MIDAS) with the normalization data
%              .ImporterParameters = parameters to load MIDAS file
%              .Labels =labels of old cube
%              .PasstoData = whether to copy the data for t0. If not
%               defined, it will be true if there are NaNs in the data
%
% OUTPUTS:
% NewCube  = normalized data cube
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%--------------------------------------------------------------------------
% TODO:
%
% -     double check and fix this function! not functional now, not called from DataRail
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



    
iSignal=5;

ImporterParameters=Parameters.ImporterParameters;
% Import all signals in new file
fields = parseHeader(Parameters.filename);
ImporterParameters.timeCols = cellfun(@(x)(['DA:' x]), fields.DA.Value, ...
    'UniformOutput', false);
ImporterParameters.valueCols = cellfun(@(x)(['DV:' x]), fields.DV.Value, ...
    'UniformOutput', false);
% Import new raw data
newData = MidasImporter(Parameters.filename, ImporterParameters);
newData=CanonicalForm(newData);
try Parameters.Passt0Data;
catch%If there are nans it is probably due to t0 replication
    if ~isempty(find(isnan(newData.Value)))
        Parameters.Passt0Data=true  ;
    end
end


if Parameters.Passt0Data==true  
 t0data = newData.Value(:,1,1,:,:);
    % Fill in t=0 data for other treatments
    for dim3=1:size(newData.Value,3)
        newData.Value(:,1,dim3,:,:)=t0data;
    end  
end

newData.Labels = PolishLabels(newData.Labels);
newData = CanonicalForm(newData);

%% Cat cubes along signal dimension
TempCube = cat(iSignal,Cube, newData.Value);

ParamRel.RefDim=5;
ParamRel.RefValue=size(TempCube,5);
TempCube=GetRelative(TempCube,ParamRel);
NewCube=TempCube(:,:,:,:,[1:(size(TempCube,5)-1)]);

NewLabels=Parameters.Labels;