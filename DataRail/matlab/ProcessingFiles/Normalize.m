function [NewData Parameters]=Normalize(OldData,Parameters)
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


DefaultParameters.Type = 1;
DefaultParameters.Value.Divider = 1;
DefaultParameters.Value.Inhib = 1;
DefaultParameters.Value.Treat = 1;
DefaultParameters.Value.CellType = 1;
Parameters = setParameters(DefaultParameters, Parameters);
nanflag = 0;

NewData=NaN(size(OldData));
if Parameters.Type == 1             % initial time point
    for j = 1:size(OldData,2)
        NewData(:,j,:,:,:) = OldData(:,j,:,:,:)./OldData(:,1,:,:,:);
    end
    if any(any(any(any(OldData(:,1,:,:,:)==0)))) || any(any(any(any(isnan(OldData(:,1,:,:,:))))))
        nanflag = 1;
    end
elseif Parameters.Type == 2         % max for each treatment condition
    NewData = MaxSignalRelativator(OldData,Parameters);
elseif Parameters.Type == 3         % value entered by user
    for i=1:size(OldData,4)
        for j=1:size(OldData,5)
            NewData(:,:,:,i,j) = OldData(:,:,:,i,j) ./ Parameters.Value;
        end
    end
elseif Parameters.Type == 4         % respective value of a certain cell type
    for ct = 1:size(OldData,1)
        if length(size(OldData)) == 6
            NewData(ct,:,:,:,:,:) = OldData(ct,:,:,:,:,:) ./ OldData(Parameters.Value.CellType,:,:,:,:,:);
        else
            NewData(ct,:,:,:,:) = OldData(ct,:,:,:,:) ./ OldData(Parameters.Value.CellType,:,:,:,:);
        end
    end
%     if Parameters.Value.Inhib <= size(OldData,4) && Parameters.Value.Treat <= size(OldData,5) && Parameters.Value.CellType <= size(OldData,1)
%         for i=1:size(OldData,4)
%             for j=1:size(OldData,5)
%                 NewData(:,:,:,i,j) = OldData(:,:,:,i,j) ./ OldData(Parameters.Value.CellType,1,Parameters.Value.Treat,Parameters.Value.Inhib,1);
%                 if OldData(Parameters.Value.CellType,1,Parameters.Value.Treat,Parameters.Value.Inhib,1)==0
%                     nanflag = 1;
%                 elseif isnan(OldData(Parameters.Value.CellType,1,Parameters.Value.Treat,Parameters.Value.Inhib,1))
%                     nanflag = 1;
%                 end
%             end
%         end
%     else
%         warndlg('Your parameter exceed the dimension of the dataset! No changes have been made.')
%     end
elseif Parameters.Type == 5         % total amount of protein
    % not working
    %{
    Preg='Choose MIDAS file with total protein data';
        [filename,pathname, filterindex] = uigetfile({'*.csv'},Preg);
        if filename==0
            warndlg('Can not normalize without a file with total protein information.')
            return
        end
        handles.Parameters.filename=fullfile(pathname,filename);
        handles.Parameters.ImporterParameters=SourceData.Parameters;
        handles.Parameters.Labels=SourceData.Labels;
        [NewData NewLabels] = NormalizeTotalProt(OldData,handles.Parameters)
    %}
        notify(notifier); % Unhide GUI
elseif Parameters.Type == 6         % average for each treatment condition
    for ct = 1:size(OldData,1)
        for cyt = 1:size(OldData,3)
            for inh = 1:size(OldData,4)
                for i = 1:size(OldData,2)
                    NewData(ct,i,cyt,inh,:) = OldData(ct,i,cyt,inh,:) ./ nanmean(OldData(ct,:,cyt,inh,:));
                end
            end
        end
    end
elseif Parameters.Type == 7
    Array.Value=OldData;
    Array.Labels=Parameters.Labels;
    Pars=GuiBooleanizerPars(Array);
    NewData=Booleanizer(OldData,Pars);
    Pars.Type = Parameters.Type;
    Parameters = Pars;
elseif Parameters.Type == 8
    Array.Value=OldData;
    Array.Labels=Parameters.Labels;
    Pars=GuiBooleanizerParsMKM(Array);
    NewData=BooleanizerMKM(OldData,Pars);
    Pars.Type = Parameters.Type;
    Parameters = Pars;
elseif Parameters.Type == 9
    for i = 1:size(OldData,3)
        NewData(:,:,i,:,:) = OldData(:,:,i,:,:)./OldData(:,:,1,:,:);
    end
    if any(any(any(any(OldData(:,:,1,:,:)==0)))) || any(any(any(any(isnan(OldData(:,:,1,:,:))))))
        nanflag = 1;
    end
elseif Parameters.Type == 10
    for i = 1:size(OldData,3)
        NewData(:,:,i,:,:) = (OldData(:,:,i,:,:)-OldData(:,:,1,:,:))./OldData(:,:,1,:,:);
    end
    if any(any(any(any(OldData(:,:,1,:,:)==0)))) || any(any(any(any(isnan(OldData(:,:,1,:,:))))))
        nanflag = 1;
    end
elseif Parameters.Type == 11             % relative to initial time point
    for j = 1:size(OldData,2)
        NewData(:,j,:,:,:) = (OldData(:,j,:,:,:)-OldData(:,1,:,:,:))./OldData(:,1,:,:,:);
    end
    if any(any(any(any(OldData(:,1,:,:,:)==0)))) || any(any(any(any(isnan(OldData(:,1,:,:,:))))))
        nanflag = 1;
    end
end

if nanflag == 1
    msgbox('Division by 0 or NaN! Normalization created NaNs in the new array. Try using "Copy t=0 data across conditions" while importing your file.','Try Copy t=0 data across conditions!')
end
                
 