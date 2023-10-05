function [X,listTri] = MaxFlowMinCost(Prob,flowApplied,nbTri)

Prob.b_L(1) = flowApplied * 3;
Prob.b_U(1) = flowApplied * 3;

Prob.b_U(end) = -flowApplied * 3;
Prob.b_L(end) = -flowApplied * 3;
Prob.MIP.cpxControl.ITLIM = 300000;%20000;
% Prob.N

% Prob.SolverLP = 'pdco'; 

Prob.MIP.IntVars = nbTri;%Prob.N; %IF IT IS SET TO nbTri - then triplets are split
Prob.MIP.IntVars = (1:Prob.MIP.IntVars)';
% Result = tomRun('cplex', Prob, 1);

R = tomRun('cplex', Prob, [], 1);

% OUT = R.x_k(1:nbTri)
% o = round(OUT)

R.x_k(1:nbTri) = R.x_k(1:nbTri) * 3; % the result (X)
X=R.x_k;

listTri=X(1:nbTri)./3;

if listTri~=fix(listTri)
    listTri
    warning('the flow does not go only thru triplets')
%     listTri=fix(listTri);
end

listTri=round(listTri); % it was 'fix' which kills all negative entries!