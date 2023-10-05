function [X,listTri] = MaxFlowMinCostCplexVersion(costVec,A,demaVec,nbArcs,capaVec,flowApplied,nbTri)

% Aineq = A([1,end],:);
% Aineq = [Aineq; -Aineq];
% bineq = zeros(4,1);
% bineq(1) = 3*nbTri;
% bineq(2) = 0;
% bineq(3) = 0;
% bineq(4) = 3*nbTri;
Aeq = A;
beq = demaVec';
beq(1) = flowApplied * 3;
beq(end) = -flowApplied * 3;

ctype = ones(1,nbArcs);
ctype = char(ctype*'I');
[ans,mxNbTr] = cplexmilp(costVec, [],[],Aeq,beq,[],[],[],zeros(nbArcs,1),capaVec',ctype);
mxNbTr = -mxNbTr;

ans(1:nbTri) = ans(1:nbTri) * 3;
X = ans;
listTri=X(1:nbTri)./3;

if listTri~=fix(listTri)
    listTri
    warning('the flow does not go only thru triplets')
%     listTri=fix(listTri);
end

listTri=round(listTri); % it was 'fix' which kills all negative entries!