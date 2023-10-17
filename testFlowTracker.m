function [trackedLinks,flow]=testFlowTracker

load('M:\unc\resultsAlex\Meta10sNov17\cands\cands01.mat');
cands1=cands;
clear cands;
LL1=length(cands1);
cands1=cands1(find([cands1.status]==1));
L1=length(cands1);
%--------------------------------------------------------------------------
load('M:\unc\resultsAlex\Meta10sNov17\cands\cands02.mat');
cands2=cands;
clear cands;
LL2=length(cands2);
cands2=cands2(find([cands2.status]==1));
L2=length(cands2);
%--------------------------------------------------------------------------
load('M:\unc\resultsAlex\Meta10sNov17\cands\cands03.mat');
cands3=cands;
clear cands;
LL3=length(cands3);
cands3=cands3(find([cands3.status]==1));
L3=length(cands3);
%-----------------------------------------------------------------------
for i=1:L1
    y1(i) = cands1(i).Lmax(1);
    x1(i) = cands1(i).Lmax(2);
end
frames1.pos=[y1',x1'];

for i=1:L2
    y2(i) = cands2(i).Lmax(1);
    x2(i) = cands2(i).Lmax(2);
end
frames2.pos=[y2',x2'];

for i=1:L3
    y3(i) = cands3(i).Lmax(1);
    x3(i) = cands3(i).Lmax(2);
end
frames3.pos=[y3',x3'];
%--------------------------------------------------------------------------
trackedLinks = [];
% [trackedLi,flowN,cluster_index,bestmu,flowMap,dir] = testW4redSpindle(frames1.pos,frames2.pos,frames3.pos,dist);
[trackedLi,flowN,cluster_index,bestmu,flowMap,dir] = flowTracker(frames1.pos,frames2.pos,frames3.pos,5,1,1,1,2,1,1,0);

trackedLinks = [trackedLinks;trackedLi];
%-----------------------------------------------------------------------
scaling=1;
Map = [trackedLinks(:,1:4);trackedLinks(:,3:6)]; %DISPLAYS THE RESULT OF THE TRACKER
h0 = vectorFieldPlot(Map,0,[],scaling);
axis ij
axis(gca,'equal')
%-------------------------------------------------------
I = imread('M:\unc\data\SpindleRedRawAligned\RedRawAligned01.tif');
name = 'redSpindle';
rate = 10;
pixelS = 67;
%-----------------------------------------------------------------------
shift = 10;
img = double(Gauss2D(I,1));
h = figure;
imshow(img(1+shift:end-shift,1+shift:end-shift),[]);
hold on
for i = 1:length(bestmu)
    hEachD = vectorFieldPlot(dir(i).map-shift,h,[],3);
end
hold off



