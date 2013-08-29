
function Res=CreateCNAData(CubeBoolean,Parameters)
%
%**************************************************************************
%
%   function Res=CreateCNAData(CubeBoolean,Parameters)
%
%   04/03/07 J. Saez
%   Converts Cube of Boolean Data into CellNetAnalyzer Format
%
%   WARNING: Works only on the canonical form
%
%   Parameters.DimFixed=[1 1]
%   Parameters.Labels=Labels
%   Parameters.dim2={'EGF,','TGF',...}
%   Parameters.dim3={'PI3Ki'} with or without i
%
%--------------------------------------------------------------------------

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
%
try
    Parameters.DimFixed;
catch
    Parameters.DimFixed=[1 1]  ;
end

Labels=Parameters.Labels;
dim2=unique(Parameters.dim2);
dim3=unique(Parameters.dim3);

%sometimes needed....
%for readi=1:numel(Labels(5).Value)   
%    Labels(5).Value{readi}=regexprep(Labels(5).Value{readi},'-','_');
%end

%Remove InputEqOutput because can not be used-note that there is a
CubeBoolean=RemoveInputEqOutput(CubeBoolean,struct('Labels',Labels));
                          
Dimens=size(CubeBoolean);
if Dimens(1)~=numel(Labels(1).Value)||Dimens(1)~=numel(Labels(1).Value)||...
   Dimens(3)~=numel(Labels(3).Value)||Dimens(4)~=numel(Labels(4).Value)||...
   Dimens(5)~=numel(Labels(5).Value)
    disp(' ')
    disp(' **dimensions of labels and data do not agree-check the input data')
    disp(' ')
    return
end


for cytok=1:numel(dim2)
    if ~isempty(find(strfind(dim2{cytok},'=')))
        eqpos=strfind(dim2{cytok},'=');
        dim2{cytok}=dim2{cytok}(1:(eqpos-1));
        disp([' ** ' dim2{cytok} ': concentrations information will be removed for boolean analysis** ']);
    end
end

for inhib=1:numel(dim3)
    if ~isempty(find(strfind(dim3{inhib},'-')));
     ipos=strfind(dim3{inhib},'-')-1;
        disp([ ' ** ' dim3{inhib} ': name of inhibitor will be removed for boolean analysis**' ])        ;
        dim3{inhib}=dim3{inhib}(1:ipos);    
end
end

for cytok=1:numel(dim2)
    if strcmp(dim2{cytok},'ALL')==1
        warndlg('use of ALL to define use of all stimuli is not supported')
        return
    end
end

for inhib=1:numel(dim3)
    if strcmp(dim3{inhib},'ALL')==1
        warndlg('use of ALL to define use of all inhibitors is not supported')
        return
    end
end

%for the inhibitors remove the i to match the metabolites names
if isempty(dim3)
    dim3NoI='';
elseif ~isempty(dim3{1})>0
    for i=1:numel(dim3)
        if strcmp(dim3{i}(end),'i')==1
            dim3NoI{i}=dim3{i}(1:(end-1));
        elseif ~isempty(regexp(dim3{i},'i-', 'once' ))
            posi=regexp(dim3{i},'i-', 'once' )-1;
            dim3{i}=dim3{i}([1:posi]);
        else%if ~strcmp(dim3{i},'DMSO')
            disp(' ')
            disp([' ** The inhibitor ' dim3{i} ' is not tagged with i. This does not comply with the standard data input can lead to errors.']);
            dim3NoI{i}=dim3{i};
        end
    end
else
    dim3NoI=dim3;
end
for str=1:numel(dim3NoI)
    PosPC=findstr(';',dim3NoI{str});
    if ~isempty(PosPC)
        dim3NoI{end+1}= dim3NoI{str}(PosPC(1)+1:end);        
        dim3NoI{str}=   dim3NoI{str}(1:PosPC(1)-1);
    end
end
for str=1:numel(dim3)
    PosPC=findstr(';',dim3{str});
    if ~isempty(PosPC)
        dim3{end+1}= [dim3{str}(PosPC(1)+1:end) ];        
        dim3{str}=   [dim3{str}(1:PosPC(1)-1) 'i'];
    end
end
% Add metabolites names: cues+inhbitors+readouts
if  ~isempty(dim3NoI)&&(size(dim2,2)==size(dim3NoI,1))
    dim2=dim2';
end
if  ~isempty(dim3NoI)&&(size(dim3NoI,1)==size(Labels(5).Value,2))
    dim5=Labels(5).Value';
else
    dim5=Labels(5).Value;
