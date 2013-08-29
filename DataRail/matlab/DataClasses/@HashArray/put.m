function h = put(h, key, value)
% put a value into a HashArray
% Copy the hash!
h.hash = java.util.HashMap(h.hash);
if ~h.hash.containsKey(key)
    h.keys{end+1} = key;
    h.values{end+1} = value;
end
h.hash.put(key, value);