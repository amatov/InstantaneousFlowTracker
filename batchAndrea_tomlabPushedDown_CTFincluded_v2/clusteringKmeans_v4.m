function [costAdd,w3,cluster_index,gmm,flowMap,dir,nbDir] = clusteringKmeans_v4(links,nbDir,ve,w3,singleTriplets, SigmaU)

% if nbDir == [], it means the EM algorithm is supposed to find number of
% required directions (nbDir). If it is already a valid number, the
% algorithm will assign each data to one gaussian.

% if nargin == 0
% %     load(['U:\june8ss3polar\links\links1535']);
%     load(['M:\unc\resultsAlex\Meta10sAug23\links\links01']);
%     nbDir = 2;
%     ve = [links(:,1),links(:,2),links(:,5),links(:,6)];
%     w3 = 0.7;singleTriplets=[];
% end

dy = [links(:,5)-links(:,1)];
dx = [links(:,6)-links(:,2)];
fY = [links(:,1)];
fX = [links(:,2)];
fYt = [links(:,5)];
fXt = [links(:,6)];

ang = atan2(dy,dx);

if isempty(nbDir)
    [bestk,bestpp,bestmu,bestcov,dl,countf] = mixtures4_circular(ang);
else
    bestk = nbDir;
end

angDiff = zeros(size(ang));

% if bestk == 1
%     cluster_index=ones(size(ang)); %NO CLASTERING APPLIED
%     bestmu = 1.53;
% else
%     [cluster_index,bestmu] = wrapAroundClustering(ang);
%    [cluster_index, bestmu] = kmeans(ang, nbDir,'emptyaction','singleton');
while 1
    [bestk,bestpp,bestmu,bestcov,dl,countf] = mixtures4_circular_known_K(ang,bestk);
    bestmu * 180 / pi
    bestpp
    [bestcov(:)]'
    
    cluster_index = zeros(1,length(ang));
    pGaussian = zeros(length(ang),bestk);
    for i = 1:length(ang)
        pGaussian(i,:) = ProbabilityOfXinGaussian(ang(i),bestmu, bestcov, bestpp);
        [~, cluster_index(i)] = max(pGaussian(i,:));
    end
    checkChange = 0;
    if isempty(nbDir)
        for i = 1:bestk
            if sum(cluster_index == i)<length(ang)/bestk*(1/3)
                checkChange = 1;
                bestk = bestk - 1;
                break;
            end
        end
    end
    if checkChange == 0
        break;
    end
end
nbDir = bestk;

resAngles = bestmu./pi.*180;

angBeta = [];costAdd = [];

