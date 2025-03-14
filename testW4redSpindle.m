function [links,flow,cluster_index,bestmu,flowMap,dir] = testW4redSpindle(I,J,K,dist)

Graph.Ipos=[];
Graph.Jpos=[];
Graph.Kpos=[];
% dist = 4; 3-polar [0.45 0.63 0.4];
w1 = 1.3;%0.22;%1.2;%1.2;%6.5;%0.3;%900;%530;%1300;%%33%1.25;%default 0.8 angle 0.4 benchmark   
w2 = .58;%1.6;%0.5;%0.5;%1.9;%0.3;%100;%65;%145;%%21%0.45;%default 0.2 distance 0.6 benchmark
w3 = .18;%0;%2.9;%0.26;%0.7;%0.7;%1.3;%0.34;%5;%%32%5.5;% default 1
nbDir =2;%2;
nbWindows = 0;
iterations = 3; %3 %30
aux = 0;
a = 1;

links = [];li=[];singleTriplets=[];
for i = a:a+nbWindows
    [Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos]=readCands(i); % ACCUMULATE FRAMES
    MinDist=minDist(Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos) % ADDITIONAL
    [Graph(i).nbTri,Graph(i).nbArcs,Graph(i).capaVec,Graph(i).demaVec,Graph(i).A,Graph(i).F1,Graph(i).F2,Graph(i).F3] = ...
        buildGraph(Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos,dist);
    %---------------------------------------------------------------------
%     [uE1,nO1] = countEntries(Graph(i).F1);
%     uA1=uE1(nO1==1);
%     for j = 1:length(uA1)
%         indx1(j) = find(Graph(i).F1 == uA1(j));
%     end
%     
%     [uE2,nO2] = countEntries(Graph(i).F2);
%     uA2=uE2(nO2==1);
%     for j = 1:length(uA2)
%         indx2(j) = find(Graph(i).F2 == uA2(j));
%     end
%     
%     [uE3,nO3] = countEntries(Graph(i).F3);        
%     uA3=uE3(nO3==1);
%     for j = 1:length(uA3)
%         indx3(j) = find(Graph(i).F3 == uA3(j));
%     end
%     
%     for j = 1:length(indx1)
%         [sta2(j),row2(j)]=ismember(indx1(j),indx2);
%         [sta3(j),row3(j)]=ismember(indx1(j),indx3);
%     end
%     auxInd = sta2.*sta3;
%     indxOne = find(auxInd);
%     auxT = zeros(size(Graph(i).F1));
%     auxT(indx1(indxOne))=1;
%     Graph(i).auxT = auxT;
    %----------------------------------------------------------------------
    costIndx(i) = aux;
    aux = aux + Graph(i).nbTri;
    [lillinks,Graph(i).flow,Graph(i).mxNbTri,Graph(i).listTri,Graph(i).X,Graph(i).angV,Graph(i).deltaDv] = ...
        tft(Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos,dist,w1,w2,w3,Graph(i).nbTri,Graph(i).nbArcs,Graph(i).capaVec,Graph(i).demaVec,...
        Graph(i).A,Graph(i).F1,Graph(i).F2,Graph(i).F3);
    links = [links;lillinks];
    lillinks =[];
    lilli = [Graph(i).Ipos(Graph(i).F1,:) Graph(i).Jpos(Graph(i).F2,:) Graph(i).Kpos(Graph(i).F3,:)]; % ALL TRIPLETS
    li = [li;lilli];
    %--------------------------------------------------------
%     singT = Graph(i).auxT.*Graph(i).X(1:Graph(i).nbTri);
%     singleTriplets = [singleTriplets;lilli(find(singT),:)];
    %--------------------------------------------------------
    lilli = []; singT = [];
end
ve = [li(:,1),li(:,2),li(:,5),li(:,6)]; % ALL TRIPLETS/VECTORS
% h = vectorFieldPlot(ve,0,[],1); %PLOT ALL TRIPLETS
for j = 1:iterations
    costAdd = [];cAdd = [];cluster_index = [];bestmu=[];
    [cAdd,w3,cluster_index,bestmu,flowMap,dir] = clusteringKmeans(links,nbDir,ve,w3,singleTriplets); 
    
%     w3 = 0;
    
    if nbDir > 1
        costAdd = min(cAdd'); % TAKE THE MIN OF THE TWO W3 FOR EACH VECTOR
        costAdd = fix(costAdd);
    else
        costAdd = fix(cAdd');
    end
    
%     figure, plot(cAdd); %LOOK AT COSTS ADDED WITH W3
    
    links = [];flow = 0;X = 0;angV = [];deltaDv = [];listTri = [];singleTriplets = [];
    for i = a:a+nbWindows
        [frames1.pos,frames2.pos,frames3.pos]=readCands(i);
        Graph(i).costAdd = costAdd(1+costIndx(i):Graph(i).nbTri+costIndx(i)); % BREAK THE LONG W3 INTO PIECES
        
        [lillinks,Graph(i).flow,Graph(i).mxNbTri,Graph(i).listTri,Graph(i).X,Graph(i).angV,Graph(i).deltaDv] = ...
            tft(Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos,dist,w1,w2,w3,Graph(i).nbTri,Graph(i).nbArcs,Graph(i).capaVec,Graph(i).demaVec,...
            Graph(i).A,Graph(i).F1,Graph(i).F2,Graph(i).F3,Graph(i).mxNbTri,Graph(i).costAdd);
        links = [links;lillinks];
        X = [X;Graph(i).X(1:Graph(i).nbTri)];
        listTri = [listTri;Graph(i).listTri];
        flow = flow + Graph(i).flow;
        angV = [angV;Graph(i).angV'];
        deltaDv = [deltaDv;Graph(i).deltaDv'];
        %---------------------------------------------------------
%         singT = Graph(i).auxT.*Graph(i).X(1:Graph(i).nbTri);
%         lilli = [Graph(i).Ipos(Graph(i).F1,:) Graph(i).Jpos(Graph(i).F2,:) Graph(i).Kpos(Graph(i).F3,:)]; % ALL TRIPLETS
%         singleTriplets = [singleTriplets;lilli(find(singT),:)];
%         lilli = [];
        %--------------------------------------------------------
        lillinks = [];singT = [];
    end
    Solution(j).links = links;
    %------------------------------------------------------------------
    [distTestAlpha,Palpha] = kstest(angV)
    [distTestDelta,Pdelta] = kstest(deltaDv)
    
%         figure,hist(angV,20)
%         legend('pdf angle alpha')
%         xlim([-pi pi])
%         figure,hist(deltaDv,20)
%         legend('pdf delta distance')
        
    STD_ALPHA = std(angV)
    STD_DELTA_D = std(deltaDv)
    w1n = 1/(STD_ALPHA*STD_ALPHA)
    w2n = 1/(STD_DELTA_D*STD_DELTA_D)
    if j > 1
        matches = 0;
        auxFlow = size(Solution(j-1).links,1);
        for k = 1:auxFlow
            [status,row]=ismember(Solution(j-1).links(k,:),links,'rows');
            if status == 1
                matches = matches + 1;
            end
        end
        PERCENT_TRIPLET_CHANGE(j-1) = (1 - matches/flow)*100;
    end
end

% if iterations > 1
%     figure,plot(PERCENT_TRIPLET_CHANGE)
% % axis(gca,'equal')
% end

links =[];
links = Solution(end).links;
flow = [];
flow = Graph(end).flow;





