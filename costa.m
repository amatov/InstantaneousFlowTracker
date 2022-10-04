function cost=costa(a,b,c,d,e,f,w1,w2) % list all x, then all y


if nargin < 6
    error('not enough input arguments');
end
if nargin == 6
    w1 = 0.8; %default
    w2 = 0.2;
end
if nargin == 7
    w2 = 1 - w1;
end

dx(1)= b-a;
dx(2)= c-b;
dy(1)= e-d;
dy(2)= f-e;


aa(1)=sqrt(dx(1).*dx(1)+dy(1).*dy(1));
aa(2)=sqrt(dx(2).*dx(2)+dy(2).*dy(2));

if aa(1)==0 || aa(2)==0
    cosAngle=0;
else
    cosAngle=(dx(1).*dx(2)+dy(1).*dy(2))./(aa(1).*aa(2)); % cos of the angle
end

if aa(1)==0 & aa(2)==0
    length = 0;
else
    length=sqrt(aa(1).*aa(2))./(aa(1)+aa(2)); % std of the length
end

% cost=(a(1)+a(2)); % only distance
cost=100*(w1.*(1-cosAngle) + w2.*(1-2*length)); 