% I = double(imread('M:\unc\FSMdataUNC\SpindleRedRawAligned\RedRawAligned01.tif'));
% h_fig = figure, imshow(I,[]);
for i = 1:nbDir
    indx = find(cluster_index==i);
    STD_ANG_EACH_DIR(i) = std(ang(indx));
    
    fXf=fX(indx);
    fYf=fY(indx);
    fXtf=fXt(indx);
    fYtf=fYt(indx);
    
    %     if i == 1
    %         ang1 = ang(find(cluster_index==1));
    %     elseif i == 2
    %         ang2 = ang(find(cluster_index==2));
    %     else
    %         fprintf('more than 2 clusters');
    %     end
    
    
    flowVecList = ones(length(fXf),2);
    flowVecList(:,1) = flowVecList(:,1)*sin(bestmu(i));
    flowVecList(:,2) = flowVecList(:,2)*cos(bestmu(i));
    aux =[];
    %---------------------------------------EACH DIR
    %         aux=vecFldInterpAnisoA([fYf,fXf,fYtf,fXtf],[fYf,fXf], flowVecList, 40,10);
    [aux,vecDir]=vecFldInterpAnisoB([fYf,fXf,fYtf,fXtf],[fYf,fXf],SigmaU,SigmaU/4,3);%40 10 / 16-4
    %         [listN,vecDir] = normList(vecDir);
    %     h11=vectorFieldInterp([fYf,fXf,fYtf,fXtf],[fYf,fXf],33,[]);
    
    h11=[fYf,fXf,fYf+aux(:,1),fXf+aux(:,2)];
    %-------------------------------------
    %         aux=vecFldInterpAnisoA([fYf,fXf,fYtf,fXtf],[fYf,fXf], flowVecList, 40,10);
    [auxEachD,vecDirEachD]=vecFldInterpAnisoB([fYf,fXf,fYtf,fXtf],[fYtf,fXtf],12,3,3);%40 10 / 16-4
    %         [listNeachD,vecDirEachD] = normList(vecDirEachD);
    %     h11=vectorFieldInterp([fYf,fXf,fYtf,fXtf],[fYf,fXf],33,[]);
    
    h11d=[fYtf,fXtf,fYtf+auxEachD(:,1),fXtf+auxEachD(:,2)];
    %       ---------------------------------------------------
    %         hEachD = vectorFieldPlot(h11d,[],[],1); % PLOT FOR EACH DIR ONLY
    %         VECTOS ONLY
    %     fIntY = h11(:,3);
    %     fIntX = h11(:,4);
    %     dyInt = [fIntY-fYf];
    %     dxInt = [fIntX-fXf];
    %     angInt = atan2(dyInt,dxInt); % ANGLES BETWEEN ROW TRIPLETS AND ANISOTROPIC FILTERED LINKS
    angInt = atan2(aux(:,1),aux(:,2));
    
    %     vectorFieldPlot(h11,h1,[],1);
    
    h22=[fYf,fXf,fYtf,fXtf];
    %     hv = vectorFieldPlot(h22,[],[],1); % PLOT SELECTED TRIPLETS IN ONE OF THE DIRECTIONS (BLACK)
    %     axis(gca,'equal')
    
    %     vectorFieldPlot(h11,hv,[],1); % PLOT THE INTERPOLATED LINKS IN ONE OF THE DIRECTIONS (RED)
    %     axis(gca,'equal')
    
    %     hh=[fYf,fXf,fYf+flowVecList(:,1),fXf+flowVecList(:,2)];
    eachDir=[fYf,fXf,fYf+vecDir(:,1),fXf+vecDir(:,2)];
    %     vectorFieldPlot(eachDir,hv,[],5); % PLOT THE DIRECTIONS OF THE UNISOTROPIC FILTER (BLUE)
    %     axis(gca,'equal')
    
    %------single triplets----------
    %     hold on
    %     quiver(singleTriplets(:,2),singleTriplets(:,1),singleTriplets(:,6)-singleTriplets(:,2),singleTriplets(:,5)-singleTriplets(:,1),0,'b--');
    %     hold off
    %----------YANG--------------------------
    %     I = double(imread('M:\unc\Test_WH_data\tub29\tub29_01.tif'));
    
    %     vectorFieldPlot(h22,h_fig,[],1);
    %----------------------------------------
    %     auxAngleBeta = [];
    %     auxAngleBeta(indx) = ang(indx) - angInt;%resAngles(i);
    %     angBeta = [angBeta;auxAngleBeta'];
    angBeta(indx) = ang(indx) - angInt;
    STD_ANG_BETA(i) = std(angBeta(indx));
    %------------------------------------
    
    %-----------------------------
    
    %     figure, quiver(fXf,fYf,fXtf-fXf,fYtf-fYf,0);
    %----------------------------USED TO CALCULATE W3 involving ALL TRIPLETS------------------------------------------
    flVecList = ones(size(ve,1),2);
    flVecList(:,1) = flVecList(:,1)*sin(bestmu(i));
    flVecList(:,2) = flVecList(:,2)*cos(bestmu(i));
    aux=[];vecDir=[];listN=[];
    %         aux=vecFldInterpAnisoA([fYf,fXf,fYtf,fXtf],[ve(:,1) ve(:,2)], flVecList, 15,3);
    [aux,vecDir]=vecFldInterpAnisoB([fYf,fXf,fYtf,fXtf],[ve(:,1) ve(:,2)],40,10,3); % or 40,40
    [listN,vecDir] = normList(vecDir);
    aux(find(isnan(aux)))=0;
    % interpolate on grid of the complete set of triplets and calculate w3
    %     allTr = vectorFieldInterp([fYf,fXf,fYtf,fXtf],[ve(:,1) ve(:,2)],33,[]);
    allTr=[ve(:,1),ve(:,2),ve(:,1)+aux(:,1),ve(:,2)+aux(:,2)];
    %------------------------------------------------------------------------
    %      vectorFieldPlot(hf,hv,[],1);
    
    %     IVF=vectorFieldInterp([fYf,fXf,fYtf,fXtf],[fYf,fXf],33,[]);
    
    %     axis xy
    %----------------------------------------------------------------------
    
    %------------------------------------------------------------------
    %   vectorFieldPlot(allTr,[],[],1); % PLOT ALL TRIPLETS - USED TO CALCULATE W3
    flowMap(i).map = allTr;
    dir(i).map = eachDir;
    %-------------------------------------------------------------------
    len = size(ve,1);
    for j = 1:len
        costAdd(j,i) = angle(ve(j,4),ve(j,2),allTr(j,4),ve(j,3),ve(j,1),allTr(j,3),w3);
    end
    
    fXf=[];
    fYf=[];
    fXtf=[];
    fYtf=[];
end

% STD_ANG_EACH_DIR
[distTestBeta,pBeta] = kstest(angBeta);

% figure,hist(angBeta,20) %AANGLE HIST!!
% legend('pdf angle beta')
% xlim([-pi pi])

STD_ANG_BETA=std(angBeta);
w3 = 1/(STD_ANG_BETA*STD_ANG_BETA);

gmm.bestk = bestk;
gmm.bestcov = bestcov;
gmm.bestmu = bestmu;
gmm.bestpp = bestpp;

% PLOT THE TWO CLUSTERS IN THE SAME FIGURE
% figure, [n1,x1] = hist(ang1,15);
% hh1 = bar(x1,n1);
% set(hh1,'FaceColor','y')
% xlim([-pi pi])
% %HISTOGRAM FOR TWO DIRECTIONS!!
% hold on
% [n2,x2] = hist(ang2,15);
% hh2 = bar(x2,n2);
% set(hh2,'FaceColor','r')
% xlim([-pi pi])
%--------------------------------------------------------------------
function costAdd=angle(x1,x2,x3,y1,y2,y3,w3) % list all x, then all y

dx1= x2-x1;
dx2= x3-x2;
dy1= y2-y1;
dy2= y3-y2;

aa1=sqrt(dx1*dx1+dy1*dy1);
aa2=sqrt(dx2*dx2+dy2*dy2);
if aa1==0 || aa2==0
    cosAngle=-1;
else
    cosAngle=(dx1*dx2+dy1*dy2)/(aa1*aa2);
end

ang = acos(cosAngle);
angSq = ang*ang;
costAdd=w3*10000*angSq; % multiply by 100 to make it integer