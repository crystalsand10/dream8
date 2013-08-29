function display(h,varargin)
% display a HashArray structure
if nargin == 1
    disp([class(h) ':']);
elseif nargin == 2
    name = varargin{1};
    disp(sprintf('HashArray %s:', name));
end
s = struct('Index',[],'Key',[],'Value',[]);
for i=1:numel(h.values)
    s.Index = i;
    s.Key = h.keys{i};
    s.Value = h.values{i};
    disp(s);
end
