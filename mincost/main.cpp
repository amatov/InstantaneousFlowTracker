// This is the main function of the mincost.dll according to
// Matlab specifications

#include <mex.h>
#include "Array.h"
#include "Tracker.h"

void errorMsg(char* message) {
  mexErrMsgTxt(message);
}

void trackspeckle(Array<double>& asiout,
                  Array<double>& asifirst,
                  Array<double>& asisecond,
                  double *flow, int rowx, int rowy,
                  double *indCostFun, int nmbParams,
                  Array<double>& allcosts, Array<double>& costs, Array<double>& maxflow);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  // Initialize pointers
  double *x, *y, *z, *flow;

  int	mrowsX, ncolsX, mrowsY, ncolsY;

  // Check for input number
  if (nrhs != 4) {
    mexErrMsgTxt("The function requires 4 inputs.");
  }

  // Dimensions of the input
  mrowsX = mxGetM(prhs[0]);
  ncolsX = mxGetN(prhs[0]);
  mrowsY = mxGetM(prhs[1]);
  ncolsY = mxGetN(prhs[1]);

  int nbLinks = (mrowsX < mrowsY ? mrowsX : mrowsY);

  // Create matrix for the return argument
  plhs[0] = mxCreateDoubleMatrix(2, nbLinks * 4, mxREAL);

  // matrix returns all the costs
  plhs[1] = mxCreateDoubleMatrix(1, nbLinks * 4, mxREAL); //used to be *4

  // matrix returns the costs of the solution
  plhs[2] = mxCreateDoubleMatrix(1, nbLinks, mxREAL);

  // matrix returns the max flow
  plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);

  // Assign pointers to each input and output
  x = mxGetPr(prhs[0]);
  y = mxGetPr(prhs[1]);
  flow = mxGetPr(prhs[2]);

  int mrowsZ = mxGetM(plhs[0]);
  int ncolsZ = mxGetN(plhs[0]);
  z = mxGetPr(plhs[0]);

  Array<double> asifirst(x,ncolsX*mrowsX),
  asisecond(y,ncolsY*mrowsY),
  asiout(ncolsZ*mrowsZ);

  Array<double> allcosts(nbLinks*4), costs(nbLinks), maxflow(1);

  // Extract the index of the cost function as the 4th parameter of the DLL
  double *indCostFun = mxGetPr(prhs[3]);

  // call tracker
  //   trackspeckle(asiout, asifirst, asisecond,
  // 	  flow, mrowsX, mrowsY, indCostFun, mxGetM(prhs[3])*mxGetN(prhs[3]),
  // 	  allcosts, costs, maxflow);


  Tracker myTracker(asifirst, asisecond, asiout, allcosts, costs);
  myTracker.trackspeckle((double*) 0, mrowsX, mrowsY, indCostFun, 1, maxflow);

  myTracker.asiout.copyTo(z);
  myTracker.allcosts.copyTo(mxGetPr(plhs[1]));
  myTracker.costs.copyTo(mxGetPr(plhs[2]));
  maxflow.copyTo(mxGetPr(plhs[3]));
} // void mexFunction



