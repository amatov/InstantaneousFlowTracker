# Environment / Requirements

This is legacy Matlab + C/C++ research code developed and tested primarily
on Windows between roughly 2003 and 2013. There is no automated build or
dependency-management system (no `requirements.txt` / package manager) --
this file lists what you need to install and set up yourself.

## Matlab

- The code was developed against Matlab releases from the 2000s-2010s era
  (exact version not recorded). Functions using `find`, `struct`, `imread`,
  `imshow`, `hist`, `uigetfile`, and `inputdlg` are used throughout, so any
  reasonably recent Matlab with the **Image Processing Toolbox** should be
  able to load the `.m` files, though some syntax may trigger deprecation
  warnings on modern Matlab releases.
- No `.mlx`/live-script files; everything is plain `.m` script/function
  files.

## Optimization solver (required for the actual flow-tracking step)

The three-frame triplet-selection step is a 3-dimensional matching
problem, which is NP-hard, not a min-cost flow problem: its LP relaxation
is not integral, so a flow solver settles on a fractional solution
instead of the integer, all-or-nothing triplet selection this step needs.
Conversely, an MIP solver (CPLEX by ILOG/IBM, or TOMLAB) can enforce that
integer solution. The pipeline depends on **one** of the following
commercial solvers, each requiring its own paid license:

- **IBM ILOG CPLEX** -- used by the current/final version of the pipeline,
  in `IFTA_CPLEX/` (the "Cplex" functions,
  e.g. `MaxFlowCplexVersionTrunc.m`, `MaxFlowMinCostCplexVersionTrunc.m`).
  This replaced the TOMLAB wrapper in 2013.
- **TOMLAB** -- used by the earlier version of the pipeline. TOMLAB itself
  wraps a solver (e.g. CPLEX) via its own Matlab interface.

Neither CPLEX nor TOMLAB is included in this repository; you must install
and license one yourself and make sure its Matlab interface is on your
Matlab path.

## C/C++ components

The `mincost/`, `mincostCPP/`, `mincostDLL/`, `COSTexe/`, and
`GoldbergMaxFlow/` folders contain C/C++ implementations of max-flow /
min-cost solvers used for testing and comparison (not the production
pipeline -- see README.md "Repository contents"). Precompiled Windows
binaries for these are kept under `binaries/` (mirroring the original
folder layout) if you don't want to rebuild them; to rebuild from source
on Windows you'll need Visual C++ (the `.dsp`/`.dsw`/`.sln`/`.vcproj` files
are old Visual Studio project files); each folder's `Makefile` may also
work under MinGW/Cygwin/WSL, but this has not been verified on Linux/macOS.

## MEX files

Some `.m` files (e.g. `createDistanceMatrix.m`) call into compiled MEX
files (`.mexw64`, `.mexglx`). The precompiled MEX binaries under
`binaries/` are Windows/Linux-specific (32-bit `.mexglx` is for a very old
Linux/Matlab combination); on a modern platform you will need to recompile
the corresponding `.c`/`.cpp` source with `mex` yourself.

## What's NOT required

`SIFT_Detector/`, `SpindleSimulation/`, and
`emClustering_Modified_Circular/` are self-contained Matlab code with no
external solver dependency.
