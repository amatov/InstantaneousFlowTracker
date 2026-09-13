function MinDist=minDist(frames1,frames2,frames3)

% Alexandre Matov (2003)

D1 = createDistanceMatrix([frames1(:,1:2)],[frames1(:,1:2)]);
D1(find(D1==0))=1000;
MeanMinDistF1 = mean(min(D1,[],2));
D2 = createDistanceMatrix([frames2(:,1:2)],[frames2(:,1:2)]);
D2(find(D2==0))=1000;
MeanMinDistF2 = mean(min(D2,[],2));
D3 = createDistanceMatrix([frames3(:,1:2)],[frames3(:,1:2)]);
D3(find(D3==0))=1000;
MeanMinDistF3 = mean(min(D3,[],2));
MinDist = (MeanMinDistF1+MeanMinDistF2+MeanMinDistF3)/3;
