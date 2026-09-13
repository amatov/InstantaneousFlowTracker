### IFTA

The code I wrote for the software modules of the Instantaneous Flow Tracking Algorithm (IFTA) is in C++ and Matlab.

## Quick start

1. **Requirements:** MATLAB with the Image Processing Toolbox, plus a
   licensed installation of **IBM ILOG CPLEX** (or TOMLAB, for the older
   code path) for the optimization step. See [ENVIRONMENT.md](ENVIRONMENT.md)
   for details.
2. **Which folder to use:** the working pipeline is
   [`IFTA_CPLEX/`](IFTA_CPLEX/)
   (CPLEX-based, current since 2013). `MaxFlow/`, `GoldbergMaxFlow/`,
   `mincost/`, `mincostCPP/`, `mincostDLL/`, and `COSTexe/` are earlier
   test/comparison solver implementations, kept for reference -- they are
   not part of the working pipeline. See "Repository contents" below.
3. **Try it:** run [`examples/run_demo.m`](examples/run_demo.m) in MATLAB.
   It exercises the data-loading/plotting infrastructure against small
   synthetic sample data in `examples/sample_data/`. **Read
   [`examples/README.md`](examples/README.md) first** -- the core tracking
   function is intentionally not included in this repository (see below),
   so the demo verifies your setup, not the full algorithm.
4. Reference figures showing real IFTA output are in
   [`examples/figures/`](examples/figures/).

## Repository contents

- **Proprietary core omitted:** every file whose name ends in `Trunc.m`
  (e.g. `flowTrackerTrunc.m`, `flowTrackTrunc.m`, `tftTrunc.m`,
  `buildGraphTrunc.m`, `MaxFlowMinCostTrunc.m`, `biObjectFlowTrunc.m`,
  `costaTrunc.m`, `costaaTrunc.m`, `coFunTrunc.m`, and their `*1Trunc.m` /
  `*CplexVersionTrunc.m` variants) contains only a function signature and
  docstring -- the actual implementation has been intentionally omitted
  from this public repository for proprietary reasons. This means the
  scripts that call them (e.g. `flowTest.m` calling `flowTracker`) will
  raise an "undefined function" error at that point when run as-is. This
  is expected, not a bug.
- **Alternative/test solver implementations:** `MaxFlow/`
  (Kolmogorov-Boykov), `GoldbergMaxFlow/` (Goldberg, via Rothberg),
  `mincost/` / `mincostCPP/` / `mincostDLL/` / `COSTexe/`
  (Sedgewick-based, adapted by Pascal Vallotton and Alexandre Matov) were
  all evaluated during development. The pipeline that was actually used
  for published results switched from a **TOMLAB** wrapper to a direct
  **IBM ILOG CPLEX** call in 2013 (see point 8 below); the other solver
  folders are kept for reference/comparison only.
- **`binaries/`** -- precompiled Windows binaries (`.dll`, `.exe`,
  `.mexw64`, and MSVC build artifacts) for the C/C++ components.
- **`media/`** -- supplementary videos, images, and publication PDFs that
  were previously in the repository root.
- **`examples/`** -- synthetic sample input data and a demo script for
  smoke-testing your setup, plus reference figures of real published
  output. See [`examples/README.md`](examples/README.md).
- **License:** see [LICENSE](LICENSE) -- research/educational use, with
  separate terms noted for bundled third-party components.

## About

Published papers in which the IFTA was applied for data analysis, starting in the summer of 2004 when I completed all software modules and wrote the manuscript:

1) Computer Vision and Pattern Recognition (CVPR) 2005 (see Figures 4-6 and Table 1 - IFTA improved the success rate of a linear Kalman filter from 61.1% to 96.0% in four iterations) https://researchgate.net/publication/224625167_Reliable_tracking_of_large_scale_dense_antiparallel_particle_motion_for_fluorescence_live_cell_imaging

2) Journal of Cell Biology (JCB) 2006 (IFTA initialized the linear Kalman filter and computed the overlapped flows for tracking - see section "Speckle tracking and data analysis") https://rupress.org/jcb/article/173/2/173/44281/Kinesin-5-independent-poleward-flux-of-kinetochore

3) Nature Cell Biology (NCB) 2007 (IFTA initialized the linear Kalman filter and computed the overlapped flows for tracking - see section "Measurement of speckle intensity") https://www.nature.com/articles/ncb1643

4) Journal of Cell Biology (JCB) 2008 (IFTA initialized the linear Kalman filter and computed the overlapped flows for tracking - see Figures 1B and 1C) https://rupress.org/jcb/article/182/4/631/45381/Regional-variation-of-microtubule-flux-reveals

5) Current Biology 2009 (IFTA initialized the linear Kalman filter and computed the overlapped flows for tracking - see section "Determination of monopole size by EB1 tracking") https://www.cell.com/current-biology/fulltext/S0960-9822(09)00627-7?_returnURL=https%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS0960982209006277%3Fshowall%3Dtrue

6) Journal of Cell Biology (JCB) 2010 (IFTA computed spindle flows in rotating spindles; see mitotic spindle flow tracking in Figure S1) http://dx.doi.org/10.13140/RG.2.2.17118.41283 "Directly probing the mechanical properties of the spindle and its matrix", see a 6-min Podcast: https://youtu.be/rF3mNr4l4XU?t=43

