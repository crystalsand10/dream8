function PlotSignals(PlotData,Parameters)
% PlotSignals plots a data cube in a set of subplots data
%
%   PlotSignalsCompact(PlotData,Parameters)
%
%  If BoolData is provided, the plots aare filled as follows
%
%   green  = sustained
%   yellow = transient
%   magenta= late
%   grey   = no significant signal
%
%  the intensity of the fill is relative to the strength of signal
%   (relative to others for the same measurement), as provided by
%  RelatData
%
%
%--------------------------------------------------------------------------
% INPUTS
%  PlotData        =      data to plot
% Optional Parameters (default value in parenthesis)
%     .Labels          =      labels to  use for labeling the plots
%     .BoolData(zeros) =      discretize data to define colors for plotting
%     .RelatData(ones) =      relative data to define intensity of color
%     .TimeScale(1)       = 1 real, [0 1 2] else
%     .MinYMax(25)        = Minimal value for the y axis to plot
%     .ShowRed(1)         =clolours red if signals goes down
%     .Redder(0.5);       = Threshold to plot in rot
%     .CouplePlots(1;     =All plots for a particular readout are scaled together
%     .OrderMeasu([1:size(PlotData,5)]) =to change the order of the dim 5 (tipically readout) in the plot
%     .ColorModus('max'); =colouring modus:
%                          'max'    intensity related to maximal value of signal
%                                   color defined by discretized data
%                                   (green sustained [0 1 1], yellow transient [0 1 0],
%                                   magenta late [0 0 1], grey no signal [0 0 0])
%                          'change' related to change
%                                   color defined by discretized data
%                                   (green sustained [0 1 1], yellow transient [0 1 0],
%                                    magenta late [0 0 1], grey no signal [0 0 0])
%                          'refmax' related to reference treatment(compare max values),
%                                   bigger than reference green, lower magenta
%                          'refAUC'   related to reference treatment (compare AUCs),
%                                    bigger than reference green,  lower magenta
%                          'cytok'  Colors blue whenever it goes up
%     .Dims2Exp([3 4 5]   =defines the 3 dimensions of the data cube to loop through
%     .DimFixed([1 1]     =defines dimension not looped through and chooses a value
%     .PlotPairsOfDrugs(1 =if you plot drugs pairwise the plots will be distributed accordingly and
%                          the background will be different for each element of the pair of drugs
%     .Reference=[1 NaN NaN NaN NaN] = if there is a notNaN, the
%                          corresponding conditions are used to plot a reference signal in black
%                          e.g. in this case always plot the same data for the second cell line;
%                          can also be e.g. [ 1 NaN 1 1 NaN] then it plots
%                          the 1st cell, the 1st treatment and the 1st inhibitor
%     .Background('n')    = if there is a reference plot, the background is coloured
%                          bluish if the (average of the ) data of interest is higher
%                          and redish if the reference is higher
%     .BackgDeactiv('noise') =condition used to define whether to plot background or not;
%                           'noise'  :if signal is below exerimental error (MinYMax) it will not be pllote
%                           'boolean':if Boolean is [ 0 0 0] it will not be plotted
%     .HeatMap('no')      =if yes, plots a heatmap in each subplot, either
%                          of the mean or a gradient through the time (see .PlotMean)
%     .PlotMean('no')     = if ploting heat map, defines whether to plot the mean or the time course
%     .PlotLumped('no')   = instead of each plot in one subfigures, it compresses all plots
%                           for different values of dim2 into a single plot
%     .ErrorbarData([])   = data for errorbar plots
%
%  OUTPUTS
%
%  None
%
%
%--------------------------------------------------------------------------
% EXAMPLE:
% figure;PlotSignals(Compendium.CubeNormBSA,Parameters)
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

%% Default parameters
% Check required parameters
if ~isfield(Parameters, 'Labels');
    error('The required Parameter Labels was not specified.');
end
DefaultParameters = struct('Labels',[], 'BoolData', [], 'RelatData', [],...
    'TimeScale', 1, 'MinYMax', 25, 'ShowRed', 1, 'Redder', 0.5', ...
    'CouplePlots', 1, 'OrderMeasu', [1:size(PlotData,5)], 'ColorModus', 'max', ...
    'Dims2Exp', [3 4 5],'DimFixed', [1 1]', ...
    'PlotPairsOfDrugs', 0, 'Reference', [nan(1, 5)], ...
    'Background', 'n', 'BackgDeactiv', 'noise', ...
    'HeatMap', 'n', 'PlotMean', 'no', 'PlotLumped', 'no', 'Plot2D','no', ...
    'ErrorbarData', []);
Parameters = setParameters(DefaultParameters, Parameters);

Labels = Parameters.Labels;
BoolData = Parameters.BoolData;
RelatData = Parameters.RelatData;

Parameters = rmfield(Parameters, {'Labels', 'BoolData', 'RelatData'});

%% Check for 'replicates' dimension, and calculate errorbar data
if isempty(Parameters.ErrorbarData)
    iReplicate = strmatch('replicates', lower({Labels.Name}), 'exact');
    if ~isempty(iReplicate)
        Parameters.ErrorbarData = nanstd(PlotData, iReplicate);
        PlotData   = nanmean(PlotData, iReplicate);
        if ~isempty(RelatData)
            RelatData = nanmean(RelatData, iReplicate);        
        end
        if ~isempty(BoolData)
            BoolData = nanmean(BoolData, iReplicate);
        end
        % % Delete replicate label?
        % Labels(iReplicate) = [];
    end
end
%% Do plotting
% these values correspond to the 4-HCCs+PriHu 16x experiments
%Parameters.OrderMeasu=[14 1 15 2 8 11 7 6 13 4 5 10 16 3 12 9];

% seems BoolData is not reordered; we do it here as for now
%BoolData=BoolData(:,:,:,:,Parameters.OrderMeasu);                         
%PlotDifferences(Labels,PlotData,BoolData,RelatData,Parameters);
PlotAllSignalsCompact(Labels,PlotData,BoolData,RelatData,Parameters);
