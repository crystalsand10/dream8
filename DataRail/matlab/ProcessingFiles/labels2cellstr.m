function newLabels = labels2cellstr(oldLabels)
% labels2cellstr converts all values in a labels structure to cellstr
%
% newLabels = labels2cellstr(oldLabels)
%
%--------------------------------------------------------------------------
% INPUTS:
% oldLabels = a structure containing a Value field
%
% OUTPUTS:
% newLabels = a structure with Value fields converted to cellstr type
%
% Note: warnings are issued if values cannot be converted.
% Currently, only character and numeric values are converted to cellstr.
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Labels(1).Value = [1,2,3]
% Labels(2).Value = 'abc'
% newLabels = labels2cellstr(Labels);
%
%--------------------------------------------------------------------------
% TODO:
%
% - Check the consistency of DA: and DV: fields
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


% Check that oldLables is really a labels structure
if ~isstruct(oldLabels) || ~isfield(oldLabels, 'Value')
    error('Input argument does not appear to be a valid labels structure');
end
newLabels = oldLabels;
for i=1:numel(newLabels)
    value = newLabels(i).Value;
    if iscell(value)
        if ~iscellstr(value)
            warning('Cannot convert cell label at index %d', i);
        end
    elseif ischar(value)
        newLabels(i).Value = cellstr(value);
    elseif isnumeric(value)
        n = numel(value);
        newLabels(i).Value = cell(n,1);
        for j=1:n
            if isreal(value(j))
                newLabels(i).Value{j} = sprintf('%g',value(j));
            else
                newLabels(i).Value{j} = num2str(value(j));
            end
        end
    else
        warning('Labels of class %s at index %d cannot be converted to cell strings.', ...
            class(value), i);
    end
end