end    

try
     Res.MetaboliteNames=[dim2 dim3NoI dim5];
catch
    Res.MetaboliteNames=[dim2; dim3NoI; dim5]';
end
    
if  (size(Labels(4).Value,2)==size(dim3NoI,1))
    dim3n=Labels(4).Value';
else
    dim3n=Labels(4).Value;
end

% if we are passing only one time point, this is probably not a time zero
% so we consider it as the first to look at. Otherwise, the first we look
% at is t=1 (we assume t=0 to be "known" or fixed in the model
%Number Scenarios depends on time points accordingly
if numel(Labels(2).Value)==1
    FirstTime=1;
    NumberScenarios= numel(Labels(3).Value)*numel(Labels(4).Value)*(numel(Labels(2).Value));
else
    FirstTime=2;
    NumberScenarios= numel(Labels(3).Value)*numel(Labels(4).Value)*(numel(Labels(2).Value)-1);
    
end

%Define TimeScales and Scenario Names
Res.ScenarioNames=[];
Res.TimeScales =[];
i=1;
for cyt=1:numel( Labels(3).Value)
    if isempty(Labels(3).Value{cyt})
        Labels(3).Value{cyt}=['No' Labels(3).Name(1:4)];
    end
    
    for inh=1:numel( Labels(4).Value)
        inhib=Labels(4).Value{inh};
        inhib=inhib(1:(end-1));
        Res.TimeScales=[Res.TimeScales Labels(2).Value([FirstTime:end])'];
        for time=FirstTime:numel(Labels(2).Value)
            if numel(Labels(4).Value)>1
                Res.ScenarioNames{i}=[Labels(3).Value{cyt} '-'...
                    Labels(4).Value{inh} '-' num2str(Labels(2).Value(time))];
            else
                Res.ScenarioNames{i}=[Labels(3).Value{cyt} '-'...
                   char(Labels(4).Value)  '-' num2str(Labels(2).Value(time))];              
            end
            %if a dimension is empty it will be filled with a 'DummyValue'
            Res.ScenarioNames{i}=regexprep(Res.ScenarioNames{i},'DummyValue','');
            VecOut=[];
            for measu=1:numel(Labels(5).Value)
            %{ obsolete we do it with RemoveInpEqOutput 
            %if ~strcmpi(Labels(5).Value{measu},inhib)
                    VecOut=[VecOut CubeBoolean(Parameters.DimFixed(2),time,cyt,inh,measu)];
            %    else
            %        VecOut=[VecOut NaN];
            %    end
            end

            VecInp=zeros(1,(numel(dim2)+numel(dim3)));
            for cytok=1:numel(dim2)
                if ~isempty(strfind(Res.ScenarioNames{i},dim2{cytok}))
                    VecInp(cytok)=1;
                else
                    VecInp(cytok)=0;
                end            
            end
            for inhib=1:numel(dim3)
                TempSc=regexprep(Res.ScenarioNames{i},';','i');%we replace ; with i so that it matches dim3 
                if ~isempty(strfind(TempSc,dim3{inhib}))
                    VecInp((numel(dim2)+inhib))=0;
                else
                    VecInp((numel(dim2)+inhib))=NaN;
                end                
            end            
            InputReadouts(i,:)=VecOut;
            InputStimuli(i,:)=VecInp;
            i=i+1;
        end
    end
end

Res.InputMatrix =[InputStimuli NaN(NumberScenarios,numel(Labels(5).Value))];
Res.OutputMatrix=[NaN(size(InputStimuli)) InputReadouts];

%Do some checks
for i=1:numel(dim2)
    if isempty(nonzeros(Res.InputMatrix(:,i)))==1
        warndlg(['The cytokine ' Parameters.dim2{i} ' was not found in the data structure']);
    end
end
for i=1:numel(dim3)
    if isempty(nonzeros(Res.InputMatrix(:,(numel(dim2)+i))))==1
        warndlg(['The inhibitor ' Parameters.dim3{i} ' was not found in the data structure']);
    end
end

% To remove double species-
% we take the first appearance for the input (the one from dim3/dim4)
% and the second for the output (the one from dim5 aka readout)

[a b c]   =unique(Res.MetaboliteNames,'first');
[al bl cl]=unique(Res.MetaboliteNames);

[NewOrd indxNew]=sort(b);

Res.MetaboliteNames= Res.MetaboliteNames(NewOrd);
Res.InputMatrix    = Res.InputMatrix (:,NewOrd);
Res.OutputMatrix   = Res.OutputMatrix(:,bl(indxNew));


