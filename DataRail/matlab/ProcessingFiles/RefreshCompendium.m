function Compendium=RefreshCompendium(Compendium,Parameters)
% RefreshCompendium(Compendium) reruns the creation of all cubes
%
% Compendium=RefreshCompendium(Compendium,Parameters)
%
%--------------------------------------------------------------------------
% INPUTS: 
% Compendium =a SBPipeline Compendium
%
% Parameters(optional)
%    .useStoredFunctions(false) = true to choose the function stored in the
%                                CodeHashArray, false to use the current version
%    
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  Comp2 = RefreshCompendium(Comp,[])
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
%    SBPipeline.harvard.edu
DefaultParameters = struct(...
    'useStoredFunctions',false);

Parameters=setParameters(DefaultParameters, Parameters);

if Parameters.useStoredFunctions
    CodeField = 'CodeHashArray';
else
    CodeField = 'Code';
end

Compendium.data(1)= createDataCube(...
    'Name',      Compendium.data(1).Name, ...
    'Value',     Compendium.data(1).Value,...
    'Labels',    Compendium.data(1).Labels,...
    'Info',       Compendium.data(1).Info , ...
    CodeField,      Compendium.data(1).(CodeField), ...
    'Parameters', Compendium.data(1).Parameters, ...
    'SourceData', Compendium.data(1).SourceData);

for i=2:numel(Compendium.data)
    display(['Refreshing cube ' Compendium.data(i).Name]);
    or = strmatch(Compendium.data(i).SourceData, {Compendium.data.Name}, 'exact');
    if numel(or) == 0
        warning('Unable to find the SourceData named "%s" for cube "%s"', ...
            Compendium.data(i).SourceData, ...
            Compendium.data(i).Name);
    elseif numel(or) > 1
        warning('Found multiple SourceData named "%s" for cube "%s"', ...
            Compendium.data(i).SourceData, ...
            Compendium.data(i).Name);
    elseif or >= i
        error('DataRail:InvalidCompendium', ...
            'Unable to refresh cube %s because it depends on a cube that occurs later in the Compendium.', ...
            Compendium.data(i).Name);
    else
        Compendium.data(i)= createDataCube(...
            'Name',      Compendium.data(i).Name, ...
            'Info',       Compendium.data(i).Info , ...
            CodeField,       Compendium.data(i).(CodeField),...
            'Parameters', Compendium.data(i).Parameters, ...
            'SourceData', Compendium.data(or));
    end
end
