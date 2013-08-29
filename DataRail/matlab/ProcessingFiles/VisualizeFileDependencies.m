function VisualizeFileDependencies(varargin)%(File,Parameters)
% VisualizeFileDependencies shouws files on which one file depends using biograph
%
% with right click on a function one can recursively plot
% dependencies
%
%--------------------------------------------------------------------------
% INPUTS:
% File = a string with a file
% Parameters = dummy field
%
% OUTPUTS:
%
%   None
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%   VisualizeFileDependencies('GuiMain')
%
%--------------------------------------------------------------------------
% TODO:
% - Plot on one figure recusrive dependencies
%
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

if numel(varargin)==1
    File=varargin{1};
elseif numel(varargin)==2
    File=varargin{1};
    Parameters=varargin{2};
else
    [FileName, PathName]= uigetfile({'*.m'},'Select a m file ');
    File=fullfile(PathName,FileName);
end

if ischar(File)
    m=mydepfun(File);%m=depfun(File,'-toponly');%Model is name
else
    disp('input must be a string describing a file')
    return
end

numfunc = numel(m);
IDs{1}=File;

if numfunc==1
    warndlg('this file has no dependencies out of the internal MATLAB routines.')
    return
end

AdjMatrix=zeros(numfunc,numfunc);
%Determine adjacency matrix
AdjMatrix(1,[2:end])=1;
for i=2:numfunc
    Cuts=strfind(m{i},'/');
    LongN=m{i};
    mcomp{i}=LongN((Cuts(end)+1):(end-2));

    IDs{i}=mcomp{i};
end

BioInf=which('biograph');
if ~isempty(BioInf)
    ModelMap=biograph(AdjMatrix,IDs);
else
    figure('Name',[ 'File Dependencies for ' File ]);
    Shapes=ones(numel(IDs),1);
    Shapes(1)=0;
    draw_graph(AdjMatrix,IDs,Shapes); 
end

set(ModelMap.Nodes(:),'Shape','ellipse');
set(ModelMap.Nodes(1),'Color',[.7 .7 1]);
ModelMap.LayoutType='radial';%'equilibrium';
ModelMap.LayoutScale=1.2;
ModelMap.NodeCallbacks={@(node)VisualizeFileDependencies(node.ID)};
view(ModelMap)


