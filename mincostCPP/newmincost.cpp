// The Main Program With The MATLAB Interface
// AM 31.01.2003

#include "structs.h"
#include "graphstruct.h"
#include "goldberg.h"
#include "Array.h"

//----------------------------------------------------------------------------
/* cs2 - main program */

void  cs2 (long n_p,   /* number of nodes */
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

}


//----------------------------------------------------------------------------
#ifdef COST_RESTART

void cs_cost_reinit ()
{
  node   *i;          /* current node */
  arc    *a;          /* current arc */
  bucket *b;          /* current bucket */
  double rc, minc, sum;
  arc *a_stop;

  for (b = buckets; b != l_bucket; b ++)
    RESET_BUCKET(b);

  rc = 0;
  FOR_ALL_NODES_i
    {
      rc = MIN(rc, i -> price);
      i -> first = i -> suspended;
      i -> current = i -> first;
      i -> q_next = sentinel_node;
    }

  /* make prices nonnegative and multiply */
  FOR_ALL_NODES_i {
    i->price = (i->price - rc) * dn;
  }

  /* multiply arc costs */
  for (a = arcs ; a != sentinel_arc ; a ++)
    a -> cost *= dn;

  /* for debugging only
     for (a = arcs ; a != sentinel_arc ; a ++)
     if (a->cost >= 0) {
     a -> cost += n;
     a -> sister ->cost -= n;
     }
  */

  sum = 0;
  FOR_ALL_NODES_i {
    minc = 0;
    FOR_ALL_ARCS_a_FROM_i {
      if ((OPEN(a) && ((rc = REDUCED_COST(i, a->head, a)) < 0)))
	minc = MAX(epsilon, -rc);
    }
    sum += minc;
  }

  epsilon = ceil (sum / dn);

  cut_off_factor = CUT_OFF_COEF * pow ((double) n, CUT_OFF_POWER);

  cut_off_factor = MAX ( cut_off_factor, CUT_OFF_MIN );

  n_ref = 0;

  n_refine = n_discharge = n_push=n_relabel = 0;
  n_update = n_scan = n_prefine = n_prscan = n_prscan1 = n_bad_pricein
    = n_bad_relabel = 0;

  flag_price = 0;

  excq_first = NULL;

  empty_push_bound = n * EMPTY_PUSH_COEF;

} /* end of reinitialization */

//----------------------------------------------------------------------------
/* restart after a cost update */
void cs2_cost_restart (double *obj_ad/* objective */)
{
  int cc;             /* for storing return code */

  printf("c \nc ******************************\n");
  printf("c Restarting after a cost update\n");
  printf("c ******************************\nc\n");

  cs_cost_reinit ();

  printf ("c Init. epsilon = %6.0f\n", epsilon);
  cc = update_epsilon();

  if (cc != 0)
    printf("c Old solution is optimal\n");
  else {

    do {  /* scaling loop */

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

      if (cc)
        break;

      refine ();

      if ( n_ref >= PRICE_OUT_START ) {
        price_out ( );
      }

      if ( update_epsilon () )
        break;
    } while (cc == 0);
  }

  finishup ( obj_ad );

}
#endif

//----------------------------------------------------------------------------

void print_solution(node *ndp, arc *arp, long nmin, Array<double>& z, Array<double>& costs) //asiout

