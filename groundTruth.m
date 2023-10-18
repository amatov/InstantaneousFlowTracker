function [trackedLinks,flow]=groundTruth
% [artificLinks,trackedLinks,flow,matches,success]=groundTruth

% numbOfFrames = 3;
% nbPoints = 500;
% [frameStack,track]=spindleSimulation_v72(numbOfFrames,nbPoints);
%-------------------------------------------------------------------
% f = rotDishRead('new_sqfeatures.txt');
% f = rotDishRead('rotdish80.trk');
% f = rotDishRead('rubicfeatures.txt');
% f = pivread;
% stackIm = length(f)
% % frameStack(1).coordinate = f(1).points;
% % frameStack(2).coordinate = f(2).points;
% for i = 1:3%stackIm
%     frameStack(i).coordinate = round([f(i).points]); % ARTIFICIAL DATA TO BE TRACKED
% end
% clear f
% 
% % track = f; % GROUND TRUTH?
% aux = 3;
counter = 0;
%----------------------------------------------------------------------
% slide windows!
trackedLinks = [];
for i = 1:1%stackIm-2%1:3:16
    A = pivread(i);
    B = pivread(i+1);
    C = pivread(i+2);
    len1 = min(size(find(A(:,2)),1),size(find(B(:,2)),1));
    len2 = min(len1,size(find(C(:,2)),1)); % NUMBER OF POINTS
    len = round(len2);
    L1 = A(1:len,:);
    L2 = B(1:len,:);
    L3 = C(1:len,:);
    
    I = L1(:,2:3); % INPUT FOR THE TRACKER, LISTS OF COORDINATES
    D1 = createDistanceMatrix([I(:,1:2)],[I(:,1:2)]);
    D1(find(D1==0))=1000;
    MeanMinDistF1 = mean(min(D1,[],2));
    J = L2(:,2:3);
    D2 = createDistanceMatrix([J(:,1:2)],[J(:,1:2)]);
    D2(find(D2==0))=1000;
    MeanMinDistF2 = mean(min(D2,[],2));
    K = L3(:,2:3);
    D3 = createDistanceMatrix([K(:,1:2)],[K(:,1:2)]);
    D3(find(D3==0))=1000;
    MeanMinDistF3 = mean(min(D3,[],2));
    MinDist = (MeanMinDistF1+MeanMinDistF2+MeanMinDistF3)/3
    RatioVelDist = 4.218/MinDist
    
    searchRad =8.55; % 3-polar RAD =3 % CUBIK 11% DISH 30; SQUARE 3
    % piv1 7 8 piv3 8 9
    perturb = round(len/7);
    %----------------------------------------------------
    countTr = 0;
    for j = 1:size(L1,1)
        index1 = find(L2(:,1)==L1(j,1));
        index2 = find(L3(:,1)==L1(j,1));
        if ~isempty(index1)& ~isempty(index2)
            countTr = countTr+1;
            artificLi(countTr,:) = [L1(j,2:3) L2(index1,2:3) L3(index2,2:3)];
        end
    end
    %--------------------------------------------------
    p = zeros(countTr,3);
    per1 = round(rand(perturb,1)*(countTr-1)+1); % some indexes can be the same after rounding
    per2 = round(rand(perturb,1)*(countTr-1)+1);
    per3 = round(rand(perturb,1)*(countTr-1)+1);
    for i = 1:perturb
        p(per1(i),1)=1;
        p(per2(i),2)=1;
        p(per3(i),3)=1;
    end
    trueIndx = find(sum(p')==0);
    %----------------------------------------------------------
    for i = 1:perturb
%         I(i,1)=I(i,1)+(rand(1)-0.5)*2*8;
%         I(i,2)=I(i,2)+(rand(1)-0.5)*2*8;
        artificLi(per1(i),1:2)=artificLi(per1(i),1:2)+(rand(1)-0.5)*2*searchRad/sqrt(2);
%         artificLi(i,2)=artificLi(i,2)+(rand(1)-0.5)*2*searchRad/sqrt(2);
        artificLi(per2(i),3:4)=artificLi(per2(i),3:4)+(rand(1)-0.5)*2*searchRad/sqrt(2);
%         artificLi(i+perturb,4)=artificLi(i+perturb,4)+(rand(1)-0.5)*2*searchRad/sqrt(2);
        artificLi(per3(i),5:6)=artificLi(per3(i),5:6)+(rand(1)-0.5)*2*searchRad/sqrt(2);
%         artificLi(i+2*perturb,6)=artificLi(i+2*perturb,6)+(rand(1)-0.5)*2*searchRad/sqrt(2);
    end

    artificLinks = artificLi(trueIndx,:);
    size(artificLinks)
    PERTU = 3*perturb
    
%     [trackedLi,flow] = tft(I(1:len,1:2),J(1:len,1:2),K(1:len,1:2),searchRad); %CALL TO THE TRACKER 
%      [trackedLi,flow] = tft(artificLi(:,1:2),artificLi(:,3:4),artificLi(:,5:6),searchRad);
     [trackedLi,flow] = testW4(artificLi(:,1:2),artificLi(:,3:4),artificLi(:,5:6),searchRad);
    % append the tracking results
    trackedLinks = [trackedLinks;trackedLi];
    
end

matches = 0;

for i = 1:flow
    [status,row]=ismember(trackedLinks(i,:),artificLinks,'rows');
    if status == 1
        matches = matches + 1;
    end
end


matches 
success = matches/size(artificLinks,1)*100 % SUCCESS RATE

scaling = 1; % DEFAULT 3
Map1 = [artificLi(:,1:4);artificLi(:,3:6)]; 
h1 = vectorFieldPlot(Map1,0,[],scaling);
Map = [trackedLinks(:,1:4);trackedLinks(:,3:6)]; %DISPLAYS THE RESULT OF THE TRACKER
h1 = vectorFieldPlot(Map,h1,[],scaling);
axis ij

 