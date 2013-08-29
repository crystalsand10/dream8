function result = parseLine(line)
% parseLine parses a line from a test file
%
% result = parseLine(line)
%
%--------------------------------------------------------------------------
% INPUTS:
% line      = a line (string) of text
%
% OUTPUTS:
% result    = a cell of string results
%
%--------------------------------------------------------------------------
% EXAMPLE:
% results = parseLine('"Treatment 1",1,2,3');
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


% Remove newline-line charactes from end of line
NEWLINES = sprintf('\f\n\r');
while any( line(end) == NEWLINES )
    line(end) = [];
end
% Split line on commas
resultCell = textscan(line, '%q', 'Delimiter', ',\t');
assert2(numel(resultCell)==1, ...
    'Unexpected line format. Multiples lines found in one line?');
result = resultCell{1};
% Make sure result is a column vector
result = reshape(result,1,numel(result));
end % function parseLine