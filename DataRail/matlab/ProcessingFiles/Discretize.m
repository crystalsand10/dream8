function NewData=Discretize(OldData,Parameters)
%  Discretize discretizes the Data to a specific method chosen by the user
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
% Data.data(2).Value=Discretize(Data.data(1).Value,Parameters)
%
%--------------------------------------------------------------------------
% TODO:  
%
% - implement more discretization methods
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
%    Contact: Julio Saez-Rodriguez      Arthur Goldsipe      Nickel Dittrich   Joel Wagner
%    SBPipeline.harvard.edu%

%%

DefaultParameters.Type = 1;
DefaultParameters.Value.Int = 80;
DefaultParameters.Value.DiscLevel = 3;
DefaultParameters.Value.TMI = 0;
Parameters = setParameters(DefaultParameters, Parameters);

OrigArr = OldData;

if Parameters.Type == 5
    % irrelevant here
    Parameters.Value=rmfield(Parameters.Value,'Int');
    Parameters.Value=rmfield(Parameters.Value,'TMI');
    Parameters.Value=rmfield(Parameters.Value,'DiscLevel');

    NewArr = Booleanizer(OrigArr,Parameters.Value);
else
    if length(size(OldData)) == 6           % restructure Array if there is a 6th (replicate) dimension
        OrigArr = permute(OrigArr,[6 2 3 4 5 1]);
    end
    % reshape the 5D-Array to a 2D-Matrix
    sizeVec = [size(OrigArr,1) size(OrigArr,2) size(OrigArr,3) size(OrigArr,4) size(OrigArr,5)];
    rs1 = sizeVec(1) * sizeVec(2) * sizeVec(3) * sizeVec(4);
    rs2 = sizeVec(5);
    ReshpMat = reshape(OrigArr,rs1,rs2);
    % take out NaN columns (temporary)
    TmpMat = ReshpMat;
    j=0;
    OrigArr = zeros(size(ReshpMat,1),1);
    for i=1:size(ReshpMat,1)
        if isnan(nansum(TmpMat(i,:)))
            ReshpMat(i-j,:) = '';
            OrigArr(i) = 1;
            j = j+1;
        end
    end
    % check for TMI use and if the param Value.Int was choosen correctly by
    % user
    numobs = zeros(rs2,1);
    for i=1:rs2
        numobs(i) = size(ReshpMat,1) - sum(isnan(ReshpMat(:,i)));
    end
    minnumobs = min(numobs);
    if Parameters.Value.TMI == 0
        Parameters.Value.Int = size(ReshpMat,1); %minnumobs;
    elseif Parameters.Value.Int > size(ReshpMat,1); %minnumobs
        errordlg('Desired Intervals must not exceed Dimension of DV! Value set to max possible!');
        Parameters.Value.Int = size(ReshpMat,1); %minnumobs;
    end
    % actual discretization
    if isempty(ReshpMat)
        errordlg('There are only NaNs in your Dataset! You may want to delete the created Subcube.', 'Only NaNs');
    else
        if Parameters.Type==6
            % the warning gets fairly verbose
            disp(' ')
            disp(' Running kmeans optimization 50 times and choosing best ...')
            disp(' ')
            warning off stats:kmeans:EmptyCluster
            outVec = kmeansDisc(ReshpMat,Parameters.Value.DiscLevel);
            warning on stats:kmeans:EmptyCluster
        else
            outVec = ColDiscCalc(ReshpMat,Parameters);           
        end
    end
    % reconstruct 2D-matrix (include NaN columns)
    j = 0;
    for i=1:size(TmpMat,1)
        if OrigArr(i) == 0
            TmpMat(i,:) = outVec(i-j,:);
        else
            TmpMat(i,:) = nan;
            j = j+1;
        end
    end
    % reshape to original 5D-Array format
    NewArr = reshape(TmpMat,sizeVec(1),sizeVec(2),sizeVec(3),sizeVec(4),sizeVec(5));
    % reconstruct original format (add 6th dimension if replicates dimension is
    % not singleton)
    if length(size(OldData)) == 6
        NewArr = permute(NewArr,[6 2 3 4 5 1]);
    end
end

NewData = NewArr;
        

function outVec = ColDiscCalc(A,Parameters)
%%

% declaration of variables
toys1SS=A;
numVar=size(toys1SS,2);
if Parameters.Value.TMI == 0
    numLevels = Parameters.Value.DiscLevel;
else
    numLevels = Parameters.Value.Int;
end
vout=zeros(numVar,numLevels+1);
cellObservation = cell(numVar);

