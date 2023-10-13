#include <iostream>
#include <string>

#include "structs.h"
#include "graphstruct.h"
#include "goldberg.h"

#include "costFunctions.h"
#include "Array.h"

#include "Tracker.h"

// number of cost functions to choose from (change accordingly)
const int nmbCostFuncts = 1;

// an array of cost function pointers
static const costFunType coFunctions[nmbCostFuncts] = { cost1 };

//##############################################################################
// Destructor

Tracker::~Tracker() {
  for (int i = 0; i < edgeCount; i++)
    delete edges[i];
}

//############################################################################
// Construct a [Sedgewick] graph from the initial data

void Tracker::scanMatlab(int lz1, int lz2, double *indCostFun, int nmbParams) {

  int x1, y1, x2, y2, x2a, y2a, x3, y3, int1, int2, int2a, int3;

  ST st;

  int indexCo = (int)indCostFun[0];
  if (indexCo < 0 || indexCo >= nmbCostFuncts) {
    char *errMsg[50];
    sprintf((char*)errMsg,
            "Cost function index (%d) out of range [0, %d] !",
            indexCo, (nmbCostFuncts-1));
    errorMsg((char*)errMsg);
  }

  costFunType costFun = coFunctions[indexCo];

  // v nego vremenno se zapisva simvolnoto predstaviane na chislo
  // za da se sazdade string na negova baza
  char buf[20];
  int indexCost = 0; // index in the 'allcosts' array

  int maxCost = 0, minCost = 1111111;

  //waste index 0 unsuited for graph algo
  st.index("wasted");

  for (int i = 0; i < lz1; i++) {

    y1 =   (int) asifirst[i];
    x1 =   (int) asifirst[i +   lz1];
    y2 =   (int) asifirst[i + 2*lz1];
    x2 =   (int) asifirst[i + 3*lz1];
    int1 = (int) asifirst[i + 4*lz1];
    int2 = (int) asifirst[i + 5*lz1];

    sprintf(buf, "%d&%d", x1, y1);
    string sxy1 = buf;

    sprintf(buf, "%d&%d", x2, y2);
    string sxy2 = buf;

    for (int j = 0; j < lz2; j++) {

      y2a = (int) asisecond[j];
      x2a = (int) asisecond[j + lz2];

      // create the edges t1-t2-t3 if the source coords in z2
      // are the same as the target coords in z1.
      // line2 is x, line1 is y...

      if( (x2 == x2a) && (y2 == y2a) ) {

        y3 =    (int) asisecond[j + 2*lz2];
        x3 =    (int) asisecond[j + 3*lz2];
        int2a = (int) asisecond[j + 4*lz2];
        int3 =  (int) asisecond[j + 5*lz2];
        assert(int2 == int2a);

        double cij = costFun(x1, y1, x2, y2, x3, y3, int1, int2, int3,
                             indCostFun+1, nmbParams-1);

        //in general, this floor.. is below 50..
        int costu = (int)floor(100*cij);
        assert(costu >= 0);

        allcosts[indexCost++] = costu;

        if (costu > maxCost)
          maxCost = costu;
        if (costu < minCost)
          minCost = costu;

        sprintf(buf, "%d&d", x3, y3);
        string sxy3 = buf;

        int normalizedCost = costu <= 100 ? /*100-*/costu : 100;
        int tripletIndex = st.index(sxy1+"&"+sxy2+"&"+sxy3);
        returnsource = st.index("source");

        EDGE* ptedge1 = new EDGE(returnsource, tripletIndex, 3,
                                 normalizedCost, x1, y1, x2, y2, x3, y3);
        G.insert(ptedge1);

        //you should check it only once out of the loop
        rememberST.insert(make_pair(returnsource,ptedge1));


        EDGE* ptedge1a = new EDGE(st.index(sxy1),st.index(sxy1+"&d"), 1,
                                  1, 0, 0, 0, 0, int2, int2);
        G.insert(ptedge1a);
        rememberST.insert(make_pair(st.index(sxy1), ptedge1a));

        EDGE* ptedge2 = new EDGE(tripletIndex, st.index(sxy1), 1,
                                 1, x2, y2, x3, y3, int1, int1);
        G.insert(ptedge2);
        rememberST.insert(make_pair(tripletIndex, ptedge1));


        EDGE* ptedge3 = new EDGE(tripletIndex, st.index(sxy2), 1,
                                 1, x2, y2, x3, y3, int1, int1);
        G.insert(ptedge3);
        //rememberST.insert(make_pair(tripletIndex, ptedge1));


        EDGE* ptedge4 = new EDGE(tripletIndex, st.index(sxy3), 1,
                                 1, 0, 0, 0, 0, x3, y3);
        G.insert(ptedge4);
        //rememberST.insert(make_pair(st.index(sxy1),ptedge1));


        returnsink = st.index("sink");
        EDGE* ptedge3a = new EDGE(st.index(sxy2+"&d"), returnsink, 1,
                                  1, x2, y2, x3, y3, int2, int3);
        G.insert(ptedge3a);
        rememberST.insert(make_pair(st.index(sxy2+"&d"), ptedge3a));


        EDGE* ptedge1b = new EDGE(st.index(sxy2), st.index(sxy2+"&d"), 1,
                                  1, 0, 0, 0, 0, int2, int2);
        G.insert(ptedge1b);
        rememberST.insert(make_pair(st.index(sxy2), ptedge1b));


        EDGE* ptedge2a = new EDGE(st.index(sxy3), st.index(sxy3+"&d"), 1,
                                  1, x3, y3, 0, 0, int3, int3);
        G.insert(ptedge2a);
        rememberST.insert(make_pair(st.index(sxy3), ptedge2a));


        EDGE* ptedge2b = new EDGE(st.index(sxy1+"&d"), returnsink, 1,
                                  1, 0 ,0, 0, 0, int3, 0);
        G.insert(ptedge2b);
        rememberST.insert(make_pair(st.index(sxy1+"&d"), ptedge2b));


        EDGE* ptedge3b = new EDGE(st.index(sxy3+"&d"),returnsink, 1,
                                  1, 0, 0, 0, 0, int3, 0);
        G.insert(ptedge3b);
        rememberST.insert(make_pair(st.index(sxy3+"&d"), ptedge3b));

	edges[edgeCount++] = ptedge1;
	edges[edgeCount++] = ptedge1a;
	edges[edgeCount++] = ptedge2;
	edges[edgeCount++] = ptedge3;
	edges[edgeCount++] = ptedge4;
	edges[edgeCount++] = ptedge3a;
	edges[edgeCount++] = ptedge1b;
	edges[edgeCount++] = ptedge2a;
	edges[edgeCount++] = ptedge2b;
	edges[edgeCount++] = ptedge3b;
	//edgeCount += 10; // the number of allocated edges per each step == 10
      }
    }
  }

  
  cout<<"Number of allocated edges: "<<edgeCount;

  //cout<<"maxCost = "<<maxCost<<endl;
  //cout<<"minCost = "<<minCost<<endl;

}
; // Tracker::scanmatlabAM(...)


