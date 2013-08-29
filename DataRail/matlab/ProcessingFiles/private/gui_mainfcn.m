function  varargout = gui_mainfcn(varargin)
% gui_mainfcn protects against crashes in R2007b

persistent original_gui_mainfcn is_buggy

if isempty(original_gui_mainfcn)
    original_gui_mainfcn = bugfix_get_gui_mainfcn;
    is_buggy = strmatch('7.5', version);
    if is_buggy
        warning('DataRail:BugFix', 'Due to bugs in Matlab 7.5, debugging will be disabled during GUI functions to prevent crashes.')
    else
        is_buggy = 0;
    end
end

if is_buggy
%     % store dbstatus
%     old_status = dbstatus;            
%     % disable breaks
%     new_status = old_status;
%     for i=numel(new_status):-1:1
%         if strcmpi(new_status(i).cond, 'error')
%             new_status(i) = [];
%         end
%     end
%     dbstop(new_status);
    % wrap dispatch in try/catch
    try
        [varargout{1:nargout}] = original_gui_mainfcn(varargin{:});
    catch
        % errors
        warning('DataRail:ErrorTrap', 'An error was trapped to prevent a Matlab crash.');
        e = lasterror;
        disp(sprintf('??? %s ???', e.message));
        for i=1:numel(e.stack)
            link = sprintf('<a href="matlab:opentoline(urldecode(''%s''),%d)">%s</a>', ...
                urlencode(e.stack(i).file), e.stack(i).line, e.stack(i).name);
            disp(sprintf('Error in ==> %s at %d', link, e.stack(i).line));
        end
    end
%     % restore dbstatus
%     dbstop(old_status);
else
    [varargout{1:nargout}] = original_gui_mainfcn(varargin{:});
end