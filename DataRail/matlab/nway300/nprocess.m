function [Xnew,mX,sX]=nprocess(X,varargin);
%NPROCESS pre and postprocessing of multiway arrays
%
%
% CENTERING AND SCALING OF N-WAY ARRAYS
%
% This m-file works in two ways
%    I.  Calculate center and scale parameters and preprocess data
%    II. Use given center and scale parameters for preprocessing data
%
% Note: in each case, parameters may also be passed in a structure
%
% %%% I. Calculate center and scale parameters %%%
%
%     [Xnew,Means,Scales]=nprocess(X,Cent,Scal,iter);
% or
%     [Xnew,Means,Scales]=nprocess(X,parameters);
%
%     INPUT
%     X       Data array
%
% The remaining inputs may also be passed as fields of the structure
% parameters:
%     Cent    is binary row vector with as many elements as DimX.
%             If Cent(i)=1 the centering across the i'th mode is performed
%             i.e. cent = [1 0 1] means centering across mode one and three.
%     Scal    is defined likewise.
%             Scal(i)=1, means scaling to standard deviation one WITHIN the
%             i'th mode
%             Scal(i)=2, means scaling to standard deviation one ACROSS the
%             i'th mode (NOT RECOMMENDED)
%     iter    (Optional) Number of times to iteratively apply processing
%
%     OUTPUT
%     Xnew    The preprocessed data
%     mX      Sparse vector holding the mean-values
%     sX      Sparse vector holding the scales
%
% %%% II. Use given center and scale parameters %%%
%
%     Xnew=nprocess(X,Cent,Scal,iter,mX,sX);
% or
%     [Xnew,Means,Scales]=nprocess(X,parameters);
%
%     INPUT
%     X       Data array
%
% The remaining inputs may also be passed as fields of the structure
% parameters:
%     Cent    is binary row vector with as many elements as DimX.
%             If Cent(i)=1 the centering across the i'th mode is performed
%             I.e Cent = [1 0 1] means centering across mode one and three.
%     Scal    is defined likewise.
%             Scal(i)=1, means scaling to standard deviation one WITHIN the
%             i'th mode
%             Scal(i)=2, means scaling to standard deviation one ACROSS the
%             i'th mode (NOT RECOMMENDED)
%     iter    Optional input
%             if iter > 0 normal preprocessing is performed (default)
%             iteratively, iter number of times
%             if iter < 0 inverse (post-)processing is performed
%             iteratively, -iter number of times
%     mX      Sparse vector holding the mean-values
%     sX      Sparse vector holding the scales
%
%     OUTPUT
%     Xnew    The preprocessed data
%
% For convenience this m-file does not use iterative
% preprocessing, which is necessary for some combinations of scaling
% and centering. Instead the algorithm first standardizes the modes
% successively and afterwards centers. The prior standardization ensures
% that the individual variables are on similar scale (this MIGht be slightly
% disturbed upon centering - unlike for two-way data).
%
% The full I/O for nprocess is
% [Xnew,mX,sX]=nprocess(X,Cent,Scal,iter,mX,sX,show,usemse);
% where show set to zero avoids screen output and where usemse set
% to one uses RMSE instead of STD for scaling (more appropriate
% in some settings)

% Copyright, 1998 -
% This M-file and the code in it belongs to the holder of the
% copyrights and is made public under the following constraints:
% It must not be changed or modified and code cannot be added.
% The file must be regarded as read-only. Furthermore, the
% code can not be made part of anything but the 'N-way Toolbox'.
% In case of doubt, contact the holder of the copyrights.
%
% Rasmus Bro
% Chemometrics Group, Food Technology
% Department of Food and Dairy Science
% Royal Veterinary and Agricultutal University
% Rolighedsvej 30, DK-1958 Frederiksberg, Denmark
% Phone  +45 35283296
% Fax    +45 35283245
% E-mail rb@kvl.dk


