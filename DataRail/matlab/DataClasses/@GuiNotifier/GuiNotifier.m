function object = GuiNotifier(varargin)
% GuiNotifier shares data between two GUIs
%
% Parameters may be passed as a structure or as name/value pairs
%
% Parameters:
% figure      Handle to figure (or child UI) element to notify
% notifyFunc  Function to call upon notification; inputs to function are
%             hObject (figure handle), eventdata (empty), handles, and
%             output (from Child GUI)
% setOnNotify A cell containing pairs of HG handles and properties to set
%             to the Child GUI's output upon notification
% handlesField Field to set in guihandles variable
% autoHide    logical variable, indicated whether to hide the figure 
%             and unhide it upon notification
%
% Example usage:
%
% GuiNotifier('figure', handles.figure1, 'notifyFunc', @updateGui, ...
%              'setOnNotify', {handles.edit1, 'String'});
if nargin == 0
    error('DataRail:GuiNotifier:invalidCall', ...
        'Invalid call to GuiNotifier.')
elseif nargin == 1 && isa(varargin{1}, 'GuiNotifier')
    object = varargin{1};
    return
end

% Default object
object = struct(...
    'figure', [],...
    'notifyFunc', [],...
    'handlesField', [],...
    'setOnNotify', [], ...
    'autoHide', true,...
    'timer',[]);

% Process single structure argument
if nargin == 1 && isstruct(varargin{1}) && isscalar(varargin{1})
    params = varargin{1};
    fn = fieldnames(params);
    for i=1:numel(fn)
        if isfield(object, fn{i});
            object.(fn{i}) = params.(fn{i});
        else
            error('DataRail:GuiNotifier:invalidParameter', ...
                '"%s" is not a valid parameter.', fn{i});
        end
    end
% Process argument pairs
elseif mod(nargin,2)==0
    for i=1:2:nargin
        if ~ischar(varargin{i})
            error('DataRail:GuiNotifier:invalidParameter', ...
                ['Arguments must be supplied as string/value pairs. '...
                'Argument %d is not a string.'], i);
        elseif ~isfield(object, varargin{i})
            error('DataRail:GuiNotifier:invalidParameter', ...
                '"%s" is not a valid parameter.', fn{i});
        else
            object.(varargin{i}) = varargin{i+1};
        end
    end
else
    error('DataRail:GuiNotifier:invalidCall', ...
        'Invalid call to GuiNotifier.')
end

% Validate arguments
if ~isempty(object.figure) && ~ishandle(object.figure)
    error('DataRail:GuiNotifier:invalidParameter', ...
        'The figure parameter is not a valid figure handle.');
elseif ~isempty(object.notifyFunc) && ~isa(object.notifyFunc, 'function_handle')
    error('DataRail:GuiNotifier:invalidParameter', ...
        'The notifyFunc parameter is not a valid function handle.');
elseif ~isempty(object.setOnNotify)
    if ~iscell(object.setOnNotify) || mod(numel(object.setOnNotify),2) ~= 0
        error('DataRail:GuiNotifier:invalidParameter', ...
            'The setOnNotify parameter must be a cell of HG handle/property pairs.');
    elseif ~isvector(object.setOnNotify)
        error('DataRail:GuiNotifier:invalidParameter', ...
            'The setOnNotify parameter was not a cell vector.');
    end
    for i=1:2:numel(object.setOnNotify)
        if ~ishandle(object.setOnNotify{i})
            error('DataRail:GuiNotifier:invalidParameter', ...
                'setOnNotify parameter #%d is not a valid HG handle.', i);
        end
        try
            get(object.setOnNotify{i}, object.setOnNotify{i+1});
        catch
            error('DataRail:GuiNotifier:invalidParameter', ...
                'setOnNotify parameter #%d is not a valid HG property.', i+1);
        end
    end
elseif ~isempty(object.handlesField) && ~isvarname(object.handlesField)
    error('DataRail:GuiNotifier:invalidParameter', ...
        'The handlesField must be a valid structure field name.');
elseif ~isscalar(object.autoHide)
    error('DataRail:GuiNotifier:invalidParameter', ...
        'The autoHide parameter must be a logical scalar.');
elseif ~islogical(object.autoHide)
    try
        object.autoHide = logical(object.autoHide);
    catch
        error('DataRail:GuiNotifier:invalidParameter', ...
            'The autoHide parameter could not be converted to a logical scalar.');
    end
end

% Set handles.figure to parent figure of UI element
while ~isempty(get(object.figure, 'Type')) && ~strcmpi(get(object.figure, 'Type'), 'figure')
    object.figure = get(object.figure, 'Parent');
end

if object.autoHide && ~isempty(object.figure)
    set(object.figure, 'Visible', 'off');
    % Create emergency timer object to unhide if there are problems
%     disp('Starting a timer');
    object.timer = timer('Period', 1, 'ExecutionMode', 'FixedSpacing', ...
        'TimerFcn', {@emergencyUnhide, object}, ...
        'UserData', struct(...
            'InitialHandles', getChildren(), ...
            'figure', object.figure, ...
            'ChildGui', []));
    start(object.timer);
end
object = class(object, 'GuiNotifier');
end

function emergencyUnhide(timer, event, notifer)
% Monitor list of handles to:
%  try to identify child GUI
%  unhide GUI once the child is deleted
% disp('Running TimerFunc');

% First, see if figure still exists, and delete timer if it doesn't
UserData = get(timer, 'UserData');
if ~ishandle(UserData.figure)
    disp('Deleting timer because figure no longer exists.')
    stop(timer);
    delete(timer);
    return
end
if isempty(UserData.ChildGui)
    children = getChildren();
    UserData.ChildGui = setdiff(children, UserData.InitialHandles);
    set(timer, 'UserData', UserData);
elseif ~all(ishandle(UserData.ChildGui)) && ...
        strcmp('off', get(UserData.figure, 'Visible'))
    % ChildGui has been deleted! Unhide gui and stop timer
    % notify(notifier);
    set(UserData.figure, 'Visible', 'on');
    warning('A GUI appears to have been accidentally hidden. Redisplaying it now.');
%     disp('Stopping and deleting timer');
    stop(timer);
    delete(timer)
end
end

function children = getChildren()
oldStatus = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'on');
children = get(0, 'Children');
set(0, 'ShowHiddenHandles', oldStatus);
end