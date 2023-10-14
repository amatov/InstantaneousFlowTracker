function [frGR,bgGR,yN,xN,BEST_SIGMA,STRING_SIGMA,nmbConfSp,nmbSp,meanSig,stdSig,sumMandSs]=imageSegmentation(DEBUG)

% imageSegmentation:
% 1) segments an image to speckled and none-speckled part
% 2) automatically finds most appropiate sigma for the scale space
% 3) finds all the speckles in the image after applying statistical test
%
%
% SYNOPSIS   [frGR,bgGR,yN,xN]=imageSegmentation(DEBUG)
%
% INPUT      DEBUG    : 0 to avoid many Debug figures  
%
% OUTPUT     frGR     : speckled part of the cell   
%            bgGR     : none-speckled part of the cell (background)
%            yN       : 
%            xN       :   
%
%
% DEPENDENCES   imageSegmentation uses { }
%               imageSegmentation is used by { }
%
% Alexandre Matov, Janunary 7th, 2003

if nargin==0
    DEBUG=0;
end

[fileName,dirName] = uigetfile('*.tif','Choose an image');
I=imread([dirName,filesep,fileName]);
I=double(I);

MN=mean(I(:)); % to be improved!
It=I<=MN;

sigma=1;
If=gauss2d(I,sigma);
MN=mean(If(:));
If1=If<=MN;
If1 = double(If1); % NEW - convert logical to double

BWs1 = double(edge(If1));
BWdfill = double(imfill(BWs1,'holes'));
BWdfill=~BWdfill;

% thresholding
MNN=mean(BWdfill(:));
BWdfill=BWdfill>MNN;

BG=(If1)&(BWdfill);
BG=~BG;
bg1=double(imfill(BG,'holes')); 
bg2=~bg1;
indx=1;
sigi=1.14; % 1.25
final=1; % 0.5

% h=waitbar(0,'Please wait...');
% for SIGMA=(sigi+.000001):.01:(sigi+final) % step .001     (step .01=13min)  .0001
  SIGMA=sigi+.1;   % default 0.1, 0.2 just a few
    % substract
    img=I;
    % filter sigma 1
    I1=gauss2d(img,sigi);
    % filter sigma 2
    I2=gauss2d(img,SIGMA);
    % substract
    Isub=I1-I2;
    
    % clipping
    imgC=minZero(Isub);
    
    % border to 0
    imgC(1:6,:)=0;
    imgC(end-5:end,:)=0;
    imgC(:,1:6)=0;
    imgC(:,end-5:end)=0;
    Ifsss=imgC;
    
    minI=min(Ifsss(:));
    maxI=max(Ifsss(:));
    frGR=Ifsss.*bg1;
    bgGR=Ifsss.*bg2;
    
    Imaxsss=locmax2d(bgGR,[5 5]);
    [y x]=find(ne(Imaxsss,0));
    u=find(ne(Imaxsss,0));
   
    v=Ifsss(u); % noise speckles (vector of the local maxima intensities)
    [n,p]=hist(v); % hist of NoiSpe
     
    ImaxFsss=locmax2d(frGR,[5 5]);
    [yF xF]=find(ne(ImaxFsss,0));
    nmbSp(indx)=length(yF);
    
    uF=find(ne(ImaxFsss,0));
    
    vF=Ifsss(uF);
    [nF,pF]=hist(vF);
    
    % calculation of delta I critical
    meanSig=mean(v);
    stdSig=std(v); % STD of Noise Speckles
    sumMandSs=meanSig + 2.96*stdSig; % significance Test (7.96, almost nothing)
    
    Mask=ImaxFsss>sumMandSs;
    ImaxN=Mask.*ImaxFsss;
    [yN xN]=find(ne(ImaxN,0));
    nmbConfSp(indx)=length(yN);
    STRING_SIGMA(indx)=SIGMA;
    indx=indx+1;
    
%     % Wait bar
%     waitbar(SIGMA/(sigi+final),h);  
% end
% close(h);

BEST_SIGMA=STRING_SIGMA(find(nmbConfSp==max(nmbConfSp)));

% figures
if DEBUG==1
    
%     figure,plot(STRING_SIGMA,nmbSp);
%     title('Number of All Speckles Extracted (Before Test) as Function of the Second Sigma');

    figure,plot(STRING_SIGMA,nmbConfSp);
    title('Number of Significant Speckles Extracted as Function of the Second Sigma');
    
    figure,imshow(If1)
    title('Thresholded image (threshold - the Mean) after filtering gauss2d(I,1)');
    
    figure,hist(If(:),[min(If(:)):1:max(If(:))]);% yes
    title('Intensity Histogram of the Image')
    
    figure, imshow(BWdfill); 
    title('~binary image with filled holes');
    
    figure,imshow(BG)
    title('background');% yes
    
%     figure,imshow(bg2);
%     title('final result (background is 1)');% yes
    
    figure,imshow(bg1)
    title('foreground is 1');% yes
    
%     figure,imshow(Ifsss,[minI,maxI])
%     title('substracted image (complete)')
    
    figure,imshow(frGR,[minI,maxI])% yes
    title('foreground Only (after segmentation)')
    
%     figure,imshow(If,[])
%     title('original (filtered) image')
    
%     figure,imshow(bgGR,[minI,maxI])% yes
%     title('background Only (after segmentation)')
    
    figure,imshow(bgGR,[minI maxI])% yes
    hold on
    plot(x,y,'r.')
    hold off
    title('noise speckles in the BG')
    
    figure,hist(v);% yes
    title('histogram of Noise (BG) Speckles')
    
%     figure,plot(p,n,'b-')
%     title('distribution of Noise (BG) Speckles')
    
%     % FIG 16
%     figure,imshow(frGR,[minI maxI])% yes
%     hold on
%     plot(xF,yF,'r.')
%     hold off
%     title('ALL speckles in the foreground')
%     
    figure,hist(vF); % yes
    title('histogram of ForeGround Speckles')
    
%     figure,plot(pF,nF,'r-')
%     title('distribution of Foreground Speckles')
    
    % FIG 19
    figure,imshow(frGR,[minI maxI])% yes
    hold on
    plot(xF,yF,'r.')
    plot(xN,yN,'g.')
    hold off
    title('significant speckles GREEN, rejected RED')
    
end 

% after test FIG20
figure,imshow(If(5:end-4,5:end-4),[])% yes
hold on
plot(xN-4,yN-4,'g.')
hold off
title('Significant Speckles (overlaid on the original image)')

% length(xN)
% 
% 
% figure,imshow(I,[]) % raw
% figure,imshow(I1,[]) % sigma one
% I2=Gauss2D(I2,2);
% figure,imshow(I2,[]) % sigma two
% figure,imshow(Ifsss,[]) % substracted

% local function 
function M=minZero(M)
M(find(M<0))=0;