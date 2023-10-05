function [bestk,bestpp,bestmu,bestcov,dl,countf] = mixtures4_circular( yIn )
%PREPROCESSDATA Summary of this function goes here
%   Detailed explanation goes here
yOut = yIn;

yOut(yOut<0) = yOut(yOut<0) + 2*pi;
yOut = mod(yOut,2*pi);

y2 = yOut;
y2(end+1:2*end) = y2 + 2*pi;

y4 = y2;
y4(end+1:2*end) = y2 + 4*pi;

h = hist(y4*180/pi,0:8*180);

filt = fspecial('gaussian',101,15);
filt = filt(51,:);
filt = filt/ sum(filt);

hFilt = conv(h,filt,'same');

hFilt = hFilt(2*180+1:4*180);

[~, cutInd] = min(hFilt);
cutStep = 1;

cutDeg = 0 + (cutInd-1)*cutStep;

yIn = yIn - (cutDeg/180*pi);
yIn(yIn<0) = yIn(yIn<0) + 2*pi;
yIn = mod(yIn, 2*pi);

[bestk,bestpp,bestmu,bestcov,dl,countf] = mixtures4(yIn',1,10,0,1e-3,0,[],[],1);

bestmu = bestmu + (cutDeg/180*pi);
bestmu = mod(bestmu, 2*pi);
bestmu(bestmu>pi) = bestmu(bestmu>pi) - 2*pi;

end

