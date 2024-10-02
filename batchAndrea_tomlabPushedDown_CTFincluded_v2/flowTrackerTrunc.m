function [links,flow,cluster_index,bestmu,flowMap,dir] = flowTracker(frames,dist,w1,w2,w3,nbDir,iterations,firstF,nbWindows,RAK_ANGLE)

% flowTrack is the main function of the flow tracker
%
% SYNOPSIS   [links,flow,cluster_index,bestmu,flowMap,dir] = flowTrack(I,J,K,dist,w1,w2,w3,nbDir,iter,firstF,nbWindows)
%
% INPUT      I    :   list of coordinates in the first frame [y0,x0]
%            J    :   list of coordinates in the second frame [y1,x1]
%            K    :   list of coordinates in the third frame [y2,x2]
%            dist :   searching radius
%            w1   :   weight of the angle between segments
%            w2   :   weight of the difference of length between segments
%            w3   :   weight of the angle between triplets and the global motion
%            nbDir:   number of directions of the flow fields
%            iterations :   number of iteration during weight optimization
%            nbWindows:number of times frames of accumulation of links
%            firstF:  first time frame to be considered
%
% OUPUT      links:   the raw links of the triplets [yo xo y1 x1 y2 x2]
%            flow :   optimal flow thru this graph (scalar)
%            cluter_index: clustering index for each triplet
%            bestmu:  angles of directions of the clusters
%            flowMap: filtered links [y0 x0 y1 x1]
%            dir  :
%
% Alexandre Matov September 26th 2005

% The code in this function has been omitted for proprietary reasons.