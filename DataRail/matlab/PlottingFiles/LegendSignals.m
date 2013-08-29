% LegendSignals is a small script to create the Legend for the Signals (phosphos)
%
%
%--------------------------------------------------------------------------
% INPUTS
% 
%  None
%
% OUTPUTS
%
%  None
%
%
%--------------------------------------------------------------------------
% EXAMPLE:
% LegendSignals;
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


%Legend for PlotAllSignalsCompact
figure('Name','Legend','Toolbar','None','NumberTitle','off');
set(gcf,'DefaultLineLineWidth',4,'DefaultAxesLineWidth',3,'DefaultAxesFontSize',12)%,'DefaultAxesFontWeight','bold');
subplot(1,4,1),fill([0 1 2 2],[0 1 1 0], [0 1 0],'LineWidth',3)
title('sustained','FontSize',24)
set(gca,'YTickLabel',{})
set(gca,'YTick',[])
set(gca,'XTickLabel',{})
subplot(1,4,2),fill([0 1 2 2],[0 1 0 0], [1 1 0],'LineWidth',3)
title('transient','FontSize',24)
set(gca,'YTickLabel',{})
set(gca,'XTickLabel',{})
set(gca,'YTick',[])
subplot(1,4,3),fill([0 1 2 2],[0 0 1 0], [1 0 1],'LineWidth',3)
title('late','FontSize',24)
set(gca,'YTickLabel',{})
set(gca,'XTickLabel',{})
set(gca,'YTick',[])
subplot(1,4,4),fill([0 0 1 2 2],[0 0.1 0.2 0.1 0], [.8 .8 .8],'LineWidth',3)
ylim([0 1])
title('no response','FontSize',24)
set(gca,'YTickLabel',{})
set(gca,'XTickLabel',{})
set(gca,'YTick',[])
set(gcf, 'PaperPositionMode', 'manual');    set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [.1 1 10 2]);   %defines size of exported plot
set(gcf,'Position',[1000  0   500  100])








