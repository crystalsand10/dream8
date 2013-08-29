function vip = npls_vip(Xfactors, ssy)
% npls_vip calculates VIP (variable importance) scores for a PLS model
%
% vip = npls_vip(Xfactors, ssy)
%
%--------------------------------------------------------------------------
% INPUTS:
% Xfactors Either a matrix of Xfactors for a particular dimension
%          or a cell of Xfactors for several dimensions.
%          (See npls for additional details.)
% ssy      Variation explained in the Y-space.
%          ssy(f+1,1) is the sum-squared residual after first f factors.
%          ssy(f+1,2) is the percentage explained by first f factors.
%
% OUTPUTS:
% vip      VIP scores (variable importance)
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% [Xfactors,Yfactors,Core,B,ypred,ssx,ssy,reg] = npls(X,Y,Fac,show);
% vip = vip(Xfactors(2:end), ssy);
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

if iscell(Xfactors)
    vip = cell(size(Xfactors));
    for i=1:numel(vip);
        vip{i} = calc_vip(Xfactors{i}, ssy);
    end
else
    vip = calc_vip(Xfactors, ssy);
end

function vip = calc_vip(weights, ssy)
% Number of variables in this dimension
nvar = size(weights,1);
% Sum of squares of errors for each dimension
ss = ssy(2:end,1);
ss2 = repmat(ss', [nvar 1]);
% Non-normalized squared VIP
weightSum = cumsum(weights.^2 .* ss2, 2);
% Normalization constant (mean VIP^2 is 1)
K = nvar./ repmat(sum(weightSum,1),[nvar 1]);
% VIP
vip = sqrt( weightSum .* K );