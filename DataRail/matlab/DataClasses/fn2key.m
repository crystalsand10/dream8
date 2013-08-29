function key = fn2key(fn)
% fn2key converts fieldname to a key
if numel(fn) < 3 || ~strcmp(fn(1:3),'NUM')
    key = fn;
else
    key = fn2num(fn);
end