{
  node *i;
  arc *a;
  long ni;
  // double cost;
  map<int,EDGE *> *ptmap;
  typedef SparseMultiGRAPH<EDGE> mysp;
  typedef IO<mysp> myio;
  ptmap=& myio::rememberST;

#ifdef COMP_DUALS
  FILE *stream;
  FILE *stream2;
  stream = fopen( "fprintf1.out", "w" );
  stream2 = fopen( "fprintf2.out", "w" );
#endif

  int counti=0;
  double remembva=12345645;
  for ( i = ndp; i < ndp + n; i ++ ) {
    ni = N_NODE ( i );

    for ( a = i -> suspended; a != (i+1)->suspended; a ++ ) {
      long va=ni;
      long wa=N_NODE( a -> head );
      int fla=cap[ N_ARC (a) ] - ( a -> r_cap );

      if ( cap[ N_ARC (a) ]> 0) {
        if(((*ptmap)[va]!=0) & ((*ptmap)[wa]!=0)) {}

        // char    in_line[4];       // for reading input line
        if (/*(*(z+counti+3)==0) &*/ (fla==3) & ((*ptmap)[va]!=0)) {
          if(((*ptmap)[va]->vx()!=0) & ((*ptmap)[va]->vy()!=0)) {

            *(z+counti)= double((*ptmap)[wa]->vx());
            *(z+counti+1)=double((*ptmap)[wa]->vy());
            *(z+counti+2)=double((*ptmap)[wa]->wx());
            *(z+counti+3)=double((*ptmap)[wa]->wy());
            *(z+counti+4)=double((*ptmap)[wa]->wx());
            *(z+counti+5)=double((*ptmap)[wa]->wy());
            *(z+counti+6)=double((*ptmap)[wa]->intv());
            *(z+counti+7)=double((*ptmap)[wa]->intw());
			costs[counti/8]=double((*ptmap)[wa]->cost());
            counti=counti+8;

          }
        }
      }
    }
  }

#ifdef COMP_DUALS
  /* find minimum price */
  cost = MAXDOUBLE;
  FOR_ALL_NODES_i {
    cost = MIN(cost, i->price);
  }
  FOR_ALL_NODES_i {
    //printf("p %7ld %7.2f\n", N_NODE(i), i->price - cost);
    fprintf(stream,"p %7ld %7.2f\n", N_NODE(i), i->price - cost);
  }
  fclose( stream );
  fclose (stream2);
#endif

} // void print_solution(...) 

//===============================================

void trackspeckle(Array<double>& asiout, 
				   Array<double>& asifirst, 
				   Array<double>& asisecond, 
				   double *flow, int rowx, int rowy, 
				   double *indCostFun, int nmbParams,
				   Array<double>& allcosts,
				   Array<double>& costs,
				   Array<double>& maxflow) 
{
  
  int v=0;
 
  SparseMultiGRAPH<EDGE> G(50000);

  typedef SparseMultiGRAPH<EDGE> mysp;
  typedef IO<mysp> myio;

  myio::scanmatlabAM(G, asifirst, asisecond, rowx, rowy, indCostFun, nmbParams, allcosts);


  MAXFLOW<mysp, EDGE>(G, myio::returnsource, myio::returnsink);
  check<mysp, EDGE> mycheck;
  //cout<<mycheck.cost(G)<<endl;
  int maxflowfroms=mycheck.flow(G, myio::returnsource);
  maxflow[0]=maxflowfroms;

  //int maxflowfroms=int(*flow);
  myio::reporter=maxflowfroms;
  //   printf ( "fl %7ld \n", maxflowfroms);
  //int myio::reporter=maxflowfroms;
  myio::show2(G);


  double t=0;
  arc *arp;
  node *ndp;
  long n, m, m2, nmin;

  double cost, c_max;
  long f_sc;
  long *cap;


  //f_sc = ( argc > 1 ) ? atoi( argv[1] ): SCALE_DEFAULT;
  f_sc=SCALE_DEFAULT;

  parse( &n, &m, &ndp, &arp, &nmin, &c_max, &cap );
  //printf ( "n %10ld\n", n);

  m2 = 2 * m;

  cs2 ( n, m2, ndp, arp, f_sc, c_max, cap, &cost );


  print_solution(ndp, arp, nmin, asiout, costs);

} // void trackspeckle(...)


//declaration of static variables out of their classes
typedef SparseMultiGRAPH<EDGE> mysp;
typedef IO<mysp> myio;

map<int,EDGE *> myio::rememberST;
int myio::returnsink;
int myio::returnsource;
int myio::reporter;