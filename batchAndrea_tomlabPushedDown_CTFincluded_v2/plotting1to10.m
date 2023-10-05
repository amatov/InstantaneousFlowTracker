% clear all
 clearvars -except newtrack angleindeg
close all
shift=10;
%I=imread('C:\Users\Sarfaraz Hussein\Desktop\Work\Cell Tracking\Dataset2\Original Images\S365ACTIN02.tif')
%img = double(Gauss2D(I,1));
% h = figure;


% k=1
% j=1
% m=1
% n=1
% start =[newtrack(b,2) newtrack(b,1)]
% stop  = [newtrack2(b,2) newtrack2(b,1)]
% for x=1:10
%     I=imread(sprintf('S365ACTIN%.2d%s' ,x,'.tif'))
I=imread('S365ACTIN01.tif')
    img = double(Gauss2D(I,1));
    figure;
k=1
j=1
m=1
n=1
x=1
% for i=1:length(angleindeg)
for i=1:500
    if angleindeg(i)<=180
        trackpos1(k,:)=newtrack{1}(i,:)
        trackpos2(k,:)=newtrack{10}(i,:)
        k=k+1
%     elseif angleindeg(i)>90 && angleindeg(i)<=180
%         trackpos11(j,:)=newtrack(i,:)
%         trackpos22(j,:)=newtrack2(i,:)
%         j=j+1
    else
        trackneg1(m,:)=newtrack{1}(i,:)
        trackneg2(m,:)=newtrack{10}(i,:)
        m=m+1
%     else
%         trackneg11(n,:)=newtrack(i,:)
%         trackneg22(n,:)=newtrack2(i,:)
%         n=n+1
    end
end
for i=2000:length(angleindeg)
    if angleindeg(i)<=180
        trackpos1(k,:)=newtrack{1}(i,:)
        trackpos2(k,:)=newtrack{10}(i,:)
        k=k+1
%     elseif angleindeg(i)>90 && angleindeg(i)<=180
%         trackpos11(j,:)=newtrack(i,:)
%         trackpos22(j,:)=newtrack2(i,:)
%         j=j+1
    else
        trackneg1(m,:)=newtrack{1}(i,:)
        trackneg2(m,:)=newtrack{10}(i,:)
        m=m+1
%     else
%         trackneg11(n,:)=newtrack(i,:)
%         trackneg22(n,:)=newtrack2(i,:)
%         n=n+1
    end
end


diffxpos1=trackpos2(:,1)-trackpos1(:,1)
diffypos1=trackpos2(:,2)-trackpos1(:,2)

% diffxpos11=trackpos22(:,1)-trackpos11(:,1)
% diffypos11=trackpos22(:,2)-trackpos11(:,2)

diffxneg1=trackneg2(:,1)-trackneg1(:,1)
diffyneg1=trackneg2(:,2)-trackneg1(:,2)

% diffxneg11=trackneg22(:,1)-trackneg11(:,1)
% diffyneg11=trackneg22(:,2)-trackneg11(:,2)

imshow(img(1+shift:end-shift,1+shift:end-shift),[]);
hold on
for l=1:length(diffxpos1)
quiver(newtrack{1}(l,2),newtrack{1}(l,1),diffypos1(l),diffxpos1(l),'r', 'LineWidth',2)
end
%plot([newtrack(b,2) newtrack2(b,2)],[newtrack(b,1) newtrack2(b,1)])

for l=1:length(diffxneg1)
quiver(newtrack{1}(l,2),newtrack{1}(l,1),diffyneg1(l),diffxneg1(l),'y', 'LineWidth',2)
end
print(gcf, '-djpeg', fullfile('D:\Cell Tracking\Tracking Code\Cost-Function-Alex\tft\results', sprintf('pana4-%04d.jpg',x)));
% end
% for l=1:length(diffxpos11)
% quiver(newtrack(l,2),newtrack(l,1),diffypos11(l)*8,diffxpos11(l)*8,'r', 'LineWidth',2)
% end
% 
% for l=1:length(diffxneg11)
% quiver(newtrack(l,2),newtrack(l,1),diffyneg11(l)*8,diffxneg11(l)*8,'y', 'LineWidth',2)
% end