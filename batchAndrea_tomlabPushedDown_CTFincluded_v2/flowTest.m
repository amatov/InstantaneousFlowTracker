function [trackedLinks,flow]=flowTest(dirrName,dist,mm,n,s,nbDir,rate,pixelS,name,RAK_ANGLE)

% Alexandre Matov (2003)

if nargin == 0 || isempty(dist)
    dist=6; % 20
    fprintf('default value of 6 for searching radius assumed')
    mm = 1;
    n = 4;
    [fileName,dirName] = uigetfile('*.mat','Choose a .mat file');
    s = 2;
end
aux = 11;%  
%--------------------------------------------------------
speed1 = []; speed2 = []; H1t=[];H2t=[];
xx = [231 229 231 223 226 233 228 234 236 240 240 240 240 240 240 240 241 243 245 247 247 247 247 247 248 249 250 250 251 251 252 253 252 252 ...
    254 257 259 260 268 270 272 274 277 280 284 284 284 284 283 283 287 290 293 296 300 307 314 310 300 292 293 295 300 304 308 301 303 310 ...
    313 316 324 332 329 326];
yy = [148 151 152 151 148 152 152 149 151 147 143 140 137 135 133 131 134 137 140 142 141 140 140 139 139 136 133 130 126 121 116 111 110 110 ...
    110 110 105 105 99 96 93 90 87 86 85 85 86 86 86 86 87 87 87 87 87 82 76 80 85 90 86 82 76 70 68 79 73 73 73 73 68 64 64 64];
frame = [7 11 13 46 50 57 60 61 63 64];
% frame = [11 13];

m = struct('m',[]);
m(1).m = [];
m(2).m = [];
for j = mm:n
%     j = frame(jj);
    strg=sprintf('%%.%dd',s);
    indxStr=sprintf(strg,(j));
    %-------------------------------------------------------
    load([dirrName,filesep,'cands',indxStr,'.mat']);
    cands1=cands;
    clear cands;
    LL1=length(cands1);
    cands1=cands1(find([cands1.status]==1));
    L1=length(cands1);
    %--------------------------------------------------------------------------
    indxStr2=sprintf(strg,j+1);
    load([dirrName,filesep,'cands',indxStr2,'.mat']);
    cands2=cands;
    clear cands;
    LL2=length(cands2);
    cands2=cands2(find([cands2.status]==1));
    L2=length(cands2);
    %--------------------------------------------------------------------------
    indxStr3=sprintf(strg,j+2);
    load([dirrName,filesep,'cands',indxStr3,'.mat']);
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
    [trackedLinks,flowN,cluster_index,bestmu,flowMap,dir] = flowTracker(frames1.pos,frames2.pos,frames3.pos,dist,1,1,1,nbDir,3,1,0,RAK_ANGLE); 
    %-----------------------------------------------------------------------
    [bestmu,new_list] = sort(bestmu);
    d = [];
    d(1).map = dir(new_list(1)).map;
    if nbDir > 1
        d(2).map = dir(new_list(2)).map;
    end
    if nbDir > 2
        d(3).map = dir(new_list(3)).map;
    end
    if nbDir > 3
        d(4).map = dir(new_list(4)).map;
    end
    dir = [];
    dir = d;
    %--------------------------------------
    scaling=1;
    %     Map = [trackedLinks(:,1:4);trackedLinks(:,3:6)]; %DISPLAYS THE RESULT
    %     OF THE TRACKER
    Map = [trackedLinks(:,1),trackedLinks(:,2),trackedLinks(:,5),trackedLinks(:,6)]; %DISPLAYS THE RESULT OF THE TRACKER
    h0 = vectorFieldPlot(Map,0,[],scaling);
    saveas (h0,[dirrName(1:end-aux),filesep,'resultsROI',filesep,'rawVectors-',name,indxStr],'fig')
    %     saveas (h0,['rawVectors-',name,indxStr],'fig')
    %     axis ij
    %     axis(gca,'equal')
    %-------------------------------------------------------
    %     I = imread([dirrName,filesep,name,indxStr,'.tif']); % SMENI
    I = imread([dirrName(1:end-aux),filesep,'crop',filesep,name,indxStr,'.tif']);%crop_default
    %----------------------------vectors-------------------------------------------
    shift = 10;
    img = double(Gauss2D(I,1));
    h = figure;
    imshow(img(1+shift:end-shift,1+shift:end-shift),[]);

    % ZA 3polar STRECH
    %         imagesc(160-shift:300-shift,300+shift:420+shift,img(1+shift:end-shift,1+shift:end-shift)) % SCALE IMAGE

    % ROI
    %         tor = xlsread('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle5/resultsROI/Spindle5PolePosition.xls');
    %         dX = tor(2:end,2) - tor(1:end-1,2);
    %         dY = tor(2:end,3) - tor(1:end-1,3);
    %         dZ2 = dX.*dX + dY.*dY;
    %         movPol = sqrt(dZ2);
    %         movPol = [movPol;2.1];
    % find the shift step by step
    cr = 35;% 17
    xm = xx(j); % lookup table 74 values
    ym = yy(j) % lookup table 74 values
    xn = 212; % needle
    yn = 237;
    y0 = ym - cr;
    x0 = xm - cr;
    y3 = ym + cr;
    x3 = xm + cr;
