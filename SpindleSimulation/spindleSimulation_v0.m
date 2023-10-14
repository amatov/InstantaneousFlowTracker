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
% Step 1: Obtain spindle geometry by cropping
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
% Step 2.0: Set basic image parameters
info = imfinfo(filename1, 'tiff');
imgHeight = info.Height;
imgWidth = info.Width;

% Step 2.1: Get speckle numbers directly from the original sequence
ptNum = getSpeckleNum;

% Step 2.2: Distance control parameters
minPtDist = 2;  % Points go within this distance to each other will be merged.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Load flux field
% [filename2, pathname2] = uigetfile('*.mat', 'Please choose the flux field MAT file');
% filename2 = strcat(pathname2, filename2);
% fluxField = load(filename2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Generate synthetic images

% Step 4.1: Generate the first frame. 
% The entire data structure is track-based. Then each frame is extracted
% from this data structure.


maxPtNum = max(ptNum);
totalFrameNum = 40;

frameStack = struct('length', 0, 'coordinate', zeros(maxPtNum, 3));

track = struct('startID', 0, 'len', 0, 'points', zeros(totalFrameNum, 2), 'status', 0); 
% (status == 0) indicates that the track has terminated. 



frameStack(1).length = ptNum(1);
i = 0;
currentPtNum = 1;
tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
frameStack(1).coordinate(1, 1:2) = tempPixelCoordinate;

h = waitbar(0,'Generating the first frame. Please wait...');
while (i < frameStack(1).length)       % Objective is to fill in the whole array
    tempPixelCoordinate = round(rand(1,2).*[imgHeight, imgWidth]);
    if ((tempPixelCoordinate(1) == 0) | (tempPixelCoordinate(2) == 0))
        continue; % The point generated is not usable
    end
    
    %fprintf('new coordinate %d %d\n', temp_pixel_coordinate);
    %pause;
   
    j = 1;
    distance_flag = 1;
    while (j <= currentPtNum)  % Check the distance from existing points
        if (sqrt((tempPixelCoordinate(1) - frameStack(1).coordinate(j, 1))^2 +...
                 (tempPixelCoordinate(2) - frameStack(1).coordinate(j, 2))^2) < minPtDist)
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

fprintf('First frame generated. Now start to generate subsequent frames.\n');
%pause;

% Step 4.2: Propagate the frames. First, compute displacement according to flux
% field. Then either add or drop points depending on the desired point numbers.


% Initialize all the tracks corresponding to the first frame.
for i = 1 : ptNum(1)
    track(i).startID = 1;
    track(i).len = 1;
    track(i).points(1, 1 : 2) = frameStack(1).coordinate(i, 1 : 2);
    track(i).status = 1; % active track
end

totalTrackNum = ptNum(1);
activeTrackNum = ptNum(1);




for i = 2 : totalFrameNum
    for j = 1 : totalTrackNum  % propagation is completely track-based.
        
        if (track(j).status == 0)
            
        % Check for data integrity
        
        if ((track(j).startID + track(j).len) ~= i)
            errordlg('Data integrity violated')
            errorFlag = 1;
        end
        
        currentPoint = track(j).point(i, 1:2);
        
        % Get local flow vector
        currentVec = getFlowVec(flowmap, currentPoint);
        
        track(j).len = track(j).len + 1;
        track(j).points(track(j).len) = currentPoint + currentVec; % update position
        
        
        
        if (errorFlag == 1)
            break;
        end
    end
    
    
    if (errorFlag == 1)
            break;
    end
    
    
    % First, address possible merging of speckles.
    
    % Decide which tracks to terminate and which to add
    
end

% Second, then check for number requirements and add/drop.





















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
