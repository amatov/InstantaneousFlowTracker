function [outIndx,cluster_angles] = wrapAroundClustering(A)

% A - input vector of elements
% As - sorted A
% Ind - index list
% M1, M1 - cut off of clusters
% K1, K2 - the 2 clusters
% C1, C2 - centers of clusters

% load ang;
% A = ang;

% A1=0.1 + randn(1,860)*.4;         %0.1 + randn(1,860)*.4;
% A2=2.6 + randn(1,1160)*.7;       %2.6 + randn(1,1160)*0.7;
% A=[A1 A2];

A(find(A<0))=A(find(A<0))+2*pi; % bring them to 0 - 2pi

% binCenters = [pi/20:pi/10:2*pi];
% figure, [n,x] = hist(A,binCenters);
% hh = bar(binCenters,n);
% set(hh,'FaceColor','m')
% xlim([0 2*pi])

[As,IndexA] = sort(A);

% initialize the cut-off's
[m,inM]=max(diff(As)); % take the slowest slope of CDF
M1 = As(inM);
M2 = M1 + pi;
if M2>2*pi
    M2 = M2-2*pi;
end
if M1>M2
    Maux = M1;
    M1 = M2;
    M2 = Maux;
end

aux1 = (As>=M1&As<M2);
indx1 = find(aux1);
indx2 = find(~aux1);
K1 = As(indx1);% new clusters
K3 = As(indx2);
K2 = K3;
K2(find(K2<M1))=K2(find(K2<M1))+2*pi;

C1 = mean(K1); % center of a cluster
C2 = mean(K2); % center of a cluster
if C2>2*pi
    C2 = C2-2*pi;
end
buf1 = 0; buf2 = 0;

i = 1;

% for i = 1:5
while abs(var(K1)-var(buf1))/var(K1)>0 || abs(mean(K1)-mean(buf1))/mean(K1)>0
PAR_VAR(i) = abs(var(K1)-var(buf1))/var(K1);
PAR_MEAN(i) = abs(mean(K1)-mean(buf1))/mean(K1);
    i = i + 1;
%     %     %-------------------------------------------------------
%         figure, [n1,x1] = histc(K1,binCenters);
%         hh1 = bar(binCenters,n1);
%         set(hh1,'FaceColor','y')
%         xlim([0 2*pi])
%         hold on
%         [n2,x2] = histc(K3,binCenters);
%         hh2 = bar(binCenters,n2);
%         set(hh2,'FaceColor','r')
%         xlim([0 2*pi])
%         plot([C1,C1],[0,max(n1)],'g')
%         text(C1,max(n1),'cluster center')
%         plot([C2,C2],[0,max(n1)],'b')
%         text(C2,max(n1),'cluster center')
%         plot([M1,M1],[0,max(n1)],'c')
%         text(M1,max(n1),'cut off')
%         plot([M2,M2],[0,max(n1)],'m')
%         text(M2,max(n1),'cut off')
%         hold off
%     %     %--------------------------------------------------------
    M1 = (C1+C2)/2; % new cut off
    M2 = M1 + pi;
    if M2>2*pi
        M2 = M2-2*pi;
    end
    if M1>M2
        Maux = M1;
        M1 = M2;
        M2 = Maux;
%         disp('gaga');
    end
    buf1 = K1; buf2 = K3;
    
    K1 = []; K2=[]; K3 = []; indxK1 = []; indxK2 = []; aux = [];

    aux = (As>=M1&As<M2);
    indxK1 = find(aux);
    indxK2 = find(~aux);
    K1 = As(indxK1);% new clusters
    K3 = As(indxK2);
    K2 = K3;
    K2(find(K2<M1))=K2(find(K2<M1))+2*pi;

    C1 = mean(K1);% new center of a cluster
    C2 = mean(K2);
    if C2>2*pi
        C2 = C2-2*pi;
    end

end
%-------------------------------------------------------
% figure, [n1,x1] = histc(K1,binCenters);
% hh1 = bar(binCenters,n1);
% set(hh1,'FaceColor','y')
% xlim([0 2*pi])
% hold on
% [n2,x2] = histc(K3,binCenters);
% hh2 = bar(binCenters,n2);
% set(hh2,'FaceColor','r')
% xlim([0 2*pi])
% plot([C1,C1],[0,max(n1)],'g')
% text(C1,max(n1),'cluster center')
% plot([C2,C2],[0,max(n1)],'b')
% text(C2,max(n1),'cluster center')
% plot([M1,M1],[0,max(n1)],'c')
% text(M1,max(n1),'cut off')
% plot([M2,M2],[0,max(n1)],'m')
% text(M2,max(n1),'cut off')
% hold off
%--------------------------------------------------------
LENGHTS = [length(K1),length(K2)];
STDS=[std(K1), std(K2)];
MEAN_K2=mean(K2);
if MEAN_K2>2*pi
    MEAN_K2=MEAN_K2-2*pi;
end
MEANS_ANGLES = [mean(K1),MEAN_K2];
%-----------------------------
outIndx = zeros(size(A));

outIndx(IndexA(indxK1)) = 1;
outIndx(IndexA(indxK2)) = 2;

cluster_angles = MEANS_ANGLES;

mean(A(outIndx==1));
