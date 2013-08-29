function parameters = GuiCenterAndScale(Labels, notifier)
% GuiCenterAndScale gets list of dimensions for centering and scaling
%
% parameters = GuiCenterAndScale(Labels, notifier)
%
%--------------------------------------------------------------------------
% INPUTS:
% Labels    = structure of dimension labels
% notifier  = optional GuiNotifier
%
% OUTPUTS:
% parameters.center = vector of centering parameters (see centerAndScale)
% parameters.scale  = vector of scaling parameters (see centerAndScale)
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%--------------------------------------------------------------------------
% TODO:
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

% Number of dimensions
n = numel(Labels);
parameters = struct('center', zeros(1,n), 'scale', zeros(1,n), 'iterations', 1);
dimensionNames = {Labels.Name};
[centerDims, ok] = chooseDims(dimensionNames, ...
    ['Select the dimensions to center ACROSS to zero mean.' ...
    'Note: The recommended approach is to center ACROSS the 1st dimension only.'], 1);
if ok
    parameters.center(centerDims) = 1;
end
scaleDims = chooseDims(dimensionNames, ...
    ['Select the dimensions to scale WITHIN to unit variance.' ...
    'Note: The recommended approach is to scale WITHIN the 2nd dimension or later.'], min(2,n));
if ok
    parameters.scale(scaleDims) = 1;
end
if exist('notifier', 'var') && ~isempty(notifier)
    notifier(parameters);
end
end % function GuiCenterAndScale

function [selection, ok] = chooseDims(dimensionNames, title, initialValue)
[selection, ok] = listdlg('ListString', dimensionNames, ...
    'PromptString', title, ...
    'InitialValue', initialValue, ...
    'Name', 'Select scaling',...
    'ListSize', [200 150]);
end % function chooseDims