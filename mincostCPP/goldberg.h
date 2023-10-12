#include "structs.h" // new 31.01.2003

/* PRICE_OUT_START may not be less than 1 */
#define PRICE_OUT_START 1

#define SCALE_DEFAULT  12.0

#define BIGGEST_FLOW        1000000000


/* definitions of types: node & arc */
#define N_NODE( i ) ( ( (i) == NULL ) ? -1 : ( (i) - ndp + nmin ) )
#define N_ARC( a ) ( ( (a) == NULL )? -1 : (a) - arp )

extern long   n;         /* number of nodes */
extern long   *cap;      /* array containig capacities */

void cs_init (long n_p,  /* number of nodes */
              long m_p,      /* number of arcs */
              node *nodes_p, /* array of nodes */
              arc  *arcs_p,  /* array of arcs */
              long f_sc,     /* scaling factor */
              double max_c,  /* maximal cost */
              long *cap_p);  /* array of capacities */

int update_epsilon();

void refine ();

extern long n_ref;

void price_out ();

int price_refine ();

int price_in ();

void finishup ( double *obj_ad );

