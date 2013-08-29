function generateHelpFiles
% generateHelpFiles creates helpfiles for functions in the toolbox
%
% generateHelpFiles
%
%--------------------------------------------------------------------------
% INPUTS:
% None
%
% OUTPUTS:
% None
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%--------------------------------------------------------------------------
% TODO:
% Check anchor names for unacceptable characters
% Make sure anchor names are unique
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

%% Set options
oldPref = getpref('dirtools');
newPref = struct(...
    'h1DisplayMode', 1,...
    'helpDisplayMode', 1,...
    'copyrightDisplayMode', 0,...
    'helpSubfunsDisplayMode', 0,...
    'exampleDisplayMode', 0,...
    'seeAlsoDisplayMode', 0);

setpref_with_struct('dirtools', newPref);
try
    subdirs = startDataRail;
    filename = fullfile(subdirs{1},'help', 'Help.html');
    [fid, msg] = fopen(filename, 'w');
    for i=2:numel(subdirs)
        thisDir = subdirs{i};
        htmlCell = helprpt(thisDir, 'dir');
        % Add anchors
        for j=1:numel(htmlCell)
            htmlCell{j} = regexprep(htmlCell{j}, ...
                '<td valign="top" class="td-linetop"><a href="matlab: edit\(urldecode\(''(.*?)''\)\)"><span class="mono">(.*?)</span></a></td>', ...
                '<td valign="top" class="td-linetop"><a href="matlab: edit\(urldecode\(''$1''\)\)" name="$2"><span class="mono">$2</span></a></td>'...
                );
        end
%         filename = fullfile(thisDir, 'Help.html');
%         [fid, msg] = fopen(filename, 'w');
        if fid == -1
            error('Unable to create file %s. Message: %s', filename, msg);
        end
        fprintf(fid, '%s\n', htmlCell{:});
%         fclose(fid);
    end
catch
    fclose(fid);
end
setpref_with_struct('dirtools', oldPref);

function setpref_with_struct(group, pref_struct)
setpref(group, fieldnames(pref_struct), struct2cell(pref_struct));