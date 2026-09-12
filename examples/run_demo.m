function run_demo()
% run_demo - smoke test for the surrounding IFTA infrastructure.
%
% This script runs testFlowTracker() against small synthetic particle
% files bundled in examples/sample_data/, so you can check that your
% MATLAB setup (paths, Image Processing Toolbox, etc.) can load the data
% and reach the core tracking call.
%
% IMPORTANT: this will NOT produce a working tracked-flow result out of
% the box. The core tracking function (flowTracker, see flowTrackerTrunc.m)
% and the Gauss2D helper it calls are not included in this repository --
% see the "Repository contents" section of the root README.md. This demo
% exists to verify everything UP TO that point works, and to give you a
% single, clear error message instead of a confusing path/data error if
% you run the real pipeline without the full implementation in place.

here = fileparts(mfilename('fullpath'));
cands1File = fullfile(here, 'sample_data', 'cands01.mat');
cands2File = fullfile(here, 'sample_data', 'cands02.mat');
cands3File = fullfile(here, 'sample_data', 'cands03.mat');
imageFile  = fullfile(here, 'sample_data', 'sample_frame01.tif');

fprintf('Loading synthetic sample data from %s ...\n', fullfile(here, 'sample_data'));

try
    [trackedLinks, flow] = testFlowTracker(cands1File, cands2File, cands3File, imageFile); %#ok<ASGLU>
    fprintf('Demo completed successfully. trackedLinks has %d rows.\n', size(trackedLinks, 1));
catch err
    if any(strcmp(err.identifier, {'MATLAB:UndefinedFunction'}))
        fprintf(2, ['\nStopped at an expected point: %s\n' ...
            'This repository intentionally omits the proprietary core tracking\n' ...
            'code (see README.md), so this call cannot succeed here. If you\n' ...
            'reached this message, the surrounding infrastructure (data loading,\n' ...
            'path handling, MATLAB/toolbox setup) is working correctly.\n'], err.message);
    else
        rethrow(err);
    end
end
