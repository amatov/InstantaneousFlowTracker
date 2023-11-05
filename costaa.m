function aux=costaa(x1,x2,x3,y1,y2,y3,w1,w2,w3) % list all x, then all y

% Alexandre Matov (2003)

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

dx(1)= x2-x1;
dx(2)= x3-x2;
dy(1)= y2-y1;
dy(2)= y3-y2;
pr = dx(1)*dy(2)-dx(2)*dy(1);

aa(1)=sqrt(dx(1)*dx(1)+dy(1)*dy(1));
aa(2)=sqrt(dx(2)*dx(2)+dy(2)*dy(2));

if aa(1)==0 || aa(2)==0
    cosAngle=-1;
else
    cosAngle=(dx(1)*dx(2)+dy(1)*dy(2))/(aa(1)*aa(2)); % cos of the angle
    
end
ang = acos(cosAngle);
if pr<0
    ang = -ang;
end
ang = real(ang);
angSq = ang*ang;

deltaD = aa(1)-aa(2) ;
deltaDsq = deltaD*deltaD;

cost=100*(w1*angSq + w2*deltaDsq); % multiply by 100 to make it integer

aux = [cost ang deltaD];














ang = atan2(dy,dx);
