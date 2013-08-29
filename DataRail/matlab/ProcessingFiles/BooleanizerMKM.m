function [BoolData] =BooleanizerMKM(DataCube,Parameters)

% DataCube: 5-D data cube
% Parameters:
%   Sat : Saturation level
%   Noise: Noise level
%   EC50: EC50 for data
%   HillCoeff: Hill Coeff for data
%   EC50Noise: EC50 for noise penalty
%   HillCoeffNoise: Hill Coeff for noise penalty
%
% Output is datacube of the same size with 'zero' as the first time point


DefaultParameters = struct(...
    'DimWithControl',2,...
    'EC50',0.5,...
    'ChangeThresh', 0,...
    'HillCoeff',2,...
    'MinSignal',0,...
    'MaxSignal',inf,...
    'EC50Noise',0.1);

Parameters = setParameters(DefaultParameters,Parameters);


[NumCells NumTimes NumStim NumInhib NumSignals] = size(DataCube);

PosData = false(size(DataCube));
NegData = false(size(DataCube));
ZeroData = false(size(DataCube));
RelatData = nan(size(DataCube));
BoolData = nan(size(DataCube));
DataToFigureMax = nan(size(DataCube));

% Any value above the saturation limit of the machine or below the
% detection level are replaced by NaNs at the end.
NanData = DataCube > Parameters.MaxSignal | DataCube < Parameters.MinSignal | isnan(DataCube);


% Calculate the Relative change (to be Hilled).  This part saves values
% that increased or decreased signficantly (above the threshold set by
% ThreshMax) because they will be treated differently when the final value
% is calculated.  Note that each time point is compared to the control
% point (time zero or basal...in the first time dimension).
if Parameters.DimWithControl == 2
    NanData(:,1,:,:,:) = false;
    for i=1:NumTimes
        RelatData(:,i,:,:,:) = abs(DataCube(:,i,:,:,:)-DataCube(:,1,:,:,:))./DataCube(:,1,:,:,:);
        PosData(:,i,:,:,:) = (DataCube(:,i,:,:,:)-DataCube(:,1,:,:,:))./DataCube(:,1,:,:,:) > Parameters.ChangeThresh;
        NegData(:,i,:,:,:) = (DataCube(:,i,:,:,:)-DataCube(:,1,:,:,:))./DataCube(:,1,:,:,:) < -1*Parameters.ChangeThresh;
        ZeroData(:,i,:,:,:) = ~PosData(:,i,:,:,:) & ~NegData(:,i,:,:,:);
    end
elseif Parameters.DimWithControl == 3
    NanData(:,:,1,:,:) = false;
    for i = 1:NumStim
        RelatData(:,:,i,:,:) = abs(DataCube(:,:,i,:,:)-DataCube(:,:,1,:,:))./DataCube(:,:,1,:,:);
        PosData(:,:,i,:,:) = (DataCube(:,:,i,:,:)-DataCube(:,:,1,:,:))./DataCube(:,:,1,:,:) > Parameters.ChangeThresh;
        NegData(:,:,i,:,:) = (DataCube(:,:,i,:,:)-DataCube(:,:,1,:,:))./DataCube(:,:,1,:,:) < -1*Parameters.ChangeThresh;
        ZeroData(:,:,i,:,:) = ~PosData(:,:,i,:,:) & ~NegData(:,:,i,:,:);
    end
end
% Transform the data with a hill function
HillData = RelatData.^Parameters.HillCoeff./(Parameters.EC50^Parameters.HillCoeff+RelatData.^Parameters.HillCoeff);
% HillData(:,1,:,:,:)=0;

% Caluclate the penatly for maybe being noisey.  The data is compared to
% the maximum, which is determined without considering values above/below
% saturation.
DataToFigureMax(~NanData) = DataCube(~NanData);
if Parameters.EC50Noise > 0
    if size(DataCube,1) > 1
        CNOWarning('Calculating max signal based on all cell types provided!  If this is not what you wanted, create subcubes with each cell type before Booleanizing!')
    end
    RelatMax = nan(size(DataCube));
    for i = 1:NumSignals
        maxVal = max(max(max(max(DataToFigureMax (:,:,:,:,i)))));
        RelatMax(:,:,:,:,i) = abs(DataCube(:,:,:,:,i))/maxVal;
    end
    HillMax = RelatMax./(Parameters.EC50Noise+RelatMax);
%     HillMax(:,1,:,:,:)=0;
else
    HillMax = ones(size(DataCube));
end

BoolData(logical(PosData)) = HillMax(logical(PosData)).*HillData(logical(PosData));
BoolData(logical(NegData)) = - HillMax(logical(NegData)).*HillData(logical(NegData));

BoolData(ZeroData) = 0;

BoolData(NanData) = NaN;