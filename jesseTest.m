function [trackedLinks,flow]=jesseTest(dirName,dist,m,n,s)

% synopsis [trackedLinks,flow]=jesseTest(search radius, first frame, last frame)

if nargin == 0 || isempty(dist)
    dist=13; % 20
    fprintf('default value of 6 for searching radius assumed')
    m = 1;
    n = 4;
%     dirName = '/mnt/alex10/AlexData/Jay/20090522SpindleSkewerFSM/20090522Spindle08/cands';
    [fileName,dirName] = uigetfile('*.mat','Choose a .mat file');
    s = 3;
end
aux = 6 ;
%--------------------------------------------------------
       'pos',[0 0],...                  % Centroid - [y x]
for j = m:n
    strg=sprintf('%%.%dd',s);
    indxStr=sprintf(strg,j);
    %-------------------------------------------------------
    load([dirName,filesep,'feats',indxStr,'.mat']);
    frames1.pos(:,2)=feats.pos(:,1); 
    frames1.pos(:,1)=feats.pos(:,2); 
    clear feats;
    %--------------------------------------------------------------------------
    indxStr2=sprintf(strg,j+1);
    load([dirName,filesep,'feats',indxStr2,'.mat']);
    frames2.pos(:,2)=feats.pos(:,1); 
    frames2.pos(:,1)=feats.pos(:,2); 
    clear cands;
    %--------------------------------------------------------------------------
    indxStr3=sprintf(strg,j+2);
    load([dirName,filesep,'feats',indxStr3,'.mat']);
    frames3.pos(:,2)=feats.pos(:,1); 
    frames3.pos(:,1)=feats.pos(:,2); 
    clear cands;
    %--------------------------------------------------------------------------
    trackedLinks = [];                                    % flowTracker(I,J,K,dist,w1,w2,w3,nbDir,iterations,firstF,nbWindows);
    [trackedLinks,flowN,cluster_index,bestmu,flowMap,dir] = flowTracker(frames1.pos,frames2.pos,frames3.pos,dist,1,1,1,2,3,1,0);
%     [trackedLinks,flowN,cluster_index,bestmu,flowMap,dir] = flowTracker(frames1.pos,frames2.pos,frames3.pos,dist,0.8,1,0.3,2,3,1,0);

    %-----------------------------------------------------------------------
%     scaling=1;
%     Map = [trackedLinks(:,1:4);trackedLinks(:,3:6)]; %DISPLAYS THE RESULT OF THE TRACKER
%     h0 = vectorFieldPlot(Map,0,[],scaling);
%     axis ij
%     axis(gca,'equal')
    %-------------------------------------------------------
    I = imread([dirName(1:end-aux),filesep,'images',filesep,'Spindle08',indxStr,'.tif']);
    name = 'Xenopus_extract_poked_needle';
    rate = 5;%10;
    pixelS = 153.8;%67;
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
    saveas (h,[dirName(1:end-aux),filesep,'results',filesep,'vectorMap-',name,indxStr],'fig')  
    close 
    %----------------------------------------------------
    if size(cluster_index,1) > flowN
        cluster_index = cluster_index(1:flowN);
    end
    ind1 = find(cluster_index==1);
    ind2 = find(cluster_index==2);
    d1 = trackedLinks(ind1,:);
    d2 = trackedLinks(ind2,:);
    L1 = sqrt(sum((d1(:,5:6)-d1(:,1:2)).^2,2));
    His1 = L1/2*60/rate*pixelS/1000;
    L2 = sqrt(sum((d2(:,5:6)-d2(:,1:2)).^2,2));
    His2 = L2/2*60/rate*pixelS/1000;
    [n1,b1]=hist(His1,30);
    [n2,b2]=hist(His2,30);
    h1 = figure,bar(b1,n1,'y')
    hold on
    bar(b2,n2,'r')
    saveas (h1,[dirName(1:end-aux),filesep,'results',filesep,'histogram-',name,indxStr],'fig')  
    close
    %---
    clear L
    clear dir
    clear frames1
    clear frames2
    clear frames3
end