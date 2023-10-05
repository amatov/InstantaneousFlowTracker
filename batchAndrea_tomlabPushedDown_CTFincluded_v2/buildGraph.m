function [nbTri,nbArcs,capaVec,demaVec,A,F1,F2,F3]  = buildGraph(I,J,K,dist)

x1=  I(:,2);
y1=  I(:,1);
x2=  J(:,2);
y2=  J(:,1);
x3=  K(:,2);
y3=  K(:,1);
nbFr=3; %always

% MM1=createSparseDistanceMatrix(I(:,1:2),J(:,1:2),dist); 
MM1=createDistanceMatrix(I(:,1:2),J(:,1:2)); % NO SPARSE
in1=find(MM1>dist);
MM1(in1)=0;
M1=MM1;
[n,m]=find(MM1); % n - speckles from F1 involved, m - F2
% MM2=createSparseDistanceMatrix(J(:,1:2),K(:,1:2),dist); 
MM2=createDistanceMatrix(J(:,1:2),K(:,1:2)); % NO SPARSE
in2=find(MM2>dist);
MM2(in2)=0;
M2=MM2;
ol=[1:size(J(:,1:2),1)]';
sedi23=setdiff(ol,unique(m));
M2(sedi23,:)=0;
[q,p]=find(M2); % q - speckles from F2 involved, p - F3
sedi12=setdiff(unique(m),unique(q));
for i =1:length(sedi12)
    indx=find(m==sedi12(i));
    for j=1:length(indx)
        M1(n(indx(j)),sedi12(i))=0;
    end
end
[a,b]=find(M1~=0);
[c,d]=find(M2~=0);
if unique(c)~=unique(b)
    warning('wrong matching')
end
counter = 1;
for i=1:length(a)
    row=find(c==b(i));
    for j=1:length(row)
        F1(counter)=a(i);
        F2(counter)=b(i);
        F3(counter)=d(row(j));
        counter=counter+1;
    end
end
F1=F1';
F2=F2';
F3=F3';
%------------------------------------------------------------------

    % histogram of occurances of individual speckles in triplets
    [uniqueEntries,numberOfOccurences1] = countEntries(F1);
    [uniqueEntries,numberOfOccurences2] = countEntries(F2);
    [uniqueEntries,numberOfOccurences3] = countEntries(F3);
    numOc = [numberOfOccurences1;numberOfOccurences2;numberOfOccurences3];
%     [n,x] = hist(numOc,20);%max(numOc));
%     figure, hist(numOc, [1.475 2.425 3.375 4.325 5.275 6.225 7.175 8.125 9.075 10.025 10.975 11.925 12.875 13.825 14.775 15.725 16.675 17.625 18.575 19.525], 'FaceColor', 'k')
%     legend('Number of Triplets Each Speckle is Involved In');

%-------------------------------------------------------------------
UF1=unique(F1);
UF2=unique(F2);
UF3=unique(F3);
MAX_NUM_OC = max(numOc);
MEAN_NUM_OC = mean(numOc);

nbTri = length(find(F1));
nbSpeF1 = length(unique(a));
nbSpeF2 = length(unique(b));
nbSpeF3 = length(unique(d));
nbSpe = nbSpeF1 + nbSpeF2 + nbSpeF3;
nbArcs = nbTri + 3*nbTri + nbSpe;
nbNodes = 2 + nbTri + nbSpe;

capaVec=cat(2,3*ones(1,nbTri),ones(1,(nbArcs-nbTri))); % the capacity Vector (3 for triplets, 1 for speckles)
demand = 3*min([nbSpeF1 nbSpeF2 nbSpeF3]);
demaVec=cat(2,demand,zeros(1,nbTri),zeros(1,nbSpe),-demand);

A=sparse(nbNodes,nbArcs);
A(1,1:nbTri)=3;%1; % USED TO BE 1 % first row (all the source to triplets ones)
A(nbNodes,end-nbSpe+1:end)=-1; % last row (incoming speckles in sink) minus-ones

shift=nbTri;
for i=2:nbNodes-nbSpe-1 % = nbTri + 1 
    A(i,shift+1)=1; % the triplet to speckles ones
    A(i,shift+2)=1;
    A(i,shift+3)=1;
    if i < (nbTri+2)
        A(i,i-1)=-3;
    else
        A(i,i-1)=-1; % the diagonal under the first row (incoming from sink to triplets) minus-one
    end
    currentShift=shift;
    indx1=find(UF1==F1(i-1));
    indx2=find(UF2==F2(i-1));
    indx3=find(UF3==F3(i-1));
    A(1+nbTri                 + indx1, shift+1)=-1;  
    A(1+nbTri+nbSpeF1         + indx2, shift+2)=-1;  
    A(1+nbTri+nbSpeF1+nbSpeF2 + indx3, shift+3)=-1;  
    shift=shift+3;
end
for i=nbNodes-nbSpe:nbNodes-1 % speckles to sink ones (using the already updated 'shift')
    A(i,shift+1)=1;
    shift=shift+1;
end
% optPar = lpDef; % look it up

% capaVec(1:nbTri) = 1;
