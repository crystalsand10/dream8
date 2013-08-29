function [FacOpt,R,FactorsOpt,it,err,corcondia]=pfcv(X,FacMax,maxR,nGroups,Options,varargin);
% PARAFAC model with cross validation
% Following method of S. Wold, Technometrics (1978) 20, 397-405
% "Cross-Validatory Estimation of the Number of Components in Factor and
% Principal Components Models"
% a.k.a. expectation-maximization cross-validation
szX = size(X);
nX = numel(X);
if ~exist('FacMax', 'var') || isempty(FacMax)
    FacMax = min(szX)-1;
end
if ~exist('maxR', 'var') || isempty(maxR)
    maxR = 1;
end
if exist('nGroups', 'var') && ~isempty(nGroups) && rem(szX(1),nGroups) == 0
    warning('nGroups cannot be a factor of the size of dimension 1. Automatically setting nGroups')
    nGroups = [];
end
if ~exist('nGroups', 'var') || isempty(nGroups)
    % Make sure number of groups isn't a factor of the first dimension
    for nGroups=[7 8 6 9 10:13 nan]
        if rem(szX(1),nGroups) ~= 0
            break
        end
    end
    if isnan(nGroups)
        error('Unable to automatically set the number of groups');
    end
end
if ~exist('Options', 'var') || isempty(Options)
    Options = [0 0 0 0 NaN];
elseif ndims(X) == 2
    warning('Options will be ignored for 2D data');
end

Factors = cell(nGroups,1);
XTemp = X;
XPred = repmat({nan(szX)}, FacMax, 1);
if ndims(X) == 2
    % Use pcanipals for speed
    for i=1:nGroups
        %     disp(sprintf('Running group %d of %d', i, nGroups));
        if i~=1
            XTemp(iValidate) = X(iValidate);
        end
        iValidate = i:nGroups:nX;
        XTemp(iValidate) = NaN;
        [t,p] = pcanipals(XTemp, FacMax, 0);
        Factors{i} = {t, p'};
        for j=1:FacMax
            XModel = nmodel(submodel(Factors{i},j));
            XPred{j}(iValidate) = XModel(iValidate);
        end
    end
else
    % Use parafac
    for i=1:nGroups
        %     disp(sprintf('Running group %d of %d', i, nGroups));
        if i~=1
            XTemp(iValidate) = X(iValidate);
        end
        iValidate = i:nGroups:nX;
        XTemp(iValidate) = NaN;
        Factors{i} = parafac(XTemp, FacMax, Options, varargin{:});
        for j=1:FacMax
            XModel = nmodel(submodel(Factors{i},j));
            XPred{j}(iValidate) = XModel(iValidate);
        end
    end
end
% Check error
ssX = nansum((X(:) - nanmean(X(:))).^2 );%%%% ./ nX;
press = zeros(FacMax,1);
for j=1:FacMax
    press(j) = nansum((X(:)-XPred{j}(:)).^2);
end
R = press ./ [ssX; press(1:end-1)];
FacOpt = find(R > maxR, 1, 'first') - 1;
if isempty(FacOpt)
    FacOpt = FacMax;
end

if nargout > 2
    if FacOpt > 0
        [FactorsOpt,it,err,corcondia]=parafac(X,FacOpt,Options,varargin{:});
    else
        FactorsOpt = [];
        [it,err,corcondia] = deal(nan);
    end
end

function Fac = submodel(Fac,j)
for i=1:numel(Fac)
    Fac{i} = Fac{i}(:,1:j);
end