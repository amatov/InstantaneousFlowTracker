function [x1,y1,x2,y2]=rotateSpindle(a,b,c,d)

%rotates the spindle segments 
%so the poles are vertically above each other
%
%AM MAY 20, 2003

deltaY=d-b; % Y component
deltaX=c-a; % X component

Iup=find(deltaY>0); % everyone who goes UP

deltaYup=d(Iup)-b(Iup); % Y component (Iup)
deltaXup=c(Iup)-a(Iup); % X component (Iup)

VectorNmb=size(a,1)

SumX=sum(deltaXup)/VectorNmb
SumY=sum(deltaYup)/VectorNmb

Angle=90-57.29577951*atan(SumY/SumX)
AnRad=pi/2-atan(SumY/SumX)

rotM=[cos(AnRad) sin(AnRad); -sin(AnRad) cos(AnRad)];

x1y1=[a b];
x1y1=x1y1';
x2y2=[c d];
x2y2=x2y2';

newXY1=rotM*x1y1;
newXY2=rotM*x2y2;

x1y1=newXY1';
x2y2=newXY2';

x1=x1y1(:,1);
y1=x1y1(:,2);
x2=x2y2(:,1);
y2=x2y2(:,2);