//############################################################################
// cs2 - main program

void  cs2 (long n_p,       /* number of nodes */
           long m_p,       /* number of arcs */
           node *nodes_p,  /* array of nodes */
           arc  *arcs_p,   /* array of arcs */
           long f_sc,      /* scaling factor */
           double  max_c,  /* maximal cost */
           long *cap_p,    /* capacities */
           double *obj_ad) /* objective */
{

  int cc;             /* for storing return code */
  cs_init ( n_p, m_p, nodes_p, arcs_p, f_sc, max_c, cap_p );

  /*init_solution ( );*/
  //printf ("c scale-factor: %8.0f     cut-off-factor: %6.1f\nc\n", f_scale, cut_off_factor );

  cc = 0;
  update_epsilon ();

  do {  /* scaling loop */

    refine ();

    if ( n_ref >= PRICE_OUT_START ) {
      price_out ( );
    }

    if ( update_epsilon () )
      break;

    while ( 1 ) {
      if ( ! price_refine () )
        break;

      if ( n_ref >= PRICE_OUT_START ) {
        if ( price_in () ) {
          break;
        }
      }
      if ((cc = update_epsilon ()))
        break;
    }


  } while ( cc == 0 );


  finishup ( obj_ad );

} // void cs2()


//############################################################################
// construct a Goldberg graph from a Sedgewick graph

