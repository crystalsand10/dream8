function varargout = subsref(h, S)
% subsref gets a value from a HashArray by subscript indexing
switch S.type
    case '.'
        value = get(h, S.subs);
    case '()'
        value = h.values{S.subs{:}};
    otherwise
        error('Unsupported indexing');
end
% This work-around fixes a bug in release R2007a
varargout = cell(1,nargout);
varargout{1} = value;