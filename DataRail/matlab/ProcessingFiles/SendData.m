function SendData(Data,receiver)
%
%--------------------------------------------------------------------------
%function SendData(Data,receiver)
%
%   04/18/07 J. Saez
%
%--------------------------------------------------------------------------

try
  eval(['!display' Data '&'])
end  

if strcmp(receiver,'')==1
  eval(['!echo here it goes | nail -a ' Data ' -c julio@hms.harvard.edu -s DataYOuRequested leonidas@mit.edu'])
else
  eval(['!echo here it goes | nail -a ' Data ' -c julio@hms.harvard.edu -s DataYouRequested ' receiver])
end


