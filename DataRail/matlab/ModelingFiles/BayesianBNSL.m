function [ep epfiltered] = BayesianBNSL(OldData,para)
% BayesianBNSL infers a network from a DataArrail data set
%
%   [BayesNet BayesNetFiltered] = BayesianBNSL(DataCube,parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS
%  Labels          =      labels to  use for labeling the plots
%  PlotData        =      data to plot
%
%
%  OUTPUTS
%
%  BayesNet        =     matrix nSignalx x nSignals with all infered values
%  BayesNetFiltered=     matrix nSignalx x nSignals with  infered values
%                        above threshold
%
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% ep = BayesianBNSL(DataCube,parameters)  
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
%
%    Code contributed by Joel Wagner (jpw@mit.edu) and Nickel Dittrich
%


disp('                                                            ');
disp('   |--------------------------------------------------------|')
disp('   | For bayesian inference,                                |');
disp('   | DataRail uses functions and pieces of code of          |');
disp('   |       BNSL (Bayesian Network Structure Learning        |');
disp('   |       developed  by D. Eaton and K. Murphy, see        |');
disp('   |          http://www.cs.ubc.ca/~murphyk/                |');
disp('   |                                                        |');
disp('   |            Code for linking to DataRail contributed by |');
disp('   |   Joel Wagner (jpw@mit.edu) and Nickel Dittrich        |');
disp('   |--------------------------------------------------------|')
disp('                                                           ');


OrigArr = OldData.data(para.DC).Value;

max_parents = str2double(para.np); %4;    % user defined
% user defined ranges from 0-no(parent nodes)
edgeweight_threshold = str2double(para.pc);
% restructure Array if there is a 6th (replicate) dimension
if length(size(OldData)) == 6
    OrigArr = permute(OrigArr,[6 2 3 4 5 1]);
end

% reshape the 5D-Array to a 2D-Matrix
sizeVec = [size(OrigArr,1) size(OrigArr,2) size(OrigArr,3) size(OrigArr,4) size(OrigArr,5)];
rs2 = sizeVec(1) * sizeVec(2) * sizeVec(3) * sizeVec(4);
rs1 = sizeVec(5);
permuteArr = permute(OrigArr,[5 1 2 3 4]);
ReshpMat = reshape(permuteArr,rs1,rs2);


% take out NaN columns (temporary)
TmpMat = ReshpMat;
j=0;
OrigArr = zeros(1,size(ReshpMat,2));
for i=1:size(ReshpMat,2)
    if isnan(nansum(TmpMat(:,i)))
        ReshpMat(:,i-j) = '';
        OrigArr(i) = 1;
        j = j+1;
    end
end


discretized_data = ReshpMat; %ceil(3.*rand(10,30));

if min(min(discretized_data))==0 && max(max(discretized_data))==1
    disp(' ')
    disp(' Data is discretized to 0 and 1, converting to 1 and 2 as is standard for BNSL')
    discretized_data(discretized_data==1)=2;
    discretized_data(discretized_data==0)=1;
end

nNodes = size(ReshpMat,1);

node_labels = OldData.data(1,para.DC).Labels(5,1).Value';

% find where BNSL lives
CurrDir = pwd;
Paths=path;
BNSLStartInPath = strfind(Paths,'BNSL');
DoublePoints=strfind(Paths,':');
BegBNSLPath=DoublePoints(DoublePoints<BNSLStartInPath);
FullBNSLPath = Paths(BegBNSLPath(end)+1:BNSLStartInPath+3);
cd(FullBNSLPath);
warning off
mkPath;
warning on

node_arity = max(discretized_data, [], 2);
clamped = zeros(size(discretized_data));

maxFanIn = min(max_parents, nNodes-1); % if maxFanIn = nNodes - 1 that does not restrict the fan-in of any node
%disp('Calc aflp...')
% This uses the nchoosek form of prior
aflp = mkAllFamilyLogPrior( nNodes, 'maxFanIn', maxFanIn ); % construct the modular prior on all possible local families

% This uses a flat prior
% aflp = mkAllFamilyLogPrior( nNodes, 'maxFanIn', maxFanIn, 'priorType', 'flat');


%disp('Calc aflml...')
aflml = mkAllFamilyLogMargLik(discretized_data, 'nodeArity', node_arity , 'impossibleFamilyMask', ...
    aflp~=-Inf, 'priorESS', 1, 'clampedMask', clamped); % compute marginal likelihood on all possible local families

%disp('Calc ep...')
%epALL_clamped(:,:,ind) = computeAllEdgeProb( aflp, aflml ); % compute the marginal edge probabilities using DP
ep = computeAllEdgeProb( aflp, aflml ); % compute the marginal edge probabilities using DP



dp_inference = ep;

PlotResults=questdlg('Inference finished - would you like to plot the results as a heatmat-matrix in matlab?', 'plot results?', 'Yes','No', 'Yes');

if strcmp(PlotResults,'Yes')
    figure;
    subplot(2,1,1),imagesc(ep, [0 1])
    colorbar
    axis square
    title('All edges')
    subplot(2,1,2),imagesc(ep>edgeweight_threshold, [0 1])
    colorbar
    axis square
    title(['Edges greater than ' num2str(edgeweight_threshold)])
end

% create labels of edges which are > threshold
edge_labels = cell(nNodes,nNodes);
for i = 1:nNodes
    for j = 1:nNodes
        if ep(i,j) > edgeweight_threshold
            
            % Use a precision (significant figures) of 2
            edge_labels{i,j} = num2str(ep(i,j), 2);
        end
    end
end

cd(pwd)


epfiltered = ep>edgeweight_threshold;

PrintResults=questdlg('Would you like to create a graph of the resulting network ?', 'plot results?', 'Yes','No', 'Yes');

if strcmp(PrintResults,'Yes')   
    [FILENAME, PATHNAME, FILTERINDEX] = uiputfile('*.dot','Choose name of file to save graph');
    TotalName = fullfile(PATHNAME,FILENAME);
    % do dot file and save
    DotFile = strcat('DAGfrom' ,OldData.data(para.DC).Name,'-',date,'.dot');
    graph_to_dot(epfiltered, 'filename', TotalName, 'node_label', node_labels, 'arc_label', edge_labels);
    %save(DotFile);
    try
        [a b]=system(['dot -Tpdf ' TotalName ' -o ' TotalName(1:end-4) '.pdf']);
        if ismac
            [a b]=system(['open ' TotalName(1:end-4) '.pdf ']);
        elseif isunix
            [a b]=system(['acroread ' TotalName(1:end-4) '.pdf &']);
        end
    end    
end