function [frame1,frame2,frame3]=readCands(i)

s = 2;
strg=sprintf('%%.%dd',s);

indxStr=sprintf(strg,i);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\sparseSpeckleData\spindle3\test003\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\monopole\xaug05_04_r06f\croppedData\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_r03c\test002\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\ptk1_control_actin_myosin\actin\analysis\tack\cands\cands',indxStr,'.mat']);

load(['X:\AlexResults\Meta10sNov17\cands\cands',indxStr,'.mat']);
% load(['M:\unc\Test_WH_data\tub29\test002\cands\cands',indxStr,'.mat']);
% load('X:\AlexResults\june8ss3polar\candsOLD\cands1501.mat');
% load('U:\Meta2SpFeb26\cands\cands001.mat');
% load('U:\Meta4SpFeb28\cands\cands070.mat');
% load('S:\scripps\retro1\analysis_retro1\cands\cands01.mat');
cands1=cands;
clear cands;
LL1=length(cands1);
cands1=cands1(find([cands1.status]==1));
L1=length(cands1);

indxStr=sprintf(strg,i+1);  
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\sparseSpeckleData\spindle3\test003\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\monopole\xaug05_04_r06f\croppedData\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_r03c\test002\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\ptk1_control_actin_myosin\actin\analysis\tack\cands\cands',indxStr,'.mat']);
load(['X:\AlexResults\Meta10sNov17\cands\cands',indxStr,'.mat']);
% load(['M:\unc\Test_WH_data\tub29\test002\cands\cands',indxStr,'.mat']);
% load('X:\AlexResults\june8ss3polar\candsOLD\cands1502.mat');
% load('U:\Meta2SpFeb26\cands\cands002.mat');
% load('U:\Meta4SpFeb28\cands\cands071.mat');
% load('S:\scripps\retro1\analysis_retro1\cands\cands02.mat');
cands2=cands;
clear cands;
LL2=length(cands2);
cands2=cands2(find([cands2.status]==1));
L2=length(cands2);

indxStr=sprintf(strg,i+2);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\sparseSpeckleData\spindle3\test003\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\monopole\xaug05_04_r06f\croppedData\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_r03c\test002\cands\cands',indxStr,'.mat']);
% load(['Z:\extract_spindle_project\AlexPoster10spidnles\ptk1_control_actin_myosin\actin\analysis\tack\cands\cands',indxStr,'.mat']);
load(['X:\AlexResults\Meta10sNov17\cands\cands',indxStr,'.mat']);
% load(['M:\unc\Test_WH_data\tub29\test002\cands\cands',indxStr,'.mat']);
% load('X:\AlexResults\june8ss3polar\candsOLD\cands1503.mat');
% load('U:\Meta2SpFeb26\cands\cands003.mat');
% load('U:\Meta4SpFeb28\cands\cands072.mat');
% load('S:\scripps\retro1\analysis_retro1\cands\cands03.mat');
cands3=cands;
clear cands;
LL3=length(cands3);
cands3=cands3(find([cands3.status]==1));
L3=length(cands3);

for i=1:L1    
    y1(i) = cands1(i).Lmax(1);
    x1(i) = cands1(i).Lmax(2);
end
frame1=[y1',x1'];

for i=1:L2    
    y2(i) = cands2(i).Lmax(1);
    x2(i) = cands2(i).Lmax(2);
end
frame2=[y2',x2'];

for i=1:L3    
    y3(i) = cands3(i).Lmax(1);
    x3(i) = cands3(i).Lmax(2);
end
frame3=[y3',x3'];