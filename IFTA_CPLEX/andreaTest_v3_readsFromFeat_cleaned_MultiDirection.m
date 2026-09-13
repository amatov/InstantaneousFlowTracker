function [trackedLinks, flowHistory]=andreaTest_v3_readsFromFeat_cleaned_MultiDirection(inpDir,tifImagesDir,dist,firstTriFrame,lastTriFrame,s,nbDir,rate,pixelS,name,RAK_ANGLE, arrowScale)

%In version 3, program reads the feat.mat files instead of cand.mat
%In this version also I have tried to clean the code and make it possible
%to choose more general options as input

% synopsis [trackedLinks,flow]=andreaTest(search radius, first frame, last frame)

if nargin == 0 || isempty(dist)
    dist=4; % 20
    fprintf('default value of 4 for searching radius assumed')
    firstTriFrame = 1;
    lastTriFrame = 4;
    [fileName,dirName] = uigetfile('*.mat','Choose a .mat file');
    s = 2;
end
aux = 6;% aux = 6 or 11 depending on where Andrea put the images
%--------------------------------------------------------

for j = firstTriFrame:lastTriFrame
    %     j = frame(jj);
    
    strg=sprintf('%%.%dd',s);
    indxStr=sprintf(strg,(j));
    %-------------------------------------------------------
    load([inpDir,filesep,'feats',indxStr,'.mat']);
    frames(j-firstTriFrame+1).pos = feats.pos(:,[2,1]);
end

