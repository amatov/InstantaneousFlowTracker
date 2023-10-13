#include <math.h>

#include "costFunctions.h"


double sqr(double x) {
  return x*x;
}


// separated cost function
double cost1(double x1, double y1, double x2, double y2, double x3, double y3,
	     double i1, double i2, double i3, double *Params, int nmbParams)
{
  
  //first, calculate the smoothness of the trajectory t1, t2, t3
  //considered to calculate costs
  double dx1 = x2 - x1;
  double dy1 = y2 - y1;
  double dx2 = x3 - x2;
  double dy2 = y3 - y2;

  //most probable distance travelled from frame to frame here,2
  double d1 = sqrt(dx1*dx1 + dy1*dy1);
  double d2 = sqrt(dx2*dx2 + dy2*dy2);

  //a priori jump size:3, stddev:5
  double pl1 = exp(-sqr((d1-3.0)/5.0));
  double pl2 = exp(-sqr((d2-3.0)/5.0));
  double pl = pl1 * pl2;

  double anglecij  = (dx1*dx2 + dy1*dy2) / (d1 * d2);
  double lengthcij = sqrt(d1 * d2) / (d1 + d2);

  double meanI = (i1 + i2 + i3) / 3.0;
  double stddevI = sqrt(sqr(i1 - meanI) + sqr(i2 - meanI) + sqr(i3 - meanI));
  double costI = stddevI / meanI;

  //cij is a cost function increasing with bad matches
  double cij = 0.6*(1-anglecij) + 0.4*(1-2*lengthcij) + 0.2*costI;

  return cij / 1.15; // !!!

} // double cost (......)

