% The objective of this program is to generate synthetic images based on
% real spindle geometry and flux field. In particular, the number of point

% feature in the synthetic images should be approximately the same as
% that of real images such that the synthetic images generated will have
% approximately the same complexity of true images.

% Major issues and their solutions:
% 
% (1) Speckle distribution, birth/death control
%
%     BIRTH
%
%     a. For now, assume birth to happen within a given region (set
%     manually). 
% 
%     b. The birth rate must ensure that the number of speckles remain
%     approximately the same.
%
%
%     DEATH
%
%     a. speckles going outside of defined region will terminate.
%     b. a track whose length goes beyond a threshold will terminate.
%     c. the lifespan of a track is determined by a statistical model.
%     d. speckles coming within a small distance will merge and thus may
%     terminate.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Obtain spindle geometry by interactive cropping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[filename1, pathname1] = uigetfile('*.tif', 'Please choose the spindle image');
filename1 = strcat(pathname1, filename1);
imgtemp = imread(filename1, 'tiff');
imshow(imgtemp, []);
bw = roipoly;
figure;
imshow(bw);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Set basic parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2.0: Set basic image parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info = imfinfo(filename1, 'tiff');
imgHeight = info.Height;
imgWidth = info.Width;

% Step 2.1: Get speckle numbers directly from the original sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_path = 'D:\manTrackWT2s\';
ptNum = getSpeckleNum(start_path);

% Step 2.2: Distance control parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minPtDist = 4;  % Points go within this distance to each other will be merged.
                % This value of 4 is obtained directly from the original image.   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Load flux field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [filename2, pathname2] = uigetfile('*.mat', 'Please choose the flux field MAT file');
