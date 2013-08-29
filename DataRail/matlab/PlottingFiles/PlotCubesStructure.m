function PlotCubesStructure(Project)
% PlotCubesStructure creates a graph with the structure of cubes included in  particular Project
%
% the function used to create the plots is depicted between the input and output cube
%  
%  PlotCubesStructure(Project)
%
%--------------------------------------------------------------------------
% INPUTS
%  Project          =      labels to  use for labeling the plots
%  
% OUTPUTS 
%  
%  None
%  
%
%--------------------------------------------------------------------------
% EXAMPLE:
% figure;PlotCubesStructure(LeoData)
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


if isempty(Project.data(1).SourceData)
    Project.data(1).SourceData='MIDAS File';    
end

numCubes = numel(Project.data);
CubeMatrix=zeros(numCubes*2,numCubes*2);
%Determine adjacency matrix
for cube=1:numCubes
    for source=1:numCubes
        if ~isempty(find(strcmp(Project.data(source).Name,Project.data(cube).SourceData), 1))
              CubeMatrix(source, cube+numCubes)=1;
              CubeMatrix(cube+numCubes, cube)=1;
        end        
    end
end

CubeMatrix(numCubes+1,1)=1;%The input of the first input is the MIDAS file

BioInf=which('biograph');

%% with no bioinf toolbox
if isempty(BioInf)    
    if ischar(Project.data(1).SourceData)
        sourceString = Project.data(1).SourceData;
    elseif iscellstr(Project.data(1).SourceData)
        sourceString = [Project.data(1).SourceData{1} ...
            sprintf('\n%s', Project.data(1).SourceData{2:end})];
    end
    Shapes=zeros(size(CubeMatrix,1),1);

    for i=1:numCubes
        Labels{i}=[Project.data(i).Name ' (' num2str(i) ')'];
        Shapes(i)=1;
    end
    Labels{end+1}=sourceString;
    
    for i=2:(numCubes)
        try
            if ischar(Project.data(i).Code)
                try
                    if strcmp(Project.data(i).SourceData((end-3):end),'.csv')
                        CubeMatrix(numCubes+1,i)=1;
                    else
                        error('evaluate catch block')
                    end
                catch
                    try
                        Labels{end+1}=Project.data(i).Code;
                    catch
                        Labels{end+1}='Unknown';
                    end
                end
            else
                Labels{end+1}=func2str(Project.data(i).Code);
            end
        catch
            
        end
    end
    figure;draw_graph(CubeMatrix,Labels,Shapes);
    
%% with bioinformatics toolbox
else
    CubeMap=biograph(CubeMatrix);

    %The input of the first input is the MIDAS file, but could be a cellstr
    if ischar(Project.data(1).SourceData)
        sourceString = Project.data(1).SourceData;
    elseif iscellstr(Project.data(1).SourceData)
        sourceString = [Project.data(1).SourceData{1} ...
            sprintf('\n%s', Project.data(1).SourceData{2:end})];
    end
    set(CubeMap.nodes(numCubes+1),'Label',sourceString);

    for i=1:numCubes
        set(CubeMap.nodes(i),'Label',[Project.data(i).Name ' (' num2str(i) ')']);
    end
    for i=2:(numCubes)
        try
            if ischar(Project.data(i).Code)
                try
                    if strcmp(Project.data(i).SourceData((end-3):end),'.csv')
                        CubeMatrix(numCubes+1,i)=1;
                    else
                        error('evaluate catch block')
                    end
                catch
                    try
                        set(CubeMap.nodes(numCubes+i),'Label',Project.data(i).Code)
                    catch
                        set(CubeMap.nodes(numCubes+i),'Label','Unknown')
                    end
                end
            else
                set(CubeMap.nodes(numCubes+i),'Label',func2str(Project.data(i).Code))
            end
        catch
        end
    end

%Color differently MIDAS file
set(CubeMap.Nodes((numCubes+1)),'Color',[.5 .5 1])

%Color and shape differently transforming functions
set(CubeMap.Nodes((numCubes+2):end),'Color',[.7 1 .7])
set(CubeMap.Nodes((numCubes+2):end),'Shape','ellipse')

view(CubeMap)
end