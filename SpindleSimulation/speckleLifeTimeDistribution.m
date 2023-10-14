function lifeTime = speckleLifeTimeDistribution(paramSetting, generatorSeed, length)
% The objective of this function is to implement several models of lifetime
% distribution for various applications, especially the simulation of
% spindles.

% parameterSetting = struct('option', 0, 'mean', 0, 'std', 0);

% Option 1: Gauss distribution, i.e. assuming that the lifetime of a
% speckle follows gauss distribution.

switch paramSetting.option
    case 1 % exponential distribution
        rand('state', generatorSeed);
        lifeTime = exprnd(paramSetting.mean, length, 1);
    case 2 % possion distribution
        rand('state', generatorSeed);
        randn('state', generatorSeed + 379127);
        lifeTime = poissrnd(paramSetting.mean, length, 1);
    case 3
        rand('state', generatorSeed);
        lifeTime = wblrnd(paramSetting.mean, 2, length, 1);
    case 4 % gauss distribution
        rand('state', generatorSeed);
        lifeTime = randn(length, 1) * paramSetting.mean + paramSetting.std;
    otherwise
        ;
end

    
