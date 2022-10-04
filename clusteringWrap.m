function [costAdd,w3,cluster_index,gmm,flowMap,dir] = clusteringWrap(links,nbDir,ve,w3,singleTriplets,RAK_ANGLE)



dy = [links(:,5)-links(:,1)];
dx = [links(:,6)-links(:,2)];
fY = [links(:,1)];
fX = [links(:,2)];
fYt = [links(:,5)];
fXt = [links(:,6)];

ang = atan2(dy,dx);

angDiff = zeros(size(ang));

if nbDir == 1
    cluster_index=ones(size(ang)); %NO CLASTERING APPLIED
    bestmu = RAK_ANGLE ;
else
    [cluster_index,bestmu] = wrapAroundClustering(ang);
end
angBeta = [];costAdd = [];

for i = 1:nbDir
    indx = find(cluster_index==i);
    STD_ANG_EACH_DIR(i) = std(ang(indx));

    fXf=fX(indx);
    fYf=fY(indx);
    fXtf=fXt(indx);
    fYtf=fYt(indx);

    if i == 1
        ang1 = ang(find(cluster_index==1));
    elseif i == 2
        ang2 = ang(find(cluster_index==2));
    else
        fprintf('more than 2 clusters');
    end


    flowVecList = ones(length(fXf),2);
    flowVecList(:,1) = flowVecList(:,1)*sin(bestmu(i));
    flowVecList(:,2) = flowVecList(:,2)*cos(bestmu(i));
    aux =[];
    %---------------------------------------EACH DIR
    [aux,vecDir]=vecFldInterpAnisoB([fYf,fXf,fYtf,fXtf],[fYf,fXf],15,5,3); 
%     aux=vecFldInterpAnisoB([fYf,fXf,fYtf,fXtf],[fYf,fXf],40,10,3);

    h11=[fYf,fXf,fYf+aux(:,1),fXf+aux(:,2)];
    %-------------------------------------
    [auxEachD,vecDirEachD]=vecFldInterpAnisoB([fYf,fXf,fYtf,fXtf],[fYtf,fXtf],15,5,3);
%     auxEachD = vecFldInterpAnisoB([fYf,fXf,fYtf,fXtf],[fYtf,fXtf],40,10,3);
    
    h11d=[fYtf,fXtf,fYtf+auxEachD(:,1),fXtf+auxEachD(:,2)];
    angInt = atan2(aux(:,1),aux(:,2));

    h22=[fYf,fXf,fYtf,fXtf];

    eachDir=[fYf,fXf,fYf+vecDir(:,1),fXf+vecDir(:,2)];

    angBeta(indx) = ang(indx) - angInt;
    STD_ANG_BETA(i) = std(angBeta(indx));

    %----------------------------USED TO CALCULATE W3 involving ALL TRIPLETS------------------------------------------
    flVecList = ones(size(ve,1),2);
    flVecList(:,1) = flVecList(:,1)*sin(bestmu(i));
    flVecList(:,2) = flVecList(:,2)*cos(bestmu(i));
    aux=[];vecDir=[];listN=[];
    %         aux=vecFldInterpAnisoA([fYf,fXf,fYtf,fXtf],[ve(:,1) ve(:,2)], flVecList, 15,3);
    [aux,vecDir]=vecFldInterpAnisoB([fYf,fXf,fYtf,fXtf],[ve(:,1) ve(:,2)],12,5,3); % or 40,40
    [listN,vecDir] = normList(vecDir);
    aux(find(isnan(aux)))=0;
    % interpolate on grid of the complete set of triplets and calculate w3
    %     allTr = vectorFieldInterp([fYf,fXf,fYtf,fXtf],[ve(:,1) ve(:,2)],33,[]);
    allTr=[ve(:,1),ve(:,2),ve(:,1)+aux(:,1),ve(:,2)+aux(:,2)];

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

STD_ANG_BETA=std(angBeta);
w3 = 1/(STD_ANG_BETA*STD_ANG_BETA);
gmm.bestmu = bestmu;

%-------------------------------------------------------------------
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
costAdd=w3*10000*angSq; 