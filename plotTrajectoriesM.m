function LifeT=plotTrajectoriesM(filename)

% plotTrajectoriesM displays speckle trajectories
% in different colors depending on lenght
%
% SYNOPSIS   LifeT=plotTrajectoriesM(filename)
%
% INPUT      filename : a .TXT file containing the re-aranged M matrix
%
% OUTPUT     LifeT    : a vector containing speckle lifetimes 
% 
%
% DEPENDENCES   plotTrajectoriesM uses { }
%               plotTrajectoriesM is used by { }
%
% Alexandre Matov, November 20th, 2002

if nargin==0
    filename='trajectories_noghosts.txt';
%     filename='spindle_right.txt';
%     filename='spindle_left.txt';
%     filename='trajectories.txt';
%     filename='tr_ghost.txt';
end

traj=textread(filename);
NmRow=size(traj,1);

figure
for i=2:NmRow
    row=traj(i,:);
    row=row(find(row~=0));
    L=length(row);
    LifeT(i-1)=L/2;
    switch (L/2)
        case 2
            plot(row(2:2:L),row(1:2:(L-1)),'g-'); % x from 2 to L with step 2; y from 1 to L-1 step 2
        case 3 
            plot(row(2:2:L),row(1:2:(L-1)),'r-');
        case 4 
            plot(row(2:2:L),row(1:2:(L-1)),'m-');
        case 5
            plot(row(2:2:L),row(1:2:(L-1)),'y-');
        case 6
            plot(row(2:2:L),row(1:2:(L-1)),'c-');
        otherwise
            plot(row(2:2:L),row(1:2:(L-1)),'b-');
    end    
    hold on
    plot(row(L),row(L-1),'k.'); % a black dot at the End of a trajectory
end
hold off
title('LT2-Green LT3-Red LT4-Magenta LT5-Yellow LT6-Cyan LT7orMore-Blue BlackDot-EndOfTraj')

maxLT=max(LifeT)
minLT=min(LifeT)
number=hist(LifeT,[minLT:maxLT])

figure,hist(LifeT,[minLT:maxLT]) % histogram of speckle lifetimes
