%function [mxNbTr,ans] = MaxFlowCplexVersion(costVec,A,demaVec,nbArcs,capaVec,nbTri)
function [mxNbTr] = MaxFlowCplexVersion(costVec,A,demaVec,nbArcs,capaVec,nbTri)


f = [-ones(nbTri,1); zeros(length(costVec)-nbTri,1)];
Aineq = A([1,end],:);
Aineq = [Aineq; -Aineq];
bineq = zeros(4,1);
bineq(1) = 3*nbTri;
bineq(2) = 0;
bineq(3) = 0;
bineq(4) = 3*nbTri;
Aeq = A(2:end-1,:);
beq = demaVec(2:end-1)';

ctype = ones(1,nbArcs);
ctype = char(ctype*'I');
[anss,mxNbTr] = cplexmilp(f, Aineq,bineq,Aeq,beq,[],[],[],zeros(nbArcs,1),capaVec',ctype);
mxNbTr = -mxNbTr;
