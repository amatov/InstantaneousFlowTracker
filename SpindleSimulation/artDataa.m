function [M1,M2]=artDataa
% ArtData creates artificial data to test the tracker

close all

imgSize=200;

img1=zeros(imgSize);
img2=zeros(imgSize);
img3=zeros(imgSize);


pos1=[59 12;65 18;80 40];%93 28];
int1=[12;13;15];% 16];

% pos1=[59 12];%; 65 18;80 40];%93 28];
% int1=[12];%;13;15];% 16];

pos1=[190 150; 7 9; 10 30; 17 45; 38 67; 14 90; 129 43; 34 156; 24 94; 93 28; 59 12; 65 18; 15 65; 80 40; 160 76]; %15 points (crashes at 10)
int1=[11;2;3;4;5;6;7;8;9;10;12;13;14;15;16];

m=2;
n=.1;
i=0;
j=0;

pos2=pos1+m;
int2=int1+i;
pos3=pos2+n;
int3=int2+j;

for i=1:size(pos1,1)
    img1(pos1(i,1),pos1(i,2))=int1(i);
    img2(pos2(i,1),pos2(i,2))=int2(i);
    img3(pos3(i,1),pos3(i,2))=int3(i);
end
  
dx1=pos2(:,2)-pos1(:,2);
dx2=pos3(:,2)-pos2(:,2);
dy1=pos2(:,1)-pos1(:,1);
dy2=pos3(:,1)-pos2(:,1);

a1=sqrt(dx1.*dx1+dy1.*dy1);
a2=sqrt(dx2.*dx2+dy2.*dy2);


cosAngle=(dx1.*dx2+dy1.*dy2)./(a1.*a2);
length=sqrt(a1.*a2)./(a1+a2);

cost=0.6.*(1-cosAngle)+0.4.*(1-2*length);

% v1=[pos2(1)-pos1(1) pos2(2)-pos1(2)]
% v2=[pos3(1)-pos2(1) pos3(2)-pos2(2)]
% 
% angle=(1-(v1*v2')/sqrt(v1*v1'*v2*v2'))
% length=(1-2*sqrt(sqrt(v1*v1')*sqrt(v2*v2')))/(sqrt(v1*v1')+sqrt(v2*v2'))
% cost=0.6*angle+0.4*length

M1=fsmTrackTrackerPP(img1,img2,img3,5);
% M2=fsmTrackTrackerP(img1,img2,4);


% figure,imshow(img1,[])
% figure,imshow(img2,[])
% figure,imshow(img3,[])