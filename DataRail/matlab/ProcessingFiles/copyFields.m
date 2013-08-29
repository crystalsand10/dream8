function newStruct = copyFields(oldStruct, fields, missingValue)
% copyFields copies the specified fields from a struct (optional missing field value)
%
% newStruct = copyFields(oldStruct, fields, [missingValue])
%
%--------------------------------------------------------------------------
% INPUTS:
% oldStruct = structure to copy fields from
% fields    = cell array of field names to copy
% missingValue = optional value for missing fields. Defaults to [].
%
% OUTPUTS:
% newStruct = new structure
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% projectFields = fieldnames(project);
% project(end+1) = copyFields(otherProject, projectFields);
%
%
%--------------------------------------------------------------------------
% TODO:
%
% - Add optional warnings for missing and extra fields
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

%% Default missingValue
if ~exist('missingValue', 'var')
    missingValue = [];
end

newStruct = struct;
for i=1:numel(fields)
    f = fields{i};
    if isfield(oldStruct, f)
        newStruct.(f) = oldStruct.(f);
    else
        newStruct.(f) = missingValue;
    end
end