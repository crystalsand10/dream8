function BoolData =Booleanizer(QuantData,OldParameters)
% discretize an5-D canonical data cube into a 5D {0,1} cube
%
% BooleanData =Booleanizer(QuantData,Parameters)
%
%
%
% Rationale:
%
% This function is thought to be used to perform a Boolean analysis or to
% characterize the dynamics of the signals upon stimuli (used in plotting)
%
% To be used within a Boolean Framework, the data has to be discretized.
% In our case our models only include 2 possible values for the states (0 or 1).
% We assume that, for time 0, all states are at value 0, except constitutive
% inhibitors ('NegatOnes',  e.g. Ikb), which are active (1).
% Besides, we consider 2 time scales, t=1 and t=2, corresponding to early and late time scale.
% Thus, we have to decide whether the state changes from t=0 to t=1 from 0 to 1 (or 1 to 0), and,
% if the state reaches the value 1 at t=1, it stays at value 1 for t=2  or goes down to 0.
%
% To take the decision for time t=1, we use 3 criteria, each of which
% requires a threshold which has to be defined by the user:
%
% i) Significant increase
% Signal(t=1)/Signal(t=0))> SigniPeak
%
% ii) Signal significant with respect to maximum for this signal
% Signal(t=1)/Signal_max > ThresMax
%
% iii) Signal above experimental noise
% Signal(t=1) > MinSignal
%
% Finally, to define whether the signal decays at t=2, we define a new condition
% Signal(t=2)/Signal(t=1)< SigniDec
%
% We use the threshold to respect to the maximum instead of e.g. uni variance to discretize the data.
% The reason is that here one has to define whether see if a signal
% has a significant increase from a certain resting state.
% If a signal goes up upon different conditions,
% this should not change the fact that the signal is going up.
% If one would use unit variance, then all these signals will be pushed down.
% This perspective is different to e.g. PLSR where one is interested
% in which conditions the change is more significant than in the rest.
%
%--------------------------------------------------------------------------
% INPUTS:
%
% QuantData = a canonical 5D datacube
%
% Parameters:
%  .SigniPeak(0.5)  = threshold for a significant incresae, see above
%   .SigniDec(0.5)  = threshold for a significant decrease, see above
%   .ThreshMax(0.1) = threshold for a significant value with respect of
%                     rest of signals for the same readout, see above
%   .MinSignal(500) = experimental error, see above
%   .MaxSignal(18000) = experimental error, see above
%   .NegatOnes()= function assumes 0 for t=0;
%                     States whose value is in resting state is 1 are listed here
%                     instead of 0 and may go to 0 upon activation
%                     (e.g. when we are measruing the inhibitory site of a kinase)
%   .LabelsSignals  = Labels of Signals to map them to NegatOnes
%    .Fuzzify(true) = you can choose an actual boolean(0/1) value or a
%    continuous value between 0 and 1, the difference between the fold
%    increase and Parameter.SignalPeak determines how close it is to 1 or 0
%    .hillcoeff(2)          = hill coefficient for the mapping of the fold
%                                   increase to a value between 0 and 1
%    .Criterium('Relat') = The change can be a fold increase(t=2/t=1) or a 
%                                  relative change (t=2-t=1)/t=2
%    .ValueNoisy(NaN)  = what value to give to data which is noisy. You may
%                       want to make it zero
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% Data.data(4).Value =Booleanizer(Data.data(3).Value,Parameters)
%
% OR
%
% Data.data(3) = createDataCube(...
%    'Name', 'Boolean', ...
%    'Info', 'data converted to digitalform',...
%    'Labels', Data.Labels, ...
%    'Code', @Booleanizer,...
%    'Parameters', {'SigniPeak', 0.6, 'SigniDec', 0.6, 'ThreshMax', 0.25, ...
%        'MinSignal', .51, 'NegatOnes', {'Ikb', 'GSK3'},'Fuzzify',true,...
%        'LabelsSignals', Data.Labels(5).Value}, ...
%  'hillcoeff',2,...
%    'Boolean',true,...
%    'Criterium','Fold',...
%    'SourceData', Data.data(ChrisData.v.preBoolean));
%--------------------------------------------------------------------------
% TODO:
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

