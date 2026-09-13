# Examples

## `sample_data/` -- synthetic smoke-test input

`cands01.mat`, `cands02.mat`, `cands03.mat` are small, synthetically
generated particle-detection files (60 particles converging toward a
central point over 3 frames, mimicking a monopole-like flux pattern), in
the same struct format (`cands(i).Lmax`, `cands(i).status`) that
`flowTest.m` / `andreaTest.m` / `testFlowTracker.m` expect as input.
`sample_frame01.tif` is a small synthetic grayscale image for the same
purpose. None of this is real microscopy data -- it exists only so a new
user has *something* to point the loading/plumbing code at without first
needing their own dataset.

## `run_demo.m` -- what it actually verifies

Run `run_demo.m` from Matlab after adding the repository root to your
path. It calls `testFlowTracker()` with the sample data above.

**Read this before you run it:** the core tracking/optimization function
(`flowTracker`, defined in `flowTrackerTrunc.m`) and the `Gauss2D` helper
it depends on are **not included in this repository** -- their
implementations were intentionally omitted for proprietary reasons (see
the root `README.md`, "Repository contents" section). This is true of
every file in this repo ending in `Trunc.m`.

That means `run_demo.m` cannot produce a real tracked-flow result as-is.
What it *does* verify is that:
- your Matlab installation can load this repository's `.m` files without
  syntax errors,
- the Image Processing Toolbox functions used here (`imread`, etc.) are
  available,
- the sample data loads and reaches the tracking call correctly.

If you have your own copy of the full (non-omitted) core implementation,
drop it in and `run_demo.m` should run all the way through and produce a
tracked vector field, comparable in nature (not exact values, since the
input is synthetic) to the real published output in `figures/`.

## `figures/` -- real published output, for reference

Three figures from actual published/prepared results, included so you can
see what correct tracker output looks like on real data, even though this
repository alone cannot reproduce them (see above). See
`figures/README.md` for what each one shows.
