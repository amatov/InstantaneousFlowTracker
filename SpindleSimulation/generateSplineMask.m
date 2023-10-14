%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Obtain spindle geometry by interactive cropping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
defaultFileName = 'D:\manTrackWT2s\images\*.tif';
[filename1, pathname1] = uigetfile('*.tif', 'Please choose the spindle image', defaultFileName);
filename1 = strcat(pathname1, filename1);
imgtemp = imread(filename1, 'tiff');
[imgHeight, imgWidth] = size(imgtemp);

imageCenter = round([imgHeight * 0.5 imgWidth *0.5]);

fig1 = figure;
imshow(imgtemp, []);
[x, y] = getpts;

x = x - imageCenter(2);
y = y - imageCenter(1);

r = zeros(1, length(x));
theta = zeros(1, length(x));

for i = 1 : length(x)
    r(i) = sqrt(x(i) ^2 + y(i) ^2);
    theta(i) = atan2(y(i), x(i));
end

% Now sort the angle 

[theta_sorted, indexmat] = sort(theta);
r_sorted = r(indexmat);


pp1 = csaps(theta_sorted, r_sorted);

theta0 = linspace(theta_sorted(1), theta_sorted(end), 50000);
r0 = ppval(pp1, theta0);

x0 = zeros(1, length(theta0));
y0 = zeros(1, length(theta0));

for i = 1 : length(theta0)
    x0(i) = r0(i) * cos(theta0(i)) + imageCenter(2);
    y0(i) = r0(i) * sin(theta0(i)) + imageCenter(1);
end

figure;
imshow(imgtemp, []);
hold on;
x1 = [x0 x0(1)];
y1 = [y0 y0(1)];
plot(x1, y1);



bwimage = zeros(imgHeight, imgWidth);

xmin = round(min(x1));
xmax = round(max(x1));

for j = xmin : xmax
    
    % Check for the two bounds
    lowerbnd = imgHeight + 1;
    upperbnd = 0;
    
    tempdif = abs(x1 - j);
    tempy = y1(find(tempdif < 0.25));
    
    lowerbnd = round(min(tempy));
    upperbnd = round(max(tempy));
    
    bwimage(lowerbnd:upperbnd, j) = 1;
    
end


% %%%%%%%%%%%%% JUNK below ******************
% 
% 
% pp1  = csaps(topx,topy)
% toptempx = linspace(topx(1), topx(end), 200);
% toptempy = ppval(pp1, toptempx);
% clos(fig1);
% 
% fig1 = figure;
% imshow(imgtemp, []);
% [botx, boty] = getpts;
% pp2  = csaps(botx,boty)
% bottempx = linspace(botx(1), botx(end), 200);
% bottempy = ppval(pp2, bottempx);
% clos(fig1);
% 
% % 
% % figure;
% % fnplt(pp);
% % figure;
% % plot(tempx, tempy);
% figure;
% imshow(imgtemp, []);
% hold on;
% plot(toptempx, toptempy); 
% plot(bottempx, bottempy);
% 
% 
% 
% 
% 
% coordLen = length(x);
% vx = ppval(x);
% 
% 
% %clear vx;
% vx = [];
% densex = [];
% 
% for i = 1 : coordLen - 2
% 
%     startX = x(i);
%     endX = x(i + 1);
%     
%     tempx = linspace(startX, endX, 5)
%     tempvx = ppval(sp, tempx);
%     densex = [densex; tempx'];
%     vx = [vx; tempvx']
% end
% 
% plot(densex, vx);
% 
% return;
% 
% 
