function [tFull,pFull,MeanFull,seed,press] = pcanipals_cross_validation(X,nGroups,cent,significanceCutoff,seed)

%% Default arguments
if ~exist('nGroups','var')
    nGroups = 7;
end
if ~exist('cent','var')
    cent = 0;
end
if ~exist('significanceCutoff','var')
    significanceCutoff = 0.9;
end
if ~exist('seed','var')
    seed = mod(floor(now*1e10),2^32);
end
rand('twister',seed);

[I,J]=size(X);
FacMax = min(I,J)-1;
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
%% Main loop
XOriginal = X;
warning('Not currently recentering/rescaling training data.');
[t,p,XTrain,XVal,XPred,pressi] = deal(cell(FacMax,nGroups));
[press,ss] = deal(zeros(FacMax,1));
for num_lv=1:FacMax
    % Results for each group
    for k=1:nGroups
        iValidate = find(groups==k);
        iTrain = find(groups~=k);
        % TODO: Recenter/rescale training data
        XTrain{num_lv,k} = X(iTrain,:);
        XVal{num_lv,k} = X(iValidate,:);
        % Train and validate using residuals
        [t{num_lv,k},p{num_lv,k},mean{num_lv,k}] = pcanipals(XTrain{num_lv,k},1,cent);
        % Validate
        XPred{num_lv,k} = XVal{num_lv,k} / p{num_lv,k} * p{num_lv,k};
        % Update press statistics
        pressi{num_lv,k} = nansum((XPred{num_lv,k}-XVal{num_lv,k}).^2, 2)';
    end % k
    % Calculate statistics
    press(num_lv) = nansum([pressi{num_lv,:}]);
    ss(num_lv) = nansum(X(:).^2);
    test = press(num_lv)./ss(num_lv);
    if (test > significanceCutoff)
        % Component is not significant
        break
    end
    disp(sprintf('Component %i is significant...', num_lv));
    % If significant, calculate full model & new Yres
    [T{num_lv},P{num_lv},Mean{num_lv}] = pcanipals(X,1,cent);
    X = X - T{num_lv}*P{num_lv};
end % num_lv
[tFull,pFull,MeanFull] = pcanipals(XOriginal,num_lv-1,cent);