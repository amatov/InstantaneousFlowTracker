function readandhist1(DEBUG)

%reads text file of speckle segments
%plots the segments and histograms of segment distribution
%and interpolated vector field
%
%first version AM NOV 1, 2002
%interpolation added JAN 23, 2004

if nargin==0
    DEBUG=1;
end
close all
% load jha;
% F=jha;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [a,b,c,d]=textread('spindle_clean.txt','%f %f %f %f');
[a,b,c,d]=textread('segments.txt','%f %f %f %f');
% a=jha(:,1);
% b=jha(:,2);
% c=jha(:,3);
% d=jha(:,4);
% a=a(1:3390*2.5); % ?? LOOK INTO THAT!
% b=b(1:3390*2.5);
% c=c(1:3390*2.5);
% d=d(1:3390*2.5);
%%%%%%%%%%%%%%%%%%%%
a=a(1:3900);%30images
b=b(1:3900);
c=c(1:3900);
d=d(1:3900);
% figure, quiver(a(1:1300),b(1:1300),c(1:1300)-a(1:1300),d(1:1300)-b(1:1300),0);
figure, quiver(a,b,c-a,d-b,0);
xlabel('all vectors before rotation');
    
% [a,b,c,d]=rotateSpindle(a,b,c,d); % COMMENT FOR ALIGNED SPINDLE

dif=d-b; % y component

Iup=find(dif>0); % everyone who goes UP
Idown=find(dif<0); % everyone who goes DOWN

%vector field plot
vectorFieldPlot([b(Iup),a(Iup),d(Iup),c(Iup)],0,[],1);
axis xy

d0=5;
%interpolated vector field
IVF=vectorFieldInterp([b(Iup),a(Iup),d(Iup),c(Iup)],[b(Iup),a(Iup)],d0,[]);
vectorFieldPlot(IVF,0,[],2);
axis xy
%calculate the divergence of the vector field
[div,d0]=vectorFieldDiv([b(Iup),a(Iup),d(Iup),c(Iup)],[b(Iup),a(Iup)],d0,[]);
%update d0 depending on divergence
d0=updateD0FromDiv(div,d0,1,size(a(Iup),1),size(a(Iup),1));
%interpolated vector field
IVF=vectorFieldInterp([b(Iup),a(Iup),d(Iup),c(Iup)],[b(Iup),a(Iup)],d0,[]);
vectorFieldPlot(IVF,0,[],2);
axis xy

NumberUp=size(Iup,1)
NumberDown=size(Idown,1)

% length of the displacement of all speckles going North
lengthMTup=sqrt((c(Iup)-a(Iup)).^2+(d(Iup)-b(Iup)).^2); 
LeMTup=mean(lengthMTup)
stdMTup=std(lengthMTup)

% length of the displacement of all speckles going South
% lengthMTdown=sqrt((c(Idown)-a(Idown)).^2+(d(Idown)-b(Idown)).^2); 
% LeMTdown=mean(lengthMTdown)
% stdMTdown=std(lengthMTdown)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
midY=(max(d)-min(b))/2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% speckles moving towards the North pole and originate above the Metaphase Plate (MixMT)
IupMixMT=find(dif>0 & b>midY);
% speckles moving towards the North pole and originate under the Metaphase Plate (nonKC MT)
IupNonKC=find(dif>0 & b<midY);

%interpolated vector field
IVF=vectorFieldInterp([b(IupMixMT),a(IupMixMT),d(IupMixMT),c(IupMixMT)],[b(IupMixMT),a(IupMixMT)],9,[]);
vectorFieldPlot(IVF,0,[],2);
axis xy
% interpolated vector field
IVF=vectorFieldInterp([b(IupNonKC),a(IupNonKC),d(IupNonKC),c(IupNonKC)],[b(IupNonKC),a(IupNonKC)],9,[]);
vectorFieldPlot(IVF,0,[],2);
axis xy

% speckels moving UP and Originate ABOVE the MP and having lateral Displacement over 2 Pixels
% or Trying to Separate KC and nonKC based on Lateral Displacement
IupSepNonKCaboveMP=find(dif>0 & b>midY & abs(c-a)>2);
SIZE_IupSepNonKCaboveMP=size(IupSepNonKCaboveMP,1)
% speckles moving UP and Originate ABOVE the MP and having lateral Displacement less than 2 Pixels
IupSepKC=find(dif>0 & b>midY & abs(c-a)<2);
SIZE_IupSepKC=size(IupSepKC,1)

% length of the displacement of all speckles going North and originate above the Metaphase Plate (MixMT)
lengthMixMTup=sqrt((c(IupMixMT)-a(IupMixMT)).^2+(d(IupMixMT)-b(IupMixMT)).^2); 
LeMixMTup=mean(lengthMixMTup)
stdMixMTup=std(lengthMixMTup)
nmbMixMTup=size(lengthMixMTup,1)
% X displacement MIXed up
xDispMix=abs(c(IupMixMT)-a(IupMixMT));
MEANxDispMixUp=mean(xDispMix)

% length of the displacement of all speckles going North and originate above the Metaphase Plate (NonKC MT)
lengthNonKCup=sqrt((c(IupNonKC)-a(IupNonKC)).^2+(d(IupNonKC)-b(IupNonKC)).^2); 
LeNonKCup=mean(lengthNonKCup)
stdNonKCup=std(lengthNonKCup)
nmbNonKCup=size(lengthNonKCup,1)
% X displacement NON KC up
xDispNonK=abs(c(IupNonKC)-a(IupNonKC));
MEANxDispNonKcUp=mean(xDispNonK)

