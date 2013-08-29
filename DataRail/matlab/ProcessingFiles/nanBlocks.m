function [blocks, iStart, iEnd] = nanBlocks(data)
% NANBLOCKS identifies blocks of NaN's in a multi-dimensional array
%
% [blocks, iStart, iEnd] = nanBlocks(data)
%
% INPUTS:
%   data = multidimensional array of data
%
% OUTPUTS:
%   blocks = cell array, each element is a list of subscripts for blocks of
%            NaN's, e.g. data(blocks{1}{:}) is the first block of NaN's
%   iStart = 2D array of starting subscripts for blocks. Each row is a 
%            different block, and each subscript a different dimension. For
%            example, iStart(1,:) are the subscripts of the first NaN of 
%            the first block.
%   iEnd   = 2D array of ending subscripts for blocks. Each row is a 
%            different block, and each subscript a different dimension. For
%            example, iEnd(1,:) are the subscripts of the last NaN of the 
%            first block.

%% Initialization
check = double(isnan(data));
% check is 0 if not a NaN, 1 if a NaN (and not in a block), and 
% 2 if a NaN and part of a block
sz = size(check);
nd = numel(sz);
sub = cell(size(sz));
blocks = {};
%% Identify blocks
% Check each element
for i=1:numel(check)
    % Look for NaN's that are not yet part of a block
    if check(i) == 1
        % Start a new block
        [sub{:}] = ind2sub(sz, i);
        % Increase the block size along each dimension
        for dim=1:nd
            while 1
                jOld = sub{dim};
                jNew = jOld(1):jOld(end)+1;
                if jNew(end) > sz(dim)
                    % Can't increase past the size of the dimension!
                    break
                end
                subNew = sub;
                subNew{dim} = jNew;
                checkNew = check(subNew{:});
                if all(checkNew(:)==1)
                    sub = subNew;
                else
                    break
                end
            end
        end
        % Update check for these elements to note that they are now part of
        % a block
        check(sub{:}) = 2;
        % Store this block's subscripts
        blocks{end+1} = sub;
    end
end
%% Determine iStart and iEnd
nBlocks = numel(blocks);
iStart = zeros(nBlocks,nd);
iEnd = iStart;
for i=1:nBlocks
    for j=1:nd
        iStart(i,j) = blocks{i}{j}(1);
        iEnd(i,j) = blocks{i}{j}(end);
    end
end