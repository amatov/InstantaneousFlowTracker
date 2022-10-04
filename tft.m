function [links,flow,mxNbTri2,listTriO2,Xo2,angVo,deltaDvO] = tft(I,J,K,dist,w1,w2,w3,nbTri,nbArcs,capaVec,demaVec,A,F1,F2,F3,mxNbTri2,costAdd)

% tft is the main function of the three frame tracker
%
% SYNOPSIS   links = tft(I,J,K,dist)
%
% INPUT      I    :   list of coordinates in the first frame [y0,x0]
%            J    :   list of coordinates in the second frame [y1,x1]
%            K    :   list of coordinates in the third frame [y2,x2]
%            dist :   searching radius
% 
% OUPUT      links:   the raw links of the triplets [yo xo y1 x1 y2 x2]
%            flow :   optimal flow thru this graph
%
% DEPENDENCES   tft uses { coreTFT }
%               tft is used by { fsmTrackMain }
%
% Alexandre Matov June 19th 2004


[costV,angV,deltaDv] = coFun(I,J,K,F1,F2,F3,'costaa',w1,w2,w3);

% figure, plot(costV);% THE COST VALUES

costVec=cat(2,costV,zeros(1,(nbArcs-nbTri))); % the input cost vector for NWsimplx.m (single speckles have 0)
costVec=100*costVec;
costVec=fix(costVec);
costVec = costVec * 3;
%-------------------------------------------------
if nargin == 17 % add the external field cost
    costVec(1:nbTri) = costVec(1:nbTri) + costAdd;
end
%---------------LOG_FILE-----------------------------------
%     fid = fopen('/tmp/TOM-LOG.txt','a+');
%     fprintf(fid,'size(A) = %i %i (%1.4f Gb) nbTri = %i \n', size(A),prod(size(A))*8/1e9, nbTri);
%     fclose(fid)
%-------------------------------------------------

%Prob=cplexlp(costVec,sparse(A),demaVec,[],[],zeros(nbArcs,1),capaVec)


% Prob = mipAssign(costVec, sparse(A), demaVec, demaVec, zeros(nbArcs,1), capaVec, [], [], [], [], nbArcs);
% Prob.SolverLP = 'lpSolve';
% Prob.SolverDLP = 'lpSolve';
% Prob.PriLev = 0;
% Prob.optParam.IterPrint = 0;
% Prob.PriLevOpt = 1;
%-------------------------------------------------
if nargin < 16 % get the MaxFlow if it is not known
    %mxNbTri = MaxFlow(Prob,nbTri);
    mxNbTri2 = MaxFlowCplexVersion(costVec,A,demaVec,nbArcs,capaVec,nbTri);
end
%---------------------------------------------------
mxNbTri = mxNbTri2;
%[Xm,listTriM] = MaxFlowMinCost(Prob,mxNbTri,nbTri);
[Xm2,listTriM2] = MaxFlowMinCostCplexVersion(costVec,A,demaVec,nbArcs,capaVec,mxNbTri2,nbTri);

%---------------LOG_FILE-----------------------------------
%     fid = fopen('/tmp/TOM-LOG.txt','a+');
%     fprintf(fid,'size(Prob.A) = %i %i (%i1.4f Gb) listTriM = %i \n', size(Prob.A), prod(size(Prob.A))*8/1e9, listTriM);
%     fclose(fid)
%-------------------------------------------------------------

REDU = biObjectFlow(costVec,nbTri,Xm2);

flow = mxNbTri2 - REDU;

%[Xo,listTriO] = MaxFlowMinCost(Prob,flow,nbTri);
[Xo2,listTriO2] = MaxFlowMinCostCplexVersion(costVec,A,demaVec,nbArcs,capaVec,flow,nbTri);


angVo = angV(find(Xo2(1:nbTri)));
deltaDvO = deltaDv(find(Xo2(1:nbTri)));

listF1= listTriO2.*F1;
listF1=listF1(find(listF1));

listF2= listTriO2.*F2;
listF2=listF2(find(listF2));

listF3= listTriO2.*F3;
listF3=listF3(find(listF3));

links = [I(listF1,1:2) J(listF2,1:2) K(listF3,1:2)];% SOLUTION