7) Computer Vision and Image Understanding (CVIU) 2011 (the IFTA methodology paper - see Figures 1-5) https://researchgate.net/publication/51458935_Optimal-flow_minimum-cost_correspondence_assignment_in_particle_flow_tracking_Instantaneous_Flow_Tracker

8) Convention of Electrical and Electronics Engineers in Israel (IEEEI) 2012 (IFTA applications to crowd monitoring and surveillance) https://www.academia.edu/61280387/2012_IEEE_27_th_Convention_of_Electrical_and_Electronics_Engineers_in_Israel (Eilat, Paper #153) "Analysis of Unstructured Crowded Scenes: Instantaneous Flow Tracking Algorithm Applied to Surveillance" Alex Matov and Nino Marina (accepted paper)

See my presentation in 2013 at [CRCV](https://crcv.ucf.edu) of IFTA and its applications: https://youtube.com/watch?v=kTYyltX9RFg

See videos of a similar product here: https://lnkd.in/gHxqxMXe (4 movie files)

In 2013, I replaced the TOMLAB Optimization wrapper with a direct call to the ILOG CPLEX solver, and this code is available at: https://github.com/amatov/InstantaneousFlowTracker/tree/main/IFTA_CPLEX

## Analysis of Unstructured High-Density Crowded Scenes for Video Surveillance and Crowd Monitoring

Computer vision algorithms can extract information from videos of crowded scenes and automatically track groups of individuals undergoing organized motion, which might represent anomalous behavior. Computational tools and applied mathematics are indispensable for automated image analysis of human crowds, where information about changes in pixel intensity is translated into particle tracks used to detect rapid changes in crowd dynamics. 

I proposed to use the existing infrastructure of video cameras for collecting images and develop an innovative software system for parsing of significant events by analyzing image sequences taken inside and outside of sports stadia. 

**My specific aims would be:** 1. Design and implement software for automated human detection and use our existing image analysis algorithms for human tracking in crowded scenes. 2. Develop novel computer vision algorithms for classification of motion patterns and anomalous motion identification in video surveillance. 

My existing optimal-cost algorithm has been improved by optimizing the objective function and applying Markov Random Field to sparse datasets. The feature selection is based on detectors such as SIFT, SURF, or ORB. To compute circular expectation maximization, the assignment uses a mixture of von Mises distributions. The weights of the Pareto optimality multi-objective function are based on Bayesian statistics, which makes the algorithm self-adaptive with rapid convergence within several iterations. 

An implementation with robotics computer vision libraries allows for real-time analysis on-the-fly. I aim at developing a system which can reliably analyze the behavior of up to 200,000 people and vehicles located inside and in the surroundings of a large stadium. My goal is to create a fully automated accident aversion system, which detects anomalous behaviors in real time as events are progressing. 

**Rationale:** Video cameras monitoring the activity of people around sports venues are commonplace in cities worldwide. At sports games, where crowds of tens of thousands gather, such monitoring is important for safety and security purposes. It is also challenging to automate. Human operators are generally employed for the task, but even the most vigilant individuals may fail to see important information that could ultimately signal the onset of a potentially dangerous situation, such as the overcrowding of a sector of the stadium. 

My research efforts have been focused on the development of systems that provide the security personnel, on-the-fly, with automatedly generated alert signal regarding rapid motion of groups of individuals or events of interest in crowded scenes. The system would offer crowd density estimation and prediction of overcrowding at a parking lot and the gates outside as well as within the stadium. 

My system would, further, be able to detect, in real time, when small groups of fans are about to confront each other and predict the place of their clash prior to the actual confrontation by calculating the speed and direction of motion of the opposing groups by extrapolating the intersection coordinates based on only three to four consecutive live feed images. 

**Significance:** I apply computer vision methods to capture organized movement of groups of spectators in crowded scenes. Tracking in unstructured crowded scenes has gained momentum in computer vision for the surveillance of human or vehicle motion in vulnerable public areas such as stadiums, airports, train stations or roads. My approach offers a high-speed solution allowing real-time tracking. Thus, it could be used to predict on-the-fly anomalous behaviors or congestions associated with a security alert outside or within a sports stadium, an airport terminal or with the arrival of a new train in a highly frequented station. 

This project would generate novel technology, which can be used to analyze live videos of conflict situations at different types of sports stadia, e.g., for association football (soccer), American football, and baseball. Furthermore, I envisage additional applications such as using the technology to detect dangerous behaviors at airports, train stations, political rallies, mass demonstrations, music festivals, large chain stores, busy resorts, among a number of other important security applications. 

I would develop software applications for various platforms and devices, such as CCTV camera systems, smartphones (iOS/Android) as well as smart glasses (Vive/HoloLens). My technology can be made available as a software as a service (SaaS) through a web interface, where additional algorithmic modules, including video-tagging of spectators, for the analysis of live images with specific types of motion from live cameras or other imaging methods can be continuously added.

For detailed information, see: https://www.researchgate.net/publication/390301493_Analysis_of_Unstructured_High-Density_Crowded_Scenes_for_Crowd_Monitoring

See also: https://www.frontiersin.org/journals/cell-and-developmental-biology/articles/10.3389/fcell.2025.1681065/full
