function [] = deleteAllFigures()
% deleteAllFigures deletes all figures, even hidden ones

status = get(0, 'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
delete(get(0,'Children'));
set(0, 'ShowHiddenHandles', status);