%     cr = cr + 30;
    y1 = yn - cr;
    x1 = xn - cr;
    y2 = yn + cr;
    x2 = xn + cr;


%     list2 = find( dir(4).map(:,1)>y1 & dir(4).map(:,1)<y2 & dir(4).map(:,2)>x1 & dir(4).map(:,2)<x2 );
%     list1 = find( dir(2).map(:,1)>y0 & dir(2).map(:,1)<y3 & dir(2).map(:,2)>x0 & dir(2).map(:,2)<x3 );
    list1 = find( dir(3).map(:,1)>y1 );
    d1.map = dir(3).map(list1,:);
    d2.map = dir(4).map;%(list2,:);
    clear dir
    dir(1).map = d1.map;
    dir(2).map = d2.map;
% 
%     %DEBUG
%     if j == 11 || j == 13 || j == 7
        m(1).m = [m(1).m;dir(1).map];
        m(2).m = [m(2).m;dir(2).map];
%     end

    hold on
    for i = 1:1%2%length(bestmu) % SET HERE THE DIRECTION YOU WANT
        hEachD = vectorFieldPlot(dir(i).map-shift,h,[],3); % scle 3 for actin/ 5 for red spindle
    end
    hold off
    saveas (h,[dirrName(1:end-aux),filesep,'resultsROI',filesep,'vectorMap-',name,indxStr],'fig')
    %         saveas (h,['vectorMap-',name,indxStr],'fig')
