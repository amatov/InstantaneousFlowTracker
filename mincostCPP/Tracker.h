#ifndef __TRACKER_H
#define __TRACKER_H

#include "Array.h"
#include "graphstruct.h"
#include "costFunctions.h"

//############################################################################

class Tracker {

  int returnsink;
  int returnsource;
  int reporter;

  map<int,EDGE *> rememberST;
  map<int,string> remembertemp;

public:
  typedef SparseMultiGRAPH<EDGE> TGraph;
  typedef Array<double> DArray;

  DArray& asiout, allcosts, costs;

  Tracker(DArray& a1, DArray& a2, DArray& a0, DArray& ac, DArray& c)
    : asifirst(a1), asisecond(a2), asiout(a0), allcosts(ac), costs(c),
    G(50000), edges(50000)
    {
      edgeCount = 0;
   };

  ~Tracker();

  void trackspeckle(double *flow, int rowx, int rowy,
                    double *indCostFun, int nmbParams,
                    DArray& maxflow);

protected:
  DArray& asifirst, asisecond;

  // the graph object used for the maxflow analysis
  TGraph G;

  void scanMatlab(int lz1, int lz2, double *indCostFun, int nmbParams);

  void generateGoldbergGraph();

  void print_solution(node *ndp, arc *arp, long nmin);

  int edgeCount;
  Array<EDGE*> edges;

  long ggN, ggM, ggMinNode;
  node* ggNodes;
  arc* ggArcs;
  double ggMaxArcCost;
  long* ggCap;

};

//############################################################################

#endif

