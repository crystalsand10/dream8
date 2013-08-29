%% function pcanipals
function [t,p,Mean] = pcanipals(X,F,cent)
% NIPALS-PCA WITH MISSING ELEMENTS
% 20-6-1999
%
% Calculates a NIPALS PCA model. Missing elements
% are denoted NaN. The solution is nested
%
% Comparison for data with missing elements
% NIPALS : Nested    , not least squares, not orthogonal solutoin
% LSPCA  : Non nested, least squares    , orthogonal solution
%
% I/O
% [t,p,Mean,Fit,RelFit] = pcanipals(X,F,cent);
%
% X   : Data with missing elements set to NaN
% F   : Number of componets
% cent: One if centering is to be included, else zero
%
% Copyright
% Rasmus Bro
% KVL 1999
% rb@kvl.dk
%

[I,J]=size(X);
isnanX = isnan(X);
if any(sum(isnanX)==I)||any(sum(isnanX,2)==J)
    error(' One column or row only contains missing')
end

% Xorig      = X;
% Miss       = isnan(X);
NotMiss    = ~isnan(X);

% ssX    = sum(X(NotMiss).^2);

Mean   = zeros(1,J);
if cent
    Mean    = nanmean(X);
end
X      = X - ones(I,1)*Mean;

t=zeros(I,F);
p=zeros(F,J);

for f=1:F
    it     = 0;

    T      = nanmean(X,2);
    P      = nanmean(X);
    Fit    = 2;
    FitOld = 3;

    while abs(Fit-FitOld)/FitOld>1e-7 && it < 1000;
        FitOld  = Fit;
        it      = it +1;

        for j = 1:J
            id=find(NotMiss(:,j));
            P(j) = T(id)'*X(id,j)/(T(id)'*T(id));
        end
        P = P/norm(P);

        for i = 1:I
            id=find(NotMiss(i,:));
            T(i) = P(id)*X(i,id)'/(P(id)*P(id)');
        end

        Fit = X-T*P;
        Fit = sum(Fit(NotMiss).^2);
    end
    t(:,f) = T;
    p(f,:) = P;
    X = X - T*P;
end

% Model   = t*p' + ones(I,1)*Mean;
% Fit     = sum(sum( (Xorig(find(NotMiss)) - Model(find(NotMiss))).^2));
% RelFit  = 100*(1-Fit/ssX);

