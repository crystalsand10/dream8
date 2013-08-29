function [XfactorsFull,YfactorsFull,CoreFull,BFull,...
    ypredFull,ypredTrain,ssxFull,ssyFull,regFull,groupInfo,xmodelFull,processing2,FacOpt, ...
    R2Y,R2Yi,Q2,Q2V,YValPred,YValRes] = ...
    npls_cross_validation(X0,Y0,show,nGroups,significanceCutoff,seed,processing,FacMax1)
%NPLS_CROSS_VALIDATION cross-validated multilinear partial least squares
%regression
%
% See also:
% 'parafac' 'tucker'
%
%
% MULTILINEAR PLS  -  N-PLS
%
% INPUT
% X        Array of independent variables
% Y        Array of dependent variables
%
% OPTIONAL
% show	   If show = NaN, no outputs are given;
%          0 = final output only
%          1 = all outputs
% nGroups  Number of groups to use for cross validation (default is 7)
%          OR assigment of observations to groups
% significanceCutoff  Cutoff(s) for significance tests
% seed     random number seed (for group determination)
% processing is a 1 or 2 element structure of pre-processing parameters (see nprocess)
%             If 1 element in structure, processing applies to both X and Y
%             If 2 elements in structure, first applies to X, second to Y
% FacMax   maximum number of factors to consider
%
%
% OUTPUT
% Xfactors Holds the components of the model of X in a cell array.
%          Use fac2let to convert the parameters to scores and
%          weight matrices. I.e., for a three-way array do
%          [T,Wj,Wk]=fac2let(Xfactors);
% Yfactors Similar to Xfactors but for Y
% Core     Core array used for calculating the model of X
% B        The regression coefficients from which the scores in
%          the Y-space are estimated from the scores in the X-
%          space (U = TB);
% ypred    The predicted values of Y for one to Fac components
%          (array with dimension Fac in the last mode)
% ssx      Variation explained in the X-space.
%          ssx(f+1,1) is the sum-squared residual after first f factors.
%          ssx(f+1,2) is the percentage explained by first f factors.
% ssy      As above for the Y-space
% reg      Cell array with regression coefficients for raw (preprocessed) X
%
%
% AUXILIARY
%
% If missing elements occur these must be represented by NaN.
%
%
% [Xfactors,Yfactors,Core,B,ypredTrain,ssx,ssy,reg] = npls(X,y);
% or short
% [Xfactors,Yfactors,Core,B] = npls(X,y);
%

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

% NPLS VERSION INFO:
% $ Version 1.02 $ Date July 1998 $ Not compiled $
% $ Version 1.03 $ Date 4. December 1998 $ Not compiled $ Cosmetic changes
% $ Version 1.04 $ Date 4. December 1999 $ Not compiled $ Cosmetic changes
% $ Version 1.05 $ Date July 2000 $ Not compiled $ error caused weights not to be normalized for four-way and higher
% $ Version 1.06 $ Date November 2000 $ Not compiled $ increase max it and decrease conv crit to better handle difficult data
% $ Version 2.00 $ May 2001 $ Changed to array notation $ RB $ Not compiled $
% $ Version 2.01 $ June 2001 $ Changed to handle new core in X $ RB $ Not compiled $
% $ Version 2.02 $ January 2002 $ Outputs all predictions (1 - LV components) $ RB $ Not compiled $
% $ Version 2.03 $ March 2004 $ Changed initialization of u $ RB $ Not compiled $
% $ Version 2.04 $ Jan 2005 $ Modified sign conventions of scores and loads $ RB $ Not compiled $

% NPLS_CROSS_VALIDATION VERSION INFO:
% Version 1.0 July 2007 created by ACG (based on npls.m)

%% Help info
if nargin==0
    disp(' ')
    disp(' ')
    disp(' THE CROSS-VALIDATED N-PLS REGRESSION MODEL')
    disp(' ')
    disp(' Type <<help npls>> for more info')
    disp('  ')
    disp(' [Xfactors,Yfactors,Core,B,ypredTrain,ssx,ssy] = npls_cross_validation(X,y);')
    disp(' or short')
    disp(' [Xfactors,Yfactors,Core,B] = npls_cross_validation(X,y);')
    disp(' ')
    return
