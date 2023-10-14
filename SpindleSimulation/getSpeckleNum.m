function ptNum = getSpeckleNum(start_path)

candsPath = strcat(uigetdir(start_path, 'Please choose the directory for the cands files.'), '\');

startID = 51;
endID = 90;
total_frame_num = endID - startID + 1;

MAX_SPECKLE_NUM = 3000;  % This is mainly for allocation of memory.

ptNum = [];

h = waitbar(0, 'Reading speckle data files, Please wait...');
im_base = startID; % This provides an offset so that it is not necessary to have to start from the first frame.
for i = 1 : (endID - startID + 1)
    if ((i + im_base - 1) < 10)
        cands_name = strcat(candsPath, 'cands00', num2str(i + im_base - 1),'.mat');
    elseif ((i + im_base - 1) <100)
        cands_name = strcat(candsPath, 'cands0', num2str(i + im_base - 1),'.mat');
    else
        cands_name = strcat(candsPath, 'cands', num2str(i + im_base - 1),'.mat');
    end
    
    temp1 = load(cands_name);
    cands_dim = size(temp1.cands);
    frame_speckle(i) =  struct('length', 0, 'coordinate', zeros(MAX_SPECKLE_NUM, 3), 'total_lmax_num', 0, 'typeone_num', 0, 'typetwo_num',0, 'typethree_num', 0);
    
    for j = 1 : cands_dim(2)
        if (temp1.cands(j).status == 1)   % only consider primary speckles
            frame_speckle(i).length = frame_speckle(i).length + 1;
        end
    end
    ptNum = [ptNum; frame_speckle(i).length];
    waitbar(i / (endID - startID + 1), h);
end
close(h);
fprintf('Speckle numbers have been computed.\n');

