# Reference figures: what correct IFTA output looks like

These are examples of real IFTA tracking output, included so a user can
visually compare their own run's vector-field output against known-correct
results. They are not reproducible from this repository alone, since the
core tracking implementation is not included here (see the root
`README.md` and `examples/README.md`).

## `Figure1_MonopoleAndRotatingSpindle.pdf`

Speckle flux tracking in mitotic spindles.
- **A-B:** Flux vectors in a monopolar spindle, shown at a single
  time-point (A) and accumulated over a full movie (B, inset), color-coded
  by direction (red/yellow).
- **C:** Flux vectors in individual kinetochore fibers near a spindle
  pole, at a single time-point.
- **D:** Histogram of speckle flux rate (µm/min) for the monopole,
  accumulated over the full movie.
- **E-F:** Flux vectors in a rotating spindle at a single time-point (E,
  with red/yellow arrows indicating the two opposing flow directions), and
  the corresponding bimodal histogram of flux rates for the two
  populations (F).

## `Figure2_LamellipodialConeNeckFlow.pdf`

Actin speckle flux in a lamellipodial "cone" structure.
- **A:** Flux vectors across a cell edge region, with an inset showing
  vectors over the full cell.
- **B:** Flux vectors near the cone's "neck," with red/yellow arrows
  indicating flow toward the neck vs. exiting the cone.
- **C:** Histogram of speckle flux rate, split into vectors moving toward
  the cone neck (red) vs. exiting the cone (yellow), and overlaid with all
  vectors at a single time-point.

## `Figure3_AnterogradeRetrogradeActinFlow.pdf`

Overlapping anterograde/retrograde actin flows -- the "four overlapped
flows" case that motivated IFTA (conventional single-direction trackers
fail here).
- **A, C:** Flux vectors across two different cell regions, each showing
  multiple, spatially overlapping flow populations (color-coded), with
  insets showing the raw/simplified vector field.
- **B, D:** Corresponding histograms of speckle flux rate, decomposed into
  the separate anterograde and retrograde populations (two of each, in B)
  identified by IFTA within the same overlapping region.

These correspond to the kind of "highly dynamic, anti-parallel networks
where previous methods failed" described in the repository description --
i.e., exactly the case IFTA was designed to solve.
