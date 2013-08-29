function w = missXtu(X,u,miss,J)
w = zeros(J,1);
for i=1:J
    m = find(miss(:,i));
    if (u(m)'*u(m))~=0
        ww=X(m,i)'*u(m)/(u(m)'*u(m));
    else
        ww=X(m,i)'*u(m);
    end
    if isempty(ww)
        w(i)=0;
    else
        w(i)=ww;
    end
end