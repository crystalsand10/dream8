function num = fn2num(fn)
% fn2num converts special field names to numbers
% num = fn2num(fn)
% fn is a string or cell of strings
% num is a number or array of numbers

switch class(fn)
    case 'char'
        if numel(fn) < 4 || ~strcmp(fn(1:3),'NUM')
            error('Not a num2fn generated fieldname!');
        end
        str = fn(4:end);
        % Replace '__' with '-'
        str = regexprep(str,'__','-');
        % Replace '_' with '.'
        str = regexprep(str,'_','.');
        num = str2num(str);
    case 'cell'
        n = numel(fn);
        num = nan(1,n);
        for i=1:n
            num(i) = fn2num(fn{i});
        end
    otherwise
        error('Not a num2fn generated fieldname!');
end