function currentVec = getFlowVec(flowmap, currentPoint, magVec, thetaVec)

magMean = magVec(1);
magStd = magVec(2);

thetaMean = thetaVec(1);
thetaStd = thetaVec(2);


% Assuming normal distribution for both

theta = (randn(1) * thetaStd + thetaMean) / 180 * pi;  % original number is in degree
mag = randn(1) * magStd + magMean;



if (rand(1) >= 0.5)  % simulate antiparallel flow. Decide direction randomly
        % Height coordinate comes first.
        currentVec = [mag * sin(theta), mag * cos(theta)];
else
        currentVec = [-mag * sin(theta), -mag * cos(theta)];
end
