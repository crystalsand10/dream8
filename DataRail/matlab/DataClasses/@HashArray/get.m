function value = get(h, key)
% get a value from a HashArray by key
idx = h.hash.get(key);
nIdx = numel(idx);
if nIdx == 0
    warning('Key not in HashArray.');
    value = [];
    return
elseif nIdx > 1
    warning('Duplicate keys found. Returning cell of all matching values.');
    value = h.values(idx);
else
    value = h.values{idx};
end

