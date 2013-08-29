function [] = deleteAllFigures()
% deleteAllFigures deletes all figures, even hidden ones

status = get(0, 'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
set(get(0,'Children'),'Visible','on');
set(0, 'ShowHiddenHandles', status);