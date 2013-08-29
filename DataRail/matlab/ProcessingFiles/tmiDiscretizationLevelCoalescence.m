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
            rowIx = Hx-nansum(Hxy');
            I=nansum(rowIx)+nansum(Hy);
            tPx = Px(1:currNumLevels)+Px(2:(currNumLevels+1));
            tPxy = Pxy(1:currNumLevels,:)+Pxy(2:(currNumLevels+1),:);
            tHx = -tPx.*log2(tPx);
            tHxy = -tPxy.*log2(tPxy);
            tI = nansum([repmat(I,[1,currNumLevels]);...
                -rowIx(1:currNumLevels);...
                -rowIx(2:(currNumLevels+1));...
                (tHx-nansum(tHxy'))]);
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