function o = init(o)

o.DimX = size(o.XOrig);
o.X = reshape(o.XOrig,o.DimX(1),prod(o.DimX(2:end)));
o.ordX = length(o.DimX);
if o.ordX==2 && size(o.X,2) == 1
    o.ordX = 1;
end
o.DimY = size(o.YOrig);
o.Y = reshape(o.YOrig,o.DimY(1),prod(o.DimY(2:end)));
o.ordY = length(o.DimY);
if o.ordY==2 && size(o.Y,2) == 1
    o.ordY = 1;
end

[o.I,o.Jx]=size(o.X);
[o.I,o.Jy]=size(o.Y);

o.missX=0;
o.missY=0;
o.MissingX = 0;
o.MissingY = 0;

if any(isnan(o.X(:))) || any(isnan(o.Y(:)))
   if any(isnan(X(:)))
      o.MissingX=1;
   else
      o.MissingX=0;
   end
   if any(isnan(Y(:)))
      o.MissingY=1;
   else
      o.MissingY=0;
   end
   if o.show~=0 && ~isnan(o.show)
      disp(' ')
      disp(' Don''t worry, missing values will be taken care of')
      disp(' ')
   end
   o.missX=abs(1-isnan(o.X));
   o.missY=abs(1-isnan(o.Y));
end

o.B=zeros(o.Fac,o.Fac);
o.T=[];
o.U=[];
o.Qkron =[];
if o.MissingX
   o.SSX=sum(sum(o.X(find(o.missX)).^2));
else
   o.SSX=sum(sum(o.X.^2));
end
if o.MissingY
   o.SSy=sum(sum(o.Y(find(o.missY)).^2));
else
   o.SSy=sum(sum(o.Y.^2));
end
o.ssx=[];
o.ssy=[];
o.Xres=o.X;
o.Yres=o.Y;
o.xmodel=zeros(size(o.X));
o.Q=[];
o.W=[];
o.num_lv = 0;

[o.Xfac,o.Xfactors,o.Yfactors,o.Core,o.reg] = deal({});
[o.B,o.Wkron,o.ypred,o.Ypred,o.ssx,o.ssy] = deal([]);