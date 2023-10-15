%function [mxNbTr,anss] = MaxFlow(Prob,nbTri)
function [mxNbTr] = MaxFlow(Prob,nbTri)

% Alexandre Matov June 19th 2004

Prob.QP.c = [-ones(nbTri,1) ; zeros(length(Prob.QP.c)-nbTri,1)]; % maximize (all cost of triplets to 1)

Prob.b_L(1) = 0;
Prob.b_U(1) = nbTri * 3;

Prob.b_U(end) = 0;
Prob.b_L(end) = -nbTri * 3;

Prob.MIP.cpxControl.ITLIM = 30000000; %20000;

Prob.MIP.IntVars = (1:nbTri)';%Prob.N;
% Prob.MIP.IntVars = nbTri;%Prob.N;
% Prob.MIP.IntVars = [];

% Prob.CPLEX.LogFile = 'ilog.txt';
% save Prob;

% Prob.MIP.cpxControl.ITLIM = 

PROBLEM_GOES_INTO_TOMRUN = 1
%keyboard;
%Prob = cplexmilp(costVec', [],[],A,demaVec,[],[],[],zeros(nbArcs,1),capaVec',ctype);
R = tomRun('cplex', Prob, [], 1);

PROBLEM_IS_OUT_OF_TOMRUN = 1;

mxNbTr = -fix(R.f_k); 
anss = R.x_k;
