function NewData=ComputeWeightsMR(OldData,Parameters)
% ComputeWeightsMR computes two-componentn multiple regression analysis
%
%   NewData=ComputeWeightsMR(OldData,Parameters)
%
%  This function performs a two-component multiple regression analysis 
%  on a CSR Compendium as described in Alexopoulos et al. 2008
%--------------------------------------------------------------------------
% INPUTS:
%
% OldData = n-dimensional DataRail data array                 
%
%
% OUTPUTS:
%
% NewData = DataRail data array with weights in matrix format
%
% Parameters = empty
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  NewData = ComputeWeightsMR(OldData,Parameters)
%
%
%--------------------------------------------------------------------------
% TODO:
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




Expand2DParams=GuiExpandCubeto2DPars(OldData.Labels);
ExpandedCube=ExpandCubeto2D(OldData.Value,Expand2DParams);
X1=ExpandedCube.Matrices(1).Value;
X2=ExpandedCube.Matrices(2).Value;
Y =ExpandedCube.Matrices(4).Value;
% 1st Component of multiple regression: Cue->Phospho
%X1*W1=Y
W1=X1\Y;
%Compute the residuals
Res=Y-(X1*W1);
%Run 2nd componoent of mulitple regression Inhib->Phospho
%X2*W2=Res
W2=X2\Res;

%Y=X1*W1+X2*W2
NewData.W1=W1;
NewData.W2=W2;
NewData.X1=X1;
NewData.X2=X2;
NewData.Y=Y;
NewData.Labels(1).Name='X1';
NewData.Labels(1).Value=ExpandedCube.Labels(1).Value;
NewData.Labels(2).Name='X2';
NewData.Labels(2).Value=ExpandedCube.Labels(2).Value;
NewData.Labels(3).Name='Y';
NewData.Labels(3).Value=ExpandedCube.Labels(4).Value;





