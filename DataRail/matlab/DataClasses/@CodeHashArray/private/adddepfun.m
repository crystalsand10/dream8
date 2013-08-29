function [finfo] = adddepfun(f)
% add dependent functions  to the CodeHashArray
[finfo1,path] = getfun(f);
file1 = finfo1.file;
if ~isempty(file1)
    list = mydepfun(file1);
    finfo = cell(numel(list), 1);
    for i=1:numel(list)
        finfo{i} = getfun(list{i},path);
    end
else
    finfo = {finfo1};
end

function list = mydepfun(file)
% Get dependent functions, excluding those in toolbox directory
toolboxdir = [matlabroot filesep 'toolbox'];
sz = numel(toolboxdir);
% Keep track of functions that I've already looked at
hList = java.util.HashSet;
% hList.add(file);
list = depfun(file, '-quiet', '-toponly');
while numel(list) > 0
    for i=numel(list):-1:1
        % Delete toolbox items or already looked up items
        if strcmp(toolboxdir, list{i}(1:sz)) || hList.contains(list{i})
            list(i) = [];
        end
    end
    % Get dependent functions for remaining items in list
    listNew = cell(1,numel(list));
    for i=1:numel(list)
        if ~hList.contains(list{i})
            hList.add(list{i});
            listNew{i} = depfun(list{i}, '-quiet', '-toponly');
        end
    end
    % Flatten the list of lists
    list = cat(1,listNew{:});
end
% Convert hList to cell string
javaList = hList.toArray;
n = numel(javaList);
list = cell(n,1);
for i=1:n
    list{i} = javaList(i);
end
1;