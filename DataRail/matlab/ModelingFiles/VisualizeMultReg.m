function VisualizeMultReg(M,Parameters)
%VisualizeMultReg plots a map with the edges defined from the weights resulting from multiple regression
%
%    VisualizeMultReg(M,Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
%  M     = structure containing
%            .CueNames      = string of names of cues
%            .InhNames      = string of names of cues
%            .PhosphoNames  = string of names of cues
%            .CytoNames     = string of names of cues
%            .PhosphoW      = matrix of weights from cue+inhibtors to  phosphos
%            .CytoW         = matrix of weights from phosphos to cytos
% Parameters=
%             .MinStrength(0)= threshold below which a weight is not plotted
%                            
% OUTPUTS:
%  none
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%--------------------------------------------------------------------------
% TODO
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

try   Parameters.MinStrength;
catch Parameters.MinStrength=0;
end

numCues     =  numel(M.CueNames);
numInhs     =  numel(M.InhNames);
numPhosphos =  numel(M.PhosphoNames);
numCytos    =  numel(M.CytoNames);

IDs={M.CueNames{:},M.InhNames{:},M.PhosphoNames{:},M.CytoNames{:}};

TotalStates=numel(IDs);
for k=1:TotalStates
     if ~isempty(find(strcmp({IDs{1:(k-1)}},IDs{k})))
         IDs{k}=strcat(IDs{k},'o');
     end
end

AdjMatrix=zeros(TotalStates,TotalStates);
AdjMatrix(1:(numCues+numInhs)                               ,(numCues+numInhs)+1:(numCues+numInhs+numPhosphos))              =M.PhosphoW;
AdjMatrix((numCues+numInhs)+1:(numCues+numInhs+numPhosphos),numCues+numInhs+numPhosphos+1:end)=M.CytoW;

ModelMap=biograph(AdjMatrix,IDs);
ModelMap.ArrowSize=6;
ModelMap.LayoutScale=3;
%ModelMap.Scale=10;
for i=1:numel(ModelMap.Nodes)
    ModelMap.Nodes(i).FontSize=12;
end
dolayout(ModelMap);%make the layout before we remove elements, otherwise will be uncoupled
set(ModelMap.Nodes(:),'Shape','ellipse');
VecPW=M.PhosphoW(:);
VecCW= M.CytoW(:);
Weights=[VecPW/max(abs(VecPW)); VecCW/max(abs(VecCW))];
Weights=nonzeros(Weights);%/max(Weights);
Weights=sign(Weights).*Weights./(.2*sign(Weights)+Weights);
ToKeep=[];
for i=1:numel(Weights)   
    if abs(Weights(i))>Parameters.MinStrength
        ToKeep=[ToKeep i];
    end
    if Weights(i)>0
        ModelMap.Edges(i).LineWidth=Weights(i)*3; 
        ModelMap.Edges(i).LineColor= [(1-Weights(i)) (1-Weights(i)) 1];    
    elseif Weights(i)<0
        ModelMap.Edges(i).LineWidth=-Weights(i)*3; 
        ModelMap.Edges(i).LineColor= [1 (1+Weights(i)) (1+Weights(i))];      
    end
end
ModelMap.Edges=ModelMap.Edges(ToKeep);
view(ModelMap)

