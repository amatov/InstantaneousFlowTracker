function [trackedLinks, flowHistory]=andreaTest_v4_readsFromFeat_cleaned_MultiDirection(inpDir,tifImagesDir,dist,firstTriFrame,lastTriFrame,s,nbDir,rate,pixelS,name,RAK_ANGLE, arrowScale, nbWindows, filterSigmaU, debug)

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

if ~debug
    hWaitBar = waitbar(0,'First Iteration! Calculating time...');
end

flowHistory = cell(1,lastTriFrame-firstTriFrame+1);
for j = firstTriFrame:lastTriFrame-nbWindows-2
    tWaitBar(j-firstTriFrame+1) = tic;
    strg=sprintf('%%.%dd',s);
    indxStr=sprintf(strg,(j));
    
    trackedLinks = [];                                    % flowTracker(I,J,K,dist,w1,w2,w3,nbDir,iterations,firstF,nbWindows);
    %     nbDir = 2;
    %     RAK_ANGLE = [];
    
    [trackedLinks,flowN,cluster_index,gmm,flowMap,dir] = flowTracker_v4(frames(j-firstTriFrame+1:j-firstTriFrame+3+nbWindows),dist,1,1,1,nbDir,3,1,nbWindows,RAK_ANGLE, filterSigmaU); %3-4 dir % TORSTENS DATA
    %         [trackedLinks,flowN,cluster_index,bestmu,flowMap,dir] = flowTracker(frames1.pos,frames2.pos,frames3.pos,dist,0.8,1,0.3,2,3,1,0);
    %-----------------------------------------------------------------------
    [~,new_list] = sort(gmm.bestmu);
    dir = dir(new_list);
    gmm.bestmu = gmm.bestmu(new_list);
    gmm.bestcov = gmm.bestcov(new_list);
    gmm.bestpp = gmm.bestpp(new_list);
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
    if size(I,3) == 3
        I = rgb2gray(I);
    end
    %----------------------------vectors-------------------------------------------
    shift = 10;
    img = double(Gauss2D(I,1));
    if exist('h','var')
        figure(h);
        close(h);
    end
    
    h = figure;
    imshow(img(1+shift:end-shift,1+shift:end-shift),[]);
        
    hold on;

    cMap = hsv(length(gmm.bestmu));
    
    thisFlow = [];
    thisFlow = struct([]);
    for i = 1:length(gmm.bestmu)
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
    for i = 1:length(gmm.bestmu)
        figure(h);
        hold on;
        F = dir(i).map-shift;
        F(:,3:4)=F(:,1:2)+arrowScale*(F(:,3:4)-F(:,1:2));
        quiver(F(:,2),F(:,1),F(:,4)-F(:,2),F(:,3)-F(:,1),0,'Color',cMap(i,:));
    end
    
    hold off
    figure(h);
    set(gca,'position',[0 0 1 1],'units','normalized');
    
    R1 = 50;
    R2 = 100;
    TestAng = [0:0.003:2*pi]';
    cluster_index = zeros(1,length(TestAng));
    TestpGaussian = zeros(length(TestAng),gmm.bestk);
    for i = 1:length(TestAng)
        TestpGaussian(i,:) = ProbabilityOfXinGaussian(TestAng(i),gmm.bestmu, gmm.bestcov, gmm.bestpp);
        [~, cluster_index(i)] = max(TestpGaussian(i,:));
    end
    hold on
    for i = 1:gmm.bestk
        [X,Y] = pol2cart(TestAng, R1 + R2*TestpGaussian(:,i));
        plot(X+(R1+R2*max(max(TestpGaussian))),Y+(R1+R2*max(max(TestpGaussian))),'Color', [0,0,0],'Marker','.','LineStyle','none','MarkerSize',7);
        plot(X+(R1+R2*max(max(TestpGaussian))),Y+(R1+R2*max(max(TestpGaussian))),'Color', [0.91,0.91,0.91],'Marker','.','LineStyle','none','MarkerSize',2);
    end
    for i = 1:gmm.bestk
        [X,Y] = pol2cart(TestAng, R1 + R2*TestpGaussian(:,i));
        X = X(cluster_index == i);
        Y = Y(cluster_index == i);
        plot(X+(R1+R2*max(max(TestpGaussian))),Y+(R1+R2*max(max(TestpGaussian))),'Color', cMap(i,:),'Marker','.','LineStyle','none','MarkerSize',3);
    end
    if ~debug
        if ~exist([tifImagesDir,filesep,'resultsROI2'])
            mkdir([tifImagesDir,filesep,'resultsROI2']);
        end
        saveas (h,[tifImagesDir,filesep,'resultsROI2',filesep,'vectorMap-',name,indxStr],'fig')
        %saveas (h,[tifImagesDir,filesep,'resultsROI2',filesep,'vectorMap-',name,indxStr],'jpg')
        print(h,'-djpeg','-r300',[tifImagesDir,filesep,'resultsROI2',filesep,'vectorMap-',name,indxStr]);
        close(h);
        ratioDone = (j-firstTriFrame+1)/(lastTriFrame-nbWindows-1-firstTriFrame);
        waitbar(ratioDone, hWaitBar, sprintf('Elapsed: %0.0f secs, Remains: %0.0f secs', toc(tWaitBar(1)), toc(tWaitBar(1))*(1/ratioDone-1)));
    end
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
    
end
if ~debug
    if exist('h','var')
        figure(h);
        close(h);
    end
    waitbar(1, hWaitBar, sprintf('Done! Close me please. time: %0.0f secs', toc(tWaitBar(1))));
end