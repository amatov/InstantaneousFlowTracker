% The objective of this program is to generate synthetic image sequences
% based on real spindle geometry and flux field. Such groundtruth movies
% can be useful for many purposes, especially for the benchmarking of
% visual tracking algorithms and flow computation algorithms.
%
% This program is designed to emulate real spindle flow by three measures
% (a) The numbers of point feature in the synthetic images are set to be
%     approximately the same as that of real images such that the synthetic
%     images generated will have approximately the same complexity as that
%     of true images.
% (b) Synthetic spindle geometry comes directly from real spindles.
% (c) Synthetic spindle flux comes directly from real spindle flux, which is
%     computed using graph/flow optimization algorithms.
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Major issues and their solutions:
% 
% (1) Speckle distribution, birth/death control
%
%     BIRTH
%
%     a. For now, assume birth to happen within the entire ROI (set
%     manually by interactive cropping). 
% 
%     b. The birth rate must ensure that the number of speckles remain
%     approximately the same.
%
%
%     DEATH
%
%     a. speckles going outside of defined region will terminate.
%     b. a track whose length goes beyond a threshold (deterimined by a user-
%        specified distribution) will terminate.
%     c. the lifespan of a track is determined by a statistical model.
%     d. speckles coming within a small distance will merge and thus may
%     terminate.
%
%     NOTE: the lifespan of a speckle is predetermined, although it may not
%     ever by reached due to the finite length of the movie. 
%
%     IMPLEMENTATION: lifetime distribution is computed using random number
%     generators in the Statistical toolbox. Currently, the supported
%     distributions include: uniform, Gaussian, Weibull, exponential and
%     Poission. Of course, extensions to other distributions are straight-
%     forward. NOTE: the seed for such generation must be fixed for repetitiveness!
%
%
%
%
% (2) Intensity cue
%
%     The initial intensity of each speckle is distributed with a given
%     range controlled by a mean and a STD. Then the intensity of each speckle
%     is changed on an individual basis controlled by another STD.
%
% (3) Antiparallel flow
%
%     a. flow field is always bidirectional at each point (always
%     anti-parallel).
%
%     b. Each speckle is randomly assigned an initial direction. Then its
%     next direction is determined so that the change in orientation does
%     not exceed 180. 
%
% (4) 
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Obtain spindle geometry by interactive cropping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [filename1, pathname1] = uigetfile('*.tif', 'Please choose the spindle image');
% filename1 = strcat(pathname1, filename1);
% imgtemp = imread(filename1, 'tiff');
% imshow(imgtemp, []);
% bw = roipoly;
% figure;
% imshow(bw);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Set basic parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2.0: Set basic image parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% info = imfinfo(filename1, 'tiff');
% imgHeight = info.Height;
% imgWidth = info.Width;
% 
% save data001;
clear all;
close all;
clc;
load data001;
imshow(bw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2.1: Get speckle numbers directly from the original sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_path = 'D:\manTrackWT2s\';
ptNum = getSpeckleNum(start_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2.2: Distance control parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minPtDist = 4;  % Points go within this distance to each other will be merged.
                % This value of 4 is obtained directly from the original image 
                % using for example 3-frame overlapping.   



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Load flux field data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [filename2, pathname2] = uigetfile('*.mat', 'Please choose the flux field MAT file');
% filename2 = strcat(pathname2, filename2);
% fluxField = load(filename2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Generate synthetic images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4.1: Generate the first frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The entire data structure is track-based. Then each frame is extracted
% from this track data structure.

maxPtNum = max(ptNum); % Find the maximal number of speckles per frame.
% If even-larger speckle numbers are required, the array ptNum can be
% manipulated directly.

totalFrameNum = 20;
frameStack = struct('length', 0, 'coordinate', zeros(maxPtNum, 3));
track = struct('startID', 0,... 
               'len', 0,... 
               'lifespan', 0,...
               'points', zeros(totalFrameNum, 2),...
               'status', 0,...
               'mergeCounter', 0); 
% len --> actual length of the track
% lifespan --> obtained from a random number generator. May not be reached.
% (status == 0) indicates that the track has terminated. 


currentPtNum = 0;
h = waitbar(0,'Generating the first frame. Please wait...');
i = 0;
failedGenerationNum = 0;
maxAllowedFailureNum = 1000;

frameStack(1).length = 0;

while (currentPtNum < ptNum(1))       % Need to fill the whole array
    tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
    while ((tempPixelCoordinate(1) == 0) | (tempPixelCoordinate(2) == 0) | (bw(tempPixelCoordinate(1), tempPixelCoordinate(2)) == 0))
        tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
    end

    %fprintf('new coordinate %d %d\n', temp_pixel_coordinate);
    %pause;
   
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
        frameStack(1).coordinate(currentPtNum, 3) = -1;  % This is a new point. In fact, this is the first frame.
        
        failedGenerationNum = 0;
        frameStack(1).length = frameStack(1).length + 1;
        % fprintf('Generated a new point.\n');
    else
        failedGenerationNum = failedGenerationNum + 1;
    end

    %fprintf('%d points generated, %d more points to go.\n', current_array_length, frame_stack(1).length - current_array_length);
    if (failedGenerationNum > maxAllowedFailureNum)
        fprintf('Maximum number of failure reached. Program now terminates.\n');
        break;
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
paramSetting.option = 3;
paramSetting.mean = 0.35 * totalFrameNum;
paramSetting.std = 1;

generatorSeed = 3557;
length = totalFrameNum * maxPtNum; % Compute the maximal track number 

lifeTime1 = round(speckleLifeTimeDistribution(paramSetting, generatorSeed, length));
lifeTime2 = round(speckleLifeTimeDistribution(paramSetting, generatorSeed, length));
if sum(abs(lifeTime1 - lifeTime2)) > 1e-3
    fprintf('Inconsistency in lifetime generation\n');
    pause;
end

if paramSetting.option == 1
    [muhat, muci] = expfit(lifeTime1);
elseif paramSetting.option == 2
    [lambdathat, lambdaci] = poissfit(lifeTime1)
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
    track(i).len = 1;
    track(i).points(1, 1 : 2) = frameStack(1).coordinate(i, 1 : 2);
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

magVec = [1 0.5];
thetaVec = [0 15]; % in degrees
for i = 2 : totalFrameNum
    fprintf('------------------Generating frame %d-------------------\n', i); 
    % Step 1, -------------------update tracks-------------------------------
    fprintf('-Step 1- Updating tracks based on flux field.\n');
    previousFrameTrackNum = max(size(track));
    for j = 1 : previousFrameTrackNum  % propagation is completely track-based.
        if (track(j).status == 0)
            continue; % ignore inactive tracks
        end
        % Check for data integrity
        %         if ((track(j).startID + track(j).len -1) ~= i)
        %             errordlg('Data integrity violated')
        %             errorFlag = 1;
        %         end
        %         
        currentPoint = track(j).points(track(j).len, 1:2);
        flowmap = [];
        currentVec = getFlowVec(flowmap, currentPoint, magVec, thetaVec);      % Get local flow vector
        % must consider the smoothness of direction
        
        if (track(j).len > 1) % we need to consider the constraint of smoothness
            previousVec = track(j).points(track(j).len, 1:2) - track(j).points(track(j).len-1, 1:2);
            if (dot (currentVec, previousVec) < 0)
                currentVec = -currentVec; % reverse the direction
            end
        end
        track(j).len = track(j).len + 1;
        track(j).points(track(j).len, 1:2) = currentPoint + currentVec; % update position  
    end
        
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
        end
        
        if ((tempCoordinate(1) > imgHeight) | (tempCoordinate(2) > imgWidth))
            track(m).len = track(m).len - 1;
            track(m).status = 0; % terminate tracks going beyond image boundary for date integrity
        end
        
        % Check for ROI boundary
        if (bw(tempCoordinate(1), tempCoordinate(2)) == 0)
            track(m).len = track(m).len - 1;
            track(m).status = 0; % terminate tracks goings beyond ROI boundary.
        end
        
        % Check for lifetime
        if (track(m).len == track(m).lifespan)
            track(m).status = 0;
        end
    end
        
    % Third, --------------- Handling track / speckle merging ------------------    
    fprintf('-Step 3- Checking for merged tracks.\n');
    for m = 1 : previousFrameTrackNum
        if (track(m).status == 0)
            continue;
        end
        L1 = track(m).len;
        
        for n = (m + 1)  : previousFrameTrackNum
            if (track(n).status == 0)
                continue;
            end
        
%             if (m == n)
%                 coutinue; % Avoid comparing with self
%             end
            
            L2 = track(n).len;
            if (EuclideanDistance(track(m).points(L1, 1:2), track(n).points(L2, 1:2)) < minPtDist)
                track(m).status = 0; % terminate it
                track(m).mergeCounter = track(m).mergeCounter + 1;
                track(n).mergeCounter = track(n).mergeCounter + 1;
            end
        end
    end
            
    % Fourth, check for track numbers, decide which tracks to terminate and which to add
    fprintf('-Step 4- Handling birth and death. \n');
    %fprintf('Counting number of active tracks. Then add or drop based on given point number.\n');

    activePreviousFrameTrackNum = 0;
    activeTrackList = [];
    for m = 1 : previousFrameTrackNum
        if (track(m).status == 1)
            activePreviousFrameTrackNum = activePreviousFrameTrackNum + 1;
            activeTrackList = [activeTrackList m];
        end
    end
    
    if (activePreviousFrameTrackNum > ptNum(i)) % need to terminate some tracks. 
        % Remember for long sequences, you should consider length as a factor. 
        dropNum = activePreviousFrameTrackNum - ptNum(i);
        activeLen = max(size(activeTrackList));
        dropID = 0;
        for k = 1 : dropNum
            while (dropID == 0) | (activeTrackList(dropID).status == 0))
                dropID = round(rand(1) * activeLen);
            end
            track(activeTrackList(dropID)).status = 0;
            track(activeTrackList(dropID)).len = track(activeTrackList(dropID)).len - 1;
        end
    end
     
    
    if (activePreviousFrameTrackNum < ptNum(i)) % need to add some new tracks
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
               
                activePreviousFrameTrackNum = activePreviousFrameTrackNum + 1; 
                activeTrackList = [activeTrackList previousFrameTrackNum];

                track(previousFrameTrackNum).startID = i;
                while (lifeTime1(lifeTimeCounter) == 0)
                    lifeTimeCounter = lifeTimeCounter + 1;
                end
                track(previousFrameTrackNum).lifespan = lifeTime1(lifeTimeCounter);
                track(previousFrameTrackNum).len = 1;
                track(previousFrameTrackNum).points(1, 1 : 2) = tempPixelCoordinate;
                track(previousFrameTrackNum).status = 1;      % active track
                track(previousFrameTrackNum).mergeCounter = 0;   % not merged, of course
            end
        end
        if (failedGenerationNum > maxAllowedFailureNum)
            fprintf('Maximum failure number reached in attempting to add points. Now exiting. \n');
            break;
        end
    end
    waitbar(i/totalFrameNum,h)
end
close(h)
   

% Step 5: Generate frames by browsing tracks. 
% Convert from tracks to frames.
for i = 1 : previousFrameTrackNum
    for j = 1 : track(i).len
        tempIndex = track(i).startID + j - 1;
        if (tempIndex == 1)
            continue;
        else
            frameStack(tempIndex).length = frameStack(tempIndex).length + 1;
            frameStack(tempIndex).coordinate(frameStack(tempIndex).length, 1 : 2) = track(i).points(j, 1 :2);
        end
    end
end

% Write out frames as a TXT file
fileName2 = 'testjunk.txt';
start_path = 'D:\manTrackWT2s\';
path2 = strcat(uigetdir(start_path, 'Please choose the directory to save the point date file.'), '\');
fileName2 = strcat(path2, fileName2);
fid = fopen(fileName2, 'wt');
totalSpeckleNum = 0;



h = waitbar(0, 'Generating point data files, Please wait...');
for i = 1 : totalFrameNum
    fprintf('Total number of speckles is %d in image %d\n', frameStack(i).length, i);
        for j = 1 : frameStack(i).length
                % temp_center = round(frame_speckle(i).coordinate(j, 1:2)); %This rounding can be a problem!!!! 
             temp_center = round(frameStack(i).coordinate(j, 1:2));
             fprintf(fid,' (');
             fprintf(fid, '%10.6f %10.6f %10.6f', temp_center(2), temp_center(1), 0);
             fprintf(fid,')');
             if (mod(j,5) == 0)
                 fprintf(fid,' \n');
             end
             totalSpeckleNum = totalSpeckleNum + 1;
        end
        fprintf(fid,' .\n'); 
    waitbar(i / totalFrameNum, h);
end
fclose(fid);
close(h);
fprintf('Frame point file %s has been generated.\n', fileName2);
fprintf('Total number of speckles is %d\n', totalSpeckleNum);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 6: Computing basic statistics of the synthetic data for verification
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

hist(syntheticLifeTime, 100);





















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 7: Generating a color movie and take a visual check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

image_stack = uint8(zeros(imgHeight, imgWidth, 3, totalFrameNum));
temp_image = ones(imgHeight, imgWidth, 3);

for i = 1 : totalFrameNum
    temp_image (1:imgHeight, 1:imgWidth, 1:3) = 0;
    speckle_size_half = 1;

    for j = 1 : frameStack(i).length
        temp_center = round(frameStack(i).coordinate(j, 1:2));
        if ((temp_center(1) > 2) & (temp_center(1) < imgHeight - 2) & (temp_center(2) > 2) & (temp_center(2) < imgWidth -2))     
            temp_image(temp_center(1) - speckle_size_half : temp_center(1) + speckle_size_half,... 
            temp_center(2) - speckle_size_half : temp_center(2) + speckle_size_half, 2) = 127;  % use green to represent general points
        end
    end
    image_stack(:,:,:,i) = uint8(temp_image);
end

movie_temp = immovie(image_stack);
fprintf('Please press enter to start to play the movie.\n');
% pause;
% axis off;
% movie(movie_temp,5,5);

filename1 = 'spindle003.avi';
mov1 = avifile(filename1, 'FPS', 10, 'COMPRESSION', 'indeo5');

for i= 1 : totalFrameNum
    mov1 = addframe(mov1,image_stack(:,:,:,i));
end


mov1 = addframe(mov1,image_stack(:,:,:,1));
mov1 = addframe(mov1,image_stack(:,:,:,1));
mov1 = close(mov1);


% Step 3: image alignment


        
