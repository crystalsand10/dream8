function [T,Z] = mk_stochastic(T)
% MK_STOCHASTIC Ensure the argument is a stochastic matrix, i.e., the sum over the last dimension is 1.
% [T,Z] = mk_stochastic(T)
%
% If T is a vector, it will sum to 1.
% If T is a matrix, each row will sum to 1.
% If T is a 3D array, then sum_k T(i,j,k) = 1 for all i,j.

% Set zeros to 1 before dividing
% This is valid since S(j) = 0 iff T(i,j) = 0 for all j


if (ndims(T)==2) & (size(T,1)==1 | size(T,2)==1) % isvector
  [T,Z] = normalise(T);
elseif ndims(T)==2 % matrix
  Z = sum(T,2); 
 % Z = single(Z);
  
  S = Z + (Z==0);
  %S = single(S);
  
  norm = repmat(S, 1, size(T,2));
  
  
  T = T ./ norm;
else % multi-dimensional array
 %   pwd
    
%     disp('mk_stochastic.m Before')
%     whos
    
  ns = size(T);
  T = reshape(T, prod(ns(1:end-1)), ns(end));
  Z = sum(T,2);
  Z = single(Z);
%   disp('size Z')
%   size(Z)
%   
  
  S = Z + (Z==0);
  S = uint8(S);
  
  norm = repmat(S, 1, ns(end));
  clear S
  
  norm = single(norm);
  %save figure_out_vars S T Z norm 
  
  T = T ./ norm;
  
  clear norm 
 % clear Z
  
  T = reshape(T, ns);
  
  
  %T = logical(T);
  
%   disp('size T')
%   size(T)
%   
%   
   disp('mk_stochastic.m After')
   whos
end