% speckles moving towards the South pole and originate under the Metaphase Plate (MixMT)
IdownMixMT=find(dif<0 & b<midY);

% length of the displacement of all speckles going South and originate under the Metaphase Plate (MixMT)
% lengthMixMTdown=sqrt((c(IdownMixMT)-a(IdownMixMT)).^2+(d(IdownMixMT)-b(IdownMixMT)).^2); 
% LeMixMTdown=mean(lengthMixMTdown)
% stdMixMTdown=std(lengthMixMTdown)

NumberUpMIX=size(IupMixMT,1)
NumberDownMIX=size(IdownMixMT,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
length=sqrt((c-a).^2+(d-b).^2); 

lengthAll=mean(length)
stdAll=std(length)

mn=min(length)
mn=fix(mn)
mx=max(length)
mx=fix(mx)+1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Substacting the BINs of the HIST UP under MP from HIST UP above MP
[n1,h1]=hist(lengthMixMTup)
[n2,h2]=hist(lengthNonKCup)
resN=n1-n2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figures
if DEBUG==1
    
%     figure,bar(h1,resN) % kak da go praintvam kato HIST?
    
%     figure,hist(resN,min(h1):max(h1))
    
%     figure, quiver(a,b,c-a,d-b,0);
%     xlabel('all vectors');
    
%     [n,h]=hist(length,mn:mx)
%     figure,hist(length,mn:mx)
%     xlabel('length of the displacement of all speckles');
%     axis([0 10 0 3000])
    
    % different directions with different colors
    figure, h=quiver(a(Iup),b(Iup),c(Iup)-a(Iup),d(Iup)-b(Iup),0); % zashto 0? kak da go napraia po-debelo?
    set(h,'LineWidth',1);
    hold on
    h=quiver(a(Idown),b(Idown),c(Idown)-a(Idown),d(Idown)-b(Idown),0,'r');
    set(h,'LineWidth',1);
    hold off
    xlabel('different directions with different colors');
    
    % speckles moving towards the North pole
    figure, quiver(a(Iup),b(Iup),c(Iup)-a(Iup),d(Iup)-b(Iup),0);
    xlabel('speckles moving towards the North pole');
    
%     figure,hist(lengthMTup)
%     xlabel('length of the displacement of all speckles going North');
%     axis([0 10 0 1000])
    
    % speckles moving towards the South pole
%     figure, quiver(a(Idown),b(Idown),c(Idown)-a(Idown),d(Idown)-b(Idown),0);
%     xlabel('speckles moving towards the South pole');
    
%     figure,hist(lengthMTdown)
%     xlabel('length of the displacement of all speckles going South');
%     axis([0 10 0 1000])
    
    figure, quiver(a(IupMixMT),b(IupMixMT),c(IupMixMT)-a(IupMixMT),d(IupMixMT)-b(IupMixMT),0);
    xlabel('speckles moving towards the North pole and originate above the Metaphase Plate (MixMT)');
    
    figure, quiver(a(IupNonKC),b(IupNonKC),c(IupNonKC)-a(IupNonKC),d(IupNonKC)-b(IupNonKC),0);
    xlabel('speckles moving towards the North pole and originate under the Metaphase Plate (nonKC)');
    
%     figure, quiver(a(IupSepNonKCaboveMP),b(IupSepNonKCaboveMP),c(IupSepNonKCaboveMP)-a(IupSepNonKCaboveMP),d(IupSepNonKCaboveMP)-b(IupSepNonKCaboveMP),0);
%     xlabel('speckles moving up the North pole and originate above the MP with xDisp>2 (nonKC??)');
%     
%     figure, quiver(a(IupSepKC),b(IupSepKC),c(IupSepKC)-a(IupSepKC),d(IupSepKC)-b(IupSepKC),0);
%     xlabel('speckles moving up the North pole and originate above the MP with xDisp<2 (KC??)');
    
%     figure,hist(lengthMixMTup)
%     xlabel('length of the displacement of all speckles going North and originate above the Metaphase Plate (MixMT)');
%     axis([0 10 0 600])
  
%     IupSepNonKCaboveMP
    figure,hist(lengthMixMTup)
    xlabel('length of the displacement of all speckles going North and originate above the Metaphase Plate (MixMT)');
    axis([0 10 0 600])
    
    figure,hist(lengthNonKCup)
    xlabel('length of the displacement of all speckles going North and originate under the Metaphase Plate (nonKC MT)');
    axis([0 10 0 600])
    
%     figure,hist(xDispMix)
%     xlabel('horizontal displacement of speckles going North and originate above the Metaphase Plate (MixMT)');
%     axis([0 10 0 600])
    
%     figure,hist(xDispNonK)
%     xlabel('horizontal displacement of all speckles going North and originate under the Metaphase Plate (nonKC MT)');
%     axis([0 10 0 600])
    
%     figure, quiver(a(IdownMixMT),b(IdownMixMT),c(IdownMixMT)-a(IdownMixMT),d(IdownMixMT)-b(IdownMixMT),0);
%     xlabel('speckles moving towards the South pole and originate under the Metaphase Plate');
%     
%     figure,hist(lengthMixMTdown)
%     xlabel('length of the displacement of all speckles going South and originate under the Metaphase Plate (MixMT)');
%     axis([0 10 0 1000])

    
end  
    
    
    
    
    
    