% $ Version 1.03 $ Date 6. May 1998 $ Drastic error in finding scale parameters corrected $ Not compiled $
% $ Version 1.031 $ Date 25. January 2000 $ Error in scaling part $ Not compiled $
% $ Version 1.032 $ Date 28. January 2000 $ Minor bug$ Not compiled $
% $ Version 1.033 $ Date 14. April 2001 $ Incorrect backscaling fixed.
% $ Version 2.00 $ May 2001 $ Changed to array notation $ RB $ Not compiled $
% $ Version 2.00 $ May 2001 $ rewritten by Giorgio Tomasi $ RB $ Not compiled $
% $ Version 2.01 $ Feb 2002 $ Fixed errors occuring with one-slab inputs $ RB $ Not compiled $
% $ Version 2.02 $ Oct 2003 $ Added possibility for sclaing with RMSE $ RB $ Not compiled $


% $ Version 1.03 $ Date 6. May 1998 $ Drastic error in finding scale parameters corrected $ Not compiled $

% Copyright (C) 1995-2006  Rasmus Bro & Claus Andersson
% Copenhagen University, DK-1958 Frederiksberg, Denmark, rb@LIFe.ku.dk
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA  02110-1301, USA.

ord  = ndims(X);
DimX = size(X);

if isstruct(varargin{1})
    defaultParameters = struct(...
        'Cent', [], ...
        'Scal', [], ...
        'iter', [], ...
        'mX',   [], ...
        'sX',   [], ...
        'show', [], ...
        'usemse', []);
    p = setParameters(defaultParameters, varargin{1});
    Cent = p.Cent;
    Scal = p.Scal;
    iter = p.iter;
    mX = p.mX;
    sX = p.sX;
    show = p.show;
    usemse = p.usemse;
else
    try
        Cent = varargin{1};
        Scal = varargin{2};
        iter = varargin{3};
        mX = varargin{4};
        sX = varargin{5};
        show = varargin{6};
        usemse = varargin{7};
    catch
    end
end

if ~exist('Cent','var') || isempty(Cent)
    Cent = zeros(1,ord);
end

if ~exist('Scal','var') || isempty(Scal)
    Scal = zeros(1,ord);
end
    
if ( exist('mX','var') && ~isempty(mX) && (~exist('sX','var') || isempty(sX)) ) || ...
        ( exist('sX','var') && ~isempty(sX) && (~exist('mX','var') || isempty(mX)) )
    error(' You must input both mX and sX even if you are only doing centering')
end

if ~exist('usemse','var') || isempty(usemse)
    usemse=0;
end

if ~exist('iter','var') || isempty(iter)
    iter=1;
elseif iter < 0 && ( ~exist('mX','var') || ~exist('sX','var') )
    error(' You must input both mX and sX when doing post-processing');
end

if ~exist('mX','var') || isempty(mX)
    mX = cell(ord,abs(iter));
elseif any(size(mX) ~= [ord, abs(iter)])
    error(' mX must be a cell of dimension %d x %d', ord, abs(iter))
end
if ~exist('sX','var') || isempty(sX)
    sX = cell(ord,abs(iter));
elseif any(size(sX) ~= [ord, abs(iter)])
    error(' sX must be a cell of dimension %d x %d', ord, abs(iter))
end

if ~exist('show','var')==1
    show=1;
end

if iter == 0 || mod(iter,1) ~= 0
    error( 'The input <<iter>> must be a non-zero integer')
end

% iteratively apply the function, if necessary
if iter > 1
    % Extra levels of pre-processing add to end of mX and sX
    iterIndex = abs(iter);
    nextIter = iter - 1;
    [Xnew,mX(:,1:end-1),sX(:,1:end-1)]=nprocess(X,Cent,Scal,nextIter,...
        mX(:,1:end-1),sX(:,1:end-1),show,usemse);
elseif iter < -1
    % Extra levels of post-processing work use beginning of mX and sX
    iterIndex = 1;
    nextIter = iter + 1;
    [Xnew,mX(:,2:end),sX(:,2:end)] = nprocess(X,Cent,Scal,nextIter,...
        mX(:,2:end),sX(:,2:end),show,usemse);
else
    iterIndex = 1;
    Xnew = X;
end

% See whether sX and mX need to be calculated this iteration
if iter < 0
    % sX and mX must be provided for post-processing
    MODE = true;
else
    MODE = true;
    for i=1:ord
        if ( Cent(i) && isempty(mX{i,iterIndex}) ) || ...
                ( Scal(i) && isempty(sX{i,iterIndex}) )
            MODE = false;
            break
        end
    end
end

