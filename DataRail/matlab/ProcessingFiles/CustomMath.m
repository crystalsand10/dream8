function NewData=CustomMath(OldData,Parameters,Compendium)
%  Normalize normalizes the Data to a specific value chosen by the user
%
%--------------------------------------------------------------------------
% INPUTS:
%
% OlData = 5-dimensional data cube in the canonical form
%
% Parameters = structure of parameters (default value in parenthesis)
%       
%
%
% OUTPUTS:
%
% NewData = 5-dimensional data cube in the canonical form
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(2).Value=NormalizeToT0(Data.data(1).Value,Parameters)
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
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe    Nickel Dittrich
%    SBPipeline.harvard.edu%


DefaultParameters.Type = 2;
DefaultParameters.Value.ApplyTo = 1;
DefaultParameters.Value.SubCube = 1;
DefaultParameters.Value.Command = 'min';
DefaultParameters.Value.Cube1 = 1;
DefaultParameters.Value.Cube2 = 1;
DefaultParameters.Value.Operator = 1;
Parameters = setParameters(DefaultParameters, Parameters);
NewData = nan(size(OldData));

if Parameters.Type == 1
    command = str2func(Parameters.Value.Command);
    switch Parameters.Value.ApplyTo
        case 1
            NewData(:) = command(OldData(:));
        case 2
            if length(size(OldData)) == 5
                NewData(:) = command(command(command(command(command(OldData(Parameters.Value.SubCube,:,:,:,:))))));
            else
                NewData(:) = command(command(command(command(command(OldData(Parameters.Value.SubCube,:,:,:,:,:))))));
            end
        case 3
            if length(size(OldData)) == 5
                NewData(:) = command(command(command(command(command(OldData(:,Parameters.Value.SubCube,:,:,:))))));
            else
                NewData(:) = command(command(command(command(command(OldData(:,Parameters.Value.SubCube,:,:,:,:))))));
            end
        case 4
            if length(size(OldData)) == 5
                NewData(:) = command(command(command(command(command(OldData(:,:,Parameters.Value.SubCube,:,:))))));
            else
                NewData(:) = command(command(command(command(command(OldData(:,:,Parameters.Value.SubCube,:,:,:))))));
            end
        case 5
            if length(size(OldData)) == 5
                NewData(:) = command(command(command(command(command(OldData(:,:,:,Parameters.Value.SubCube,:))))));
            else
                NewData(:) = command(command(command(command(command(OldData(:,:,:,Parameters.Value.SubCube,:,:))))));
            end
        case 6
            if length(size(OldData)) == 5
                NewData(:) = command(command(command(command(command(OldData(:,:,:,:,Parameters.Value.SubCube))))));
            else
                NewData(:) = command(command(command(command(command(OldData(:,:,:,:,Parameters.Value.SubCube,:))))));
            end
    end
else
    switch Parameters.Value.Operator
        case 1  % multiply
            NewData(:) = Compendium.data(1,Parameters.Value.Cube1).Value(:) .* Compendium.data(1,Parameters.Value.Cube2).Value(:);
        case 2  % divide
            NewData(:) = Compendium.data(1,Parameters.Value.Cube1).Value(:) ./ Compendium.data(1,Parameters.Value.Cube2).Value(:);
        case 3  % add
            NewData(:) = Compendium.data(1,Parameters.Value.Cube1).Value(:) + Compendium.data(1,Parameters.Value.Cube2).Value(:);
        case 4  % substract
            NewData(:) = Compendium.data(1,Parameters.Value.Cube1).Value(:) - Compendium.data(1,Parameters.Value.Cube2).Value(:);
    end
end