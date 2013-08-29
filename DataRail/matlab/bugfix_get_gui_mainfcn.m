function fh = bugfix_get_gui_mainfcn()
% bugfix_get_gui_mainfcn returns a handle to GUIDE's gui_mainfcn
% This is uses as part of a bug fix for R2007b crashes
fh = @gui_mainfcn;