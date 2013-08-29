function obj = nplsObj(varargin)
%% nplsObj is an OO representation of an n-way PLSR analysis of data
%
% Contructors:
% * Method 1: No arguments; creates an empty data set.
% * Method 2: One argument, another nplsObj; creates a copy of the object.
% * Method 3: Two to four arguments (X,Y,Fac,show); see npls.m

showDefault = 1;
FacDefault = 2;
%% Method 1
if nargin == 0
    obj = struct('XOrig',[],'YOrig',[],'Fac',FacDefault,'show',showDefault);
    obj = class(obj, 'nplsObj');
    obj = class(obj, 'nplsObj');
    return
end

%% Method 2
if nargin == 1
    obj = varargin{1};
    assert2( isa(obj, 'nplsObj'), ...
        'nplsObj constructor expected a single nplsObj as its argument');
    return
end

%% Method 3
assert2( nargin >= 2 && nargin <= 4, 'Expecting at two to four input arguments.');
if nargin < 3
    varargin{3} = FacDefault;
end
if nargin < 4
    varargin{4} = showDefault;
end
obj = struct('XOrig',varargin{1},'YOrig',varargin{2},'Fac',varargin{3},'show',varargin{4});
obj = init(obj);
obj = class(obj, 'nplsObj');
return