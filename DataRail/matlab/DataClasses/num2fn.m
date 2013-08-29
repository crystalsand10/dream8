function fn = num2fn(num)
% num2fn converts numbers to valid structure fieldnames
% fn = num2fn(num)
% num is a number or array of numbers
% fn is a string or cell of strings

switch numel(num)
    case 0
        fn = {};
    case 1
        str = num2str(num);
        % Replace '.' with '_'
        str = regexprep(str,'\.','_');
        % Delete '+'
        str = regexprep(str,'\+','');
        % Replace '-' with '__';
        str = regexprep(str,'-','__');
        fn = ['NUM',str];
    otherwise
        n = numel(num);
        fn = cell(1,n);
        for i=1:n
            fn{i} = num2fn(num(i));
        end
end