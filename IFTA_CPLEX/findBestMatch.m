function p = findBestMatch(thisFlow, previousFlow)

%nbDir = length(thisFlow.mean,1);

for i = 1:length(thisFlow)
    thisDegree(i) = thisFlow(i).degMean;
end

for i = 1:length(previousFlow)
    previousDegree(i) = previousFlow(i).degMean;
end

err = zeros(length(thisDegree));

for i = 1:length(thisDegree)
    for j = 1:length(thisDegree)
        err(i,j) = thisDegree(i)-previousDegree(j);
    end
end
err = mod(err,360);
err(err>180) = 360 - err(err>180);

allP = perms(1:length(thisDegree));

for i = 1:size(allP,1)
    inds = sub2ind(size(err),[1:length(thisDegree)],allP(i,:));
    allPErrors(i) = sum(sum(err(inds)));
end

[minP minPind] = min(allPErrors);

p = allP(minPind,:);

% err1 = [mod((thisFlow(1).degree - previousFlow(1).degMean),365) , mod((thisFlow(2).degMean - previousFlow(2).degMean),365)];
% err1(err1>180) = 365 - err1(err1>180);
% err1 = sum(err1);
% 
% err2 = [mod((thisFlow(1).degMean - previousFlow(2).degMean),365) , mod((thisFlow(2).degMean - previousFlow(1).degMean),365)];
% err2(err2>180) = 365 - err2(err2>180);
% err2 = sum(err2);
% 
% if err1<= err2
%     p2 = [1, 2];
% else
%     p2 = [2, 1];
% end
% 
% keyboard;
return