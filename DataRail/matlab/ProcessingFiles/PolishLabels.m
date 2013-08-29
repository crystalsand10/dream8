function NewLabels=PolishLabels(Labels)
% PolishLabels removes the MIDAS tags (TR, DA, DV) and other strings
%  
% In particular, it removes
% - the =1 text created by the MidasImporter
% - parenthized expressions (e.g. BioPlex bead numbers)  
% - replaces "_" with "-" for nicer labeling in matlab plots
% - removes leading and TRAILing whitespaces
%  
%  NewLabels=PolishLabels(Labels)
%
%
%--------------------------------------------------------------------------
% INPUTS:
%
% Labels = Structure with Labels
%
%
% OUTPUTS:
%
% NewLabels = Structure with  nicer labels
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Labels=PolishLabels(Labels);
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
%    SBPipeline.harvard.edu%
NewLabels=Labels;
for dim=1:numel(Labels)
    if iscell(Labels(dim).Value)
        relevantConcentrationsFound = false;
        for lab=1:numel(Labels(dim).Value)
            newLabel = Labels(dim).Value{lab};
            
            % Remove leading tags
            try
                % TR: can occur multiple times
                newLabel = regexprep(newLabel, '\<TR:', '');
                if any( strcmp(newLabel(1:3), {'DA:', 'DV:'}) )
                    newLabel = newLabel(4:end);
                end
            end

            % Look for "=##.##"
            if ~relevantConcentrationsFound
                numbers = regexp(newLabel, '(?<==)[0-9.][0-9.eE+-]*', 'match');
                for i=1:numel(numbers)
                    if isempty(strmatch(numbers{i}, '1'))
                        relevantConcentrationsFound = true;
                        break
                    end
                end
            end
            
            % Remove parenthized expressions (e.g. BioPlex bead numbers)
            %   Use a while look to remove nested parenthesis
            %   "\(" matches the left parenthesis
            %   "[^()]*" matches zero or more non-parenthesis characters
            %   "\)" matches the right parenthesis
            while regexp(newLabel,'\([^()]*\)');
                newLabel = regexprep(newLabel, '\([^()]*\)', '');
            end
            
            % Replace "_" with "-"
            newLabel = regexprep(newLabel,'_','-');
            
            % Remove leading and TRAILing whitespace
            newLabel = regexprep(newLabel, '^\s+', '');
            newLabel = regexprep(newLabel, '\s+$', '');

            % Remove "Hu "
            newLabel = regexprep(newLabel, '\<Hu ', '');

            % Finally, save newLabel
            NewLabels(dim).Value{lab} = newLabel;
        end
        if ~relevantConcentrationsFound
            % Remove =1's
            for lab=1:numel(Labels(dim).Value)
                newLabel = NewLabels(dim).Value{lab};
                newLabel = regexprep(newLabel, '=1\>', '');
                % Finally, save newLabel
                NewLabels(dim).Value{lab} = newLabel;
            end
        end
    end
end


            % Remove "=1" from anywhere in the label (but not "=12", etc.)
            
