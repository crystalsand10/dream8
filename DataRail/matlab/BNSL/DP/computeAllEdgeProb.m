function [prob Z] = computeAllEdgeProb( allFamilyLogPrior, allFamilyLogMargLik )
global nNodes;


%**********
% It seems that converting to single format with variables that are
% computed in .mex files causes MATLAB to crash!

[nNodes] = size(allFamilyLogMargLik, 1); % set it once. used to determine no. of bits used for set/element ops

warning('off','MATLAB:log:logOfZero');

[alpha beta] = mkAlphaBeta(allFamilyLogPrior, allFamilyLogMargLik );

% figure;
% imagesc(alpha)
% title('alpha')
% 
% figure;
% imagesc(beta)
% title('beta')

clear allFamilyLogPrior
clear allFamilyLogMargLik

% alpha = single(alpha);
% beta = single(beta);

left = mkLeft(alpha');
right = mkRight(alpha');

clear alpha

Z = left(end); % normalization constant

mask0 = zeros(nNodes,2^nNodes);
for v=1:nNodes
	mask0(v, 2^(v-1)+1 ) = 1;
	mask0(v, :) = fumt(mask0(v, :));
end

%mask0 = single(mask0);

gamma = mkGamma(left, right);
%gamma = single(gamma);

prob = repmat(-Inf,[nNodes nNodes]);

for v=1:nNodes
	maskv = ~(mask0(v,:)>0); % none of the sets containing v
	for u=1:nNodes
		if u==v, continue; end
        
        mask = find(maskv&mask0(u,:));
        pxe = logadd_sum( beta(v,mask) + gamma(v,mask) );
                
		prob(u,v) = pxe;
	end
end

clear left 
clear right
clear beta

warning('on','MATLAB:log:logOfZero');

prob = exp(prob - Z);
%whos 