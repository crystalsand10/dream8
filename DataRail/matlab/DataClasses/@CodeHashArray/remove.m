function h = remove(h, key)
% Can't remove a value from a CodeHashArray by key
error('CodeHashArray cannot be changed. Create a new CodeHashArray instead.')