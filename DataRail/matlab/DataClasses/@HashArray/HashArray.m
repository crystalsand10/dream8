function h = HashArray(keys, values)
% HashArray is a constructor for a Hash/Array object
% h = HashArray(keys, values)
%    keys = 1D cell/array of keys
%    values = 1D cell/array of values

ClassName = 'HashArray';
switch nargin
    case 0
        keys = {};
        values = {};
    case 1
        if isa(keys, ClassName)
            h = keys;
            % Copy the hash!
            h.hash = java.util.HashMap(h.hash);          
            return
        else
            error('Wrong argument type');
        end
    case 2
        if length(keys) ~= length(values)
            error('Number of keys must match number of values');
        end
        if isnumeric(keys)
            keys = num2cell(keys);
        end
        if isnumeric(values)
            values = num2cell(values);
        end
    otherwise
        error('Wrong number of arguments, USAGE: h = HashArray(keys, values)');
end

% Look for duplicate keys
countHash = java.util.HashMap;
for i=1:numel(keys)
    if countHash.containsKey(keys{i})
        count = countHash.get(keys{i}) + 1;
    else
        count = 1;
    end
    countHash.put(keys{i}, count);
end

hash = java.util.HashMap;
for i=1:numel(keys)
    if countHash.get(keys{i}) > 1
        % Duplicate keys! See if we've set any fields
        if hash.containsKey(keys{i})
            value = hash.get(keys{i});
        else
            warning('Duplicate keys found. Indexing by key will return a cell of values.')
            value = [];
        end
        value(end+1) = i;
        hash.put(keys{i}, value);
    else
        hash.put(keys{i}, i);
    end
end
h = struct('hash',{hash}, 'keys',{keys}, 'values',{values});
h = class(h, ClassName);