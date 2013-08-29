function code = CodeHashArray(f)
% CodeHashArray constructor
% code = CodeHashArray(f) where f is either
% * a function handle;
% * an inline function object;
% * a string referring to a function; or
% * the text of a function

code = struct;
if nargin == 0
    f = '';
end
if isa(f, 'CodeHashArray')
    % % Must create copy of HashArray
    % hash = HashArray(f.hash);
    % code = class(code, 'CodeHashArray', h);
    % return

    % Don't need to copy if I make the hash unchangeable
    code = f;
end
if isempty(f)
    finfo = {};
else
    finfo = adddepfun(f);
end
nfunc = numel(finfo);
fname = cell(nfunc,1);
for i=1:nfunc
    fname{i} = finfo{i}.file; % Use "file" as key, since it should be unique
end
hash = HashArray(fname, finfo);
code = class(code,'CodeHashArray',hash);