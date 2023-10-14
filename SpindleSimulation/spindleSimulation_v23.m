% The objective of this program is to generate synthetic image sequences
% based on real spindle geometry and flux field. Such groundtruth data
% may be used for many purposes, especially for the benchmarking of
% speckle tracking algorithms and flow computation algorithms.

% This program is developed to emulate real spindle flow by following the
% design guidelines listed below:
%
% (a) The numbers of point feature in the synthetic images are set to be
%     exactly the same as that of real images s0 that the synthetic images
%     generated will have approximately the same complexity as that of true
%     images.
% (b) Synthetic spindle geometry comes directly from real spindles by 
%     interactive cropping.
% (c) Synthetic spindle flux comes directly from real spindle flux, which is
%     computed using graph/flow optimization algorithms.
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Major implementation issues and their solutions:
% 
% (1) Speckle distribution, birth/death control
%
%     BIRTH
%
%     a. Currently speckle birth is assumed to happen within the entire ROI
%     (set manually by interactive cropping). 
% 
%     b. The birth rate must ensure that the number of speckles remain
%     exactly the same as that of true images.
%
%     c. As of V.15, track splitting is not implemented. 
%
%
%     DEATH
%
%     a. speckles going outside of defined region will terminate.
%     b. a track whose length goes beyond a preset lifespan threshold will
%        terminate. The lifespan of a track is determined by a statistical
%        model selected by users. 
%     c. speckles coming within a predefined minimal distance will merge. 
%        Only one track may survive while all others are terminated. (It is
%        possible that more than 2 tracks merge.)
%
%     NOTE: the lifespan of a speckle is predetermined, although it may not
%     ever be reached due to various events and the finite length of the movie. 
%
%     IMPLEMENTATION: lifetime distribution is computed using random number
%     generators from the Statistical toolbox. Currently, the supported
%     distributions include: uniform, Gaussian, Weibull, exponential and
%     Poission. Extensions to other distributions are straight-
%     forward. NOTE: the seed for such generation is fixed for
%     repetitiveness.
%
%
% (2) Intensity cue
%
%     The initial intensity of each speckle is distributed with a given
%     range controlled by a mean and a STD. Then the intensity of each speckle
%     is changed on an individual basis controlled by another (smaller)
%     STD. However, currently this smaller STD is set to be the same for
%     all tracks.
%
% (3) Antiparallel flow
%
%     a. flow field is always bidirectional at each point (always
%     anti-parallel).
%
%     b. Each speckle is randomly assigned an initial direction. Then its
%     next direction is determined so that the change in orientation does
%     not exceed 180 degrees. 
%
% (4)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% REVISION HISTORY:
% 
% V.14   added intensity cue and distribution.    
%
% V.15   program reorganized. First stable release. 
%
%  
% 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% COORDINATE SYNTAX:
%
% It is clear that the syntax of speckle coordinate must be consistent
% under all circumstances. This will be critical to the integration of
% multiple programs. Such syntax is defined in the following
%
%              -----------------------> X axis (width/horizontal direction)       
%              |
%              | 
%              |
%              | 
%              |
%              | 
%              |
%             \|/ 
%       Y axis (height/vertical direction)
%
% Whenever an vector/array is used to record point coordinates, the
% Y-coordinate always comes first and the X-coordinates comes second. The
% same is true for direction vectors.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Obtain spindle geometry by interactive cropping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
defaultFileName = 'D:\manTrackWT2s\images\*.tif';
[filename1, pathname1] = uigetfile('*.tif', 'Please choose the spindle image', defaultFileName);
filename1 = strcat(pathname1, filename1);
imgtemp = imread(filename1, 'tiff');
[imgHeight, imgWidth] = size(imgtemp);


fig1 = figure;
imshow(imgtemp, []);
[topx, topy] = getpts;
pp1  = csaps(topx,topy)
toptempx = linspace(topx(1), topx(end), 200);
toptempy = ppval(pp1, toptempx);
clos(fig1);

fig1 = figure;
imshow(imgtemp, []);
[botx, boty] = getpts;
pp2  = csaps(botx,boty)
bottempx = linspace(botx(1), botx(end), 200);
bottempy = ppval(pp2, bottempx);
clos(fig1);