void Tracker::generateGoldbergGraph() {

  //#define ABS( x ) ( (x) >= 0 ) ? (x) : -(x)

  long inf_cap = 0;
  long    n,                      // internal number of nodes
  node_min,               // minimal no of node
  node_max,               // maximal no of nodes
  *arc_first,              // internal array for holding
  //   - node degree
  //  - position of the first outgoing arc
  *arc_tail,               // internal array: tails of the arcs
  // temporary variables carrying no of nodes
  head, tail, i;

  long    m,                      // internal number of arcs
  // temporary variables carrying no of arcs
  last, arc_num, arc_new_num;

  node    *nodes,                 // pointers to the node structure
  *head_p,
  *ndp,
  *in,
  *jn;

  arc     *arcs,                  // pointers to the arc structure
  *arc_current,
  *arc_new,
  *arc_tmp;

  long    //excess,                 // supply/demand of the node
  low,                    // lowest flow through the arc
  acap;                    // capacity

  long    cost;                   // arc cost

  double  dcost,                  // arc cost in double mode
  m_c;                    // maximal arc cost

  long    *cap;                   // array of capacities

  double  total_p,                // total supply
  total_n,                // total demand
  cap_out,                // sum of outgoing capacities
  cap_in,                 // sum of incoming capacities
  no_nlines=0,            // no of node lines
            no_alines=0,            // no of arc-lines
                      pos_current=0;          // 2*no_alines

  int s;
  int counteredge = 0;
  for (s = 0; s < G.V(); s++) {
    /*typename*/ TGraph::adjIterator A(G, s);
    for (EDGE* t= A.beg(); !A.end(); t = A.nxt()) {
      if (t->v()!=0 && t->w()!=0 && t->from(s)) {
        ++counteredge;
      }
    }
  }

  n = (max_element(rememberST.begin(), rememberST.end()))->first;
  m = counteredge;

  /* allocating memory for  'nodes', 'arcs'  and internal arrays */
  nodes    = (node*) calloc ( n+2,   sizeof(node) );
  arcs     = (arc*)  calloc ( 2*m+1, sizeof(arc) );
  cap      = (long*) calloc ( 2*m,   sizeof(long) );
  arc_tail = (long*) calloc ( 2*m,   sizeof(long) );
  arc_first= (long*) calloc ( n+2,   sizeof(long) );
  /* arc_first [ 0 .. n+1 ] = 0 - initialized by calloc */

  for ( in = nodes; in <= nodes + n; in ++ )
    in -> excess = 0;

  if ( nodes == NULL || arcs == NULL ||
       arc_first == NULL || arc_tail == NULL )
    /* memory is not allocated */
  {}

  /* setting pointer to the first arc */
  arc_current = arcs;
  node_max = 0;
  node_min = n;
  m_c      = 0;
  total_p = total_n = 0;

  for ( ndp = nodes; ndp < nodes + n; ndp ++ )
    ndp -> excess = 0;

  nodes[returnsource].excess = reporter;
  total_p += reporter;

  nodes[returnsink].excess = -reporter;
  total_n += reporter;

  // go through all the arcs of the graph
  for ( s = 0; s < G.V(); s++) {
    /*typename*/ TGraph::adjIterator A(G, s);

    for (EDGE* t= A.beg(); !A.end(); t = A.nxt()) {
      if (t->v()!=0 && t->w()!=0 && t->from(s)) {

        tail = t->v();
        head = t->w();
        low = 0;
        acap = t->cap();
        cost = t->cost();

        /* no of arcs incident to node i is placed in arc_first[i+1] */
        arc_first[tail + 1] ++;
        arc_first[head + 1] ++;
        in    = nodes + tail;
        jn    = nodes + head;
        dcost = (double)cost;

        /* storing information about the arc */
        arc_tail[int(pos_current)]        = tail;
        arc_tail[int(pos_current)+1]      = head;


        //HERE you put a trace to the arcs head and tail

        arc_current->begarc=head;
        arc_current->endarc=tail;
        //_________________________________________

        arc_current       -> head    = jn;
        arc_current       -> r_cap   = acap - low;
        cap[int(pos_current)]             = acap;
        arc_current       -> cost    = dcost;
        arc_current       -> sister  = arc_current + 1;
        ( arc_current + 1 ) -> head    = nodes + tail;
        ( arc_current + 1 ) -> r_cap   = 0;
        cap[int(pos_current)+1]           = 0;
        ( arc_current + 1 ) -> cost    = -dcost;
        ( arc_current + 1 ) -> sister  = arc_current;

        in -> excess -= low;
        jn -> excess += low;

        /* searching for minimum and maximum node */
        if ( head < node_min )
          node_min = head;
        if ( tail < node_min )
          node_min = tail;
        if ( head > node_max )
          node_max = head;
        if ( tail > node_max )
          node_max = tail;

        if ( dcost < 0 )
          dcost = -dcost;
        if ( dcost > m_c && acap > 0 )
          m_c = dcost;

        no_alines   ++;
        arc_current += 2;
        pos_current += 2;


      }
    }
  }


  /* first arc from the first node */
  ( nodes + node_min ) -> first = arcs;

  /* before below loop arc_first[i+1] is the number of arcs outgoing from i;
     after this loop arc_first[i] is the position of the first 
     outgoing from node i arcs after they would be ordered;
     this value is transformed to pointer and written to node.first[i]
  */

  for ( i = node_min + 1; i <= node_max + 1; i ++ ) {
    arc_first[i]          += arc_first[i-1];
    ( nodes + i ) -> first = arcs + arc_first[i];
  }


  for ( i = node_min; i < node_max; i ++ ) /* scanning all the nodes
        					      exept the last*/
  {

    last = ( ( nodes + i + 1 ) -> first ) - arcs;
    /* arcs outgoing from i must be cited
    from position arc_first[i] to the position
    equal to initial value of arc_first[i+1]-1  */

    for ( arc_num = arc_first[i]; arc_num < last; arc_num ++ ) {
      tail = arc_tail[arc_num];

      while ( tail != i )
        /* the arc no  arc_num  is not in place because arc cited here
           must go out from i;
           we'll put it to its place and continue this process
           until an arc in this position would go out from i */

      { arc_new_num  = arc_first[tail];
        arc_current  = arcs + arc_num;
        arc_new      = arcs + arc_new_num;

        /* arc_current must be cited in the position arc_new
           swapping these arcs:                                 */

        head_p               = arc_new -> head;
        arc_new -> head      = arc_current -> head;
        arc_current -> head  = head_p;

        acap                 = cap[arc_new_num];
        cap[arc_new_num]     = cap[arc_num];
        cap[arc_num]         = acap;

        acap                 = arc_new -> r_cap;
        arc_new -> r_cap     = arc_current -> r_cap;
        arc_current -> r_cap = acap;

        dcost                = arc_new -> cost;
        arc_new -> cost      = arc_current -> cost;
        arc_current -> cost  = dcost;

        if ( arc_new != arc_current -> sister ) {
          arc_tmp                = arc_new -> sister;
          arc_new  -> sister     = arc_current -> sister;
          arc_current -> sister  = arc_tmp;

          ( arc_current -> sister ) -> sister = arc_current;
          ( arc_new     -> sister ) -> sister = arc_new;
        }

        arc_tail[arc_num] = arc_tail[arc_new_num];
        arc_tail[arc_new_num] = tail;

        /* we increase arc_first[tail]  */
        arc_first[tail] ++ ;

        tail = arc_tail[arc_num];
      }
    }
    /* all arcs outgoing from  i  are in place */
  }

  /* -----------------------  arcs are ordered  ------------------------- */

  /*------------ testing network for possible excess overflow ---------*/

  for ( ndp = nodes + node_min; ndp <= nodes + node_max; ndp ++ ) {
    cap_in  =   ( ndp -> excess );
    cap_out = - ( ndp -> excess );
    for ( arc_current = ndp -> first; arc_current != (ndp+1) -> first;
          arc_current ++ ) {
      arc_num = arc_current - arcs;
      if ( cap[arc_num] > 0 )
        cap_out += cap[arc_num];
      if ( cap[arc_num] == 0 )
        cap_in += cap[( arc_current -> sister )-arcs];
    }
  }

  /* ----------- assigning output values ------------*/
  ggM = m; //*m_ad = m;
  ggN = node_max - node_min + 1;//*n_ad = node_max - node_min + 1;
  ggMinNode = node_min; //*node_min_ad = node_min;
  ggNodes = nodes + node_min; //*nodes_ad = nodes + node_min;
  ggArcs = arcs; //*arcs_ad = arcs;
  ggMaxArcCost = m_c; //*m_c_ad  = m_c;
  ggCap = cap; //*cap_ad   = cap;

  /* free internal memory */
  free ( arc_first );
  free ( arc_tail );

} // Tracker::generateGoldberGraph()


