function [frame1_pos,frame2_pos,frame3_pos]=art3dirFlow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The objective of this program is to generate benchmark testing trajectories for
% graph-based flow computing algorithms. The generated flow pattern is organized
% into multiple regions with different directions in each region.

% DESCRIPTION:      In this first implementation, a simple assumption is made about the flow  
%                   pattern. Specifically, it is assumed to be organized into three regions.
%                   It is assumed that there is a generation region (a circle) at the center
%                   of the square. Point features generated within this region is moved along
%                   different directions based on their directions.
%
% 
% Created by:
%                   Ge Yang
%                   Laboratory for Computational Cell Biology
%                   Department of Cell Biology, CB167
%                   The Scripps Research Institute 
%                   10550 N. Torrey Pines Road
%                   La Jolla, CA 92037
%
%                   Email geyang@scripps.edu
%
% Date of creation: April 27, 2004
% Version:          0.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 0: definition of basic parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Step 0.1   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Definition of image size and point window size
image_height = 480;
image_width = 640;

image_center = [image_height/2;  image_width/2];  % use a column vector

kernel_radius = 120; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  End of Step 0.1  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Step 0.2   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of point numbers and distributions
point_num = 2000;   % This is just a base approximation. The actual number can be more or less
point_num_dev = 0; % Standard deviation of number of points. (Be conservative and start with 5)DEF4

frame_num = 3;       % Number of frames
min_dist = 10; % The minimum distance between points is 3 pixels. If the distance is smaller, 
                      % the points will be merged. 

vec_field = struct('ori', zeros(2,1), 'mag', 0, 'angle', 0);

theta = 30 / 180 * pi;
vec_field(1).ori = [sin(theta); cos(theta)];
vec_field(1).mag = 4;
vec_field(1).angle = theta;

theta = 150 / 180 * pi;
vec_field(2).ori = [sin(theta); cos(theta)];
vec_field(2).mag = 12;
vec_field(2).angle = theta;

theta = 270 / 180 * pi;
vec_field(3).ori = [sin(theta); cos(theta)];
vec_field(3).mag = 20;
vec_field(3).angle = theta;

frame_stack = struct('length', 0, 'points', zeros((point_num + 3 * point_num_dev), 4));

% Basic definition of the data structure. 
% The third column of the coordinate will be the index of its predecessor in
% the coordinate_array to which it belongs.
% The fourth column of the coordinate will be the index of its successor in
% the coordinate array to which it belongs. This feature is not supported
% in this version.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  End of Step 0.2  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Step 0.3   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of basic motion parameters
ori_perturb_mag = 15 /180 * pi; % fifteen degrees
disp_perturb_mag = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  End of Step 0.3  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 1: generate the first frame. Assume uniform distribution

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Step 1.1   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the 

max_new_pt_num = 6;     % maximum number of new points to be generated DEF25
total_trial_num = 200;  % try at most 1000 times, then accept whatever is there

frame_stack(1).length = 0;
frame_stack(1).points = zeros((point_num + 3 * point_num_dev), 4);

bound_angle1 = 0.5 * pi;
bound_angle2 = -pi / 6;
bound_angle3 = -pi * 5 / 6;


