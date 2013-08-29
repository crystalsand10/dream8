function [] = display(d, varargin)
if nargin > 1
    name = varargin{1};
else
    name = d.name;
end
disp(sprintf([class(d) ' Object %s:'],name));
s = struct(d);
disp(s);
fn = fieldnames(s);
for i=1:numel(fn)
    if isa(s.(fn{i}), 'HashArray')
        str = evalc('display(s.(fn{i}),fn{i})');
        disp(str);
    end
end

