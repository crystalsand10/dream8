function sub = getsub(h, key)
% getsub gets the array subscript for a key of a HashArray
sub = h.hash.get(key);
if numel(sub) > 1
    warning('Duplicate keys found. Returning a list of all matching subscripts.');
end
