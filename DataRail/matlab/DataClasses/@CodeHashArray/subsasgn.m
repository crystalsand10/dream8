function h = subsasgn(h, S, B)
% Can't subsasgn to a CodeHashArray
error('Can''t subsasgn to a CodeHashArray. Create a new object instead.');