%%Default parameters
DefaultParameters = struct(...
    'SigniPeak',0.5,...
    'SigniDec', 0.5,...
    'ThreshMax',0.1,...
    'MinSignal',500,...
    'MaxSignal',18000,...
    'NegatOnes',{{}},...
    'hillcoeff',2,...
    'Fuzzify',true,...
    'Criterium','Relat',...
    'ValueNoisy',NaN,...
    'LabelsSignals', {@(x)('')});

Parameters = setParameters(DefaultParameters,OldParameters);
h=Parameters.hillcoeff;
RelatData=zeros(size(QuantData));
BoolData=NaN(size(QuantData));

if Parameters.SigniPeak<1&&strcmp(Parameters.Criterium,'Fold')
    disp(['Parameters.SigniPeak for fold increase is <1, the fold increase threshold will be then its inverse=' num2str(1/Parameters.SigniPeak)])
    Parameters.SigniPeak=1/Parameters.SigniPeak;
elseif Parameters.SigniPeak>1&&~strcmp(Parameters.Criterium,'Fold')
    disp(' Parameters.SigniPeak for relative increase is >1 (non consistent); the threshold will be set to its inverse')
    Parameters.SigniPeak=1/Parameters.SigniPeak;
end

%zeros for t=0
BoolData(:,1,:,:,:)=zeros(size(BoolData(:,1,:,:,:)));

%% For size 3
if size(QuantData,2)==3
    for cell=1:size(QuantData,1)
        for measure=1:size(QuantData,5)
            for cyt=1:size(QuantData,3)
                for inh=1:size(QuantData,4)
                    %Compute relative signal (signal/max for this measurement-required to see if signal is relevant enough)
                    if max(max(max(QuantData(cell,:,:  ,: ,measure))))<Parameters.MinSignal
                        %if max is 0 to avoid 0/0 problems we define values to zero
                        RelatData(cell,1,cyt,inh,measure)=0;
                        RelatData(cell,2,cyt,inh,measure)=0;
                        RelatData(cell,3,cyt,inh,measure)=0;
                        BoolData(cell,1,cyt,inh,measure)=Parameters.ValueNoisy;
                        BoolData(cell,2,cyt,inh,measure)=Parameters.ValueNoisy;
                        BoolData(cell,3,cyt,inh,measure)=Parameters.ValueNoisy;
                    else
                        RelatData(cell,1,cyt,inh,measure)=QuantData(cell,1,cyt,inh,measure)/max(max(max(QuantData(cell,:,:  ,: ,measure))));
                        RelatData(cell,2,cyt,inh,measure)=QuantData(cell,2,cyt,inh,measure)/max(max(max(QuantData(cell,:,:  ,: ,measure))));
                        RelatData(cell,3,cyt,inh,measure)=QuantData(cell,3,cyt,inh,measure)/max(max(max(QuantData(cell,:,:  ,: ,measure))));
%% Decide for t=2/t=1
                        %Define the fold change
                        if  QuantData(cell,2,cyt,inh,measure)<=QuantData(cell,1,cyt,inh,measure)
                            Fold =0;
                        elseif strcmp(Parameters.Criterium,'Fold')
                            Fold  =QuantData(cell,2,cyt,inh,measure)/QuantData(cell,2,cyt,inh,measure);
                        elseif  strcmp(Parameters.Criterium,'Relat')
                            Fold  =(QuantData(cell,2,cyt,inh,measure)-QuantData(cell,1,cyt,inh,measure))/QuantData(cell,1,cyt,inh,measure);
                        elseif strcmp(Parameters.Criterium,'RelatToZeroCond')
                            Fold  =(QuantData(cell,2,cyt,inh,measure)-QuantData(cell,1,1,1,measure))/QuantData(cell,1,1,1,measure);
                        end
                        
