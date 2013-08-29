function obj = set(obj, varargin)
while numel(varargin) >= 2
    propName = varargin{1};
    val = varargin{2};
    varargin = varargin(3:end);
    obj.(propName) = val;
end
