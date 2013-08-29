function [Xfactors,Yfactors,Core,B,ypred,ssx,ssy,reg,xmodel,processing,R2Y] = npls(X0,Y0,Fac,show,inProcessing);

%NPLS multilinear partial least squares regression
%
% See also:
% 'parafac' 'tucker'
%
%
% MULTILINEAR PLS  -  N-PLS
%
% INPUT
% X        Array of independent variables
% Y        Array of dependent variables
% Fac      Number of factors to compute
% show     If set to 1, display outputs
% processing is a 1 or 2 element structure of pre-processing parameters (see nprocess)
%             If 1 element in structure, processing applies to both X and Y
%             If 2 elements in structure, first applies to X, second to Y
% 
% OPTIONAL
% show	   If show = NaN, no outputs are given
%
%
% OUTPUT
% Xfactors Holds the components of the model of X in a cell array.
%          Use fac2let to convert the parameters to scores and
%          weight matrices. I.e., for a three-way array do
%          [T,Wj,Wk]=fac2let(Xfactors);
% Yfactors Similar to Xfactors but for Y
% Core     Core array used for calculating the model of X
% B        The regression coefficients from which the scores in
%          the Y-space are estimated from the scores in the X-
%          space (U = TB);
% ypred    The predicted values of Y for one to Fac components
%          (array with dimension Fac in the last mode)
% ssx      Variation explained in the X-space.
%          ssx(f+1,1) is the sum-squared residual after first f factors.
%          ssx(f+1,2) is the percentage explained by first f factors.
% ssy      As above for the Y-space
% reg      Cell array with regression coefficients for raw (preprocessed) X
% xmodel   The predicted values of X for one to Fac components
%          (array with dimension Fac in the last mode)
% processing With mean and std. dev. stored (for use with npred)
%
%
% AUXILIARY
%
% If missing elements occur these must be represented by NaN.
%
%
% [Xfactors,Yfactors,Core,B,xmodel,ypred,ssx,ssy,reg] = npls(X,y,Fac);
% or short
% [Xfactors,Yfactors,Core,B] = npls(X,y,Fac);
%

% Copyright (C) 1995-2006  Rasmus Bro & Claus Andersson
% Copenhagen University, DK-1958 Frederiksberg, Denmark, rb@LIFe.ku.dk
%
% This program is free software; you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free Software 
% Foundation; either version 2 of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with 
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin 
% Street, Fifth Floor, Boston, MA  02110-1301, USA.


% $ Version 1.02 $ Date July 1998 $ Not compiled $
% $ Version 1.03 $ Date 4. December 1998 $ Not compiled $ Cosmetic changes
% $ Version 1.04 $ Date 4. December 1999 $ Not compiled $ Cosmetic changes
% $ Version 1.05 $ Date July 2000 $ Not compiled $ error caused weights not to be normalized for four-way and higher
% $ Version 1.06 $ Date November 2000 $ Not compiled $ increase max it and decrease conv crit to better handle difficult data
% $ Version 2.00 $ May 2001 $ Changed to array notation $ RB $ Not compiled $
% $ Version 2.01 $ June 2001 $ Changed to handle new core in X $ RB $ Not compiled $
% $ Version 2.02 $ January 2002 $ Outputs all predictions (1 - LV components) $ RB $ Not compiled $
% $ Version 2.03 $ March 2004 $ Changed initialization of u $ RB $ Not compiled $
% $ Version 2.04 $ Jan 2005 $ Modified sign conventions of scores and loads $ RB $ Not compiled $

if nargin==0
   disp(' ')
   disp(' ')
   disp(' THE N-PLS REGRESSION MODEL')
   disp(' ')
   disp(' Type <<help npls>> for more info')
   disp('  ')
   disp(' [Xfactors,Yfactors,Core,B,ypred,ssx,ssy] = npls(X,y,Fac);')
   disp(' or short')
   disp(' [Xfactors,Yfactors,Core,B] = npls(X,y,Fac);')
   disp(' ')
   return