%% Decide for t=2/t=3
                        FoldD=(QuantData(cell,3,cyt,inh,measure)-QuantData(cell,2,cyt,inh,measure))/QuantData(cell,2,cyt,inh,measure);
                        %
                        if RelatData(cell,2,cyt,inh,measure)>Parameters.ThreshMax&&(QuantData(cell,2,cyt,inh,measure)>=Parameters.MinSignal )
                            BoolData(cell,2,cyt,inh,measure)= Hillf(Fold,Parameters.SigniPeak,h);
                            if BoolData(cell,2,cyt,inh,measure)>0.5%.t=2 is on
                                if FoldD<0 % HillF makes it always >0, so we need two cases
                                    BoolData(cell,3,cyt,inh,measure)= 1-Hillf(FoldD,Parameters.SigniDec,h);
                                else
                                    BoolData(cell,3,cyt,inh,measure)=BoolData(cell,2,cyt,inh,measure)+Hillf(FoldD,Parameters.SigniDec,h);
                                    if BoolData(cell,3,cyt,inh,measure)>1
                                        BoolData(cell,3,cyt,inh,measure)=1;
                                    end                                        
                                end
                            else%t=2 is off->apply to t=1->t=3
                                if strcmp(Parameters.Criterium,'Fold')
                                    Fold=QuantData(cell,3,cyt,inh,measure)/QuantData(cell,1,cyt,inh,measure);
                                else
                                    Fold=(QuantData(cell,3,cyt,inh,measure)-QuantData(cell,1,cyt,inh,measure))/QuantData(cell,3,cyt,inh,measure);
                                end
                                 if Fold<0 % HillF makes it always >0, so we need two cases
                                    BoolData(cell,3,cyt,inh,measure) = 0;
                                 else
                                    BoolData(cell,3,cyt,inh,measure)=  Hillf(Fold,Parameters.SigniPeak,h);
                                 end
                            end
                        else%ThresMax and MinSignal are KO criterion
                            if RelatData(cell,2,cyt,inh,measure)<Parameters.ThreshMax
                                BoolData(cell,2,cyt,inh,measure)=0;
                            elseif QuantData(cell,2,cyt,inh,measure)<Parameters.MinSignal
                                BoolData(cell,2,cyt,inh,measure)=Parameters.ValueNoisy;%t=2 is off->apply to t=1->t=3
                                % if is a nan comparisons can not take place; oherwise they should be one or the other...
                            elseif ~any(isnan(QuantData(cell,:,cyt,inh,measure)))
                                MyWarning('error-some inconsistency in code')
                                return
                            end
                            if  RelatData(cell,3,cyt,inh,measure)>Parameters.ThreshMax&&(QuantData(cell,3,cyt,inh,measure)> Parameters.MinSignal )
                                if strcmp(Parameters.Criterium,'Fold')
                                    Fold=QuantData(cell,3,cyt,inh,measure)/QuantData(cell,1,cyt,inh,measure);
                                else
                                    Fold=(QuantData(cell,3,cyt,inh,measure)-QuantData(cell,1,cyt,inh,measure))/QuantData(cell,3,cyt,inh,measure);
                                end
                                BoolData(cell,3,cyt,inh,measure)=Hillf(Fold,Parameters.SigniPeak,h);
                            else
                                if  RelatData(cell,3,cyt,inh,measure)<Parameters.ThreshMax
                                    BoolData(cell,3,cyt,inh,measure)=0;
                                else
                                    BoolData(cell,3,cyt,inh,measure)=Parameters.ValueNoisy;
                                end
                            end
                        end
%%                        
                    end
                    %Inverse data when measurement corresponds to negative effect
                    if isempty(nonzeros(strcmpi(Parameters.NegatOnes,Parameters.LabelsSignals(measure))))==0
                        BoolData(cell,:,cyt,inh,measure)=1-BoolData(cell,:,cyt,inh,measure);
                    end
                end
            end
        end
    end

