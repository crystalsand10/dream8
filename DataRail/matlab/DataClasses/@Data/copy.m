function d2 = copy(d1)
% copy a Data object
d2 = d1;
d2.labels = HashArray(d1.labels);
d2.code = HashArray(d2.code);
d2.params = HashArray(d2.params);