function results = compareModels(xDataCubes, yDataCubes, Parameters)
% compareModels compares various input/output models of different processed data cubes
%
% results = compareModels(xDataCubes, yDataCubes, Parameters)
%
%--------------------------------------------------------------------------
%INPUTS:
% xDataCubes  = array of input (X) data cube STRUCTURES
% yDataCubes  = array of output (Y) data cube STRUCTURES
% Parameters  = a multi-level structure of parameters
%    .DataMode = OPTIONAL string
%                      Default: If empty or set to 'Independent', then X
%                      and Y data are steppend through independently.
%                      If set to 'Dependent', then X and Y data are
%                      stepped through simultaneously. In this case,
%                      XDataCubes & YDataCubes must have the same size.
%    .XProcessing = structure array, one per pre/post processing step
%      .PreFunction    = pre-processing function
%      .PreParameters  = pre-processing parameters
%      .PostFunction   = post-processing function
%      .PostParameters = post-processing parameters
%    .YProcessing = OPTIONAL structure array, formatted like XProcessing
%                  If not supplied, the same processing is ued for both X and Y data 
%    .ProcessingMode = OPTIONAL string
%                      Default: If empty or set to 'Independent', then X
%                      and Y processing are done independently.
%                      If set to 'Dependent', then X and Y are
%                      processed simultaneously. In this case,
%                      XProcessing & YProcessing must have the same size.
%    .Models    = structure array, one per modeling step
%      .Function       = modeling function
%      .Parameters     = modeling parameters
%    .XStandardizers = structure array, one per dataCube
%      .Function       = standardizing function
%      .Parameters     = standardizing parameters
%    .YStandardizers = OPTIONAL structure array, formatted like XProcessing
%                  If not supplied, the same processing is ued for both X and Y data 
%    .Comparisons = OPTIONAL structure array (one per yDataCube) for comparison of model results
%      .Function       = comparison function
%      .Parameters     = comparison parameters
%
% Notes:
% (1) Processing and Standardizing functions should use the following interface:
%    [outDataValue, outParameters] = f(inDataValue, inParameters)
%    where inDataValue and outDataValue are data.Value arrays and
%    inParameters and outParameters are Parameter structures.
% (2) Model functions should use the following interface:
%    [modelXData, modelYData, modelOutputs] = g(xData, yData, modelParameters)
%
%OUTPUTS:
% results    = a structure of modeling results
%    .TODO
%
%--------------------------------------------------------------------------
% EXAMPLE:
% - TODO
%
%--------------------------------------------------------------------------
% TODO:
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

% Parameters
DefaultParameters = struct(...
    'DataMode', 'Independent', ...
    'XProcessing', [], ...
    'YProcessing', Parameters.XProcessing, ...
    'ProcessingMode', 'Independent', ...
    'Models', [], ...
    'XStandardizers', [], ...
    'YStandardizers', Parameters.XStandardizers, ...
    'Comparisons', []);

Parameters = setParameters(DefaultParameters, Parameters);

% Check Parameters
nXCubes = numel(xDataCubes);
if numel(Parameters.XStandardizers) ~= nXCubes
    error('One Parameters.XStandardizers must be supplied for each each xDataCube.');
end
nYCubes = numel(yDataCubes);
if numel(Parameters.YStandardizers) ~= nYCubes
    error('One Parameters.YStandardizers must be supplied for each each yDataCube.');
end
% Check Independent/Dependent status of DataMode & ProcessingMode
switch lower(Parameters.DataMode)
    case 'independent'
        dependentCubes = false;
    case 'dependent'
        nYCubes = 1;
        if nXCubes ~= nYCubes
            error('Dependent processing requires equal size XProcessing and YProcessing');
        end
        dependentCubes = true;
    otherwise
        error('Invalid value for Parameters.DataMode')
end
nXProcesses = numel(Parameters.XProcessing);
nYProcesses = numel(Parameters.YProcessing);
switch lower(Parameters.ProcessingMode)
    case 'independent'
        dependentProcessing = false;
    case 'dependent'
        if nXProcesses ~= nYProcesses
            error('Dependent processing requires equal size XProcessing and YProcessing');
        end
        nYProcesses = 1;
        dependentProcessing = true;
    otherwise
        error('Invalid value for Parameters.ProcessingMode')
end
nModels = numel(Parameters.Models);

% Process cubes
for ix=1:nXCubes
    xData = xDataCubes(ix);
    XStandardizer = Parameters.XStandardizers(ix);
    fXStandardizer = XStandardizer.Function;

    for jx=1:nXProcesses
        % Pre-process
        XProcess = Parameters.XProcessing(jx);
        fXPre = XProcess.PreFunction;
        fXPost = XProcess.PostFunction;
        [preXData, preXOutputs] = fXPre(xData.Value, setParameters(xData, XProcess.PreParameters));
        % Combine parameters output from pre-processing with other
        % explicit post-processing parameters (which take precedence)
        XPost = setParameters(preXOutputs, XProcess.PostParameters);

        for iy=1:nYCubes
            if dependentCubes
                yData = yDataCubes(ix);
                YStandardizer = Parameters.YStandardizers(ix);
            else
                yData = yDataCubes(iy);
                YStandardizer = Parameters.YStandardizers(iy);
            end
            fYStandardizer = YStandardizer.Function;

            for jy=1:nYProcesses
                if dependentProcessing
                    YProcess = Parameters.YProcessing(jx);
                else
                    YProcess = Parameters.YProcessing(jy);
                end
                fYPre = YProcess.PreFunction;
                fYPost = YProcess.PostFunction;
                [preYData, preYOutputs] = fYPre(yData.Value, setParameters(yData, YProcess.PreParameters));
                YPost = setParameters(preYOutputs, YProcess.PostParameters);
                
                for m=1:nModels
                    disp(sprintf('%d/%d ', ix, nXCubes, jx, nXProcesses, iy, nYCubes, jy, nYProcesses, m, nModels));
                    % Run model
                    Model = Parameters.Models(m);
                    fModel = Model.Function;
                    [modelXData, modelYData, modelOutputs] = fModel(preXData, preYData, Model.Parameters);

                    % Post-process
                    [postXData, postXOutputs] = fXPost(modelXData, XPost);
                    [postYData, postYOutputs] = fYPost(modelYData, YPost);

                    % Convert cubes to standard for comparison
                    [dataXStandard, standardizerXOutputs] = fXStandardizer(postXData, XPost);
                    [dataYStandard, standardizerYOutputs] = fYStandardizer(postYData, YPost);

                    % Save results
                    results(ix,jx,iy,jy,m) = struct(...
                        'ModelXData', modelXData, ...
                        'ModelYData', modelYData, ...
                        'ModelOutputs', modelOutputs, ...
                        'DataXStandard', dataXStandard, ...
                        'DataYStandard', dataYStandard, ...
                        'Comparison', []);
                end % m
            end % jy
        end % iy
    end % jx
end % ix

% Compare models?
if isempty(Parameters.Comparisons)
    return
end
fCompare = Parameters.Comparisons.Function;
pCompare = Parameters.Comparisons.Parameters;
for i=1:numel(results)
    results(i).Comparisons = fCompare(results(i).DataXStandard, results(i).DataYStandard, pCompare);
end 