function NewData=GetConcentrations(OldData,Parameters)
% GetConcentrations converts a canonical 5-D datacube from 50-plex signal to concentration of cytokines
%
% function NewData=GetConcentrations(OldData,Parameters)
%
% This function convert a 5-D datacube where the signal is the 5th
% dimension from 50-plex signal to concentration (cytokine release)
%
%--------------------------------------------------------------------------
% INPUTS:
%
% OlData = 5-dimensional data cube in the canonical form
%
% Parameters = 
%      .FitParameters(no default)= must be passed. Provides:
%                                  .Value = the values in a 5 X numreadouts matrix
%                                  .Labels= array of strings of labels
%                                  Can be created with CreateCalibration.m
%      .Labels(no default) = Labels of the Cube OldData
%
% OUTPUTS:
%
% NewData = 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(2).Value=GetConcentrations(Data.data(1).Value,Parameters)
%
%--------------------------------------------------------------------------
% TODO:
%
% - 
%

%--------------------------------------------------------------------------
% Copyright 2007 President and Fellow of Harvard College
%
%
%  This file is part of SBPipeline.
%
%    SBPipeline is free software; you can redistribute it and/or modify
%    it under the terms of the GNU Lesser General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or
%    (at your option) any later version.
%
%    SBPipeline is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Lesser General Public License for more details.
% 
%    You should have received a copy of the GNU Lesser General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe
%    SBPipeline.harvard.edu%

NewData=OldData;

allparamets = Parameters.FitParameters.Value;

iOrder=[];
for i=1:numel(Parameters.Labels(5).Value)
    iMatch = strmatch(Parameters.Labels(5).Value(i), Parameters.FitParameters.Labels, 'exact');
    if numel(iMatch) ~= 1
        error('Incompatible labels');
    end
    iOrder(i) = iMatch;
end
fitted_params.Value=fitted_params.Value(:,iOrder);

for dim1=1:size(OldData,1)
    for dim2=1:size(OldData,2)
        for dim3=1:size(OldData,3)
            for dim4=1:size(OldData,4)
                for dim5=1:size(OldData,5)
%                    paramets=fitted_params(:,dim5);
                    NewData(dim1,dim2,dim3,dim4,dim5)=invcurvefunc_3models(OldData(dim1,dim2,dim3,dim4,dim5),dim5,allparamets);
                end
            end
        end
    end
end
end


%---
function [conc] = invcurvefunc_3models(FI, cytonum,allparamets)

%load Three_Models_Cal_27x-5005744-Cal23x-5005844_Feb2007.mat

paramets = allparamets( cytonum,  :) ;

        a = paramets(1);
        b = paramets(2);
        c = paramets(3);
        d = paramets(4);
        g = paramets(5);
   maxCon = paramets(6);

   
if (isnan(c) == 1 && isnan(d) == 1 && isnan(g) == 1)
%Linear Model
    if (isnan(a) == 1 || isnan(b) == 1 )
    qqq='something wrong with the linear function'
    return
    end
conc = (FI-b)/a ; %pg/ml
end

if (isnan(c) == 0 && isnan(d) == 0 && isnan(g) == 0)
%5plmodel
    if (isnan(a) == 1 || isnan(b) == 1 )
    qqq='something wrong with the 5pl model'
    return
    end
    
    maxFI = d + (a-d) / (1+ (maxCon/c)^b)^g; 
    
    if (FI >= maxFI)  % ---> saturation point 
    conc = maxCon; 
    elseif (FI <= d)
    conc = 0.;      
    else    
    conc = max(0, c * (((a-d)/(FI-d))^(1./g) - 1.) ^ (1/b));   %pg/ml
    end
    
    
end    
    
%conc = conc/1000; %ng/ml
     

end


%%------
function [val] = invcurvefunc(y, paramets)
a = paramets(1);
b = paramets(2);
c = paramets(3);
d = paramets(4);
g = paramets(5);

if (y >= 0.95*d)  % ---> saturation point
    val = d;
else
    val = c * (((a-d)/(y-d))^(1./g) - 1.) ^ (1/b);
end

if (y <=1.05*a)   % ---> lower value
    val = a;
end


end