% assign correct functions to different discretization methods
for i=1:numVar
    currObservation=toys1SS(:,i);
    if Parameters.Type == 1         % quantile deterministic
        vout(i,:) = quantilePolicyVector(currObservation,numLevels);
        cellObservation{i} = deterministicDiscretizationMatrix(currObservation,vout(i,:));
    elseif Parameters.Type == 2     % interval deterministc
        vout(i,:) = intervalPolicyVector(currObservation,numLevels);
        cellObservation{i} = deterministicDiscretizationMatrix(currObservation,vout(i,:));
    elseif Parameters.Type == 3     % quantile stochastic
        vout(i,:) = quantilePolicyVector(currObservation,numLevels);
        stdDev = stdnan(vout);
        % stdDev = stdnan(vout(i,:)... ???
        cellObservation{i} = stochasticDiscretizationMatrix(currObservation,vout(i,:),stdDev);
    elseif Parameters.Type == 4     % interval stochastic
        vout(i,:) = intervalPolicyVector(currObservation,numLevels);
        stdDev = stdnan(vout);
        cellObservation{i} = stochasticDiscretizationMatrix(currObservation,vout(i,:),stdDev);
    end
end

% create split Matrix
if Parameters.Value.TMI == 1
    dendogram=tmiDiscretizationLevelCoalescence(cellObservation);
    dendogramInput=dendogram(:,:,1);
    splitHere=constructDendogramTMI(vout,dendogramInput,numVar,numLevels);
% else
%     splitHere = constructDendogram(vout,numVar,numLevels);
end

% choose actual split vector
desiredLevels=Parameters.Value.DiscLevel;
desiredLevelsAdj=desiredLevels-1;
splitVec=zeros(numVar,desiredLevelsAdj);
for i=1:numVar
    if Parameters.Value.TMI == 1
        currSplitVec=splitHere{i,(numLevels-desiredLevelsAdj)};
    else
        currSplitVec = vout(i,:);
    end
    splitVec(i,:)=currSplitVec(2:desiredLevels);
end


cellData=cell(numVar,1);
for i=1:numVar
    cellData(i)={toys1SS(:,i)};
end


finalOutput=finalDiscStepv2(cellData,splitVec,numVar);
outVec = zeros(length(finalOutput{1}),numVar);
for i=1:numVar
    outVec(:,i)=finalOutput{i}';
end



function qpv=quantilePolicyVector(observationVec,numLevels)
%%
sortedObserv=sort(observationVec);
qpv=zeros(1,numLevels-1);
numExp=length(observationVec);
for j=1:(numLevels-1)
    bndryIdx=floor(j*numExp/numLevels);
    qpv(j)=(sortedObserv(bndryIdx)+sortedObserv(bndryIdx+1))/2;
end
qpv=[-inf,qpv,inf];


function ipv = intervalPolicyVector(observationVec,numLevels)
%%
sortedObserv = sort(observationVec);
ipv = zeros(1,numLevels-1);    
bndrySpacing = (sortedObserv(end) - sortedObserv(1))/numLevels;
for j=1:(numLevels-1)
    ipv(j) = sortedObserv(1) + (j*bndrySpacing);
end
ipv = [-inf,ipv,inf];



function dd = deterministicDiscretizationMatrix(observationVec,discPolicyVec)
%%
numObserv = length(observationVec);
numLevels = length(discPolicyVec)-1;
dd = zeros(numObserv,numLevels);
[ignore,binIdx] = histc(observationVec,discPolicyVec);
for i = 1:numLevels
    dd(:,i) = (binIdx == i);
end



function sd = stochasticDiscretizationMatrix(observationVec,discPolicyVec,stdDev)
%%
numObserv = length(observationVec);
numLevels = length(discPolicyVec) - 1;
sd = zeros(numObserv,numLevels);
for i=1:numObserv
    currObserv = observationVec(i);
    normCumDist = normcdf(discPolicyVec,currObserv,stdDev);
    sd(i,:) = normCumDist(2:numLevels+1) - normCumDist(1:numLevels);
end



function coalescenceInfo = tmiDiscretizationLevelCoalescence(arrayOfDiscMatrices)
%%
numVar = length(arrayOfDiscMatrices);
[numObserv,numLevels] = size(arrayOfDiscMatrices{1});
numDLC = numLevels-1;
coalescenceInfo = zeros(numDLC,numVar,2);

for i = 1:numDLC
    for j = 1:numVar
        currNumLevels = numLevels-i;
        sumI=zeros(1,currNumLevels);
        for k = setdiff(1:numVar,j)
            Px=nansum(arrayOfDiscMatrices{j})/numObserv;
            Py=nansum(arrayOfDiscMatrices{k})/numObserv;
            Pxy=(arrayOfDiscMatrices{j}'*arrayOfDiscMatrices{k})/numObserv;
            Hx=-Px.*log2(Px);
            Hy=-Py.*log2(Py);
            Hxy=-Pxy.*log2(Pxy);
            rowIx = Hx-(nansum(Hxy,2))';
            I=nansum(rowIx)+nansum(Hy);
            tPx = Px(1:currNumLevels)+Px(2:(currNumLevels+1));
            tPxy = Pxy(1:currNumLevels,:)+Pxy(2:(currNumLevels+1),:);
            tHx = -tPx.*log2(tPx);
            tHxy = -tPxy.*log2(tPxy);
            tI = nansum([repmat(I,[1,currNumLevels]);...
                -rowIx(1:currNumLevels);...
                -rowIx(2:(currNumLevels+1));...
                (tHx-(nansum(tHxy,2))')]);
            sumI=sumI+tI;
        end
        [maxMutualInfo,maxIdx] = max(sumI);
        coalescenceInfo(i,j,:) = [maxIdx,maxMutualInfo];
    end
    for j = 1:numVar
        coalesceIdx = coalescenceInfo(i,j,1);
        currDiscMatrix = arrayOfDiscMatrices{j};
        currDiscMatrix(:,coalesceIdx) = currDiscMatrix(:,coalesceIdx)+...
            currDiscMatrix(:,coalesceIdx+1);
        currDiscMatrix(:,coalesceIdx+1) = [];
        arrayOfDiscMatrices{j} = currDiscMatrix;
    end
end



function qvpAdj=constructDendogramTMI(qvp,dendogramMat,numVar,numLevels)
%%
qvpAdj=cell(numVar,numLevels);
for i=1:numVar
    qvpAdj(i,1)={qvp(i,1:numLevels+1)};
    for j=2:numLevels
        merge=dendogramMat(j-1,i);
        qvpPrev=qvpAdj{i,j-1};
        lPrev=length(qvpPrev);
        mergeLimit=lPrev-2;
        if merge == 1
            qvpNew1=qvpPrev(1);
            qvpNew2=qvpPrev(merge+2:end);
            qvpAdj(i,j)={[qvpNew1 qvpNew2]};
        elseif merge == mergeLimit
            qvpNew1=qvpPrev(1:merge);
            qvpNew2=qvpPrev(end);
            qvpAdj(i,j)={[qvpNew1 qvpNew2]}; 
        else
            qvpNew1=qvpPrev(1:merge);
            qvpNew2=qvpPrev(merge+2:end);
            qvpAdj(i,j)={[qvpNew1 qvpNew2]};
        end
    end
end


function dendogram = constructDendogram(qvp, numVar, numLevels)
%%
dendogram = cell(numVar, numLevels);
for i = 1:numVar
    cellvalue = qvp(i,1:numLevels+1);
    cellvalue(isnan(cellvalue)) = -inf;
    dendogram(i,1) = {cellvalue};
    mergevec = zeros(1,length(cellvalue-1));
    for j = 2:numLevels
        mergevec(1) = inf;
        for k = 2:length(cellvalue-1)
            mergevec(k) = cellvalue(k) - cellvalue(k-1);            
        end
        mergevec(end) = '';
        [ignore, mergehere] = min(mergevec);
        if mergehere > 1
            if ignore > -inf
                cellvalue(mergehere) = (cellvalue(mergehere) + cellvalue(mergehere-1)) / 2;
                cellvalue(mergehere-1) = '';
            else
                cellvalue(mergehere) = '';
            end
        else
            cellvalue(2) = '';
        end
        dendogram(i,j) = {cellvalue};
    end
end


function newData=finalDiscStepv2(dataArr,cutoffVec,numVar)
newData=cell(numVar,1);
currNewData = zeros(1,length(dataArr{numVar}));

% cutoffVec

for i=1:numVar
    currObs=dataArr{i};
    lcurrObs=length(currObs);        
    cut = [cutoffVec(i,:) inf];
    for j=1:lcurrObs
        dataPoint=currObs(j);
        if isnan(dataPoint);
            currNewData(j) = NaN;
        else
            currNewData(j) = find(cut >= dataPoint,1,'first');
        end
    end
    newData(i)={currNewData};
end


%% function by J. Wagner to discretize using kmeans;
% idx_raw2 is the discretized data properly reordered
function idx_raw2=kmeansDisc(QuantData,num_disc_levels)

A=QuantData';
clear QuantData

nNodes=size(A,1);
idx_raw = [];
c_raw = [];
for i = 1:nNodes
    % Here this assumes 3-level discretized data and 50 replicates of k-means
    % (k-means is stochastic, so you have to run it multiple times and take the best result)
    [idx_raw(i,:) c_raw(i,:)] = kmeans(A(i,:), num_disc_levels, 'replicates', 50, 'emptyaction', 'singleton');
end

% convert_disc_data re-orders the data (so that 1 = low, 2 = med., and 3 = high, for example) after the k-means discretization procedure
for i = 1:size(A,1)   
    arity = max(idx_raw(i,:));
    
    for j = 1:arity
        level{j} = find(idx_raw(i,:) == j);
        
        averages(j) = mean(A(i,level{j}));
    end
    [vals index] = sort(averages);
    
    for j = 1:arity
        idx_raw2(i,level{j}) = find(index == j);
    end    
end
idx_raw2=idx_raw2';