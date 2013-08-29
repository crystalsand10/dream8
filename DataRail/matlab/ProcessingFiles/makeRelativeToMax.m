function [newData, maxData] = makeRelativeToMax(oldData, OldParameters)
% makeRelativeToMax divides data by maximum across specified dimensions
%
% [newData, maxData] = makeRelativeToMax(oldData, Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
% oldData   = hypercube of data values
% Parameters = optional structure of parameters
%             .Modes(1) = modes across which the max should be take
%             .NotModes([]) = modes across which the max should NOT be taken
%                NOTE: Either Modes or NotModes should be specified, but
%                not both!
%
% OUTPUTS:
% newData   = re-scaled hypercube of data
% maxData   = hypercube of maximum values used to scale each data point
%
%--------------------------------------------------------------------------
% EXAMPLE:
% [newData, maxData] = makeRelativeToMax(oldData, struct('Modes', [2 3]));
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

DefaultParameters = struct('Modes', 1, 'NotModes', []);
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

maxData = oldData;
repeat = ones(size(sz)); % To use with repmat
for mode=Modes
    % Find max across this mode
    maxData = nanmax(maxData, mode);
    % And we'll need to repeat across this mode
    repeat(mode) = sz(mode);
end
maxData = repmat(maxData, repeat);
newData = oldData ./ maxData;