elseif nargin<2
    error(' The inputs X and y must be given')
end
%% Look for completely missing observations
if any(all(isnan(Y0(:,:)),2)) || any(all(isnan(X0(:,:)),2))
    error('One or more X or Y observations consists of only missing values (NaN''s).');
end
%% Default arguments
if ~exist('nGroups','var') || isempty(nGroups)
    nGroups = 7;
end
if ~exist('show','var') || isempty(show)
    show = NaN;
    showFinal = 1;
else
    switch show
        case 0
            show = NaN;
            showFinal = 1;
        case 1
            showFinal = 1;
        otherwise % NaN, and other numbers.
            showFinal = show;
    end
end
if ~exist('significanceCutoff','var') || isempty(significanceCutoff)
    significanceCutoff = 0.9;
end
if numel(significanceCutoff) == 3
    nonSigLimit2 = significanceCutoff(3);
    significanceCutoff(3) = [];
else
    nonSigLimit2 = 0.03;
end
if numel(significanceCutoff) == 2
    nonSigLimit1 = significanceCutoff(2);
    significanceCutoff(2) = [];
else
    nonSigLimit1 = 0.01; % Simca-P default
end

if ~exist('seed','var') || isempty(seed)
    seed = mod(floor(now*1e10),2^32);
end
rand('twister',seed);

defaultProcessing = struct(...
    'Cent', [], ...
    'Scal', [], ...
    'iter', 1, ...
    'mX',   [], ...
    'sX',   []);
if ~exist('processing','var') || isempty(processing)
    processing = defaultProcessing;
else
    processing = setParameters(defaultProcessing, processing);
end
% Apply Y processing to X as well...
if numel(processing) == 1
    processing(2) = processing(1);
end

%% Apply processing
[X,mX,sX] = nprocess(X0,processing(1));
[Y,mY,sY] = nprocess(Y0,processing(2));

% % Uncomment if separately doing processing of CV groups
% X = X0;
% Y = Y0;

%% Determine size of inputs
DimX = size(X);
X = reshape(X,DimX(1),prod(DimX(2:end)));
ordX = length(DimX);if ordX==2&&DimX(2)==1;ordX = 1;end
DimY = size(Y);
Y = reshape(Y,DimY(1),prod(DimY(2:end)));
ordY = length(DimY);if ordY==2&&DimY(2)==1;ordY = 1;end

[I,Jx]=size(X);
[I,Jy]=size(Y);
FacMax = min(I,Jx)-1;
if exist('FacMax1','var') && ~isempty(FacMax1) && FacMax1 < FacMax
    FacMax = FacMax1;
end

%% Validate the number of groups and determine grouping
if ~isscalar(nGroups)
    % Validate the vector form of nGroups
    if numel(nGroups) ~= I
        error('nGroups must be a vector containing one element per X & Y observation.');
    end
    groups = nGroups(:);
    nGroups = max(nGroups);
    if nGroups > I
        error(['The number of observations is smaller than the number'...
            'of cross-validation groups\n']);
    end
    if any(~isreal(groups)) || any(floor(groups)~=groups) || min(groups) < 1
        error('nGroups must be a vector of non-negative integers, corresponding to group assignments.');
    end
    % Make sure at least 1 observation exists for each group
    for i=1:nGroups
        if all(groups ~= i)
            error('nGroups does not assign any observations to group %d', i);
        end
    end
    seed = nan;
elseif nGroups > I
    warning(['The number of observations (%d) is smaller than the requested number'...
        'of cross-validation groups (%d)\n' ...
        'Setting the number of cross-validation groups to %d'], ...
        I, nGroups, I);
    nGroups = I;
    groups = 1:I;
else
    perm = randperm(I);
    % Partition perm into nGroups groups of roughly equal size
    groups = ceil(perm*nGroups/I);
