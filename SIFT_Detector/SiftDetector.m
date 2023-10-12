function [ feats ] = SiftDetector(debug, filePath, firstFrame, lastFrame, s,showOutput, PeakThre, EdgeThre )
% VLFeat -- Vision Lab Features Library
% The VLFeat open source library implements popular computer vision algorithms specialising in image understanding 
% and local featurexs extraction and matching. Algorithms incldue Fisher Vector, VLAD, SIFT, MSER, k-means, 
% hierarchical k-means, agglomerative information bottleneck, SLIC superpixes, quick shift superpixels, 
% large scale SVM training, and many others. It is written in C for efficiency and compatibility, 
% with interfaces in MATLAB for ease of use, and detailed documentation throughout.


addpath('../VLfeat/vlfeat-0.9.14/toolbox/');
vl_setup();

for i = firstFrame:lastFrame
    strg=sprintf('%%.%dd',s);
    indxStr=sprintf(strg,i);
    I = imread([filePath(1:end-(s+4)),indxStr,'.tif']);
    if size(I,3)==3
        I = rgb2gray(I);
    end
    
    F = vl_sift(single(I),'PeakThresh',PeakThre,'EdgeThresh',EdgeThre);
    
    if size(F,2)
        [~,outlier,~] = deleteoutliers(F(3,:),0.01,1);
        F(:,outlier) = [];
    end
    
    feats.pos = zeros(size(F,2),2);
    
    feats.pos(:,1) = F(1,:);
    feats.pos(:,2) = F(2,:);
    
    slash = strfind(filePath,'/');
    if isempty(slash)
        slash = strfind(filePath,'\');
    end
    slash = slash(end);
    
    if ~debug
        if ~exist([filePath(1:slash), 'cands'])
            mkdir([filePath(1:slash), 'cands']);
        end
        save([filePath(1:slash),'cands',filesep,'feats',indxStr],'feats');
    end
    
    if debug
        imagesc(I) ; colormap gray ;
        axis equal ;  axis off ; axis tight ;
        hold on ;
        scatter(feats.pos(:,1),feats.pos(:,2),25,'r','.');
        %plot(feats.pos(:,1),feats.pos(:,2),'Marker','*','LineStyle','none','Color','r');
    end
%     h1 = vl_plotframe(F) ;
%     set(h1,'color','k','linewidth',3) ;
%     h2 = vl_plotframe(F) ;
%     set(h2,'color','y','linewidth',2) ;
%     
    if showOutput
        h = figure() ;
        clf ;
        imagesc(I) ; colormap gray ;
        axis equal ;  axis off ; axis tight ;
        hold on ;
        h1 = vl_plotframe(F) ;
        set(h1,'color','k','linewidth',3) ;
        h2 = vl_plotframe(F) ;
        set(h2,'color','y','linewidth',2) ;
        %         plot( F(1,:) , F(2,:), '*', 'LineStyle', 'none');
        if ~debug
            saveas(h,[filePath(1:slash),'cands',filesep,'feats',indxStr,'.fig']);
        end
    end
end
end


