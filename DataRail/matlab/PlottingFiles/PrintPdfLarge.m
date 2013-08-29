function PrintPdfLarge(name)
% PrintEpsLarge creates an eps out of a matlab figure in large size
%
%
%
%
%--------------------------------------------------------------------------
% INPUTS
%
% name = name of the file to save the figure  
%
%  OUTPUTS
%
%  None
%
%
%--------------------------------------------------------------------------
% EXAMPLE:
% PrintEpsLarge('CoolPlot')
%
%--------------------------------------------------------------------------
% TODO:
%
% -
%

%--------------------------------------------------------------------------
% Copyright 2007 President and Fellow of Harvard College
%
%  sbpipeline@hms.harvard.edu 

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


set(gcf, 'PaperPosition', [.1 1 14 10]);   %defines size of exported plot
set(gcf,'Position',[0  0   1200  1200])
eval(['print -dpdf ' name '.pdf'])