#ifndef __COST_FUNCTIONS_H
#define __COST_FUNCTIONS_H

//############################################################################

// the type of pointer to cost function
typedef double (*costFunType)
(double x1, double y1, double x2, double y2, double x3, double y3,
 double i1, double i2, double i3, double *Params, int nmbParams);

// the original cost function
double cost1(double x1, double y1, double x2, double y2, double x3, double y3,
             double i1, double i2, double i3, double *Params, int nmbParams);

//############################################################################

#endif

