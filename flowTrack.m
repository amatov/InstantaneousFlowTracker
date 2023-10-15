function [links,flow,cluster_index,bestmu,flowMap,dir] = flowTrack(I,J,K,dist,w1,w2,w3,nbDir,iterations,firstF,nbWindows)
%function [links,flow,cluster_index,bestmu,flowMap,dir] = flowTrack(I,J,K,dist)%,w1,w2,w3,nbDir,iterations,firstF,nbWindows)

% flowTrack is the main function of the flow tracker
%
% SYNOPSIS   [links,flow,cluster_index,bestmu,flowMap,dir] = flowTrack(I,J,K,dist,w1,w2,w3,nbDir,iter,firstF,nbWindows)
%
% INPUT      I    :   list of coordinates in the first frame [y0,x0]
%            J    :   list of coordinates in the second frame [y1,x1]
%            K    :   list of coordinates in the third frame [y2,x2]
%            dist :   searching radius
%            w1   :   weight of the angle between segments
%            w2   :   weight of the difference of length between segments
%            w3   :   weight of the angle between triplets and the global motion
%            nbDir:   number of directions of the flow fields
%            iterations :   number of iteration during weight optimization
%            nbWindows:number of times frames of accumulation of links 
%            firstF:  first time frame to be considered
% 
% OUPUT      links:   the raw links of the triplets [yo xo y1 x1 y2 x2]
%            flow :   optimal flow thru this graph (scalar)
%            cluter_index: clustering index for each triplet
%            bestmu:  angles of directions of the clusters
%            flowMap: filtered links [y0 x0 y1 x1]
%            dir  : 
%
% Alexandre Matov June 19th 2004

aux = 0;
links = [];li=[];singleTriplets=[];

for i = firstF:firstF+nbWindows
    [Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos]=readCands(i); % ACCUMULATE FRAMES -> CHANGE LINKS
    MinDist=minDist(Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos) % ADDITIONAL
    [Graph(i).nbTri,Graph(i).nbArcs,Graph(i).capaVec,Graph(i).demaVec,Graph(i).A,Graph(i).F1,Graph(i).F2,Graph(i).F3] = ...
        buildGraph(Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos,dist);

    costIndx(i) = aux;
    aux = aux + Graph(i).nbTri;
    [lillinks,Graph(i).flow,Graph(i).mxNbTri,Graph(i).listTri,Graph(i).X,Graph(i).angV,Graph(i).deltaDv] = ...
        tft(Graph(i).Ipos,Graph(i).Jpos,Graph(i).Kpos,dist,w1,w2,w3,Graph(i).nbTri,Graph(i).nbArcs,Graph(i).capaVec,Graph(i).demaVec,...
        Graph(i).A,Graph(i).F1,Graph(i).F2,Graph(i).F3);
    links = [links;lillinks];
    lillinks =[];
    lilli = [Graph(i).Ipos(Graph(i).F1,:) Graph(i).Jpos(Graph(i).F2,:) Graph(i).Kpos(Graph(i).F3,:)]; % ALL TRIPLETS
    li = [li;lilli];
    lilli = []; singT = [];
end
ve = [li(:,1),li(:,2),li(:,5),li(:,6)]; % ALL TRIPLETS/VECTORS

for j = 1:iterations
    costAdd = [];cAdd = [];cluster_index = [];bestmu=[];
    [cAdd,w3,cluster_index,bestmu,flowMap,dir] = clusteringWrap(links,nbDir,ve,w3,singleTriplets); 
%      [cAdd,w3,cluster_index,bestmu,flowMap,dir] = clusteringKmeans(links,nbDir,ve,w3,singleTriplets); 
  
    if nbDir > 1
        costAdd = min(cAdd'); % TAKE THE MIN OF THE TWO W3 FOR EACH VECTOR
        costAdd = fix(costAdd);
    else
        costAdd = fix(cAdd');
    end
    
    links = [];flow = 0;X = 0;angV = [];deltaDv = [];listTri = [];singleTriplets = [];
    for i = firstF:firstF+nbWindows
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
        lillinks = [];singT = [];
    end
    Solution(j).links = links;

links =[];
links = Solution(end).links;
flow = [];
flow = Graph(end).flow;
end