if show~=0
    disp(['Iteration ' num2str(iter)]);
    if MODE
        if iter>0
            disp(' Using given mean and scale values for preprocessing data')
        elseif iter<0
            disp(' Using given mean and scale values for postprocessing data')
        end
    else
        disp(' Calculating mean and scale and processing data')
    end
end

Inds = cell(1,ord);
for i=1:ord
    Inds{i} = ones(DimX(i),1);
end
Indm = repmat({':'},ord - 1,1);

if iter > 0
    % Pre-processing
    % Scale
    for j = ord:-1:1
        o = [j 1:j-1 j+1:ord];
        if Scal(j) == 1
            if show~=0
                disp([' Scaling mode ',num2str(j)])
            end
            if ~MODE
                if ~usemse
                    sX{j,iterIndex} = (stdnan(nshape(Xnew,j)')').^-1;
                else
                    sX{j,iterIndex} = (rmsenan(nshape(Xnew,j)')').^-1;
                end
            end
            Xnew = Xnew.*ipermute(sX{j,iterIndex}(:,Inds{o(2:end)}),o);
        elseif Scal(j) == 2
            if show~=0
                disp([' Scaling ACROSS mode ',num2str(j)])
            end
            if ~MODE
                if ~usemse
                    sX{j,iterIndex} = nanstd(Xnew,j).^-1;
                else
                    sX{j,iterIndex} = sqrt(nanmean(Xnew.^2,j)).^-1;
                end
            end
            oo = ones(1,ord);
            oo(j) = DimX(j);
            Xnew = Xnew.*repmat(sX{j,iterIndex},oo);
        end
    end
    %Center
    for j = ord:-1:1
        o = [1:j-1 j+1:ord,j];
        if Cent(j)
            if show~=0
                if MODE
                    disp([' Subtracting off-sets in mode ',num2str(j)])
                else
                    disp([' Centering mode ',num2str(j)])
                end
            end
            if ~MODE
                if ord ~= 2
                    mmm = nshape(Xnew,j);
                    if min(size(mmm))==1
                        %mmm = mmm;
                    else
                        mmm = missmean(mmm);
                    end
                    mX{j,iterIndex} = reshape(mmm,DimX(o(1:end-1)));
                else
                    mX{j,iterIndex} = reshape(missmean(nshape(Xnew,j)),DimX(o(1)),1);
                end
            end
            Xnew = Xnew - ipermute(mX{j,iterIndex}(Indm{:},Inds{j}),o);
        end
    end

else

    %Center
    for j = 1:ord

        if Cent(j)
            if show~=0
                disp([' Adding off-sets in mode ',num2str(j)])
            end
            Xnew = Xnew + ipermute(mX{j,iterIndex}(Indm{:},Inds{j}),[1:j-1 j+1:ord,j]);
        end
    end
    %Scale
    for j = 1:ord
        o = [1:j-1 j+1:ord];
        if Scal(j) == 1
            if show~=0
                disp([' Rescaling back to original domain in mode ',num2str(j)])
            end
            Xnew = Xnew ./ ipermute(sX{j,iterIndex}(:,Inds{o}),[j o]);
        elseif Scal(j) == 2
            if show~=0
                disp([' Rescaling back to original domain ACROSS mode ',num2str(j)])
            end
            oo = ones(1,ord);
            oo(j) = DimX(j);
            Xnew = Xnew ./ repmat(sX{j,iterIndex},oo);
        end
    end

end

function st=rmsenan(X);

%RMSENAN estimate RMSE with NaN's
%
% Estimates the RMSE of each column of X
% when there are NaN's in X.
%
% Columns with only NaN's get a standard deviation of zero


% $ Version 1.02 $ Date 28. July 1998 $ Not compiled $
%
%
% Copyright, 1998 -
% This M-file and the code in it belongs to the holder of the
% copyrights and is made public under the following constraints:
% It must not be changed or modified and code cannot be added.
% The file must be regarded as read-only. Furthermore, the
% code can not be made part of anything but the 'N-way Toolbox'.
% In case of doubt, contact the holder of the copyrights.
%
% Rasmus Bro
% Chemometrics Group, Food Technology
% Department of Food and Dairy Science
% Royal Veterinary and Agricultutal University
% Rolighedsvej 30, DK-1958 Frederiksberg, Denmark
% E-mail: rb@kvl.dk

st = sqrt(nanmean(X.^2,1));
st(isnan(st)) = 0;