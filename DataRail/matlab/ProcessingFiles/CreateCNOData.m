function Res=CreateCNOData(DataCube,Parameters)

% CNOCreateCNOData takes a 5-D canonical cube and creates structure for CNO
%
% Res=CNOCreateCNOData(DataCube,Parameters)
%
%--------------------------------------------------------------------------
% INPUTS:
% DataCube = 5-dimensional data cube in the canonical form
%
% Parameters = structure of parameters (default value in parenthesis)
%     .Labels(required) = Labels to perform the match of names
%     .Model() =CNO model to match indexes of species
%     .DimFixed([1 1])  one dimension can not be expanded in the matrix,
%                       typically the 1st (cell type); DimFixed(1) defines
%                       the dimension and DimFixed(2) the value for that
%                       dimension chosen
%     .dim3','',  field describing the names of cue in the 3rd dimension
%                 will be automatically defined based on labels if not set
%     .dim4','',  field describing the names of cue in the 4rd dimension
%                 will be automatically defined based on labels if not set
%
% OUTPUTS:
%
% Res= structure with the fields:
%
%     .namesStimuli: { stimuli x 1 cell}
%     .namesInhibitors: {inhibs x 1 cell}
%     .namesCues: {stimuli+inhibs x 1 cell}
%     .namesSignals: {signals x 1 cell}
%     .timeSignals: [t double]
%     .timeCues: 0
%     .valueStimuli: 3D matrix (condition x stimuli    x time)
%     .valueIhibs: 3D matrix (condition x inhibs   x time)
%     .valueSignals: 3D matrix (condition x signals x time)
%     .valueCues: 3D matrix (condition x stimuli + Inhibitors x time)
%     .DataCubeStruct: 2-D matrix (condition X dim3 x dim4) with values of dim3 and dim4 in DataCube of
%                   each experiment. Faciliates to reconstruct 5-D format
%
%
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%--------------------------------------------------------------------------
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
%    Written by Melody Morris
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe
%    SBPipeline.harvard.edu%


DefaultParameters = struct(...
    'Labels','',...
    'Model',[],...
    'DimFixed',[1 1],...
    'dim3','',...
    'dim4',''...
    );

Parameters = setParameters(DefaultParameters,Parameters);