elseif nargin<3
   error(' The inputs X, y, and Fac must be given')
end

if any(all(isnan(Y0(:,:)),2))
    i = all(isnan(Y0(:,:)),2);
    warning('Automatically removing completely missing Y observations');
    ordX = ndims(X0);
    ordY = ndims(Y0);
    idxX = repmat({':'},[1 ordX]);
    idxY = repmat({':'},[1 ordY]);
    idxX{1} = i;
    idxY{1} = i;
    X0(idxX{:}) = [];
    Y0(idxY{:}) = [];
end

if ~exist('show')==1||nargin<4
   show=1;
end

defaultProcessing = struct(...
    'Cent', [], ...
    'Scal', [], ...
    'iter', 1, ...
    'mX',   [], ...
    'sX',   []);
if exist('inProcessing','var') && ~isempty(inProcessing)
    for i=1:numel(inProcessing)
        processing(i) = setParameters(defaultProcessing, inProcessing(i));
    end
    % Apply Y processing to X as well...
    if numel(processing) == 1
        processing(2) = processing(1);
    end
    [X,mX,sX] = nprocess(X0,processing(1));
    [Y,mY,sY] = nprocess(Y0,processing(2));
    processing(1).mX = mX;
    processing(1).sX = sX;
    processing(2).mX = mY;
    processing(2).sX = sY;
    deprocessing = processing;
    deprocessing(1).iter = -deprocessing(1).iter;
    deprocessing(2).iter = -deprocessing(2).iter;
else
    X = X0;
    Y = Y0;
    processing = [];
    deprocessing = [];
end

maxit=120;


DimX = size(X);
X = reshape(X,DimX(1),prod(DimX(2:end)));
ordX = length(DimX);if ordX==2&&DimX(2)==1;ordX = 1;end
DimY = size(Y);
Y = reshape(Y,DimY(1),prod(DimY(2:end)));
ordY = length(DimY);if ordY==2&&DimY(2)==1;ordY = 1;end


[I,Jx]=size(X);
[I,Jy]=size(Y);

missX=0;
missy=0;
MissingX = 0;
MissingY = 0;
if any(isnan(X(:)))|any(isnan(Y(:)))
   if any(isnan(X(:)))
      MissingX=1;
   else
      MissingX=0;
   end
   if any(isnan(Y(:)))
      MissingY=1;
   else
      MissingY=0;
   end
   if show~=0&~isnan(show)
      disp(' ')
      disp(' Don''t worry, missing values will be taken care of')
      disp(' ')
   end
   missX=~isnan(X);
   missy=~isnan(Y);
end
crit=1e-10;
B=zeros(Fac,Fac);
T=[];
U=[];
Qkron =[];
if MissingX
   SSX=sum(sum(X(missX).^2));
else
   SSX=sum(sum(X.^2));
end
if MissingY
   SSy=sum(sum(Y(missy).^2));
else
   SSy=sum(sum(Y.^2));
end
ssx=[];
ssy=[];
Xres=X;
Yres=Y;
xmodel=zeros(size(X));
Q=[];
W=[];

