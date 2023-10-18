[frames1,frames2,frames3,I,name,rate,pixelS]=loadCands(i)


s = 2;
strg=sprintf('%%.%dd',s);

indxStr=sprintf(strg,i);
%-------------------------------------------------------
switch imageNumber
    case 0
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\072904_tub19_for_figure1\aligned_horizontal_73deg\test002\cands\cands001.mat');
    case 1
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\confocal\xjul29_04_16\croppedImages\cropped_xjul29_04_16_tub\test003\cands\cands01.mat');
    case 2
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub23\test002\cands\cands01.mat');
    case 3
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub24\test002\cands\cands01.mat');
    case 4
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\confocal\xjul29_04_06\test001\cands\cands001.mat');
    case 5
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_r03c\test002\cands\cands01.mat');
    case 6
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_02\cropped_MT\test001\cands\cands01.mat');
    case 7
        load('Z:\extract_spindle_project\AlexPoster10spidnles\amppnp\AMP_PNP01\test003\cands\cands01.mat');
    case 8
        load('Z:\extract_spindle_project\AlexPoster10spidnles\sparseSpeckleData\spindle3\test003\cands\cands01.mat');
    case 9
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\monopole\xaug05_04_r06f\croppedData\cands\cands72.mat');
    case 10
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub29\test002\cands\cands01.mat');
    otherwise
        load('M:\unc\resultsAlex\Meta10sNov17\cands\cands01.mat');
end
cands1=cands;
clear cands;
LL1=length(cands1);
cands1=cands1(find([cands1.status]==1));
L1=length(cands1);
%--------------------------------------------------------------------------
switch imageNumber
    case 0
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\072904_tub19_for_figure1\aligned_horizontal_73deg\test002\cands\cands002.mat');
    case 1
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\confocal\xjul29_04_16\croppedImages\cropped_xjul29_04_16_tub\test003\cands\cands02.mat');
    case 2
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub23\test002\cands\cands02.mat');
    case 3
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub24\test002\cands\cands02.mat');
    case 4
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\confocal\xjul29_04_06\test001\cands\cands002.mat');
    case 5
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_r03c\test002\cands\cands02.mat');
    case 6
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_02\cropped_MT\test001\cands\cands02.mat');
    case 7
        load('Z:\extract_spindle_project\AlexPoster10spidnles\amppnp\AMP_PNP01\test003\cands\cands02.mat');
    case 8
        load('Z:\extract_spindle_project\AlexPoster10spidnles\sparseSpeckleData\spindle3\test003\cands\cands02.mat');
    case 9
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\monopole\xaug05_04_r06f\croppedData\cands\cands73.mat');
    case 10
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub29\test002\cands\cands02.mat');
    otherwise
        load('M:\unc\resultsAlex\Meta10sNov17\cands\cands02.mat');
end
cands2=cands;
clear cands;
LL2=length(cands2);
cands2=cands2(find([cands2.status]==1));
L2=length(cands2);
%--------------------------------------------------------------------------
switch imageNumber
    case 0
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\072904_tub19_for_figure1\aligned_horizontal_73deg\test002\cands\cands003.mat');
    case 1
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\confocal\xjul29_04_16\croppedImages\cropped_xjul29_04_16_tub\test003\cands\cands03.mat');
    case 2
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub23\test002\cands\cands03.mat');
    case 3
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub24\test002\cands\cands03.mat');
    case 4
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\confocal\xjul29_04_06\test001\cands\cands003.mat');
    case 5
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_r03c\test002\cands\cands03.mat');
    case 6
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_02\cropped_MT\test001\cands\cands03.mat');
    case 7
        load('Z:\extract_spindle_project\AlexPoster10spidnles\amppnp\AMP_PNP01\test003\cands\cands03.mat');
    case 8
        load('Z:\extract_spindle_project\AlexPoster10spidnles\sparseSpeckleData\spindle3\test003\cands\cands03.mat');
    case 9
        load('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\monopole\xaug05_04_r06f\croppedData\cands\cands74.mat');
    case 10
        load('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub29\test002\cands\cands03.mat');
    otherwise
        load('M:\unc\resultsAlex\Meta10sNov17\cands\cands03.mat');
end
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
%-------------------------------------------------------
switch imageNumber
    case 0
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\072904_tub19_for_figure1\aligned_horizontal_73deg\images\repaired_crop_tub19_01Rotated001.tif');
        name = 'widefield3';
        rate = 3;
        pixelS = 64.5;
    case 1
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\control\confocal\xjul29_04_16\croppedImages\cropped_xjul29_04_16_tub\images\crop_xjul29_04_16_tub01.tif');
        name = 'confocal1';
        rate = 5;
        pixelS = 64.5;
    case 2
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub23\croppedImages\crop_tub23_01.tif');
        name = 'widefield1';
        rate = 3;
        pixelS = 64.5;
    case 3
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub24\croppedImages\crop_tub24_01.tif');
        name = 'widefield2';
        rate = 3;
        pixelS = 64.5;
    case 4
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\control\confocal\xjul29_04_06\images\repaired_crop_xjul29_04_6_tub01Rotated001.tif');
        name = 'confocal2';
        rate = 5;
        pixelS = 64.5;
    case 5
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_r03c\xa0504_r03c01.tif');
        name = 'monastrolBipole1';
        rate = 5;
        pixelS = 67;
    case 6
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\bipole\xaug05_04_02\cropped_MT\crop_xa0504_r02b01.tif');
        name = 'monastrolBipole2';
        rate = 5;
        pixelS = 67;
    case 7
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\amppnp\AMP_PNP01\images\pnp18eu01.tif');
        name = 'amppnp';
        rate = 10;
        pixelS = 110;
    case 8
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\sparseSpeckleData\spindle3\images\crop_KL_spindle3_01.tif');
        name = 'singleFl';
        rate = 2;
        pixelS = 160;
    case 9
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\monastrol_spindle\monopole\xaug05_04_r06f\croppedData\crop_xa0504_r06f01.tif');
        name = 'monopole';
        rate = 5;
        pixelS = 67;
    case 10
        I = imread('Z:\extract_spindle_project\AlexPoster10spidnles\control\widefield\tub29\croppedImages\crop_tub29_01.tif');
        name = 'widefield4';
        rate = 3;
        pixelS = 64.5;
    otherwise
        I = imread('M:\unc\data\SpindleRedRawAligned\RedRawAligned01.tif');
        name = 'redSpindle';
        rate = 10;
        pixelS = 67;
end
%-----------------------------------------------------------------------