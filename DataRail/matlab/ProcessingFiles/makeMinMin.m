function [newData, addData] = makeMinMin(oldData, OldParameters)
% makeMinMin adds a constant to data so that the min is at least a minimum value
%
% [newData, addData] = makeRelativeToMax(oldData, Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
% oldData   = hypercube of data values
% Parameters = optional structure of parameters
%             .NewMin(1) = the new minimum min
%             .Modes(1) = modes across which the min should be take
%             .NotModes([]) = modes across which the min should NOT be taken
%                NOTE: Either Modes or NotModes should be specified, but
%                not both!
%
% OUTPUTS:
% newData   = re-scaled hypercube of data
% addData   = hypercube of values used to scale each data point
%
%--------------------------------------------------------------------------
% EXAMPLE:
% [newData, addData] = makeMinMin(oldData, struct('NewMin', 0, 'Modes', [2 3]));
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

DefaultParameters = struct('NewMin', 1, 'Modes', 1, 'NotModes', []);
Parameters = setParameters(DefaultParameters, OldParameters);

sz = size(oldData);
if ~isempty(Parameters.NotModes)
    assert2(isempty(Parameters.Modes) || ...
        all(Parameters.Modes == DefaultParameters.Modes), ...
        'Please specify either Modes or NotModes, but not both!');
    Modes = setdiff(1:ndims(oldData), Parameters.NotModes);
else
    Modes = Parameters.Modes;
end

minData = oldData;
repeat = ones(size(sz)); % To use with repmat
for mode=Modes
    % Find max across this mode
    minData = nanmin(minData, mode);
    % And we'll need to repeat across this mode
    repeat(mode) = sz(mode);
end
% Now, determine addData
addData = zeros(size(minData));
test = minData < Parameters.NewMin;
addData(test) = -minData(test) + Parameters.NewMin;
addData = repmat(addData, repeat);
newData = oldData + addData;