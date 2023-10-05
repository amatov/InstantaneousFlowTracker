% close all
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
for x=1:10
    I=imread(sprintf('S365ACTIN%.2d%s' ,x,'.tif'))
    img = double(Gauss2D(I,1));
    figure;
k=1
j=1
m=1
n=1

for i=1:length(angleindeg{x})
    if angleindeg{x}(i)>0
        trackpos1(k,:)=newtrack{x}(i,:)
        trackpos2(k,:)=newtrack{x+1}(i,:)
        k=k+1
%     elseif angleindeg(i)>90 && angleindeg(i)<=180
%         trackpos11(j,:)=newtrack(i,:)
%         trackpos22(j,:)=newtrack2(i,:)
%         j=j+1
    else
        trackneg1(m,:)=newtrack{x}(i,:)
        trackneg2(m,:)=newtrack{x+1}(i,:)
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
quiver(newtrack{x}(l,2),newtrack{x}(l,1),diffypos1(l)*8,diffxpos1(l)*8,'r', 'LineWidth',2)
end
%plot([newtrack(b,2) newtrack2(b,2)],[newtrack(b,1) newtrack2(b,1)])

for l=1:length(diffxneg1)
quiver(newtrack{x}(l,2),newtrack{x}(l,1),diffyneg1(l)*8,diffxneg1(l)*8,'y', 'LineWidth',2)
end
print(gcf, '-djpeg', fullfile('C:\Users\Sarfaraz Hussein\Downloads\tft (1)\tft\results', sprintf('pana4-%04d.jpg',x)));
end
% for l=1:length(diffxpos11)
% quiver(newtrack(l,2),newtrack(l,1),diffypos11(l)*8,diffxpos11(l)*8,'r', 'LineWidth',2)
% end
% 
% for l=1:length(diffxneg11)
% quiver(newtrack(l,2),newtrack(l,1),diffyneg11(l)*8,diffxneg11(l)*8,'y', 'LineWidth',2)
% end