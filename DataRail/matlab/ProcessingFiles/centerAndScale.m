function [data, parameters] = centerAndScale(data, parameters)
% centerAndScale is a DataRail interface to nprocess of the nway toolbox
%
% [data, parameters] = MidasImporter(data, parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
% data      = hypercube of data
% parameters(default) = optional structure of parameters
%             .center([]) = List of 0 or 1's for each dimension:
%                           0 means no centering;
%                           1 centers ACROSS the dimension
%             .scale([])  = List of 0/1/2 for each dimension;
%                           0 means no scaling
%                           1 means scale WITHIN this dimension
%                           2 means scale ACROSS this dimension (NOT RECOMMENDED)
%             .iterations(1) = A scalar; the number of times to
%                               iteratively apply proessing; negative
%                               numbers apply DEPROCESSING (i.e.
%                               UNcentering and UNscaling)
%             .mean([])   = Cell of means for each dimension to use for centering
%             .std([])    = Cell of std. dev. for each dimension to use for
%                           scaling
%
% OUTPUTS:
% data       = the processed data
% parameeters = the structure of actual parameters used, including the
%               means and std. dev.
%
%--------------------------------------------------------------------------
% EXAMPLE:
% % Apply normal auto-scaling for a 2D matrix:
% params = struct('Center', [1 0], 'Scale', [0 1]);
% [data, params] = MidasImporter(data, params);
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

defaultParameters = struct(...
    'center', [], ...
    'scale', [], ...
    'iterations', 1, ...
    'mean', [], ...
    'std', []);
parameters = setParameters(defaultParameters, parameters);

% convert to nprocess-style parameters
p = struct(...
    'Cent', parameters.center, ...
    'Scal', parameters.scale, ...
    'iter', parameters.iterations, ...
    'mX', parameters.mean, ...
    'sX', parameters.std);
[data, mX, sX] = nprocess(data, p);
% store actual mean and std
parameters.mean = mX;
parameters.std = sX;