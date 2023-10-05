function feats = EB3a(debug,coef,sigma,s,km,kn,filePath)

% input debug -> if 0 - save all 'cands' files to disk (k should be #images), 
% else if 1 - run for the k-th image and plot detection figure
% 
% coef = 1; sigma = 4;
% s = 2 if image numbers are XX
% s = 3 if image number are XXX
%
% run:
% EB3a(1,1,4,s,numberOfDebugImage) to plot figure and look at results
% EB3a(0,1,4,s,numberOfLastImage) to run thru whole movie and save detection

%[fileName,dirName] = uigetfile('*.tif','Choose a .tif file');
%dirName = 'E:\Dropbox\Matlab\Cell Tracking\Detection_Code\testInputs\';
%fileName = '062612_Hs578T_Control-01_t000.tif';
I = imread(filePath);
m = km;
n = kn;
% if debug == 0
%     m = 1; %0 claudio
%     n = k;
% elseif debug == 1
%     m = k;
%     n = k;
% end
if ~debug
    hWaitBar = waitbar(0,'First Iteration! Calculating time...');
end

for i = m:n %0:le was m:n
    tWaitBar(i-m+1) = tic;

%     s =3;%2 some noco & torsten
    strg=sprintf('%%.%dd',s);
    indxStr=sprintf(strg,i);

    I = imread([filePath(1:end-(s+4)),indxStr,'.tif']); %-6 torsten. -7 otherwise
%         I = imread([dirName,fileName(1:end-(s+10)),indxStr,'c3_ORG.tif']); %-6 DMITRI
    if size(I,3) > 1
        I = rgb2gray(I);
    end
    
    I=double(I);
    aux = Gauss2D(I,1);%1 
    I2 = Gauss2D(I,sigma); %4 (Yukako 10)
    I3 = aux - I2;
%     I3(find(I3<0))=0; % clipping
    [cutoffInd, cutoffV] = cutFirstHistMode(I3,0);

    % coef = 4 Katsu; coef = 1 Claudio; coef = 1 Lisa_xju103_r11; 
    I4 = I3>cutoffV*coef; % REMOVE THE NOISE FEATURES %no 3

    X = bwlabel(I4);
%     warningState = warning;
     warning off all
%keyboard; disp('maybe something is wrong here!');
    %intwarning off
    stats = regionprops(X,'all'); % Warning: Out of range value converted to intmin('uint8') or intmax('uint8').
%     warning(warningState)

    % Initialize 'feats' structure
    feats=struct(...
        'pos',[0 0],...                  % Centroid - [y x]
        'ecc',0,...                      % Eccentricity
        'ori',0);   % Orientation

    for j = 1:length(stats)
        feats.pos(j,1) = stats(j).Centroid(1);
        feats.pos(j,2) = stats(j).Centroid(2);
        feats.ecc(j,1) = stats(j).Eccentricity;
        feats.ori(j,1) = stats(j).Orientation;
        feats.len(j,1) = stats(j).MajorAxisLength;

        e1 = [-cos(stats(j).Orientation*pi/180) sin(stats(j).Orientation*pi/180) 0];
        e2 = [sin(stats(j).Orientation*pi/180) cos(stats(j).Orientation*pi/180) 0];
        e3 = [0 0 1];
        Ori = [stats(j).Centroid  0];
        v1 = [-10 10];
        v2 = [-5 5];
        v3 = [0 0];
        [xGrid,yGrid]=arbitraryGrid(e1,e2,e3,Ori,v1,v2,v3);

        Crop(:,:,j) = interp2(I,xGrid,yGrid);
        
%         [X,Y] = meshgrid(1:size(I,2),1:size(I,1));
%         [Xq,Yq] = meshgrid(xGrid,yGrid);
%         Crop(:,:,j) = interp2(X,Y,I,Xq,Yq);
        
%         AAA1 = Crop(:,:,j);
%         AAA2 = interp2(I,xGrid,yGrid);
%         notNan = ~isnan(AAA1 + AAA2);
%         checkpointHere = sum(sum(abs(AAA1(notNan)-AAA2(notNan))))
%         if checkpointHere
%             keyboard;
%         end
        
        %Crop(:,:,j) = interp2(I,xGrid,yGrid,'*linear');

        e1 = [];e2 = [];e3 = []; Ori = []; v1 = []; v2 = []; xGrid = []; yGrid = [];
    end

    Cm = nanmean(Crop,3); % MEAN/REPRESENTATIVE EB1 CROP
    Crop(isnan(Crop))=0;% border effect - some NaN
    Cm1 = bwlabel(Cm);
    statsC = regionprops(Cm1,'all');

%     sC = size(Crop);
%     Cm3d = repmat(Cm,[1,1,size(Crop,3)]);
%     dC = Crop - Cm3d;
%     sqC = dC.^2;
%     ssqC = squeeze(sum(sum(sqC,1),2)); %LIST OF DIFFERENCES AFTER SUBTRACTION

    B = Cm(:); % MEAN EB1
    A = ones(length(B),2); 

    for mm = 1:size(Crop,3)
        CR = Crop(:,:,mm); 
        A(:,2) = CR(:); % INDIVIDUAL EB1
        goodRows = find(A(:,2) ~= 0 & isfinite(B));
        XX = lscov(A(goodRows,:),B(goodRows));
        RES = B(goodRows) - A(goodRows,:)*XX;
        OUT(mm,:) = [mean(RES(:).^2),XX'];
    end
    [Ind,V]=cutFirstHistMode(OUT(:,1),0);% switch to 1 to see HIST

    goodFeats = find(OUT(:,1)<(V*1)); % SPOTS WHICH FIT WELL WITH THE MEAN EB1 SPOT

    featNames = fieldnames(feats);
    for field = 1:length(featNames)
        feats.(featNames{field}) = feats.(featNames{field})(goodFeats,:);
    end

    if debug == 1
        
        % find the region of immediate bkgr
%         If1 = bwmorph(If,'dilate');
%         If2 = bwmorph(If1,'dilate');
%         If3 = bwmorph(If2,'dilate');
%         If4 = If3 - If;
%         figure, imshow(If4);
        
        % connected components
        
        % get 1 mean I value for each comet
        
        % get 1 mean I for each bkgr
        
        % calculate average SNR for image
        
        aaux = 5;
%         Ibk = imread('D:\matlab\iPierian\images_not\79363_7007_1.tif');
%         Ibk = double(Ibk);
%         If=Gauss2D(Ibk,1);
        If=Gauss2D(I,1);
         imshow(If(1+aaux:end-aaux,1+aaux:end-aaux),[ ]);%I4 - 0 do 400 zashto??
        title('Scale Space Detection');
        hold on
        for j = 1:length(feats.ori)
            h = quiver(feats.pos(j,1)-aaux,feats.pos(j,2)-aaux,-cos(feats.ori(j)*pi/180),sin(feats.ori(j)*pi/180),3,'r');
            set(h,'LineWidth',2)
        end
% phi = linspace(0,2*pi,50);
%     cosphi = cos(phi);
%     sinphi = sin(phi);
%     
% for k = 1:length(stats) % DONT EXLCLUDE THE SECOND THRESHOLDING YET and does not account for shift / crop 
%         xbar = stats(k).Centroid(1);
%         ybar = stats(k).Centroid(2);
%         e = stats(k).Eccentricity;
%         
%         a = stats(k).MajorAxisLength/2;
%         b = stats(k).MinorAxisLength/2;
%         
%         theta = pi*stats(k).Orientation/180;
%         R = [ cos(theta)   sin(theta)
%             -sin(theta)   cos(theta)];
%         
%         xy = [a*cosphi; b*sinphi];
%         xy = R*xy;
%         
%         x = xy(1,:) + xbar;
%         y = xy(2,:) + ybar;
%         
% 
%             plot(xbar,ybar,'rx','MarkerSize',5,'LineWidth',2);
% 
%         plot(x,y,'r','LineWidth',2);
%     end
%     hold off
        
    elseif debug == 0
        slash = strfind(filePath,'/');
        if isempty(slash)
            slash = strfind(filePath,'\');
        end
        slash = slash(end);
        mkdir([filePath(1:slash), 'cands']);
        save([filePath(1:slash),'cands',filesep,'feats',indxStr],'feats')
        
        ratioDone = (i-m+1)/(n-m+1);
        waitbar(ratioDone, hWaitBar, sprintf('Elapsed: %0.0f secs, Remains: %0.0f secs', toc(tWaitBar(1)), toc(tWaitBar(1))*(1/ratioDone-1)));

        clear goodFeats 
        clear OUT 
        clear V 
        clear Crop
    end
end

if ~debug
    waitbar(1, hWaitBar, sprintf('Done! Close me please. time: %0.0f secs', toc(tWaitBar(1))));
end