%% For size 2
elseif size(QuantData,2)==2
    for cell=1:size(QuantData,1)
        for measure=1:size(QuantData,5)
            for cyt=1:size(QuantData,3)
                for inh=1:size(QuantData,4)
                    %Compute relative signal (signal/max for this measurement-required to see if signal is relevant enough)
                    if max(max(max(QuantData(cell,:,:  ,: ,measure))))<Parameters.MinSignal
                        %if max is 0 to avoid 0/0 problems we define values to zero
                        RelatData(cell,1,cyt,inh,measure)=0;
                        RelatData(cell,2,cyt,inh,measure)=0;
                        BoolData(cell,1,cyt,inh,measure)= Parameters.ValueNoisy;
                        BoolData(cell,2,cyt,inh,measure)= Parameters.ValueNoisy;
                    else
                        RelatData(cell,1,cyt,inh,measure)=QuantData(cell,1,cyt,inh,measure)/max(max(max(QuantData(cell,:,:  ,: ,measure))));
                        RelatData(cell,2,cyt,inh,measure)=QuantData(cell,2,cyt,inh,measure)/max(max(max(QuantData(cell,:,:  ,: ,measure))));
                        %Define the fold change
                        if  QuantData(cell,2,cyt,inh,measure)<=QuantData(cell,1,cyt,inh,measure)
                            Fold =0;
                        elseif strcmp(Parameters.Criterium,'Fold')
                            Fold  =QuantData(cell,2,cyt,inh,measure)/QuantData(cell,1,cyt,inh,measure);
                        elseif  strcmp(Parameters.Criterium,'Relat')
                            Fold  =(QuantData(cell,2,cyt,inh,measure)-QuantData(cell,1,cyt,inh,measure))/QuantData(cell,1,cyt,inh,measure);
                        else
                            if  QuantData(cell,2,cyt,inh,measure)<=QuantData(cell,1,1,1,measure)
                                Fold=0;
                            else
                                Fold  =(QuantData(cell,2,cyt,inh,measure)-QuantData(cell,1,1,1,measure))/QuantData(cell,1,1,1,measure);
                            end
                        end
                        Relat=RelatData(cell,2,cyt,inh,measure);
                        if QuantData(cell,2,cyt,inh,measure)> Parameters.MinSignal
                            BoolData(cell,2,cyt,inh,measure)= Fold^h/((Parameters.SigniPeak)^h+Fold^h)...
                                *Hillf(Relat,Parameters.ThreshMax,1);
                        else
                            BoolData(cell,2,cyt,inh,measure)=0 ;
                        end
                        if BoolData(cell,2,cyt,inh,measure)<0.5&&min(QuantData(cell,:,cyt,inh,measure))>Parameters.MaxSignal
                            try
                                Cell=Parameters.Labels(1).Value{cell};
                            catch
                                Cell=num2str(cell);
                            end
                            try
                                Stim=Parameters.Labels(3).Value{cyt};
                            catch
                                Stim=num2str(cyt);
                            end
                            try
                                Inhib=Parameters.Labels(4).Value{inh};
                            catch
                                Inhib=num2str(inh);
                            end
                            try
                                Sign=Parameters.Labels(5).Value{measure};
                            catch
                                Sign=num2str(measure);
                            end
                            msg=['device saturated for cell ' Cell ', stimulus ' Stim ...
                                ', inhibitor ' Inhib ', signal ' Sign];
                            disp(msg);
                            BoolData(cell,2,cyt,inh,measure)=NaN;
                        end
                        %Inverse data when measurement corresponds to negative effect
                        if isempty(nonzeros(strcmpi(Parameters.NegatOnes,Parameters.LabelsSignals(measure))))==0
                            BoolData(cell,:,cyt,inh,measure)=1-BoolData(cell,:,cyt,inh,measure);
                        end
                    end
                end
            end
        end
    end
%% other cases not supported
else
    warning('In the current implementation of Booleanizer, the data cube must have 2 or 3 time points. For more than 3 time points, the cube has been filled with NaNs')
    return
end

% Ensures that if raw data is not avaialble, no normalized data is created, and a nan is kept instead
BoolData(isnan(QuantData)) = NaN;

%% 
disp(' ')
if ~Parameters.Fuzzify
    BoolData=round(BoolData);
    disp('Values are rounded to 0 or 1')
else
   % disp('Values are not rounded to 0 or 1.')
end

%% 
function Val=Hillf(Fold,Threshold,h)
       if Fold==Inf
           Val=1;
       else           
           Val=Fold^h/(Threshold^h+Fold^h);
       end       

       
       


