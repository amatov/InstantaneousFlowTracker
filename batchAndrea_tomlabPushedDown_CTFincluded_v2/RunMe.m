load('ForAlex1');


% Prob = mipAssign(costVec, sparse(A), demaVec, demaVec, zeros(nbArcs,1), capaVec, [], [], [], [], nbArcs);
% Prob.SolverLP = 'lpSolve';
% Prob.SolverDLP = 'lpSolve';
% Prob.PriLev = 0;
% Prob.optParam.IterPrint = 0;
% Prob.PriLevOpt = 1;

%-------------------------------------------------
if nargin < 16 % get the MaxFlow if it is not known
    [mxNbTri1,ans1] = MaxFlowCplexVersion(costVec,A,demaVec,nbArcs,capaVec,nbTri);
    %[mxNbTri2,ans2] = MaxFlow(Prob,nbTri);
end
%---------------------------------------------------

[Xm1,listTriM1] = MaxFlowMinCostCplexVersion(costVec,A,demaVec,nbArcs,capaVec,mxNbTri1,nbTri);

%[Xm2,listTriM2] = MaxFlowMinCost(Prob,mxNbTri2,nbTri);

save('output','Xm1','listTriM1','mxNbTri');
