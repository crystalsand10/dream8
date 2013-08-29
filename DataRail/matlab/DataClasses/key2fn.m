function fn = key2fn(key)
% key2fn converts a key to a fieldname
if isnumeric(key)
    fn = num2fn(key);
else
    fn = key;
end
