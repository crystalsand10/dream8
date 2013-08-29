function ExportWeights2Cytoscape(Datacube,parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS:
% DataCube = DataRail array
%
% Parameters.OutputFile
%
% OUTPUTS:
%  none
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%--------------------------------------------------------------------------
% TODO
% 
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

parameters.OutputFileEdges=[parameters.OutputFile 'Edges.txt'];
parameters.OutputFileNodes=[parameters.OutputFile 'Nodes.txt'];

%%
 fid=fopen(parameters.OutputFileEdges,'w+');

 WeightCue=Datacube.W1;
 WeightInhibitor=Datacube.W2;
 Weightcombo=[WeightCue; WeightInhibitor];
 %Weight1=InputMatrixCue\OutputMatrixReadout;
 Inputs=[Datacube.Labels(1).Value; Datacube.Labels(2).Value];
 Outputs=Datacube.Labels(3).Value;
 [rows columns] = size(Weightcombo);

 
for Inp=1:rows
     for Reado=1:columns
             ThisText=[Inputs{Inp} '\t' Outputs{Reado} '\t' num2str(sign(Weightcombo(Inp,Reado))) '\t' num2str(abs((Weightcombo(Inp,Reado))))  '\n'];
         if strcmpi(Inputs{Inp}, 'NO-CYTO') == 1
             ThisText=[''];
         end
         if strcmpi(Inputs{Inp}, 'NO-INHIB') == 1
             ThisText=[''];
         end
         fwrite(fid,sprintf(ThisText));
     end
 end
 

fclose(fid);
Cues=numel(Datacube.Labels(1).Value);
Inhib=numel(Datacube.Labels(2).Value);
Readout=numel(Datacube.Labels(3).Value);
 
%%
fid=fopen(parameters.OutputFileNodes, 'w+');
 
for Inp=1:Cues
     ThisText=[Inputs{Inp} '\t' 'Cues' '\n'];
     if strcmpi(Inputs{Inp}, 'NO-CYTO') == 1
             ThisText=[''];
     end
     fwrite(fid,sprintf(ThisText));
end
     
for Inp=(Cues+1):(Cues+Inhib)
    ThisText=[Inputs{Inp} '\t' 'Inhib' '\n'];
     if strcmpi(Inputs{Inp}, 'NO-INHIB') == 1
             ThisText=[''];
     end
     if strcmpi(Inputs{Inp}, 'NO-CYTO') == 1
             ThisText=[''];
     end
     fwrite(fid,sprintf(ThisText));
end

for Out=1:Readout
    ThisText=[Outputs{Out} '\t' 'Readout' '\n'];
    fwrite(fid,sprintf(ThisText));
end
fclose(fid);
    
 
 