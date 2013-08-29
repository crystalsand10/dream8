function [] = notify(object, output)
% notify GuiNotifier of output

% setOnNotify
if ~isempty(object.setOnNotify)
    for i=1:2:numel(object.setOnNotify)
        try
            set(object.setOnNotify{i}, object.setOnNotify{i+1}, output);
        catch
        end
    end
end
% handlesField
try
    handles = guidata(object.figure);
    if ~isempty(object.handlesField)
        handles.(object.handlesField) = output;
        guidata(object.figure, handles);
    end
catch
    handles = [];
end

% notifyFunc
if ~isempty(object.notifyFunc)
    eventdata = [];
    object.notifyFunc(object.figure, eventdata, handles, output);
end
% autoHide
if object.autoHide
    set(object.figure, 'Visible', 'on');
end
% timer
if ~isempty(object.timer) && isvalid(object.timer)
%     disp('Stopping and deleting timer');
    stop(object.timer);
    delete(object.timer);
end