//############################################################################
// write the solution found with Goldberg's code into the array 'z'

void Tracker::print_solution(node *ndp, arc *arp, long nmin) {
  node *i;
  arc *a;
  long ni;

  map<int,EDGE *> *ptmap = &rememberST;

  int counti = 0;
  double remembva = 12345645;
  for ( i = ndp; i < ndp + n; i ++ ) {
    ni = N_NODE ( i );

    for ( a = i -> suspended; a != (i+1)->suspended; a ++ ) {
      long va = ni;
      long wa = N_NODE( a -> head );
      int fla = cap[ N_ARC (a) ] - ( a -> r_cap );

      if ( cap[ N_ARC (a) ]> 0) {
        if(((*ptmap)[va]!=0) & ((*ptmap)[wa]!=0)) {}

        if (/*(*(z+counti+3)==0) &*/ (fla==3) & ((*ptmap)[va]!=0)) {
          if(((*ptmap)[va]->vx()!=0) & ((*ptmap)[va]->vy()!=0)) {

            asiout[counti]   = double((*ptmap)[wa]->vx());
            asiout[counti+1] = double((*ptmap)[wa]->vy());
            asiout[counti+2] = double((*ptmap)[wa]->wx());
            asiout[counti+3] = double((*ptmap)[wa]->wy());
            asiout[counti+4] = double((*ptmap)[wa]->wx());
            asiout[counti+5] = double((*ptmap)[wa]->wy());
            asiout[counti+6] = double((*ptmap)[wa]->intv());
            asiout[counti+7] = double((*ptmap)[wa]->intw());

            costs[counti/8] = double((*ptmap)[wa]->cost());

            counti += 8;
          }
        }
      }
    }
  }

} // void Tracker::print_solution(...)


//############################################################################
//

void Tracker::trackspeckle(double *flow, int rowx, int rowy,
                           double *indCostFun, int nmbParams,
                           DArray& maxflow) {

  scanMatlab(rowx, rowy, indCostFun, nmbParams);

  MAXFLOW<TGraph, EDGE>(G, returnsource, returnsink);
  check<TGraph, EDGE> mycheck;
  //cout<<mycheck.cost(G)<<endl;
  int maxflowfroms = mycheck.flow(G, returnsource);
  maxflow[0] = maxflowfroms;

  reporter = maxflowfroms;

  double cost;//, c_max;

  //f_sc = ( argc > 1 ) ? atoi( argv[1] ): SCALE_DEFAULT;
  long f_sc = (long) SCALE_DEFAULT;

  generateGoldbergGraph();

  //cs2 ( n, m2, ndp, arp, f_sc, c_max, cap, &cost );
  cs2 ( ggN, 2*ggM, ggNodes, ggArcs, f_sc, ggMaxArcCost, ggCap, &cost );

  //print_solution(ndp, arp, nmin, asiout, costs);
  print_solution(ggNodes, ggArcs, ggMinNode);

  //free(ndp);
  //free(arp);

} // void Tracker::trackspeckle(...)
