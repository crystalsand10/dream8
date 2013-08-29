function y = nanvar(x,varargin)
% FORMAT: Y = NANVAR(X,DIM,FLAG)
% 
%    Standard deviation ignoring NaNs
%
%    This function enhances the functionality of NANVAR as distributed in
%    the MATLAB Statistics Toolbox and is meant as a replacement (hence the
%    identical name).  
%
%    NANVAR(X,DIM) calculates the variance along any dimension of
%    the N-D array X ignoring NaNs.  
%
%    NANVAR(X,DIM,0) normalizes by (N-1) where N is SIZE(X,DIM).  This make
%    NANVAR(X,DIM) the best unbiased estimate of the variance if X is
%    a sample of a normal distribution. If omitted FLAG is set to zero.
%    
%    NANVAR(X,DIM,1) normalizes by N and produces the 
%    second moment of the sample about the mean.
%
%    If DIM is omitted NANVAR calculates the variance along first
%    non-singleton dimension of X.
%
%    Similar replacements exist for NANMEAN, NANMEDIAN, NANMIN, NANMAX, NANSTD, and
%    NANSUM which are all part of the NaN-suite.
%
%    See also VAR

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
%    SBPipeline.harvard.edu

y = nanstd(x, varargin{:}).^2;