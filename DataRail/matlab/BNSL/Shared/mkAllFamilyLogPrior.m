function rho = mkAllFamilyLogPrior(nNodes, varargin)
% maxFanIn
% set rho(i,Gi) = 1/ nchoosek(N-1, |Gi|) or 0 if Gi contains i or is bigger than maxFanIn

[maxFanIn, layer, priorType, doSparse] = process_options(varargin, 'maxFanIn', nNodes-1, ...
    'nodeLayering', ones(nNodes,1), 'priorType', 'nchoosek', 'doSparse', false);


% disp('In rho')
% maxFanIn
% nNodes
%disp('step 1')

do_original = 1;

if do_original == 1
    % This single line below was the original line
    impossibleFamilyMask = mkImpossibleFamilyMask(nNodes, maxFanIn, layer);

%     figure;
%     imagesc(impossibleFamilyMask)
   
    %
    %  figure;
    %  imagesc(impossibleFamilyMask)
    %  title('impossibleFamilyMask')
%disp('step 2')
else
    %*************
    % This section added by Joel

    impossibleFamilyMask = zeros(nNodes,2^nNodes);

    % impossibleFamilyMask = false(nNodes,2^nNodes);

    nodes_per_layer = nNodes/2;
    %
    % %ind1 = 2^nodes_per_layer + 1;
    %
    impossibleFamilyMask(nodes_per_layer+1:nNodes,1:2^nodes_per_layer) = 1;
    %
    % % figure;
    % % colormap('hot')
    % % imagesc(impossibleFamilyMask)
    % % grid on
    %
    % impossibleFamilyMask = logical(impossibleFamilyMask);
    %
    %*************
end


if doSparse
    rho = sparse( nNodes, 2^nNodes );
else
    rho = repmat(-Inf, nNodes, 2^nNodes);
end

%disp('step 3')

logNchoosekPre = zeros(1, max(maxFanIn(:))+1 );
for k=0:max(maxFanIn(:))
    logNchoosekPre(k+1) = log(1/nchoosek(nNodes-1, k));
end

for ni=1:nNodes
    possibleFamilies = impossibleFamilyMask(ni,:);

%          figure(3)
%          imagesc(possibleFamilies)
%          title(strcat('possibleFamilies',num2str(ni)))

    switch(priorType)
        case 'nchoosek'
            for ui=find(possibleFamilies)  % returns a vector of the indeces containing ones in possibleFamilies
                              %   ui
                %                 disp('ui-1')
                %                 ui-1
                %                 disp('bitget(ui-1, 1:nNodes)')
                %                 bitget(ui-1, 1:nNodes)  %  BITGET(A,BIT) returns the value of the bit at position BIT in A

                sz = sum( bitget(ui-1, 1:nNodes) );
                %rho(ni, ui) = log(1/nchoosek(nNodes-1, sz)); % JMLR p554
                %pwd
                rho(ni, ui) = logNchoosekPre(sz+1); % JMLR p554
            end
        case 'flat'
            rho(ni, possibleFamilies) = log(1);
        otherwise
            error('Unknown family prior type: %s', priorType);
    end
end