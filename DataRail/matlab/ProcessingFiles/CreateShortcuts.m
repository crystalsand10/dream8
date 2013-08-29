function v=CreateShortcuts(Labels)
% CreateShortcuts creates an structure of shortcuts to access the elements in the cubes,
%
% These shortcuts allow you to easily find particular positions in a certain dimension, e.g.
%   LeoData.data(1).Value(v.Prim,1,v.EGF,v.PI3Ki,v.ERK12)
%
% function v=CreateShortcuts(Labels)
%
%  
%--------------------------------------------------------------------------
% INPUTS:
%
% Labels = Structure with labels in the usual form
%
% OUTPUTS:
%
% v     = strcuture with the shortcuts
%
%--------------------------------------------------------------------------
% EXAMPLE:
%    LeoData.v=CreateShortcuts(Leodata.data(1).Labels)
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

%% to access the elements via the labels with v.label
    for la=[1 3 4 5]
        for valu=1:numel(Labels(la).Value)
            Labels(la).Value{valu}=regexprep(Labels(la).Value{valu}, '-', '');
            Labels(la).Value{valu}=regexprep(Labels(la).Value{valu}, ' ', '');
    
            try
                eval(['v.' Labels(la).Value{valu} ';']);
                eval(['v.' Labels(la).Value{valu} '.dimunkn'  '=' 'v.' Labels(la).Value{valu} ';']);
                eval(['v.' Labels(la).Value{valu} '.dim' num2str(la) '=' num2str(valu) ';']);
            catch 
                ['v.' Labels(la).Value{valu} '=' num2str(valu) '']
                eval(['v.' Labels(la).Value{valu} '=' num2str(valu) ';']);
            end
        end
    end