% 
% figure;
% fnplt(pp);
% figure;
% plot(tempx, tempy);
figure;
imshow(imgtemp, []);
hold on;
plot(toptempx, toptempy); 
plot(bottempx, bottempy);





coordLen = length(x);



vx = ppval(x);


%clear vx;
vx = [];
densex = [];

for i = 1 : coordLen - 2

    startX = x(i);
    endX = x(i + 1);
    
    tempx = linspace(startX, endX, 5)
    tempvx = ppval(sp, tempx);
    densex = [densex; tempx'];
    vx = [vx; tempvx']
end

plot(densex, vx);

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Set basic parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Step 2.0: Set basic image parameters
%--------------------------------------------------------------------------
% info = imfinfo(filename1, 'tiff');
% imgHeight = info.Height;
% imgWidth = info.Width;
% 
% save data001;

load data001;
imshow(bw);

%--------------------------------------------------------------------------
% Step 2.1: Get speckle numbers directly from the original sequence
%--------------------------------------------------------------------------
start_path = 'D:\manTrackWT2s\';
ptNum = getSpeckleNum(start_path);

%--------------------------------------------------------------------------
% Step 2.2: Distance control parameters
%--------------------------------------------------------------------------
minPtDist = 4;  % Points go within this distance to each other will be merged.
                % This value of 4 is obtained directly from the original image 
                % using for example 3-frame overlapping.   
                
mergeDist = 2;  % Speckles move in within the neighborhood of this radius
                % will be merged.
                
%--------------------------------------------------------------------------
% Step 2.3: Speckle intensity parameters
%--------------------------------------------------------------------------
intMean = 125;     % mean value of speckle intensity over the entire image
intStdImg = 15;    % std value of speckle intensity over the entire image
intStdTrack = 3;   % std of speckle intensity over a single track. 
                   %Assume fluctuation of intensity to be smaller on an individual track


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Load flux field data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [filename2, pathname2] = uigetfile('*.mat', 'Please choose the flux field MAT file');
% filename2 = strcat(pathname2, filename2);
% fluxField = load(filename2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Generate synthetic images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Step 4.1: Generate the first frame
%--------------------------------------------------------------------------
% The entire data structure is track-based. Then each frame is extracted
% from this track data structure.

maxPtNum = max(ptNum); % Find the maximal number of speckles per frame.
% If even-larger speckle numbers are required, the array ptNum can be
% manipulated here directly on vector "ptNum".

totalFrameNum = 40;
frameStack = struct('length', 0, 'coordinate', zeros(maxPtNum, 3));
track = struct('startID', 0,... 
               'len', 0,... 
               'lifespan', 0,...
               'points', zeros(totalFrameNum, 3),...
               'status', 0,...
               'mergeCounter', 0); 
% len --> actual length of the track
% lifespan --> obtained from a random number generator. May not be reached.
% (status == 0) indicates that the track has terminated. 
% The third element of a coordinate is the intensity of the speckle.


currentPtNum = 0;
h = waitbar(0,'Generating the first frame. Please wait...');
i = 0;
failedGenerationNum = 0;
maxAllowedFailureNum = 1000;

frameStack(1).length = 0;

while (currentPtNum < ptNum(1))       % Need to fill the whole array
    tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
    % Again, Height-coordinate comes first. 
    while ((tempPixelCoordinate(1) == 0) | (tempPixelCoordinate(2) == 0) | (bw(tempPixelCoordinate(1), tempPixelCoordinate(2)) == 0))
        tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
    end

    % Check for distance from existing points
    j = 1;
    distance_flag = 1;
    while (j <= currentPtNum)  % Check the distance from existing points
        if (EuclideanDistance(tempPixelCoordinate, frameStack(1).coordinate(j, 1:2)) < minPtDist)
            distance_flag = 0;
            break;
        else
            j = j + 1;
        end
    end
    
    if ((distance_flag == 1))
        % Minimum distance requirement is satisfied
        currentPtNum = currentPtNum + 1;
        frameStack(1).coordinate(currentPtNum, 1:2) = tempPixelCoordinate;
        
        % Set its intensity, assuming a Gauss distribution. Notice that
        % this is the initial point of a possible track
        tempInt = randn(1,1) * intStdImg + intMean;
        if (tempInt > 255)
            tempInt = 255;
        end
        
        frameStack(1).coordinate(currentPtNum, 3) =  tempInt;

        failedGenerationNum = 0;
        frameStack(1).length = frameStack(1).length + 1;
        % fprintf('Generated a new point.\n');
    else
        failedGenerationNum = failedGenerationNum + 1;
    end

    %fprintf('%d points generated, %d more points to go.\n', current_array_length, frame_stack(1).length - current_array_length);
    if (failedGenerationNum > maxAllowedFailureNum)
        fprintf('Maximum number of failure reached. Program now terminates.\n');
        return;
    end
    waitbar(currentPtNum / ptNum(1), h);
end
close(h);

hold on;
plot(frameStack(1).coordinate(1:frameStack(1).length, 2), frameStack(1).coordinate(1:frameStack(1).length, 1), 'r.');
axis equal;
axis([1 max(imgHeight, imgWidth) 1 max(imgHeight, imgWidth)]);
fprintf('First frame generated. Now start to generate subsequent frames.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4.1: Generate the lifetime sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, generate lifetime array for all tracks (some of the tracks do not exist
% at this point)

paramSetting = struct('option', 0, 'mean', 0, 'std', 0);
paramSetting.option = 3; % Weibull distribution
paramSetting.mean = 0.35 * totalFrameNum;
paramSetting.std = 1;

generatorSeed = 3557;
length0 = totalFrameNum * maxPtNum; % Compute the maximal track number 

lifeTime1 = round(speckleLifeTimeDistribution(paramSetting, generatorSeed, length0));
lifeTime2 = round(speckleLifeTimeDistribution(paramSetting, generatorSeed, length0));
if sum(abs(lifeTime1 - lifeTime2)) > 1e-3
    fprintf('Inconsistency in lifetime generation\n');
    pause;
end

if paramSetting.option == 1
    [muhat, muci] = expfit(lifeTime1);
elseif paramSetting.option == 2
    [lambdathat, lambdaci] = poissfit(lifeTime1);
end
hold off;
figure;
hist(lifeTime1, 100);
fprintf('Double check the generated lifetime distribution.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4.2: Initialize all the tracks corresponding to the first frame.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lifeTimeCounter = 1;
for i = 1 : ptNum(1)
    track(i).startID = 1;
    while (lifeTime1(lifeTimeCounter) == 0) % Ignore zero lifespan
        lifeTimeCounter = lifeTimeCounter + 1;
    end
    track(i).lifespan = lifeTime1(lifeTimeCounter);
    lifeTimeCounter = lifeTimeCounter + 1;
    
    track(i).len = 1;
    track(i).points(1, 1 : 3) = frameStack(1).coordinate(i, 1 : 3);
    track(i).status = 1;         % active track
    track(i).mergeCounter = 0;   % not merged, of course
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4.3: Propagate the frames and generate the lifetime sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, compute displacement according to flux
% field. Then either add or drop points depending on the desired point numbers.


% previousFrameTrackNum = ptNum(1);
% activepreviousFrameTrackNum = ptNum(1);

for i = 2 : totalFrameNum
    frameStack(i) = struct('length', 0, 'coordinate', zeros(maxPtNum, 3));
end

h = waitbar(0, 'Updating tracks frame-by-frame. Please wait...');       

magVec = [1.25 0.35];
thetaVec = [0 15]; % in degrees

for i = 2 : totalFrameNum
    fprintf('------------------Generating frame %d-------------------\n', i); 
    % Step 1, -------------------update tracks-------------------------------
    
    previousFrameTrackNum = max(size(track)); % Notice that this includes those inactive tracks
    fprintf('-Step 1- Updating tracks based on flux field.\n');
    for j = 1 : previousFrameTrackNum  % propagation is completely track-based.
        if (track(j).status == 0)
            continue; % ignore inactive tracks
        end
        
        %Check for data integrity
        if ((track(j).startID + track(j).len) ~= i)
            %             errordlg('Data integrity compromised')
            %             errorFlag = 1;
            %             return;
        
            fprintf('Data integrity compromised.\n');
            fprintf('startID = %d   len = %d  actualFrameID = %d correctFrameID = %d\n',...
                track(j).startID, track(j).len, (track(j).startID + track(j).len - 1), i);
            return;
        end
                
        currentPoint = track(j).points(track(j).len, 1:2);
        flowmap = [];
        % Get local flow vector. Make sure that the first element
        % correspondes to Height-coordinate.
        currentVec = getFlowVec(flowmap, currentPoint, magVec, thetaVec); 
        
        % must consider the smoothness of direction
        if (track(j).len > 1) % we need to consider the constraint of smoothness
            previousVec = track(j).points(track(j).len, 1:2) - track(j).points(track(j).len-1, 1:2);
            if (dot (currentVec, previousVec) < 0)
                currentVec = -currentVec; % reverse the direction
            end
        end
        
        track(j).len = track(j).len + 1;
        track(j).points(track(j).len, 1:2) = currentPoint + currentVec; % update position 

        % Update speckle intensity 
        tempInt = track(j).points(track(j).len - 1, 3) + randn(1,1) * intStdTrack; 
        if (tempInt < 0)
            tempInt = 0;
        end
        
        if (tempInt > 255)
            tempInt = 255;
        end
        track(j).points(track(j).len, 3) = tempInt;
    end
    fprintf('Active track num = %d\n', activeTrackNum(track, i));
    
    fprintf('-Step 2- Terminating tracks based on condition set.\n');
    % Second, terminate those going beyond boundary
    for m = 1 : previousFrameTrackNum
        if (track(m).status == 0)
            continue; % ignore inactive tracks
        end
        
        tempCoordinate = [round(track(m).points(track(m).len, 1)), round(track(m).points(track(m).len, 2))];
             
        if ((tempCoordinate(1) == 0) | (tempCoordinate(2) == 0))
            track(m).len = track(m).len - 1;
            track(m).status = 0; % terminate tracks going beyond image boundary for data integrity
            continue;
        end
        
        if ((tempCoordinate(1) > imgHeight) | (tempCoordinate(2) > imgWidth))
            track(m).len = track(m).len - 1;
            track(m).status = 0; % terminate tracks going beyond image boundary for date integrity
            continue;
        end
        
        if (bw(tempCoordinate(1), tempCoordinate(2)) == 0)
            track(m).len = track(m).len - 1;
            track(m).status = 0; % terminate tracks goings beyond ROI boundary.
            continue;
        end
        
        if (track(m).len == track(m).lifespan)
            track(m).status = 0;
            track(m).len = track(m).len - 1;
            continue;
        end
        
        % Check for lifetime
        if (track(m).lifespan == 0)
            fprintf('Error in lifespan.\n');
            return;
        end
    end
    
    fprintf('Active track num = %d\n', activeTrackNum(track, i));
    
    % Third, --------------- Handling track / speckle merging ------------------  
    % No need to handle intensity cue
    fprintf('-Step 3- Checking for merged tracks.\n');
    for m = 1 : previousFrameTrackNum
       if (track(m).status == 0)
           continue;
       else
            L1 = track(m).len;
       end
       
       for n = 1  : previousFrameTrackNum
           if ((n == m) | (track(n).status == 0))
               continue;
           else
               L2 = track(n).len;
           end
           
           if (EuclideanDistance(track(m).points(L1, 1:2), track(n).points(L2, 1:2)) < mergeDist)
               
               % Pick the track to be terminated randomly.
               t = rand(1, 1);
               if (t > 0.5)
                   selectionID = m;
               else
                   selectionID = n;
               end
               
               if (track(selectionID).status ~= 0) % it is possible that more than 2 tracks merge.
                   track(selectionID).status = 0; % terminate it
                   track(selectionID).len = track(selectionID).len - 1;
                   track(m).mergeCounter = track(m).mergeCounter + 1;
                   track(n).mergeCounter = track(n).mergeCounter + 1;
               end
           end
        end
    end
    fprintf('Active track num = %d\n', activeTrackNum(track, i));
            
    % Fourth, check for track numbers, decide which tracks to terminate and which to add
    fprintf('-Step 4- Handling birth and death. \n');
    % fprintf('Counting number of active tracks. Then add or drop based on given point number.\n');
    % Now we need to know how many tracks are active.
    activePreviousFrameTrackNum = 0;
    activeTrackList = [];
    
    for m = 1 : previousFrameTrackNum
        if (track(m).status == 1)
            activePreviousFrameTrackNum = activePreviousFrameTrackNum + 1;
            activeTrackList = [activeTrackList m];
        end
    end
    
    if (activePreviousFrameTrackNum > ptNum(i)) % need to terminate some tracks. 
        % No need to handle speckle intensity for track termination.
        % Notice that track length distribution has been considered in the
        % previous for loop.
        dropNum = activePreviousFrameTrackNum - ptNum(i);
        activeLen = max(size(activeTrackList));
       
        for k = 1 : dropNum
            dropID = round(rand(1) * activeLen);
            while ((dropID == 0) | (track(activeTrackList(dropID)).status == 0))
                dropID = round(rand(1) * activeLen);
            end
            track(activeTrackList(dropID)).status = 0;
            track(activeTrackList(dropID)).len = track(activeTrackList(dropID)).len - 1;
        end
        fprintf('After reduction, Active track num = %d\n', activeTrackNum(track));
        %pause;
    end
     
    
    if (activePreviousFrameTrackNum < ptNum(i)) 
        % need to add some new tracks
        % NEED to consider intensity generation
        addNum = ptNum(i) - activePreviousFrameTrackNum;
       
        failedGenerationNum = 0;
        % maxAllowedFailureNum = 1000;
        
        k = 0;
        while (k < addNum)

            % First, generate a point
            tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
            while ((tempPixelCoordinate(1) == 0) | (tempPixelCoordinate(2) == 0) | (bw(tempPixelCoordinate(1), tempPixelCoordinate(2)) == 0))
                  tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
            end
   
            distance_flag = 1;
            activeLen = max(size(activeTrackList));
            
            % Check the distance from existing active tracks.
            for s = 1 : activeLen
                 tempID = activeTrackList(s);
                 if (EuclideanDistance(tempPixelCoordinate, track(tempID).points(track(tempID).len, 1:2)) < minPtDist)
                     distance_flag = 0;
                     failedGenerationNum = failedGenerationNum + 1;
                     break;
                 end
            end
            
            if (distance_flag == 1)
                failedGenerationNum = 0;  % successfully generate a new point
                k = k + 1;
                     
                previousFrameTrackNum = previousFrameTrackNum + 1; % Add a new track
                %track(previousFrameTrackNum) = struct('startID', 0, 'lifespan', 0, 'len', 0, 'points', zeros(totalFrameNum, 2), 'status', 0, 'mergeCounter', 0); 
%                 struct('startID', 0,... 
%                        'len', 0,... 
%                        'lifespan', 0,...
%                        'points', zeros(totalFrameNum, 2),...
%                        'status', 0,...
%                        'mergeCounter', 0); 
%            
               
                %activePreviousFrameTrackNum = activePreviousFrameTrackNum + 1; 
                %activeTrackList = [activeTrackList previousFrameTrackNum];

                track(previousFrameTrackNum).startID = i;
                while (lifeTime1(lifeTimeCounter) == 0)
                    lifeTimeCounter = lifeTimeCounter + 1;
                end
                track(previousFrameTrackNum).lifespan = lifeTime1(lifeTimeCounter);
                lifeTimeCounter = lifeTimeCounter + 1;
                
                track(previousFrameTrackNum).len = 1;
                track(previousFrameTrackNum).points(1, 1 : 2) = tempPixelCoordinate;
                track(previousFrameTrackNum).status = 1;         % active track
                track(previousFrameTrackNum).mergeCounter = 0;   % not merged, of course
                
                tempInt = randn(1,1) * intStdImg + intMean;
                if (tempInt > 255)
                    tempInt = 255;
                end
                track(previousFrameTrackNum).points(1, 3) = tempInt;
            end
        end
        if (failedGenerationNum > maxAllowedFailureNum)
            fprintf('Maximum failure number reached in attempting to add points. Now exiting. \n');
            return;
        end
        fprintf('After addition, Active track num = %d\n', activeTrackNum(track, i));
    end
    waitbar(i/totalFrameNum,h)
end
close(h)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5: Generate frames by browsing tracks. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert from tracks to frames.
previousFrameTrackNum = max(size(track));

for i = 1 : previousFrameTrackNum
    for j = 1 : track(i).len
        tempIndex = track(i).startID + j - 1;
        if (tempIndex == 1)
            continue;
        else
            frameStack(tempIndex).length = frameStack(tempIndex).length + 1;
            frameStack(tempIndex).coordinate(frameStack(tempIndex).length, 1 : 3) = track(i).points(j, 1 : 3);
        end
    end
end

% Write out frames as a TXT file
fileName2 = 'pointData001.txt';
start_path = 'D:\manTrackWT2s\';
str1 = uigetdir(start_path, 'Please choose the directory to save the point date file.');
path2 = strcat(str1, '\');
fileName2 = strcat(path2, fileName2);
fid = fopen(fileName2, 'wt');
totalSpeckleNum = 0;

h = waitbar(0, 'Generating point data files, Please wait...');
for i = 1 : totalFrameNum
    fprintf('Total number of speckles is %d in image %d\n', frameStack(i).length, i);
        for j = 1 : frameStack(i).length
                % temp_center = round(frame_speckle(i).coordinate(j, 1:2)); %This rounding can be a problem!!!! 
             tempData = frameStack(i).coordinate(j, 1:3);  % no rounding here.
             fprintf(fid,' (');
             
             
             fprintf(fid, '%10.6f %10.6f %10.6f', round(tempData(2)), round(tempData(1)), tempData(3)/255); 
             % Notice here that X-coordinate is printed first, followed by
             % Y-coordinate. This is required in order to be consistent
             % with the C-language LAP tracking program. 
             
             
             fprintf(fid,')');
             if (j == frameStack(i).length)
                 fprintf(fid, '.\n');
             elseif (mod(j,5) == 0)
                 fprintf(fid,' \n');
             end
             totalSpeckleNum = totalSpeckleNum + 1;
        end
    waitbar(i / totalFrameNum, h);
end
fclose(fid);
close(h);
fprintf('Frame point file %s has been generated.\n', fileName2);
fprintf('Total number of speckles is %d\n', totalSpeckleNum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 6: Generate a data file for flow field. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fileName3 = 'flowVecData001.txt';
fileName3 = strcat(path2, fileName3); % use the path from Step 6
fid = fopen(fileName3, 'wt');
totalSpeckleNum = 0;
y_grid_size = 1;
x_grid_size = 1;
y_range = imgHeight;
x_range = imgWidth;

y_grid_num = round((y_range - 1)/ y_grid_size) + 1;
x_grid_num = round((x_range - 1)/ x_grid_size) + 1;

% The basic idea is to provide the vector field data on a grid. The first
% pair denotes (y_grid_size, x_grid_size). The second pair denotes
% (y_range, x_range). (of course, assume starting from 1)

% The primary advantage of this design is that we do not need to write out
% coordinates explicitly.


fprintf(fid, '(');
fprintf(fid, '%10.6f %10.6f', y_grid_size, x_grid_size);
fprintf(fid,').\n');

fprintf(fid, '(');
fprintf(fid, '%10.6f %10.6f', y_range, x_range);
fprintf(fid,').\n');

totalPrintNum = 0;

h = waitbar(0, 'Generating vector field data files, Please wait...');
for i = 1 : y_grid_num
    for j = 1 : x_grid_num
        tempFlowVec = [0, 1]; % Horizontal direction.
        fprintf(fid,' (');
        fprintf(fid, '%10.6f %10.6f', tempFlowVec(2), tempFlowVec(1));
        % Notice that the X-component is printed first. This is necessary
        % to ensure consistency with the C-language LAP tracking program.
        
        
        fprintf(fid,')');
        totalPrintNum = totalPrintNum + 1;
        if (mod(totalPrintNum, 5) == 0)
            fprintf(fid,' \n');
        end
    end
    waitbar(i / y_grid_num, h);
end
fprintf(fid,' .\n'); 

fclose(fid);
close(h);
fprintf('Vector field data file %s has been generated.\n', fileName3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 7: Generate an intensity distribution file. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileName4 = 'intProfileData001.txt';
fileName4 = strcat(path2, fileName4); % use the path from Step 6
fid = fopen(fileName4, 'wt');


for i = 1 : totalFrameNum
    intImg = [];
    for j = 1 : frameStack(i).length
        intImg = [intImg; frameStack(i).coordinate(j, 3)];
    end
    intImg = intImg / 255;
    tempMean = mean(intImg);
    tempStd = std(intImg);
    fprintf(fid, '%10.6f %10.6f\n', tempMean, tempStd); 
end
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 8: Generate the track data file. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileName5 = 'trackData001.txt';
fileName5 = strcat(path2, fileName5); % use the path from Step 6
fid = fopen(fileName5, 'wt');

totalTrackNum = max(size(track));
totalTrackPtNum = 0;

h = waitbar(0, 'Generating track data files, Please wait...');
for i = 1 : totalTrackNum
    fprintf(fid, '(');
    fprintf(fid, '%f %f', track(i).startID, track(i).len);
    fprintf(fid, ')\n');

    for j = 1 : track(i).len
        tempData = track(i).points(j, 1:3);
        fprintf(fid,' (');
        fprintf(fid, '%10.6f %10.6f %10.6f', round(tempData(2)), round(tempData(1)), tempData(3)/255);
        % Notice here that X-coordinate is printed out first and
        % Y-coordinate second.
        fprintf(fid,')');
        if (j == track(i).len)
            fprintf(fid, '.\n');
        elseif (mod(j,5) == 0)
            fprintf(fid,'\n');
        end
    end
    totalTrackPtNum = totalTrackPtNum + track(i).len;
    waitbar( i / totalTrackNum, h);
end
close(h);
fclose(fid);
fprintf('Track data file %s has been generated.\n', fileName5);
fprintf('Total number of track points is %d\n', totalTrackPtNum);
fprintf('Total number of tracks is %d\n', totalTrackNum);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 9: Computing basic statistics of the synthetic data for verification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
totalPtNum1 = 0;

for i = 1 : totalFrameNum
    totalPtNum1 = totalPtNum1 + frameStack(i).length;
    if (abs(frameStack(i).length - ptNum(i)) > 1e-3)
        fprintf('speckle number mismatch in frame %d\n', i);
        fprintf('frameStack.length = %d  ptNum = %d\n', frameStack(i).length, ptNum(i));
    end
end

totalTrackNum = max(size(track));
syntheticLifeTime = [];

totalPtNum2 = 0;
for i = 1 : totalTrackNum
    totalPtNum2 = totalPtNum2 + track(i).len;
    syntheticLifeTime = [syntheticLifeTime; track(i).len];
end
figure;
hist(syntheticLifeTime, 100);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 8: Generating a color movie and take a visual check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

image_stack = uint8(zeros(imgHeight, imgWidth, 3, totalFrameNum));
temp_image = ones(imgHeight, imgWidth, 3);

for i = 1 : totalFrameNum
    temp_image (1:imgHeight, 1:imgWidth, 1:3) = 0;
    speckle_size_half = 1;

    for j = 1 : frameStack(i).length
        temp_center = round(frameStack(i).coordinate(j, 1:2));
        if ((temp_center(1) > speckle_size_half) &...
            (temp_center(1) < imgHeight - speckle_size_half) &...
            (temp_center(2) > speckle_size_half) & (temp_center(2) < imgWidth - speckle_size_half))     
            temp_image(temp_center(1) - speckle_size_half : temp_center(1) + speckle_size_half,... 
            temp_center(2) - speckle_size_half : temp_center(2) + speckle_size_half, 1 : 3) = round(frameStack(i).coordinate(j, 3));  % use green to represent general points
        end
    end
    image_stack(:,:,:,i) = uint8(temp_image);
end

movie_temp = immovie(image_stack);
fprintf('Please press enter to start to play the movie.\n');
% pause;
% axis off;
% movie(movie_temp,5,5);

videoFileName = 'spindleSimulation001.avi';
videoFileName = strcat(path2, videoFileName); % use the path from Step 6


mov1 = avifile(videoFileName, 'FPS', 10, 'COMPRESSION', 'indeo5');

for i= 1 : totalFrameNum
    mov1 = addframe(mov1,image_stack(:,:,:,i));
end


mov1 = addframe(mov1,image_stack(:,:,:,1));
mov1 = addframe(mov1,image_stack(:,:,:,1));
mov1 = close(mov1);


% Step 3: image alignment


        

