function list = splitString(string, token)
% splitString splits a string between tokens
%
% list = splitString(string, token)
%
%--------------------------------------------------------------------------
% INPUTS:
% string    = character string
% token     = token string (but NOT a regular expression)
%
% OUTPUTS:
% list      = cell string
%
%--------------------------------------------------------------------------
% EXAMPLE:
% list = splitString('a, b, c', ', ');
% (list should be {'a', 'b', 'c'})
%
%--------------------------------------------------------------------------
% TODO:
%
% - add support for regular expressions (or just use regexp in R2007b)
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

if ~ischar(string) || ~ischar(token)
    error('Inputs must be strings.');e
end
% indexes for beginning of tokens, or end+1 of last phrase
iEnd = [strfind(string, token) numel(string)+1];
numWords = numel(iEnd);
list = cell(1, numWords);
tokenLength = numel(token);
iStart = 1;
for i=1:numWords
    list{i} = string(iStart:iEnd(i)-1);
    iStart = iEnd(i) + tokenLength;
end