for num_lv=1:Fac
   
   %init
   
   
   % u=rand(DimX(1),1); Old version
   if size(Yres,2)==1
     u = Yres;
   else
     [u] = pcanipals(Yres,1,0);
   end
   
   t=rand(DimX(1),1);
   tOld=t+2;it=0;
   while (norm(t-tOld)/norm(t))>crit && it<maxit
      tOld=t;
      it=it+1;
      
      % w=X'u
      [wloads,wkron] = Xtu(X,u,MissingX,missX,Jx,DimX,ordX);
      
      % t=Xw
      if MissingX
         for i=1:I,
            m = missX(i,:);
            t(i)=X(i,m)*wkron(m)/(wkron(m)'*wkron(m));
         end
      else
         t=X*wkron;
      end
      
      % w=X'u
      [qloads,qkron] = Xtu(Yres,t,MissingY,missy,Jy,DimY,ordY);
      % u=yq
      if MissingY
         for i=1:I
            m = missy(i,:);
            u(i)=Yres(i,m)*qkron(m)/(qkron(m)'*qkron(m));
         end
      else
         u=Yres*qkron;
      end
   end
   
   
%    % Fix signs
%    [Factors] = signswtch({t,wloads{:}},X);
%    t = Factors{1};
%    wloads = Factors(2:end);
%    % Fix signs
%    [Factors] = signswtch({u,qloads{:}},X);
%    u = Factors{1};
%    qloads = Factors(2:end);
   
   % Arrange t scores so they positively correlated with u
   cc = corrcoef([t u]);
   if sign(cc(2,1))<0
     t = -t;
     for ii=1:length(wloads)
       wloads{ii}=-wloads{ii};
     end
   end

   
   
   
   T=[T t];
   for i = 1:max(ordX-1,1)
      if num_lv == 1
         W{i} = wloads{i};
      else
         W{i} = [W{i} wloads{i}];
      end
   end
   U=[U u];
   for i = 1:max(ordY-1,1)
      if num_lv == 1
         Q{i} = qloads{i};
      else
         Q{i} = [Q{i} qloads{i}];
      end
   end
   Qkron = [Qkron qkron];
  
   % Make core arrays
   if ordX>1
      Xfac{1}=T;Xfac(2:ordX)=W;
      Core{num_lv} = calcore(reshape(X,DimX),Xfac,[],0,1);
   else
      Core{num_lv} = 1;
   end
%   if ordY>1
%      Yfac{1}=U;Yfac(2:ordY)=Q;
%      Ycore{num_lv} = calcore(reshape(Y,DimY),Yfac,[],0,1);
%   else
%      Ycore{num_lv} = 1;
%   end
   
   
%    B(1:num_lv,num_lv)=inv(T'*T)*T'*U(:,num_lv);
%    B(1:num_lv,num_lv)=(T'*T)\T'*U(:,num_lv);
   B(1:num_lv,num_lv)=T\U(:,num_lv);
   
   if Jy > 1
      if show~=0&&~isnan(show)
         disp(' ') 
         fprintf('number of iterations: %g',it);
         disp(' ')
      end
   end
   
   % Make X model
   if ordX>2
      Wkron = kron(W{end},W{end-1});
   else
      Wkron = W{end};
   end
   for i = ordX-3:-1:1
      Wkron = kron(Wkron,W{i});
   end
   if num_lv>1
      xmodel=T*reshape(Core{num_lv},num_lv,num_lv^(ordX-1))*Wkron';
   else
      xmodel = T*Core{num_lv}*Wkron';
   end
   
   % Make Y model   
 %  if ordY>2
 %     Qkron = kron(Q{end},Q{end-1});
 %  else
 %     Qkron = Q{end};
 %  end
 %  for i = ordY-3:-1:1
 %     Qkron = kron(Qkron,Q{i});
 %  end
 %  if num_lv>1
 %     ypred=T*B(1:num_lv,1:num_lv)*reshape(Ycore{num_lv},num_lv,num_lv^(ordY-1))*Qkron';
 %  else
 %     ypred = T*B(1:num_lv,1:num_lv)*Ycore{num_lv}*Qkron';
 %  end
 ypred=T*B(1:num_lv,1:num_lv)*Qkron';
 Ypred(:,num_lv) = ypred(:); % Vectorize to avoid problems with different orders and the de-vectorize later on
   
   Xres=X-xmodel; 
   Yres=Y-ypred;
   if MissingX
      ssx=[ssx;sum(sum(Xres(missX).^2))];
   else
      ssx=[ssx;sum(sum(Xres.^2))];
   end
   if MissingY
      ssy=[ssy;sum(sum((Y(missy)-ypred(missy)).^2))];
   else
      ssy=[ssy;sum(sum((Y-ypred).^2))];
   end
end
ypred = reshape(Ypred',[size(Ypred,2) DimY]);
ypred = permute(ypred,[2:ordY+1 1]);
if ~isempty(deprocessing)
    % Deprocess
    idx = repmat({':'}, 1, ordY);
    for i=1:size(Ypred,2)
        ypred(idx{:},i) = nprocess(ypred(idx{:},i),deprocessing(2));
    end
end
ssx= [ [SSX(1);ssx] [0;100*(1-ssx/SSX(1))]];
ssy= [ [SSy(1);ssy] [0;100*(1-ssy/SSy(1))]];

if show~=0&&~isnan(show)
   disp('  ')
   disp('   Percent Variation Captured by N-PLS Model   ')
   disp('  ')
   disp('   LV      X-Block    Y-Block')
   disp('   ----    -------    -------')
   ssq = [(1:Fac)' ssx(2:Fac+1,2) ssy(2:Fac+1,2)];
   format = '   %3.0f     %6.2f     %6.2f';
   for i = 1:Fac
      tab = sprintf(format,ssq(i,:)); disp(tab)
   end
end

Xfactors{1}=T;
for j = 1:ordX-1
   Xfactors{j+1}=W{j};
end

Yfactors{1}=U;
for j = 1:max(ordY-1,1)
   Yfactors{j+1}=Q{j};
end


% Calculate regression coefficients that apply directly to X
  if nargout>7 || nargout == 1
    if length(DimY)>2
        if show~=0&&~isnan(show)
            warning(' Regression coefficients are only calculated for models with vector Y or multivariate Y (not multi-way Y)')
        end
      reg = {};
    else
        R = outerm(W,0,1);
        for iy=1:size(Y,2)
            if length(DimX) == 2
                dd = [DimX(2) 1];
            else
                dd = DimX(2:end);
            end
            for i=1:Fac
                sR = R(:,1:i)*B(1:i,1:i)*diag(Q{1}(iy,1:i));
                ssR = sum( sR',1)';
                reg{iy,i} = reshape( ssR ,dd);
            end
        end
    end
    
  end

ssy0 = nansum((Y(:)-nanmean(Y(:))).^2);
R2Y = 1-ssy(end,1)/ssy0;

if nargout == 1
    % Pack outputs into a structure
    output = struct('Xfactors',{Xfactors},'Yfactors',{Yfactors},...
        'Core',{Core},'B',{B},'ypred',{ypred},'ssx',{ssx},'ssy',{ssy},...
        'reg',{reg},'xmodel',{xmodel},'processing',{processing},'R2Y',{R2Y});
    Xfactors = output;
end


function mwa = outerm(facts,lo,vect)

if nargin < 2
  lo = 0;
end
if nargin < 3
  vect = 0;
end
order = length(facts);
if lo == 0
  mwasize = zeros(1,order);
else
  mwasize = zeros(1,order-1);
end
k = 0;
for i = 1:order
  if i ~= lo
    [m,n] = size(facts{i});
    k = k + 1;
    mwasize(k) = m;
    if k > 1
      if nofac ~= n
        error('All orders must have the same number of factors')
      end
    else
      nofac = n;
    end
  end
end
mwa = zeros(prod(mwasize),nofac);

for j = 1:nofac
  if lo ~= 1
    mwvect = facts{1}(:,j);
    for i = 2:order
	  if lo ~= i
        %mwvect = kron(facts{i}(:,j),mwvect);
		mwvect = mwvect*facts{i}(:,j)';
		mwvect = mwvect(:);
	  end
    end
  elseif lo == 1
    mwvect = facts{2}(:,j);
	for i = 3:order
      %mwvect = kron(facts{i}(:,j),mwvect);
	  mwvect = mwvect*facts{i}(:,j)';
	  mwvect = mwvect(:);
	end
  end
  mwa(:,j) = mwvect;
end
% If vect isn't one, sum up the results of the factors and reshape
if vect ~= 1
  mwa = sum(mwa,2);
  mwa = reshape(mwa,mwasize);
end