% filename2 = strcat(pathname2, filename2);
% fluxField = load(filename2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Generate synthetic images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 4.1: -----------------Generate the first frame--------------------------- 
% The entire data structure is track-based. Then each frame is extracted
% from this data structure.

maxPtNum = max(ptNum);
totalFrameNum = 40;

frameStack = struct('length', 0, 'coordinate', zeros(maxPtNum, 3));
track = struct('startID', 0, 'len', 0, 'points', zeros(totalFrameNum, 2), 'status', 0, 'mergeCounter', 0); 
% (status == 0) indicates that the track has terminated. 

frameStack(1).length = ptNum(1);
tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
while ((tempPixelCoordinate(1) == 0) | (tempPixelCoordinate(2) == 0))
    tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
end

currentPtNum = 1;
frameStack(currentPtNum).coordinate(currentPtNum, 1:2) = tempPixelCoordinate;

h = waitbar(0,'Generating the first frame. Please wait...');
i = 0;
while (i < frameStack(1).length)       % Objective is to fill in the whole array
    tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
    while ((tempPixelCoordinate(1) == 0) | (tempPixelCoordinate(2) == 0))
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
    
    if ((distance_flag == 1) & (bw(tempPixelCoordinate(1), tempPixelCoordinate(2)) ~= 0))
        % Minimum distance requirement is satisfied
        currentPtNum = currentPtNum + 1;
        frameStack(1).coordinate(currentPtNum, 1:2) = tempPixelCoordinate;
        frameStack(1).coordinate(currentPtNum, 3) = -1;  % This is a new point. In fact, this is the first frame.
        i = i + 1;
        % fprintf('Generated a new point.\n');
    end
    %fprintf('%d points generated, %d more points to go.\n', current_array_length, frame_stack(1).length - current_array_length);
    waitbar(i / frameStack(1).length, h);
end
close(h);

hold on;
plot(frameStack(1).coordinate(1:frameStack(1).length, 2), frameStack(1).coordinate(1:frameStack(1).length, 1), 'r.');
axis equal;
axis([1 max(imgHeight, imgWidth) 1 max(imgHeight, imgWidth)]);
fprintf('First frame generated. Now start to generate subsequent frames.\n');
pause;
pause;

% Step 4.2: Propagate the frames. First, compute displacement according to flux
% field. Then either add or drop points depending on the desired point numbers.


% Initialize all the tracks corresponding to the first frame.
for i = 1 : ptNum(1)
    track(1).startID = 1;
    track(1).len = 1;
    track(1).points(i, 1 : 2) = frameStack(1).coordinate(i, 1 : 2);
    track(1).status = 1;      % active track
    track(1).mergeCounter = 0;   % not merged, of course
end

previousFrameTrackNum = ptNum(1);
%activepreviousFrameTrackNum = ptNum(1);


        
h = waitbar(0, 'Updating tracks frame-by-frame. Please wait...');       
for i = 2 : totalFrameNum
    
    % First, -------------------update tracks-------------------------------
    
    fprintf('Updating tracks based on flux field.\n');
    previousFrameTrackNum = length(track);
    for j = 1 : totalTrackNum  % propagation is completely track-based.
        
        if (track(j).status == 0)
            continue;
        end
   
        % Check for data integrity
        %         if ((track(j).startID + track(j).len -1) ~= i)
        %             errordlg('Data integrity violated')
        %             errorFlag = 1;
        %         end
        %         
        
        currentPoint = track(j).point(track(j).len, 1:2);
        currentVec = getFlowVec(flowmap, currentPoint);      % Get local flow vector
        % must consider the smoothness of direction
        
        if track(j).len > 1) % we need to consider the constraint of smoothness
            previousVec = track(j).points(track(j).len, 1:2) - track(j).points(track(j).len-1, 1:2)
            if (dot (currentVec, previousVec) <0)
                currentVec = -CurrentVec; % reverse the direction
            end
        end
        track(j).len = track(j).len + 1;
        track(j).points(track(j).len) = currentPoint + currentVec; % update position       
        
        
        %         if (errorFlag == 1)
        %             break;
        %         end
    end
    
    
        %     if (errorFlag == 1)
        %             break;
        %     end
    
    fprintf('Terminating tracks based on flux field.\n');
    % Second, terminate those going beyond boundary
    for m = 1 : previousFrameTrackNum
        if (track(m).statue == 0)
            continue;
        end
        
        if (bw(track(m).points(track(m).len, 1), track(m).points(track(m).len, 2)) == 0)
            track(m).status = 0;
        end
    end
        
    % Third, ---------------address possible merging of speckles------------------    
    fprintf('Checking for merged tracks.\n');
    for m = 1 : previousFrameTrackNum
        if (track(m).statue == 0)
            continue;
        end
        L1 = track(m).len;
        
        for n = m  : previousFrameTrackNum
            if (track(n).statue == 0)
                continue;
            end
        
            if (m == n)
                coutinue; % Avoid comparing with self
            end
            
            L2 = track(n).len;
            if (EuclideanDistance(track(m).point(L1, 1:2), track(n).point(track(n).point(L2, 1:2))) < minPtDist)
                track(m).status = 0; % terminate it
                track(m).mergeCounter = track(m).mergeCounter + 1;
                track(n).mergeCounter = track(n).mergeCounter + 1;
            end
        end
    end
            
    % Fourth, check for track numbers, decide which tracks to terminate and which to add
    fprintf('Counting number of active tracks. Then add or drop based on given point number.\n');
    activePreviousFrameTrackNum = 0;
    activeTrackList = [];
    
    for m = 1 : previousFrameTrackNum
        if (track(m).status == 1)
            activePreviousFrameTrackNum = activePreviousFrameTrackNum + 1;
            activeTrackList = [activeTrackList m];
        end
    end
    
    if (activePreviousFrameTrackNum > ptNum(i) % need to terminate some tracks. 
        
        % Ideally, you should consider length as a factor. 
        
        dropNum = activePreviousFrameTrackNum - ptNum(i);
        activeLen = length(activeTrackList);
        for k = 1 : dropNum
            dropID = round(rand(1) * activeLen);
            if (dropID == 0)
                dropID = 1;
            end
            track(activeTrackList(dropID)).status = 0;
        end
    end
    
    
    if (activePreviousFrameTrackNum < ptNum(i) % need to add some new tracks
        addNum = ptNum(i) - activePreviousFrameTrackNum;
        
        for k = 1 : addNum
            tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
            while ((tempPixelCoordinate(1) == 0) | (tempPixelCoordinate(2) == 0))
                  tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
            end
   
            distance_flag = 1;
            activeLen = length(activeTrackList);
            for s = 1 : activeLen
                 if (EuclideanDistance(tempPixelCoordinate, frameStack(1).coordinate(j, 1:2)) < minPtDist)
                    distance_flag = 0;
                 break;
            else
                 previousFrameTrackNum = previousFrameTrackNum + 1;
                 activePreviousFrameTrackNum = activePreviousFrameTrackNum + 1; 
                 activeTrackList = [activeTrackList previousFrameTrackNum];

                 track(previousFrameTrackNum).startID = 1;
                 track(previousFrameTrackNum).len = 1;
                 track(previousFrameTrackNum).points(i, 1 : 2) = frameStack(1).coordinate(i, 1 : 2);
                 track(previousFrameTrackNum).status = 1;      % active track
                 track(previousFrameTrackNum).mergeCounter = 0;   % not merged, of course
            end
        end
    end
    waitbar(i/totalFrameNum,h)
end
close(h)
   

% Step 5: Generate frames by browsing tracks. 

%frameStack = struct('length', 0, 'coordinate', zeros(maxPtNum, 3));
%track = struct('startID', 0, 'len', 0, 'points', zeros(totalFrameNum, 2), 'status', 0, 'mergeCounter', 0); 

% Convert from tracks to frames.
for i = 1 : activePreviousFrameTrackNum
    for j = 1: track(i).len
        if ((startID + j - 1) == 1)
            continue;
        else
            tempIndex = startID + j - 1;
            frameStack(temIndex).length = frameStack(tempIndex).length + 1;
            frameStack(tempIndex).coordinate(frameStack(tempIndex).length, 1 : 2) = track(i).points(j, 1 :2);
        end
    end
end

% Write out frames as a TXT file
fileName2 = 'testjunk.txt';
start_path = 'D:\manTrackWT2s\';
path2 = strcat(uigetdir(start_path, 'Please choose the directory to save the point date file.'), '\');
fileName2 = strcat(path2, filename2);
fid = fopen(filename2, 'wt');

h = waitbar(0, 'Generating point data files, Please wait...');
for i = 1 : totalFrameNum
    fprintf('Total number of speckles is %d in image %d\n', frameStack(i).length, i);
        for j = 1 : frameStack(i).length
                % temp_center = round(frame_speckle(i).coordinate(j, 1:2)); %This rounding can be a problem!!!! 
             temp_center = frameStack(i).coordinate(j, 1:2);
             fprintf(fid,' (');
             fprintf(fid, '%10.6f %10.6f %10.6f', temp_center(2), temp_center(1), 0);
             fprintf(fid,')');
             if (mod(j,5) == 0)
                 fprintf(fid,' \n');
             end
             total_speckle_num = total_speckle_num + 1;
        end
        fprintf(fid,' .\n'); 
    waitbar(i / total_frame_num, h);
end
fclose(fid);
close(h);
fprintf('Frame point file %s has been generated.\n', filename);
fprintf('Total number of speckles is %d\n', total_speckle_num);
   

        

