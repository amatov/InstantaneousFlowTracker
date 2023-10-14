function num = activeTrackNum(track, frameID)

num = 0;

temp = max(size(track));

for i  = 1 : temp
    if track(i). status == 1
        num = num + 1;
    end
end

trackNum = max(size(track));
frameLen = zeros(i, 1);

for k = 1 : trackNum
    for j = 1 : track(k).len
        tempIndex = track(k).startID + j - 1;
        id = round(tempIndex);
        if (id > frameID)
            fprintf('Error.\n');
        end
        frameLen(id)= frameLen(id) + 1;
    end
end

% for k = 1 : frameID
%     fprintf('Frame %d has %d points.\n', k, frameLen(k));
% end

