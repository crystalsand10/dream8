function h = remove(h, key)
% remove a value from a HashArray by key
idx = h.hash.get(key);
% Copy the hash!
h.hash = java.util.HashMap(h.hash);
h.hash.remove(key);
h.keys(idx) = [];
h.values(idx) = [];
