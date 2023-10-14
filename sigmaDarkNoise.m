function Rsig=sigmaDarkNoise(S)

% sigmaDarkNoise calculates the decrease in the level of dark noise in an
% image in case of filtering with sigma higher than one
%
%
% SYNOPSIS   [frGR,bgGR]=imageSegmentation(DEBUG)
%
% INPUT      S       : the second sigma
%
% OUTPUT     Rsig    : the coefficient of reduction of the dark noise 
%                      because of filtering with higher than one sigma 
%
% DEPENDENCES   sigmaDarkNoise uses { }
%               sigmaDarkNoise is used by { }
%
% Alexandre Matov, Janunary 7th, 2003

A=randn(500);
B=gauss2d(A,1);
C=gauss2d(A,S);
D=B-C;

% the coefficient of reduction of the dark noise because of filtering with higher than one sigma 
Rsig=std(A(:))/std(D(:));