end
groupInfo = struct('groups', groups, 'seed', seed);
Yres{1} = Y;
%% Main loop
DimXCell = mat2cell(DimX, 1, ones(1, numel(DimX)));
DimYCell = mat2cell(DimY, 1, ones(1, numel(DimY)));
[XfactorsTrain,YfactorsTrain,CoreTrain,BTrain,ypredTrain,...
    ssxTrain,ssyTrain,regTrain,xmodelTrain] = deal(cell(nGroups,1));
[TVal,ssXVal] = deal(cell(nGroups,FacMax));
XValRes = nan(I,Jx,FacMax);
YValPred = nan(I,Jy,FacMax);
YValRes = nan(I,Jy,FacMax);
for k=1:nGroups
    iValidate = find(groups==k);
    iTrain = find(groups~=k);
    XTrain = reshape(X(iTrain,:), [], DimXCell{2:end});
    XVal = reshape(X(iValidate,:), [], DimXCell{2:end});
    YTrain = reshape(Y(iTrain,:), [], DimYCell{2:end});
    YVal = reshape(Y(iValidate,:), [], DimYCell{2:end});
    % Run model
    [XfactorsTrain{k},YfactorsTrain{k},CoreTrain{k},BTrain{k},...
        ypredTrain{k},ssxTrain{k},ssyTrain{k},regTrain{k},xmodelTrain{k}] ...
        = npls(XTrain,YTrain,FacMax,show);
    % Validate (using processed data)
    for n=1:FacMax
        [YValPred1,TVal{k,n},ssXVal{k,n},XValRes1]=...
            npred(XVal,n,XfactorsTrain{k},YfactorsTrain{k},CoreTrain{k},...
            BTrain{k},show);
        YValRes1 = YVal - YValPred1;
        XValRes(iValidate,:,n) = XValRes1(:,:);
        YValPred(iValidate,:,n) = YValPred1(:,:);
        YValRes(iValidate,:,n) = YValRes1(:,:);
    end
end
%% Calculate statistics
pressYi = shiftdim(nansum(YValRes.^2,1),1); % Size: Jy x FacMax
YCtr = bsxfun(@minus, Y, nanmean(Y, 1));
ssYi0 = shiftdim(nansum(YCtr.^2, 1),1); % Size: Jy x 1
Q2VCum = 1 - bsxfun(@rdivide, pressYi, ssYi0);
Q2Cum = 1 - nansum(pressYi,1)./nansum(ssYi0,1);
Q2V = diff([zeros(Jy,1) Q2VCum ], 1, 2);
Q2 = diff([0 Q2Cum], 1, 2);
Limit = 1-significanceCutoff;
rule1 = Q2 > Limit;
rule2 = any(Q2V > Limit, 1);
rules = rule1 | rule2;
FacOpt = 0;
% This rule can add components that don't significantly improve the model!
while FacOpt < FacMax && rules(FacOpt+1)
    FacOpt = FacOpt + 1;
end
if ~isnan(show)
    disp(sprintf('Component %i is significant...', FacOpt));
end
%% Back-calculate full model parameters
if FacOpt > 0
    if ~isnan(showFinal)
        disp(sprintf('A total of %d components are significant by Rule 1.', FacOpt));
    end
    [XfactorsFull,YfactorsFull,CoreFull,BFull,...
        ypredFull,ssxFull,ssyFull,regFull,xmodelFull,processing2] ...
        = npls(X0,Y0,FacOpt,showFinal,processing);
    %     ssy0 = nansum((Y0(:)-nanmean(Y0(:))).^2);
    %     R2Y = 1-ssyFull(end,1)/ssy0;
else
    if ~isnan(showFinal) && showFinal
        warning('No components were significant!');
    end
    % Calculate a 1 component model, but set ypred to nan & ssy to 0
    [XfactorsFull,YfactorsFull,CoreFull,BFull,...
        ypredFull,ssxFull,ssyFull,regFull,xmodelFull] ...
        = npls(X0,Y0,1,showFinal,processing);
    ypredFull(:) = nan;
    ssyFull(:) = 0;
    processing2 = processing;
    FacOpt = 0;
    %     R2Y = NaN;
    %     Q2 = NaN;
