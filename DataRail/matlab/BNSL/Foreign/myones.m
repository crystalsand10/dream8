function T = myones(sizes)
% MYONES Like the built-in ones, except myones(k) produces a k*1 vector instead of a k*k matrix,
% T = myones(sizes)


% disp('myones.m Before')
% whos

if length(sizes)==0
  T = 1;
elseif length(sizes)==1
%     index1 = round(sizes/2);
%     index2 = size(sizes);
%     
%     T1 = logical(ones(sizes(1:index1),1));
%     T2 = logical(ones(sizes(index1+1:index2),2));
%     
%     T = [T1 T2];
%     
    % only the line below was originally here, above added by Joel
  T = logical(ones(sizes, 1));
else
    
%      index1 = round(sizes/2);
%     index2 = size(sizes);
%     sizes1 = sizes(1:index1);
%     sizes2 = sizes(index1+1:index2);
%     
%     T1 = logical(ones(sizes1(:)'));
%     T2 = logical(ones(sizes2(:)'));
%     
%     T3 = [T1 T2];
%     disp('size modified T')
%     size(T3)
%     
    
    % only the line below was originally here, above added by Joel
      %T = logical(ones(sizes(:)'));
  
      

   T = true(sizes(:)');
%   disp('size original T')
%   size(T)
  
end

% disp('myones.m After')
% whos
%T = single(T);
%T