%     close all

    %     h11 = figure
    %     hEachD1 = vectorFieldPlot(dir(1).map,h11,[],1);
    % %     axis(gca,'equal')
    %     h22 = figure
    %     hEachD2 = vectorFieldPlot(dir(2).map,h22,[],1);
    %     if size(dir,2) > 2
    %         h33 = figure
    %         hEachD3 = vectorFieldPlot(dir(3).map,h33,[],1);
    %     end
    %     if size(dir,2) > 3
    %         h44 = figure
    %         hEachD4 = vectorFieldPlot(dir(4).map,h44,[],1);
    %     end
    %
    %     saveas (h11,[dirrName(1:end-aux),filesep,'results',filesep,'vectorMap1-',name,indxStr],'fig')
    %     saveas (h22,[dirrName(1:end-aux),filesep,'results',filesep,'vectorMap2-',name,indxStr],'fig')
    %     if size(dir,2) > 2
    %         saveas (h33,[dirrName(1:end-aux),filesep,'results',filesep,'vectorMap3-',name,indxStr],'fig')
    %     end
    %     if size(dir,2) > 3
    %         saveas (h44,[dirrName(1:end-aux),filesep,'results',filesep,'vectorMap4-',name,indxStr],'fig')
    %     end
    %     close all
    %     %     save([dirName(1:end-aux),filesep,'results',filesep,'dir-',name,indxStr],'dir')

    %-------------------------overlap---------------------------
    %     counts1 = histND(dir(1).map(:,1:2),'auto');
    %     if size(dir,2) == 2
    %         counts2 = histND(dir(2).map(:,1:2),size(counts1));
    %         clrMap = cat(3,counts1, counts2,zeros(size(counts1)));
    %     elseif size(dir,2) == 1
    %         clrMap = counts1;
    %     elseif size(dir,2) == 3
    %         counts3 = histND(dir(3).map(:,1:2),size(counts1));
    %         counts2 = histND(dir(2).map(:,1:2),size(counts1));
    %         clrMap = cat(3,counts1, counts2, counts3, zeros(size(counts1)));
    %     elseif size(dir,2) == 4
    %         counts4 = histND(dir(4).map(:,1:2),size(counts1));
    %         counts3 = histND(dir(3).map(:,1:2),size(counts1));
    %         counts2 = histND(dir(2).map(:,1:2),size(counts1));
    %         clrMap = cat(3,counts1, counts2, counts3, counts4, zeros(size(counts1)));
    %     elseif size(dir,2) > 4
    %         disp('more than 4 directions');
    %     end
    %     imtool(clrMap/max(clrMap(:)),[]);
    %     close
    %         save([dirrName(1:end-aux),filesep,'results',filesep,'colormap-',name,indxStr],'clrMap')
    % %--------------------histogram--------------------------------------------
    %     L = sqrt(sum((trackedLinks(:,5:6)-trackedLinks(:,1:2)).^2,2));
    %     speedHist = L/2*60/rate*pixelS/1000;
    %     centers = [0.125:0.25:3.875];

    %     L1 = sqrt(sum((dir(1).map(:,3:4)-dir(1).map(:,1:2)).^2,2));
    if size(cluster_index,1) > size(trackedLinks,1)
        cl_in = cluster_index(1:size(trackedLinks,1));
    else
        cl_in = cluster_index;
    end
    listUp = find(cl_in==new_list(3)); % because we flip the bestmu

    listDn = find(cl_in==new_list(4));

    tDn = trackedLinks(listDn,:);
    tUp = trackedLinks(listUp,:);

    li2 = find( tDn(:,1)>y1 & tDn(:,1)<y2 & tDn(:,2)>x1 & tDn(:,2)<x2 );
%     li1 = find( tUp(:,1)>y0 & tUp(:,1)<y3 & tUp(:,2)>x0 & tUp(:,2)<x3 );
        li1 = find( tUp(:,1)>y1 );

    L1 = sqrt(sum((tUp(li1,5:6)-tUp(li1,1:2)).^2,2)); % FIRST TO THIRD FRAME
%     L1 = sqrt(sum((tUp(:,5:6)-tUp(:,1:2)).^2,2)); % FIRST TO THIRD FRAME
    H1 = L1*60/rate*pixelS/1000/2;
    H1t=[H1t;H1];
    speed1(j) = mean(H1);
    [n1,b1]=hist(H1);
    %
    if nbDir > 1
        %         L2 = sqrt(sum((dir(2).map(:,3:4)-dir(2).map(:,1:2)).^2,2));
%         L2 = sqrt(sum((tDn(li2,5:6)-tDn(li2,1:2)).^2,2)); % FIRST TO THIRD FRAME
        L2 = sqrt(sum((tDn(:,5:6)-tDn(:,1:2)).^2,2)); % FIRST TO THIRD FRAME
        H2 = L2*60/rate*pixelS/1000/2;
        H2t=[H2t;H2];
        speed2(j) = mean(H2);
        [n2,b2]=hist(H2);
        diffSp(j) = speed1(j)-speed2(j);
    end

    %         Map1 = [trackedLinks(listUp,1),trackedLinks(listUp,2),trackedLinks(listUp,5),trackedLinks(listUp,6)]; %DISPLAYS THE RESULT OF THE TRACKER
    %     hU = vectorFieldPlot(Map1,0,[],scaling);
    %
    %             Map2 = [trackedLinks(listDn,1),trackedLinks(listDn,2),trackedLinks(listDn,5),trackedLinks(listDn,6)]; %DISPLAYS THE RESULT OF THE TRACKER
    %     hD = vectorFieldPlot(Map2,0,[],scaling);

    % DEBUG
