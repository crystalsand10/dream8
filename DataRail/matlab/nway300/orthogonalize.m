function W = orthogonalize(W)
% orthogonalize a set of vectors using the modified Gram-Schmidt algorithm
for i=2:size(W,2)
    for j=1:i-1
        W(:,i) = W(:,i) - W(:,j)'*W(:,i)*W(:,j)/(W(:,j)'*W(:,j));
    end
end
end % function orthogonalize
