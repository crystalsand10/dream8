function G=T3core(X,Load,Weights,NonNeg);
%T3CORE calculate Tucker core
%
% G=T3core(X,Load,Weights,NonNeg);
% Calculate a Tucker3 core given X, the loadings, Load
% in vectorized format and optionally Weights. Missing NaN, NonNeg = 1 => nonnegativity


% rewritten by Arthur Goldsipe

if ~exist('Weights', 'var')
    Weights = [];
end

if ~exist('NonNeg', 'var')
    NonNeg = 0;
end

szX = size(X);
ndX = numel(szX);

% Add "singleton" factors if necessary
Fac = zeros(1, ndX);
for i=1:ndX
    try
        Fac(i) = size(Load{i},2);
    catch
        Load{i} = 1;
        Fac(i) = 1;
    end
end

% Test for NaN's and adjust weights accordingly
nanX = isnan(X);
notNanX = ~nanX;
if any(nanX(:))
    if isempty(Weights)
        Weights = ones(szX);
    end
    Weights(nanX) = 0;
end

if isempty(Weights) % No weighting
    ztz = 1;
    xtz = X;
    for i=ndX:-1:1
        ztz = kron(ztz, Load{i}'*Load{i});
        xtz = innerProductAlongDim(i, Load{i}, xtz);
    end
else % Weighted approach
    Z = 1;
    for i=ndX:-1:1
        Z = kron(Z, Load{i});
    end
    ztz = bsxfun(@times,Z,Weights(:))'*Z;
    xtz=(X(notNanX(:)).*Weights(notNanX(:)))'*Z(notNanX(:),:);
end

if NonNeg
    G = fastnnls(ztz(:,:), xtz(:));
else
    G = pinv(ztz(:,:))*xtz(:);
end
G = reshape(G, Fac);

function p = innerProductAlongDim(i, Load, X)
sz = size(X);
ndX = numel(sz);
f = size(Load,2);
sz(i) = f;
p = zeros(sz);

idx = repmat({':'}, 1, ndX);
for j=1:f
    idx{i} = j;
    p(idx{:}) = sum(bsxfun(@times, X, shiftdim(Load(:,j), -i+1)), i);
end