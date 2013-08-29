function val = get(obj, propName)
if nargin == 1
    val = fieldnames(obj);
    return
end

try
    val = obj.(propName);
catch
    error('%s is not a valid nplsObj property.', propName);
end
