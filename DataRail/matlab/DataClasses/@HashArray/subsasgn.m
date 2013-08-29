function h = subsasgn(h, S, B)
% subsasgn assigns a value to a HashArray by subscript indexing
switch S.type
    case '.'
        if isempty(B)
            h = remove(h, S.subs(:));
        else
            h = put(h, S.subs(:), B);
        end
    case '()'
        if max(S.subs{:}) > numel(h.values)
            error('Can''t extend a HashArray using subscripts.')
        end
        if isempty(B)
            h = remove(h, h.keys{S.Subs{:}});
        else
            h.values(S.subs{:}) = B;
        end
    otherwise
        error('Unsupported indexing');
end