%Julio, this part is similar to yours but GuessCueNames only takes as input the value of the
%first label for stimuli and inhibitors...i.e. Labels(#).Value{1} (this assumes that all strings in
%the Labels.Value fields have all the stimuli or inhibitors listed with their
%respective values...which I think is the canonical form.

Labels=Parameters.Labels;

if strcmpi(Labels(3).Value{1},'');
    Labels(3).Value{1} = 'No-Stim';
end

if strcmpi(Labels(4).Value{1},'');
    Labels(4).Value{1} = 'No-Inhib';
end

dim3=Parameters.dim3;
dim4=Parameters.dim4;
if isempty(dim3) && ~isempty(Labels(3).Value)
    dim3=GuessCueNames(Labels(3).Value);
end
if isempty(dim4) && isempty(regexpi(Labels(4).Value{1},'Dummy'))
    dim4=GuessCueNames(Labels(4).Value);
end

%I think everything below here is the same, except some parts are no longer
%working because dim3 and dim 4 don't have equals signs...I'll mark what
%isn't used...

%% preprocess data and labels

%Remove InputEqOutput because can not be used-note that there is a
DataCube=RemoveInputEqOutput(DataCube,struct('Labels',Labels));

Dimens=size(DataCube);
if Dimens(1)~=numel(Labels(1).Value)||Dimens(1)~=numel(Labels(1).Value)||...
        Dimens(3)~=numel(Labels(3).Value)||Dimens(4)~=numel(Labels(4).Value)||...
        Dimens(5)~=numel(Labels(5).Value)
    disp(' ')
    disp(' **dimensions of labels and data do not agree-check the input data')
    disp(' ')
    return
end


%I'm not sure why this was here, but i don't think it's needed anymore.
for inhib=1:numel(dim4)
    if ~isempty(find(strfind(dim4{inhib},'-')));
        ipos=strfind(dim4{inhib},'-')-1;
        disp([ ' ** ' dim4{inhib} ': name of inhibitor compound removed **' ]) ;
        dim4{inhib}=dim4{inhib}(1:ipos);
    end
end

%this should still work...
%remove no treatment values
counter=numel(dim3);cytok=0;
while cytok<counter
    cytok=cytok+1;
    if strcmp(dim3{cytok},'ALL')==1
        warndlg('use of ALL to define use of all stimuli is not supported')
        return
    elseif ~isempty(regexpi(dim3{cytok},'NO-')) || ~isempty(regexpi(dim3{cytok},'NOCyto'))...
            || ~isempty(regexpi(dim3{cytok},'NOStim')) || strcmpi(dim3{cytok},'No') || strcmpi(dim3{cytok},'None')
        dim3={dim3{1:cytok-1} dim3{cytok+1:end}};
        counter=counter-1;
    end
end
counter=numel(dim4);inh=0;
while inh<counter
    inh=inh+1;
    if strcmp(dim4{inh},'ALL')==1
        warndlg('use of ALL to define use of all stimuli is not supported')
        return
    elseif ~isempty(regexpi(dim4{inh},'NO-')) || ~isempty(regexpi(dim4{inh},'NOCyto'))...
            || ~isempty(regexpi(dim4{inh},'NOInhib')) || strcmpi(dim4{inh},'No') || strcmpi(dim4{inh},'None')
        dim4={dim4{1:inh-1} dim4{inh+1:end}};
        counter=counter-1;
    end
end

%for the inhibitors remove the i to match the metabolites names
if isempty(dim4)
    dim4NoI='';
elseif ~isempty(dim4{1})>0
    for i=1:numel(dim4)
        if strcmp(dim4{i}(end),'i')==1
            dim4NoI{i}=dim4{i}(1:(end-1));
        elseif ~isempty(regexp(dim4{i},'i-', 'once' ))
            posi=regexp(dim4{i},'i-', 'once' )-1;
            dim4{i}=dim4{i}([1:posi]);
        else%if ~strcmp(dim4{i},'DMSO')
            disp(' ')
            disp([' ** The inhibitor ' dim4{i} ' is not tagged with i. This does not comply with the standard data input can lead to errors.']);
            dim4NoI{i}=dim4{i};
        end
    end
else
    dim4NoI=dim4;
end
for str=1:numel(dim4NoI)
    PosPC=findstr(';',dim4NoI{str});
    if ~isempty(PosPC)
        dim4NoI{end+1}= dim4NoI{str}(PosPC(1)+1:end);
        dim4NoI{str}=   dim4NoI{str}(1:PosPC(1)-1);
    end
end
for str=1:numel(dim4)
    PosPC=findstr(';',dim4{str});
    if ~isempty(PosPC)
        dim4{end+1}= [dim4{str}(PosPC(1)+1:end) ];
        dim4{str}=   [dim4{str}(1:PosPC(1)-1) 'i'];
    end
end

if  ~isempty(dim4NoI)&&(size(dim3,2)==size(dim4NoI,1))
    dim3=dim3';
end
if  ~isempty(dim4NoI)&&(size(dim4NoI,1)==size(Labels(5).Value,2))
    dim5=Labels(5).Value';
else
    dim5=Labels(5).Value;
end

% make all dimensions same shape, with 1st dimension singleton
SDim2=size(dim3);
SDim3=size(dim4NoI);
SDim5=size(dim5);
if SDim2(1)==1&SDim2(2)>1
    dim3=dim3';
end
if SDim3(1)==1&SDim3(2)>1
    dim4NoI=dim4NoI';
end
if SDim5(1)==1&SDim5(2)>1
    dim5=dim5';
end


%% Define fields


%%
Res.namesStimuli =dim3;
Res.namesInhibitors=dim4NoI;
Res.namesSignals=dim5;

numTimeSignals=numel(Labels(2).Value);
numStimuli=numel(Res.namesStimuli);
numSignals=numel(Res.namesSignals);
numExperiments=numel(Labels(3).Value)*numel(Labels(4).Value);
numInhibitors=length(Res.namesInhibitors);

Res.timeSignals=Labels(2).Value;
Res.timeCues=0;% the MIDAS/DAtaRail format so far only support step stimulation at t=0
numTimeCues=1;
Res.valueStimuli   =nan(numExperiments,numStimuli,numTimeCues);
Res.valueSignals=nan(numExperiments,numSignals,numTimeSignals);
Res.DataCubeStruct=nan(numExperiments,2);

Res.valueInhibitors=nan(numExperiments,numInhibitors,numTimeCues);
cutoffdim3=numel(Labels(3).Value);
cutoffdim4=numel(Labels(4).Value);%this only works because this is given a dummy value
%right now, this function AND the fuzzy simulation engine assumed the
%Cues and Inhibitors have the same times of addition and removal.
%Strictly speaking, that's not true, but datarail can only hand one cue
%addition anyway so for right now this works.

%This part defines the what each labels(3).Value and labels(4).Value string
%means in terms of valueStimuli and valueInhibitors.  It is in the order given
%by namesStimuli and namesInhibitors.
cueVec=nan(cutoffdim3,numel(dim3));
inhibVec=nan(cutoffdim4,numel(dim4));
%make cue vectors
%go through each Label name
for dim3ix=1:cutoffdim3
    %figure out what the value of each stimuli is in that label
    for eachStim=1:numStimuli
        startIx=findstr(dim3{eachStim},Labels(3).Value{dim3ix});
        equalsSign=findstr('=',Labels(3).Value{dim3ix}(startIx:end));
        commas=findstr(',',Labels(3).Value{dim3ix}(startIx:end));
        %based on the type of string, store the value of the stimuli in a
        %matrix with the first dimension corresponding to the label number.
        % This will be useful when assigning to each experiment
        if isempty(startIx)
            cueVec(dim3ix,eachStim)=0;
        elseif isempty(equalsSign) && isempty(commas)
            cueVec(dim3ix,eachStim)=1;
        elseif isempty(equalsSign)
            cueVec(dim3ix,eachStim)=1;
        elseif isempty(commas)
            cueVec(dim3ix,eachStim)=str2double(Labels(3).Value{dim3ix}(startIx+equalsSign(1):end));
        elseif equalsSign(1) > commas(1)
            cueVec(dim3ix,eachStim)=1;
        else
            cueVec(dim3ix,eachStim)=str2double(Labels(3).Value{dim3ix}(startIx+equalsSign(1):startIx+commas(1)-2));
        end
        clear startIx
        clear equalsSign
        clear commas
    end
end
%make inhibitor vectors
%go through each label name
for dim4ix=1:cutoffdim4
    %figure out what the value of each stimuli is in that label
    for eachInhib=1:numInhibitors
        startIx=findstr(dim4{eachInhib},Labels(4).Value{dim4ix});
        equalsSign=findstr('=',Labels(4).Value{dim4ix}(startIx:end));
        commas=findstr(',',Labels(4).Value{dim4ix}(startIx:end));
        if isempty(startIx)
            inhibVec(dim4ix,eachInhib)=0;
        elseif isempty(equalsSign) && isempty(commas)
            inhibVec(dim4ix,eachInhib)=1;
        elseif isempty(equalsSign)
            inhibVec(dim4ix,eachInhib)=1;
        elseif isempty(commas)
            inhibVec(dim4ix,eachInhib)=str2double(Labels(4).Value{dim4ix}(startIx+equalsSign(1):end));
        elseif equalsSign(1) > commas(1)
            inhibVec(dim4ix,eachInhib)=1;
        else
            inhibVec(dim4ix,eachInhib)=str2double(Labels(4).Value{dim4ix}(startIx+equalsSign(1):startIx+commas(1)-2));
        end
        clear startIx
        clear equalsSign
        clear commas
    end
end


%%  Check if there were any inhibitors in the first place.  If not
%%  override with empty vectors.
if ~any(Res.valueInhibitors)
    Res.valueInhibitors=[];
end

%assign entries to valuesSignals, Stimuli, and
%Inhibitors. This assumes that there is a full matrix of all combinations of inhibitors and stimuli

Dim3Names = cellstr(Labels(3).Value);
Dim4Names = cellstr(Labels(4).Value);
iter=1;
%go through inhibitors
dim4ix=1;
while dim4ix <= cutoffdim4
    %and go through stimuli
    dim3ix=1;
    while dim3ix <= cutoffdim3
        %assign the correct signal values for each timeSignal
        for time=1:numTimeSignals
            Res.valueSignals(iter,:,time)=DataCube(Parameters.DimFixed(2),time,dim3ix,dim4ix,:);
        end
        %assign the corresponding stimuli and inhib values
        Res.valueStimuli(iter,:)=cueVec(dim3ix,:);
        Res.valueInhibitors(iter,:)=inhibVec(dim4ix,:);
        Res.DataCubeStruct(iter,:)=[dim3ix dim4ix];
        Res.DataCubeNames(iter,:) = {Dim3Names{dim3ix} Dim4Names{dim4ix}};
        dim3ix=dim3ix+1;
        iter=iter+1;
    end
    dim4ix=dim4ix+1;
end

Res.valueCues=[Res.valueStimuli Res.valueInhibitors];
Res.namesCues=[Res.namesStimuli; Res.namesInhibitors];



%
% % if a model is passed the positions of Cues and Signals are determined
% if ~isempty(Parameters.Model)
%     specNames=cellstr(Parameters.Model.specID);
%     numSpecies=size(Parameters.Model.interMat,1);
%     Res.Model=Parameters.Model;
%     Res.indexStimuli=[];
%     Res.indexSignals=[];
%     Res.indexInhibitors=[];
%     for cu=1:numStimuli
%         for spec=1:numSpecies
%             if strcmpi(Res.namesStimuli{cu},specNames{spec})
%                 Res.indexStimuli=[Res.indexStimuli spec];
%             end
%         end
%     end
%     for sig=1:numSignals
%         for spec=1:numSpecies
%             if strcmpi(Res.namesSignals{sig},specNames{spec})
%                 Res.indexSignals=[Res.indexSignals spec];
%             end
%         end
%     end
%
%         if isempty(regexpi(Labels(4).Value{1},'Dummy'))
%             for inhib=1:numInhibitors
%                 for spec=1:numSpecies
%                     if strcmpi(Res.namesInhibitors{inhib},specNames{spec})
%                         Res.indexInhibitors=[Res.indexInhibitors spec];
%                     end
%                 end
%             end
%         else
%             Res.indexInhibitors=[];
%         end
%
%     Res.indexCues=[Res.indexStimuli Res.indexInhibitors];
% end




function GuessedCues=GuessCueNames(Labels)

%This function finds the names within Labels(3).Values or Labels(4).Values

%initialize
GuessedCues=cellstr('');

numCues=size(Labels,1);
%go through each label
for eachLabel=1:numCues
    %see if there's anything there
    if ~isempty(Labels{eachLabel})
        %see if there are any , or =
        commas=findstr(',',Labels{eachLabel});
        equalsSign=findstr('=',Labels{eachLabel});
        %Process name before first comma
        if ~isempty(commas)
            if isempty(equalsSign)
                GuessedCues(end+1)=cellstr(Labels{eachLabel}(1:commas(1)-1));
            elseif equalsSign(1) > commas(1)
                GuessedCues(end+1)=cellstr(Labels{eachLabel}(commas(1)+1:equalsSign(1)-1));
                GuessedCues(end+1)=cellstr(Labels{eachLabel}(1:commas(1)-1));
            elseif equalsSign(1) < commas(1)
                GuessedCues(end+1)=cellstr(Labels{eachLabel}(1:equalsSign(1)-1));
            end
        elseif ~isempty(equalsSign)
            GuessedCues(end+1)=cellstr(Labels{eachLabel}(1:equalsSign(1)-1));
        else
            GuessedCues(end+1)=Labels(eachLabel);
        end
        numInnerCues=length(commas)+1;
        %Process remaining names by looking at the portion after each
        %successive comma, starting with the first comma (indexed as
        %EachName-1.
        for eachName=2:numInnerCues
            equalsSignRemaining=findstr('=',Labels{eachLabel}(commas(eachName-1)+1:end));
            commasRemaining=findstr(',',Labels{eachLabel}(commas(eachName-1)+1:end));
            %If there are more commas
            if ~isempty(commasRemaining)
                %and no equals signs after the remaining comma
                if isempty(equalsSignRemaining)
                    %take portion between comma and next comma
                    GuessedCues(end+1)=cellstr(Labels{eachLabel}(commas(eachName-1)+1:commas(eachName-1)+commasRemaining(1)-1));
                    %if there are equal signs but they are further away
                    %than the next comma
                elseif equalsSignRemaining(1) > commasRemaining(1)
                    %take portion between current and next comma as well as
                    %portion between next comma and equal sign (possibly redundant)
                    GuessedCues(end+1)=cellstr(Labels{eachLabel}(commas(eachName-1)+commasRemaining(1)+1:commas(eachName-1)+equalsSignRemaining(1)-1));
                    GuessedCues(end+1)=cellstr(Labels{eachLabel}(commas(eachName-1)+1:commas(eachName-1)+commasRemaining(1)-1));
                    %if the equals sign is before the next comma
                elseif equalsSignRemaining(1) < commasRemaining(1)
                    %take portion between current comma and equals sign
                    GuessedCues(end+1)=cellstr(Labels{eachLabel}(commas(eachName-1)+1:commas(eachName-1)+equalsSignRemaining(1)-1));
                end
                %if there were no more commas but there were more equal signs
            elseif ~isempty(equalsSignRemaining)
                %take portion between current comma and next equal sign
                GuessedCues(end+1)=cellstr(Labels{eachLabel}(commas(eachName-1)+1:commas(eachName-1)+equalsSignRemaining(1)-1));
                %if there were no more commas or equal signs
            else
                %take portion between current comma and end
                GuessedCues(end+1)=cellstr(Labels{eachLabel}(commas(eachName-1)+1:end));
            end
        end
    end
    clear equalsSign
    clear commas
    clear commasRemaining
    clear equalsSignRemaining
end
%get rid of redundant names
GuessedCues=unique(GuessedCues);
%get rid of '' fake name used for initialization
GuessedCues=GuessedCues(2:end);
%transpose
GuessedCues=GuessedCues';



