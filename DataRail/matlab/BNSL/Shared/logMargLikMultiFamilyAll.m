function LM = logMargLikMultiFamilyAll(data, nodeArity, impossibleFamilyMask, priorESS, intervention, verbose )
% Compute log p(x(i)|X(Gi))) for all nodes i and possible parents Gi
%
% data(cases m, nodes i)
% clamped(m, i) = 1 if node i is set by intervention in case m
% sz = num states for nodes 1:N
% alpha = Dirichlet hyper param [default 1]
%
%
% LM(i,u) = log p(x(i) | x(u)) for each possible parent set u
% LM(i,u) = 0 if u contains i
%

% disp('logmarklik step 0')
% size(data)
% pause
data = double(data);

nNodes = size(data,1);

assert(nNodes==length(nodeArity));

alpha = priorESS;

LM = -Inf*ones(nNodes, 2^nNodes);

%LM = single(LM);

uncertainPerfectFlag = strcmp(intervention.type,'uncertainPerfect');

%whos

% cache the priors IF all the arities are the same
global priorCache; priorCache = {};
global gammalnPriorCache; gammalnPriorCache = {};


% This section below (lines 48-72) was commented out by Joel because it was
% causing Out of Memory crashes because when calculating the prior it does
% not account for the MaxFanIn constraint, and thus ends up calculating
% very high dimensional matrices (e.g., (nNode-1)-dimensional, or
% 15-dimensional arrays for a 16-node network) which exhaust all the memory.
% Instead of using the code below, it now simply calculates the prior for
% each local interaction (while obeying the MaxFanIn constraint) in the
% logMargLikMultiFamily.m file. The code below runs out of memory
% only for arity > 3 for a 16-node
% network, but did not run out of memory for arity <= 3. The results using
% the method below were compared to the method in local method found in
% logMargLikMultiFamily.m and were found to give the same resultant
% adjacency matrix. The local method is slower than this method, but the
% below method is only applicable (even if it didn't crash bc of memory)
% when the nodes all have the same arity.   Joel Wagner July 9 2009

do_crash = 0;
if do_crash == 1
    if all(nodeArity==nodeArity(1))
        priorCache = cell(1, nNodes);
        gammalnPriorCache = cell(2, nNodes);

        %         disp('logmarklik step 1')
        %     pause

        for pi=1:nNodes
            
            %
            %                      disp('******* logMargLikMultiFamilyAll.m whos global')
            %                  whos global

            priorCache{pi} = (alpha/prod(nodeArity(1:(pi-1)))) *  mk_stochastic(myones(nodeArity(1:pi)));

            disp('logMargLikMultiFamilyAll.m whos before')
            whos
            priorCache{pi} = single(priorCache{pi});

            %                      disp('size priorcache{pi}')
            %                      size(priorCache{pi})
            gammalnPriorCache{1,pi} = gammaln(priorCache{pi});
            gammalnPriorCache{2,pi} = gammaln(sum(priorCache{pi},pi));

            disp('logMargLikMultiFamilyAll.m whos after')
            whos


        end
    end
end

% disp('logmarklik step 2')
%     pause

% make an AD Tree to cache all the sufficient statistics
isClamped = true;
if sum(intervention.clampedMask(:))==0 && ~uncertainPerfectFlag

    %         disp('logmarklik step 2.4')
    %         whos
    %         data
    %         nodeArity
    %     pause

    % IT WAS FAILING (CRASHING MATLAB) IN THE .MEX FILE HERE BECAUSE THE
    % INPUT DATA (NAMED data) WAS IN single FORMAT!!! FOR THE .MEX FILES TO
    % WORK PROPERLY, THE INPUT VARIABLES MUST BE DOUBLE!!!  Joel Aug. 11 09
    unclampedADTreePtr = mkADTree( data', nodeArity );
    clampedADTreePtr = [];
    isClamped = false;
end

% whos
% pause
%
% isClamped

for i=1:nNodes
    %     disp('logmarklik step 2.5')
    %     pause

    possibleFamilies = find(impossibleFamilyMask(i,:)==1);

    if isClamped && ~uncertainPerfectFlag
        unclampedData = data(:, intervention.clampedMask(i,:)==0 );
        unclampedADTreePtr = mkADTree( unclampedData', nodeArity, 0 );

        if ~strcmp(intervention.type, 'perfect')
            clampedInds = intervention.clampedMask(i,:)~=0;
            clampedData = data(:, clampedInds );

            if strcmp(intervention.type, 'soft')
                uniqueTargets = unique(intervention.softTarget(i,clampedInds));
                intervention.softUniqueTargets = uniqueTargets;

                % one AD tree per "push targetr"
                % currently the max no. of AD trees is 5, simply increase
                % this in util.h under folder ADTree and re-mex to increase as
                % needed
                if length(uniqueTargets)>(maxNumADTrees()-1) % one ad tree is already in use for the unclamped data
                    error('Maximum number of concurrent AD Trees is currently %i, but %i are needed', maxNumADTrees(), length(uniqueTargets)+1);
                end

                clampedADTreePtr = uint32(zeros(1,length(uniqueTargets)));
                for vi=1:length(uniqueTargets)
                    clampedADTreePtr(vi) = mkADTree( clampedData(:, intervention.softTarget(i,clampedInds)==uniqueTargets(vi))', nodeArity, 0+vi);
                end

            elseif strcmp(intervention.type, 'imperfect')
                clampedADTreePtr = mkADTree( clampedData', nodeArity, 1 );
            else
                error('unknown intervention type');
            end
        else
            clampedData = [];
            clampedADTreePtr = [];
        end
    end
    %  disp('logmarklik step 2.7')
    %     pause

    baseMask = intervention.clampedMask(i,:);
    %
    %     disp('logmarklik step 3')
    %     pause

    for k = possibleFamilies
        pa = find(bitget(k-1,1:nNodes));

        if uncertainPerfectFlag
            interventionPa = intersect(pa, intervention.uncertainNodes);
            for pai=interventionPa
                baseMask( data(pai,:)== 2 ) = baseMask( data(pai,:)== 2 ) + 1; % increment to detect if more than one intervention parent is active
            end

            if any(baseMask)>1,
                error(['To use uncertain perfect interventions, if more than one intervention parent is ' ...
                    ' allowed then those parents should never be on simultaneously for a data case']);
            end

            clampedData = data(:, baseMask==1 );
            unclampedData = data(:, baseMask==0 );

            baseMask(:)=0;

            LM(i,k) = logMargLikMultiFamilySlow(unclampedData, clampedData, pa, i, nodeArity, alpha, intervention);

        else % easy/fast case

            %             disp('logmarklik step 4')
            %     pause

            LM(i,k) = logMargLikMultiFamily(pa, i, nodeArity, alpha, intervention, unclampedADTreePtr, clampedADTreePtr);

        end

    end

    if verbose
        fprintf('Node %i/%i\n', i, nNodes);
    end
end

LM = double(LM);

%clear priorCache;