end

%% Check for "non-signficiant components", like Simca-P rule N4
Y0Res = bsxfun(@minus, Y0, ypredFull);
Y0Res = reshape(Y0Res, I, Jy, []);
ssY0i = shiftdim(nansum(Y0Res.^2,1), 1); % Size Jy x FacOpt
Y0Mean = nanmean(Y0,1);
ssY0i0 = shiftdim(nansum(bsxfun(@minus, Y0(:,:), Y0Mean(:,:)).^2), 1);
R2Yi = 1-bsxfun(@rdivide, ssY0i, ssY0i0); % Size Jy x FacOpt
R2YiComp = R2Yi; % Size Jy x FacOpt
R2YiComp(:, 2:end) = diff(R2Yi, [], 2);
R2Y = 1 - bsxfun(@rdivide, nansum(ssY0i, 1), nansum(ssY0i0, 1)); % Size 1 x FacOpt
R2YComp = [R2Y(1) diff(R2Y)]; % Size 1 x FacOpt
nonSigTest1 = R2YComp < nonSigLimit1;
nonSigTest2 = all(R2YiComp < nonSigLimit2, 1);
nonSigTest = [nonSigTest1 & nonSigTest2 1];
FacOptNew = find(nonSigTest, 1, 'first') - 1;
if FacOptNew < FacOpt
    FacOpt = FacOptNew;
    if ~isnan(showFinal)
        disp(sprintf('Rule 2 has reduced the number of components to %d.', FacOpt));
    end
    [XfactorsFull,YfactorsFull,CoreFull,BFull,...
        ypredFull,ssxFull,ssyFull,regFull,xmodelFull,processing2] ...
        = npls(X0,Y0,FacOpt,showFinal,processing);
    %Bug fix April 12, 2010 Melody Morris: if a new plsr model is 
    %determined because of Rule 2, recalculate model statistics.
    Y0Res = bsxfun(@minus, Y0, ypredFull);
    Y0Res = reshape(Y0Res, I, Jy, []);
    ssY0i = shiftdim(nansum(Y0Res.^2,1), 1); % Size Jy x FacOpt
    Y0Mean = nanmean(Y0,1);
    ssY0i0 = shiftdim(nansum(bsxfun(@minus, Y0(:,:), Y0Mean(:,:)).^2), 1);
    R2Yi = 1-bsxfun(@rdivide, ssY0i, ssY0i0); % Size Jy x FacOpt
    R2YiComp = R2Yi; % Size Jy x FacOpt
    R2YiComp(:, 2:end) = diff(R2Yi, [], 2);
    R2Y = 1 - bsxfun(@rdivide, nansum(ssY0i, 1), nansum(ssY0i0, 1)); % Size 1 x FacOpt
    R2YComp = [R2Y(1) diff(R2Y)]; % Size 1 x FacOpt
end
%% Output arguments

% warning ('Calculating *full* FacMax factors');
%     [XfactorsFull,YfactorsFull,CoreFull,BFull,...
%         ypredFull,ssxFull,ssyFull,regFull,xmodelFull,processing2] ...
%         = npls(X0,Y0,FacMax,showFinal,processing);
if nargout == 1
    % Pack outputs into a structure
    output = struct('Xfactors',{XfactorsFull},'Yfactors',{YfactorsFull},...
        'Core',{CoreFull},'B',{BFull},'ypred',{ypredFull},...
        'ypredTrain',{ypredTrain},'ssx',{ssxFull},'ssy',{ssyFull},...
        'reg',{regFull},'groupInfo',{groupInfo},'xmodel',{xmodelFull},...
        'processing',{processing2},'FacOpt',{FacOpt},...
        'R2Y',{R2Y},'R2Yi',{R2Yi},'Q2',{Q2},'Q2V',{Q2V},...
        'YValPred',{YValPred},'YValRes',{YValRes});
    XfactorsFull = output;
end