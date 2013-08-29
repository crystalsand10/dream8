function [wloads,wkron] = Xtu(X,u,Missing,miss,J,DimX,ord);


% w=X'u
if Missing
    w = missXtu(X,u,miss,J);
else
   w=X'*u;
end

% Reshape to array
if length(DimX)>2
   w_reshaped=reshape(w,DimX(2),prod(DimX(3:length(DimX))));
else
   w_reshaped = w(:);
end


% Find one-comp decomposition
if length(DimX)==2
   wloads{1} = w_reshaped;
elseif length(DimX)==3&&~any(isnan(w_reshaped(:)))
   [w1,s,w2]=svd(w_reshaped,'econ');
   wloads{1}=w1(:,1);
   wloads{2}=w2(:,1);
else
   wloads=parafac(reshape(w_reshaped,DimX(2:length(DimX))),1,[0 2 0 0 NaN]');
   for j = 1:length(wloads);
      wloads{j} = wloads{j};
   end
end
for j=1:length(wloads)
    w_norm = norm(wloads{j});
    if w_norm == 0 || isnan(w_norm)
        warning('Invalid vector.');
        w_norm = 1;
    end
    wloads{j} = wloads{j}/w_norm;
end

% Apply sign convention
for i = 1:length(wloads)
   sq = (wloads{i}.^2).*sign(wloads{i});
%    wloads{i} = wloads{i}*sign(sum(sq));
   sum_sq = sum(sq);
   if sum_sq < 0
       wloads{i} = -wloads{i};
   end
end


% Unfold solution
if length(wloads)==1
   wkron = wloads{1};
else
   wkron = kron(wloads{end},wloads{end-1});
   for o = ord-3:-1:1
      wkron = kron(wkron,wloads{o});
   end
end