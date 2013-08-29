function value = subsref(object, s)
% GuiNotifier's subsref calls the notify function
if ~isscalar(s) || ~isequal(s.type, '()')
    error('DataRail:GuiNotifier:invalidCall', ...
        'Invalid call to subsref.');
end
notify(object, s.subs{:});