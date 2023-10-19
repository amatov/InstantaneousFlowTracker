function [M,rawlinks,allcosts,costs,maxflow]=fsmTrackTrackerPP(I,J,K,threshold)
% fsmTrackTrackerPP converts the output of newmincost.dll into the M Matrix
%
% SYNOPSIS   [M,rawlinks,allcosts,costs,maxflow]=fsmTrackTrackerPP(I,J,K,threshold)
%
% INPUT      I          :   1st image loc-max Map
%            J          :   2nd image loc-max Map
%            K          :   3rd image loc-max Map
%            threshold  :   radius of consideration for the tracker
%
% OUTPUT     M          :   the M Matrix
%            rawlinks   :   raw linked list as returned by the graph based
%                           tracker (newmincost.dll)
%                           REMARK: Both matrices are empty if there is no link
%           allcosts    :   all the possible costs calculated in newmincost.dll
%           costs       :   the costs of the solultion according to newmincost.dll
%           maxflow     :   the maximum flow of the graph (newmincost.dll)
%
% DEPENDENCES   fsmTrackTrackerPP uses { candvectorsCirc, newmincost.dll, createDistanceMatrix}
%               fsmTrackTrackerPP is used by { fsmTrackMain, testDLL }

% CHANGES    The original function is changed to return the raw links, all
%            the costs, the costs of the solution and the maximum flow
%            provided by the graph-based tracker (mainly used for debugging)
%            AM April-23/29-2003


[sizey sizex]=size(I);
Ilin=find(I);
Jlin=find(J);
Klin=find(K);

[y x]=find(I);posI=[y x];
[y x]=find(J);posJ=[y x];

% Candidate vectors
asifirst=candVectorsCirc(I,J,threshold);
asisecond=candVectorsCirc(J,K,threshold);

% Remove entries with zeroes
[y x]=find(asifirst==0);
asifirst(y,:)=[];
[y x]=find(asisecond==0);
asisecond(y,:)=[];

% Call the three point tracker
clear newmincost
if isempty(asifirst) | isempty(asisecond)
    rawlinks=[]; 
    M=[];
    return;
else
    [rawlinks,allcosts,costs,maxflow]=newmincost(asifirst,asisecond,0,0); % choose cost function - pass its number minus 1
    rawlinks(find(rawlinks<1))=0;% the DLL (mostlikely) introduces some very small values
end

if isempty(rawlinks)
    M=[];
    return;
end
auxRawLinks=rawlinks;

% Reorganize the output of the tracker
l1=prod(size(auxRawLinks))-1;
s1=1;
s2=1;
a=0;
for (i1=0:l1)
    a(1+floor(i1/4),1+rem(i1,4))=auxRawLinks(i1+1);
end
auxRawLinks=a;

% Kill the entries which are not suitable
[y x]=find(auxRawLinks==0);
auxRawLinks(y,:)=[];
auxRawLinks=[auxRawLinks(:,2),auxRawLinks(:,1),auxRawLinks(:,4),auxRawLinks(:,3)];

% Remove from auxRawLinks all entries which come from the matching of frame 2 with frame 3.
mfilter1=createDistanceMatrix(auxRawLinks(:,1:2),asisecond(:,1:2));
mfilter2=createDistanceMatrix(auxRawLinks(:,3:4),asisecond(:,3:4));
mfilter=mfilter1&mfilter2;
indm1=prod(mfilter,2);
keep=find(indm1==1);
auxRawLinks=auxRawLinks(keep,:);

% Find non-matched entries in image 1
Imatched=auxRawLinks(:,1:2);
D1=createDistanceMatrix(Imatched,posI);
[y x]=find(D1==0);
% Remove matched entries from posI
posI(x,:)=[];

% Find non-matched entries in image 2
Jmatched=auxRawLinks(:,3:4);
D2=createDistanceMatrix(Jmatched,posJ);
[y x]=find(D2==0);
% Remove matched entries from posJ
posJ(x,:)=[];

% Fill M
lM=size(auxRawLinks,1);lI=size(posI,1);lJ=size(posJ,1);
totL=lM+lI+lJ;
M=zeros(totL,4);
M(1:lM,1:4)=auxRawLinks;
M(lM+1:lM+lI,1:2)=posI;
M(lM+lI+1:totL,3:4)=posJ;
% insert a break point here
M=M;
