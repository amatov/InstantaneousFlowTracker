function [links,flow,mxNbTri2,listTriO2,Xo2,angVo,deltaDvO] = tft(I,J,K,dist,w1,w2,w3,nbTri,nbArcs,capaVec,demaVec,A,F1,F2,F3,mxNbTri2,costAdd)

% tft is the main function of the three frame tracker
%
% SYNOPSIS   links = tft(I,J,K,dist)
%
% INPUT      I    :   list of coordinates in the first frame [y0,x0]
%            J    :   list of coordinates in the second frame [y1,x1]
%            K    :   list of coordinates in the third frame [y2,x2]
%            dist :   searching radius
% 
% OUPUT      links:   the raw links of the triplets [yo xo y1 x1 y2 x2]
%            flow :   optimal flow thru this graph
%
% DEPENDENCES   tft uses { coreTFT }
%               tft is used by { fsmTrackMain }
%
% Alexandre Matov June 19th 2004


% The code in this function has been omitted for proprietary reasons.