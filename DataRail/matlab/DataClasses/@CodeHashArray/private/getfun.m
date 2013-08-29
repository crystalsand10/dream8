function [finfo,pathvar] = getfun(f,pathvar)
% Takes a function name (string) or handle and returns a structure
% containing:
%
% function  The name of the function
% file      The relative path and M-file (relative to some directory in
%            the path)
% mfile     The actual text of the file
% 
% An optional pathvar may be included as a second input or output to speed
% up searching through the path.
%
% Created by Arthur Goldsipe <goldsipe@alum.mit.edu> on July 22, 2007

finfo = struct('function','', 'file', '', 'mfile', '');

% Define path, if not an argument
if ~exist('pathvar','var')
    path_string = path;
    i = [0, find(path_string==pathsep), numel(path_string)+1];
    pathvar = cell(numel(i),1);
    pathvar{1} = '.';
    for j=1:numel(i)-1
        pathvar{j+1} = path_string(i(j)+1:i(j+1)-1);
    end
    % paths may be relative
    % convert to absolute paths
    for j=1:numel(pathvar)
        if pathvar{j}(1) == '.'
            cwd = pwd;
            cd(pathvar{j});
            pathvar{j} = pwd;
            cd(cwd);
        end
    end
end

if isa(f, 'function_handle')
    finfo1 = functions(f);
    finfo.function = finfo1.function;
    finfo.file = finfo1.file;
%     finfo.fhandle = f;
    % Special case: handle anonymous functions
    if strcmp(finfo1.type, 'anonymous')
        finfo.mfile = finfo1.workspace;
        return
    end
elseif isa(f, 'char')
    file = which(f);
    if isempty(file)
        %error('Unknown function: %s', f);
    elseif ~strcmp(file,f)
        finfo.function = f;
    else
        % See if mfile is in path
        idx = find(f==filesep);
        if ~isempty(idx)
            mfile = f(idx(end)+1:end);
        else
            mfile = f;
        end
        % Delete .m suffix, if present
        if strcmpi(mfile(end-1:end), '.m')
            mfile(end-1:end) = [];
        end
        finfo.function = mfile;
    end
    finfo.file = file;
%     finfo.fhandle = str2func(finfo.function);
else
    error('Invalid function handle');
end

% Translate file to relative location in path
if isempty(finfo.file)
    warning('No file found for function %s', finfo.function);
    return
end
file = finfo.file;
this_path = fileparts(file);
matches = cellfun(...
    @(x)( strncmp(x, this_path, numel(x)) ), ...
    pathvar);
switch sum(matches)
    case 0
        % No matches found
        path_length = 0;
    case 1
        % 1 match found
        path_length = numel(pathvar{find(matches)});
    otherwise
        % Multiple matches found; choose longest length path
        pathMatches = pathvar(find(matches));
        path_lengths = cellfun(@numel, pathMatches);
        path_length = max(path_lengths);
end
if file(path_length+1) == filesep
    rel_file = file(path_length+2:end);
    finfo.file = rel_file;
elseif path_length > 0
    rel_file = file(path_length+1:end);
    finfo.file = rel_file;
end

% Grab M-File
if isempty(file)
    % Could be an anonymous function, some built-ins, or an invalid
    % function...
    mfile = '';
else
    % Probably a valid function name, unless it contains "built-in"
    if strfind(file, 'built-in')
        mfile = '';
    else
        mfile = evalc(['type ( ''' file ''' )']);
    end
end
finfo.mfile = mfile;