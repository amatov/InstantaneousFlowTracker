% I = imread('U:\june8ss3polar\crop_xjul8_r1525.tif');
% I = imread('U:\june8ss3polar\crop_xjul8_r1525.tif');
% I = imread('U:\FSMdataUNC\SpindleRedRawAligned\RedRawAligned10.tif');

movieName = 'U:\moviesFlowPaperKmeans\TriPolarSpindle.mov';
framerate = 2;
quality = 1;

makeqtmovie('start',movieName);
makeqtmovie('framerate',framerate)
makeqtmovie('quality',quality)

s = 2;

strg=sprintf('%%.%dd',s);

for j = 1:30% 38
    
    indxStr=sprintf(strg,j);
    I = imread(['U:\FSMdataUNC\3polar4\xjul8_r15',indxStr,'.tif']);
    dy=[];dx=[];fY=[];fX=[];fYt=[];fXt=[];
    for i = j:j+5%28:38%  20:35   
        % load('U:\xjul8_r15SSmay26\links3\links1525')
        indxStr=sprintf(strg,i);
        load(['U:\june8ss3polar\links\links15',indxStr]);
        %     load(['U:\Meta10sAug23\links\links',num2str(i)]);
        
        dy = [dy; links(:,5)-links(:,3)];
        dx = [dx; links(:,6)-links(:,4)];
        fY = [fY;links(:,3)];
        fX = [fX;links(:,4)];
        fYt = [fYt;links(:,5)];
        fXt = [fXt;links(:,6)];
        
        % load('U:\xjul8_r15SSmay26\links3\links1526')
        load(['U:\june8ss3polar\links\links15',indxStr]);
        %     load(['U:\Meta10sAug23\links\links',num2str(i)]);
        
        dy = [dy;links(:,3)-links(:,1)];
        dx= [dx;links(:,4)-links(:,2)];
        fY = [fY;links(:,1)];
        fX = [fX;links(:,2)];
        fYt = [fYt;links(:,3)];
        fXt = [fXt;links(:,4)];
    end
    ang = atan2(dy,dx);
%     ang = ang';
    
    
    
    
    
    

    [cluster_index_sort, bestmu] = KMEANS(ang, 3,'emptyaction','singleton');

   
    hh=figure;
    imshow(gauss2d(I,1),[min(I(:)) max(I(:))]);
    hold on
    for i = 1:3
        fXf=fX(find(cluster_index_sort==i));
        fYf=fY(find(cluster_index_sort==i));
        fXtf=fXt(find(cluster_index_sort==i));
        fYtf=fYt(find(cluster_index_sort==i));

        flowVecList = ones(length(fXf),2);
        flowVecList(:,1) = flowVecList(:,1)*sin(bestmu(i));
        flowVecList(:,2) = flowVecList(:,2)*cos(bestmu(i));
        
        aux=vecFldInterpAnisoA([fYf,fXf,fYtf,fXtf],[fYf,fXf], flowVecList, 5,1);
        h=[fYf,fXf,fYf+aux(:,1),fXf+aux(:,2)];

        h1 = vectorFieldPlot(h,hh,[],2);
        
    end
    clear y
    clear var
    clear m
    clear flowVecList
%     
    indxStr=sprintf(strg,j);
%     
    hold off
%     
    axis([170 290 310 430]);
    
    makeqtmovie('addfigure')
    
   
    print(gcf,'-dtiff',['U:\moviesFlowPaperKmeans\Spindle',indxStr,'.tif']);
     
    close 
    
end

makeqtmovie('finish')

makeqtmovie('cleanup')