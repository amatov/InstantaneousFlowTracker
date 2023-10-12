function REDU= biObjectFlow(costVec,nbTri,X)

% Alexandre Matov (2003)

n=find(costVec(1:nbTri)==0);
costVec(n)=0.1711;

costUsed=costVec(find(costVec'.*X));

medCost = median(costUsed);

costSorted=sort(costUsed);
leCost = length(costSorted);
costSorted(find(costSorted==0.1711))=0;

%----------------------------------------------------------------
% [uniqueEntries,numOc] = countEntries(costSorted);
% % figure,hist(numOc,max(numOc));
% [hh,n]=hist(costSorted,length(uniqueEntries));
% figure,hist(costSorted,length(uniqueEntries))
% hold on
% h = line([medCost medCost],[0 hh(1)],'Color','r','Linewidth',2);
%----------------------------------------------------------------

for i = leCost:-1:1
    floww(i)=(leCost-i+1)*3;% NUMBER OF TRIPLETS (MULTIPLY BY 3 TO GET FLOW)
    cost(i)=sum(costSorted(1:end-i+1))/medCost;   
end
flo = floww(end:-1:1);

% cut_off=sqrt(cost.^2+flo.^2); % CHANGE TO MIN OF THE SUM!!
cut_off = cost + flo;
ind=find(cut_off==min(cut_off));
if length(ind)>1
    ind = ind(1);
end
if ind < 3
    ind = 3;
end
%--------------------------------------------------------------
% h1 = line([costSorted(round(ind/3)) costSorted(round(ind/3))],[0 hh(1)],'Color','g','Linewidth',2);
% hold off
% legend('Median','Cut-Off','Cost Values')

REDU = flo(ind)/3;
