function [newData, p] = averageReplicates(data, OldParameters)
% averageReplicates averages data across the replicate dimension
%
% [newData, Parameters] = averageReplicates(oldData, Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
% oldData   = a data cube
% Parameters(defaultValue) = optional structure of Parameters
%     .ReplicatesDim(ndims(data)) = replicates dimension
%     .CanonicalForm(true) = if true, make sure to leave 5 dimensions in cube
%
% OUTPUTS:
% newData   = new datacube
% Parameters = structure of inputted Parameters
%
%--------------------------------------------------------------------------
% EXAMPLE:
% newData = averageReplicates(oldData, struct('ReplicatesDim', 5));
%
%--------------------------------------------------------------------------
% TODO:
%
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

nDims = ndims(data);
try
    nLabels = numel(OldParameters.Labels);
catch
    nLabels = 0;
end

DefaultParameters = struct(...
    'ReplicatesDim', nDims, ...
    'CanonicalForm', true);

if nargin > 1
    p = setParameters(DefaultParameters, OldParameters);
else
    p = DefaultParameters;
end

newData = nanmean(data, p.ReplicatesDim);

if p.CanonicalForm && nLabels <= 5
    % Do not permute replicates dim but drop label
    if isfield(p, 'Labels')
        p.Labels(p.ReplicatesDim).Name = 'Dummy Dimension';
        p.Labels(p.ReplicatesDim).Value = {'Dummy Value'};
        % Add more dummy dims if necessary
        for i=nLabels+1:5
            p.Labels(i) = struct('Name', 'Dummy Dimension', ...
                'Value', 'Dummy Value');
        end
    end
else
    % permute and delete
    newData = permute(newData, [1:(p.ReplicatesDim-1) (p.ReplicatesDim+1):nDims p.ReplicatesDim]);
    if isfield(p, 'Labels'), ...
        p.Labels(p.ReplicatesDim) = [];
    end
end