%     hR= figure;
%     imshow(img(1+shift:end-shift,1+shift:end-shift),[]);
%     Map1 = [tUp(li1,1)-shift,tUp(li1,2)-shift,tUp(li1,5)-shift,tUp(li1,6)-shift]; %DISPLAYS THE RESULT OF THE TRACKER
%     hU = vectorFieldPlot(Map1,hR,[],5);
%     hold on
%     Map2 = [tDn(li2,1)-shift,tDn(li2,2)-shift,tDn(li2,5)-shift,tDn(li2,6)-shift]; %DISPLAYS THE RESULT OF THE TRACKER
%     hU = vectorFieldPlot(Map2,hR,[],5);
    %
    %     for i = 1:length(bestmu)
    %         hEachD = vectorFieldPlot(dir(i).map-shift,h,[],5); % scle 3 for actin/ 5 for red spindle
    %     end
%     hold off
%     saveas (hR,[dirrName(1:end-aux),filesep,'resultsROI',filesep,'rawMap-',name,indxStr],'fig')
%     close all
    %
    %     if size(dir,2) > 2
    %         L3 = sqrt(sum((dir(3).map(:,3:4)-dir(3).map(:,1:2)).^2,2));
    %         H3 = L3*60/rate*pixelS/1000;
    %         [n3,b3]=hist(H3,30);
    %     end
    %
    %     if size(dir,2) > 3
    %         L4 = sqrt(sum((dir(4).map(:,3:4)-dir(4).map(:,1:2)).^2,2));
    %         H4 = L4*60/rate*pixelS/1000;
    %         [n4,b4]=hist(H4,30);
    %     end
    %
    h1 = figure,bar(b1,n1,'y')

    if nbDir > 1
        hold on
%         bar(b2,n2,'r')
    end

    %     if size(dir,2) > 2
    %         bar(b3,n3,'g')
    %     end
    %     if size(dir,2) > 3
    %         bar(b4,n4,'m')
    %     end

    %     h1 = figure
    %     hist(speedHist,centers);

    saveas (h1,[dirrName(1:end-aux),filesep,'resultsROI',filesep,'hist2color-',name,indxStr],'fig')
    %     saveas (h1,['hist2color-',name,indxStr],'fig')
    close

    %         save([dirrName(1:end-aux),filesep,'results',filesep,'hist-',name,indxStr], 'speedHist')
    %---
    clear L1
    clear H1
    if size(dir,2) > 1
        clear L2
        clear H2
    end
    if size(dir,2) > 2
        clear L3
    end
    if size(dir,2) > 3
        clear L4
    end
    clear dir
    clear frames1
    clear frames2
    clear frames3
end

% DEBUG
% indxStr=sprintf(strg,(n+4));
% I1 = imread([dirrName(1:end-aux),filesep,'crop',filesep,name,indxStr,'.tif']);%crop_default
% shift = 10;
% img1 = double(Gauss2D(I1,1));
% hP = figure;
% imshow(img1(1+shift:end-shift,1+shift:end-shift),[]);
% hold on
% for i = 1:1%2%length(bestmu)
%     hD = vectorFieldPlot(m(i).m-shift,hP,[],5); % scle 3 for actin/ 5 for red spindle
% end
% hold off
% saveas (hP,[dirrName(1:end-aux),filesep,'resultsROI',filesep,'vectorMapPULLED-',name,indxStr],'fig')


[n1t,b1t]=hist(H1t);
% [n2t,b2t]=hist(H2t);
h1t = figure,bar(b1t,n1t,'y')
hold on
% bar(b2t,n2t,'r')
saveas (h1t,[dirrName(1:end-aux),filesep,'resultsROI',filesep,'hist2clrTot-',name,indxStr],'fig')

MEAN_UP = mean(H1t)
STD_UP = std(H1t)
NUMB_UP = length(H1t)
% MEAN_DOWN = mean(H2t)
% STD_DOWN = std(H2t)
% NUMB_DOWN = length(H2t)

save([dirrName(1:end-aux),filesep,'resultsROI',filesep,'H1t'],'H1t')
save([dirrName(1:end-aux),filesep,'resultsROI',filesep,'H2t'],'H2t')
save([dirrName(1:end-aux),filesep,'resultsROI',filesep,'speed1'],'speed1')
% save(['speed1'],'speed1')
save([dirrName(1:end-aux),filesep,'resultsROI',filesep,'speed2'],'speed2')
% save(['speed2'],'speed2')
save([dirrName(1:end-aux),filesep,'resultsROI',filesep,'diffSp'],'diffSp')