flowHistory = cell(1,lastTriFrame-firstTriFrame+1);
for j = firstTriFrame:lastTriFrame
    strg=sprintf('%%.%dd',s);
    indxStr=sprintf(strg,(j));
    
    trackedLinks = [];                                    % flowTracker(I,J,K,dist,w1,w2,w3,nbDir,iterations,firstF,nbWindows);
    %     nbDir = 2;
    %     RAK_ANGLE = [];
    
    nbWindows = 1;
    [trackedLinks,flowN,cluster_index,bestmu,flowMap,dir] = flowTracker(frames(j-firstTriFrame+1:j-firstTriFrame+3+nbWindows),dist,1,1,1,nbDir,3,1,nbWindows,RAK_ANGLE); %3-4 dir % TORSTENS DATA
    %         [trackedLinks,flowN,cluster_index,bestmu,flowMap,dir] = flowTracker(frames1.pos,frames2.pos,frames3.pos,dist,0.8,1,0.3,2,3,1,0);
    %-----------------------------------------------------------------------
    [bestmu,new_list] = sort(bestmu);
    dir = dir(new_list);
    %     d = [];
    %     d(1).map = dir(new_list(1)).map;
    %     if nbDir > 1
    %         d(2).map = dir(new_list(2)).map;
    %     end
    %     if nbDir > 2
    %         d(3).map = dir(new_list(3)).map;
    %     end
    %     if nbDir > 3
    %         d(4).map = dir(new_list(4)).map;
    %     end
    %     dir = [];
    %     dir = d;
    %--------------------------------------
    scaling=1;
    %     Map = [trackedLinks(:,1:4);trackedLinks(:,3:6)]; %DISPLAYS THE RESULT
    %     OF THE TRACKER
    Map = [trackedLinks(:,1),trackedLinks(:,2),trackedLinks(:,5),trackedLinks(:,6)]; %DISPLAYS THE RESULT OF THE TRACKER
    %h0 = vectorFieldPlot(Map,0,[],scaling);
    
    %save('Everything_RightHere');
    if ~exist([tifImagesDir,filesep,'resultsROI2'],'dir')
        mkdir([tifImagesDir,filesep,'resultsROI2']);
    end
    %saveas (vectorFieldPlot(Map,0,[],scaling),[tifImagesDir,filesep,'resultsROI2',filesep,'rawVectors-',name,indxStr],'fig')
    
    %     saveas (h0,['rawVectors-',name,indxStr],'fig')
    %     axis ij
    %     axis(gca,'equal')
    %-------------------------------------------------------
    %     I = imread([dirrName,filesep,name,indxStr,'.tif']); % SMENI
    I = imread([tifImagesDir,filesep,name,indxStr,'.tif']);%crop_default
    %----------------------------vectors-------------------------------------------
    shift = 10;
    img = double(Gauss2D(I,1));
    if exist('h','var')
        figure(h);
        close(h);
    end
    h = figure;
    imshow(img(1+shift:end-shift,1+shift:end-shift),[]);
    
    %     cr = 35;% 17
    %     xm = xx(j); % lookup table 74 values
    %     ym = yy(j) % lookup table 74 values
    %     xn = 212; % needle
    %     yn = 237;
    %     y0 = ym - cr;
    %     x0 = xm - cr;
    %     y3 = ym + cr;
    %     x3 = xm + cr;
    %     cr = cr + 30;
    %     y1 = yn - cr;
    %     x1 = xn - cr;
    %     y2 = yn + cr;
    %     x2 = xn + cr;
    
    
    %     list2 = find( dir(4).map(:,1)>y1 & dir(4).map(:,1)<y2 & dir(4).map(:,2)>x1 & dir(4).map(:,2)<x2 );
    %     list1 = find( dir(2).map(:,1)>y0 & dir(2).map(:,1)<y3 & dir(2).map(:,2)>x0 & dir(2).map(:,2)<x3 );
    
    
    %     list1 = find( dir(1).map(:,1)>0 );
    %     list2 = find( dir(2).map(:,1)>0 );
    %     d1.map = dir(1).map(list1,:);
    %     d2.map = dir(2).map(list2,:);
    %     clear dir
    %     dir(1).map = d1.map;
    %     dir(2).map = d2.map;
    
    hold on;

    cMap = hsv(length(bestmu));
    
    thisFlow = struct([]);
    for i = 1:length(bestmu)
        thisFlow(i).mean = mean(dir(i).map,1);
        thisFlow(i).map = dir(i).map;
        tmpMagnitueds = sqrt((dir(i).map(:,1)-dir(i).map(:,3)).^2+(dir(i).map(:,2)-dir(i).map(:,4)).^2);
        thisFlow(i).magAll = tmpMagnitueds;
        thisFlow(i).magMean = mean(tmpMagnitueds);
        thisFlow(i).magSTD = std(tmpMagnitueds);
        tmpDegree = atan2d(dir(i).map(:,1)-dir(i).map(:,3),dir(i).map(:,4)-dir(i).map(:,2));
        thisFlow(i).degAll = tmpDegree;
        thisFlow(i).degMean = mean(tmpDegree);
        thisFlow(i).degSTD = std(tmpDegree);
    end
    
    if j ~= firstTriFrame
        warning('I have commented this part of the code!');
        %%p = findBestMatch(thisFlow, flowHistory{j-firstTriFrame+1-1});
        p = 1:length(dir);
        dir = dir(p);
        thisFlow = thisFlow(p);
    end
    flowHistory{j-firstTriFrame+1} = thisFlow;
    for i = 1:length(bestmu)
        hold on;
        F = dir(i).map-shift;
        F(:,3:4)=F(:,1:2)+arrowScale*(F(:,3:4)-F(:,1:2));
        quiver(F(:,2),F(:,1),F(:,4)-F(:,2),F(:,3)-F(:,1),0,'Color',cMap(i,:));
    end
    
    hold off
    if ~exist([tifImagesDir,filesep,'resultsROI2'])
        mkdir([tifImagesDir,filesep,'resultsROI2']);
    end
    set(gca,'position',[0 0 1 1],'units','normalized');
    saveas (h,[tifImagesDir,filesep,'resultsROI2',filesep,'vectorMap-',name,indxStr],'fig')
    saveas (h,[tifImagesDir,filesep,'resultsROI2',filesep,'vectorMap-',name,indxStr],'jpg')
    close all
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
    %listUp = find(cl_in==new_list(3)); % because we flip the bestmu
    
    %listDn = find(cl_in==new_list(4));
    
    %     tDn = trackedLinks(listDn,:);
    %     tUp = trackedLinks(listUp,:);
    %
    %     li2 = find( tDn(:,1)>y1 & tDn(:,1)<y2 & tDn(:,2)>x1 & tDn(:,2)<x2 );
    % %     li1 = find( tUp(:,1)>y0 & tUp(:,1)<y3 & tUp(:,2)>x0 & tUp(:,2)<x3 );
    %         li1 = find( tUp(:,1)>y1 );
    %
    %     L1 = sqrt(sum((tUp(li1,5:6)-tUp(li1,1:2)).^2,2)); % FIRST TO THIRD FRAME
    % %     L1 = sqrt(sum((tUp(:,5:6)-tUp(:,1:2)).^2,2)); % FIRST TO THIRD FRAME
    %     H1 = L1*60/rate*pixelS/1000/2;
    %     H1t=[H1t;H1];
    %     speed1(j) = mean(H1);
    %     [n1,b1]=hist(H1);
    %     %
    %     if nbDir > 1
    %         %         L2 = sqrt(sum((dir(2).map(:,3:4)-dir(2).map(:,1:2)).^2,2));
    % %         L2 = sqrt(sum((tDn(li2,5:6)-tDn(li2,1:2)).^2,2)); % FIRST TO THIRD FRAME
    %         L2 = sqrt(sum((tDn(:,5:6)-tDn(:,1:2)).^2,2)); % FIRST TO THIRD FRAME
    %         H2 = L2*60/rate*pixelS/1000/2;
    %         H2t=[H2t;H2];
    %         speed2(j) = mean(H2);
    %         [n2,b2]=hist(H2);
    %         diffSp(j) = speed1(j)-speed2(j);
    %     end
    
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
    %     h1 = figure,bar(b1,n1,'y')
    % %225-248,285-289,301-303,307-322,340-360
    %     if nbDir > 1
    %         hold on
    % %         bar(b2,n2,'r')
    %     end
    
    %     if size(dir,2) > 2
    %         bar(b3,n3,'g')
    %     end
    %     if size(dir,2) > 3
    %         bar(b4,n4,'m')
    %     end
    
    %     h1 = figure
    %     hist(speedHist,centers);
    
    %     saveas (h1,[dirrName(1:end-aux),filesep,'resultsROI',filesep,'hist2color-',name,indxStr],'fig')
    %     %     saveas (h1,['hist2color-',name,indxStr],'fig')
    %     close
    
    %         save([dirrName(1:end-aux),filesep,'results',filesep,'hist-',name,indxStr], 'speedHist')
    %---
    %     clear L1
    %     clear H1
    %     if size(dir,2) > 1
    %         clear L2
    %         clear H2
    %     end
    %     if size(dir,2) > 2
    %         clear L3
    %     end
    %     if size(dir,2) > 3
    %         clear L4
    %     end
    %     clear dir
    %     clear frames1
    %     clear frames2
    %     clear frames3
end

if exist('h','var')
    figure(h);
    close(h);
end