for i = 1 : frame_num 
    
    % First, try to generate within the source circle new point features.
    % Generate no more than the number specified by 

    
    % New point feature generation 
    trial_num = 0;
    new_pt_num = 0;
    
    fprintf('start new frame generation.\n');
    while ((trial_num < total_trial_num) & (new_pt_num < max_new_pt_num))
        theta = rand(1) * pi * 2;
        new_point = rand(1) * kernel_radius * [sin(theta); cos(theta)] + image_center;
        
        % check for distance from existing points
        
        frame_pt_list_ptr = 1;
        accept_flag = 1;
        while (frame_pt_list_ptr <= frame_stack(i).length)
            dist = (new_point(1) - frame_stack(i).points(frame_pt_list_ptr, 1))^2 +...
                (new_point(2) - frame_stack(i).points(frame_pt_list_ptr, 2))^2;
            dist = sqrt(dist);
            
            if (dist < min_dist)
                accept_flag = 0;  % rejected
                break;
            end
            frame_pt_list_ptr = frame_pt_list_ptr + 1;
        end
        
        if (accept_flag == 1) % accepted
            frame_stack(i).length = frame_stack(i).length + 1;
            frame_stack(i).points(frame_stack(i).length, 1) = new_point(1);
            frame_stack(i).points(frame_stack(i).length, 2) = new_point(2);
            new_pt_num = new_pt_num + 1;
        end
        
        trial_num = trial_num + 1;
    end
    fprintf('new frame generation is done.\n');

    
    % Point feature propagation
    
    fprintf('Starting frame updata.\n');
    frame_stack(i + 1).length = 0;
    frame_stack(i + 1).points = zeros((point_num + 3 * point_num_dev), 4);

    if (i < frame_num) % skip propagation for the last frame
        
        for j = 1 : frame_stack(i).length
            current_point = [frame_stack(i).points(j,1);
                             frame_stack(i).points(j,2)];
                         
            vec_from_center = current_point - image_center;
            angle_from_center = atan2(vec_from_center(1), vec_from_center(2));
            
            if (angle_from_center >= bound_angle2) & (angle_from_center <= bound_angle1)
                temp_theta = vec_field(1).angle + (rand(1) - 0.5) * 60 / 180 * pi;
                temp_pt = current_point + (vec_field(1).mag + rand(1) * disp_perturb_mag)* [sin(temp_theta); cos(temp_theta)];
                
                if ((temp_pt(1) > 0.5 ) & (temp_pt(1) < image_height) & (temp_pt(2) > 0.5) & (temp_pt(2) < image_width))
                    frame_stack(i+1).length = frame_stack(i+1).length + 1;
                    frame_stack(i+1).points(frame_stack(i+1).length, 1) = temp_pt(1);
                    frame_stack(i+1).points(frame_stack(i+1).length, 2) = temp_pt(2);
                end

            end
            
            if (angle_from_center >= bound_angle1) | (angle_from_center <= bound_angle3)
                
                temp_theta = vec_field(2).angle + (rand(1) -0.5) * 60 / 180 * pi;
                temp_pt = current_point + (vec_field(2).mag + rand(1) * disp_perturb_mag) * [sin(temp_theta); cos(temp_theta)];

                
                if ((temp_pt(1) > 0.5 ) & (temp_pt(1) < image_height) & (temp_pt(2) > 0.5) & (temp_pt(2) < image_width))
                    frame_stack(i+1).length = frame_stack(i+1).length + 1;
                    frame_stack(i+1).points(frame_stack(i+1).length, 1) = temp_pt(1);
                    frame_stack(i+1).points(frame_stack(i+1).length, 2) = temp_pt(2);
                end
            end
            
            if (angle_from_center <= bound_angle2) & (angle_from_center > bound_angle3)
                
                temp_theta = vec_field(3).angle + (rand(1) -0.5) * 60 / 180 * pi;
                temp_pt = current_point + (vec_field(3).mag + rand(1) * disp_perturb_mag) * [sin(temp_theta); cos(temp_theta)];
                
                if ((temp_pt(1) > 0.5 ) & (temp_pt(1) < image_height) & (temp_pt(2) > 0.5) & (temp_pt(2) < image_width))
                    frame_stack(i+1).length = frame_stack(i+1).length + 1;
                    frame_stack(i+1).points(frame_stack(i+1).length, 1) = temp_pt(1);
                    frame_stack(i+1).points(frame_stack(i+1).length, 2) = temp_pt(2);
                end
            end
        end
    end
    
    fprintf('Generation of frame %d is done.\n', i);
end % now closing the big for-loop        
fprintf('Frame stack generation is done.\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  End of Step 1.2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


frame1_pos.pos = frame_stack(1).points(1:frame_stack(1).length,1:2);
frame2_pos.pos = frame_stack(2).points(1:frame_stack(2).length,1:2);
frame3_pos.pos = frame_stack(3).points(1:frame_stack(3).length,1:2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  End of Step 1.2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Step 2: Generate a color image and take a visual check

%pause;
image_stack = uint8(zeros(image_height, image_width, 3, frame_num));
temp_image = ones(image_height, image_width, 3);

filename = 'MBtraj_001.txt';

fid = fopen(filename, 'wt');

for i = 1 : frame_num

    temp_image (1:image_height, 1:image_width, 1:3) = 0;
    printed_points =0;
    
    speckle_size_half = 1;
    for j = 1 : frame_stack(i).length
        temp_center = round(frame_stack(i).points(j, 1:2));
        
        if ((temp_center(1) > 2) & (temp_center(1) < image_height - 2) & (temp_center(2) > 2) & (temp_center(2) < image_width -2))     
            temp_image(temp_center(1) - speckle_size_half : temp_center(1) + speckle_size_half,... 
            temp_center(2) - speckle_size_half : temp_center(2) + speckle_size_half, 2) = 255;  % use green to represent general points
        end
    
        fprintf(fid,' (');
        fprintf(fid, '%10.6f %10.6f', temp_center(2), temp_center(1));
        fprintf(fid,')');
        printed_points = printed_points + 1;
        
        if (printed_points == 10)
                fprintf(fid,' \n');
                printed_points = 0;
        end
    end
    fprintf(fid,' .\n');
    image_stack(:,:,:,i) = uint8(temp_image);
    %size(temp_image)
    %fprintf('Frame %d is added to the movie.\n', i);
end

fclose(fid);
fprintf('File %s has been generated.\n', filename);


movie_temp = immovie(image_stack);
fprintf('Please press enter to start to play the movie.\n');
pause;

axis off;
movie(movie_temp,5,5);

hold on