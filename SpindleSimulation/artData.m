function M=artData

% ArtData creates artificial data (3frames) to test the tracker
%
%AM MAY 20, 2003

close all

imgSize=200;

img1=zeros(imgSize);
img2=zeros(imgSize);
img3=zeros(imgSize);

pos1=[110 110; 7 9;10 30;17 45; 38 67; 14 90; 129 43; 34 156; 24 94; 93 28];
int1=[21;20;30;4;5;6;7;8;9;10];

pos2=2+pos1;
% pos2=[9 11;];% 12 32; 55 77];
% int2=[20;];%30;35];
int2=1+int1;


pos3=2+pos2;
int3=1+int2;

for i=1:size(pos1,1)
    img1(pos1(i,1),pos1(i,2))=int1(i);
end
for i=1:size(pos2,1)
    img2(pos2(i,1),pos2(i,2))=int2(i);
end
for i=1:size(pos3,1)
    img3(pos3(i,1),pos3(i,2))=int3(i);
end
    

% img1=double(img1);
% img1=gauss2d(img1,1);
% img1=locmax2d(img1,[5,5]);
% 
% img2=double(img2);
% img2=gauss2d(img2,1);
% img2=locmax2d(img2,[5,5]);
% 
% img3=double(img3);
% img3=gauss2d(img3,1);
% img3=locmax2d(img3,[5,5]);



M=fsmTrackTrackerPP(img1,img2,img3,4);
% M=fsmTrackTrackerP(img1,img2,4);

% figure,imshow(img1,[])
% figure,imshow(img2,[])
% figure,imshow(img3,[])