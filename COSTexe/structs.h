#ifndef __STRUCTS_H 
#define __STRUCTS_H 


#ifdef DOUBLE_EX
typedef double excess_t;
#else
typedef long excess_t;
#endif

// enables printing code compilation
#define PRINT_ANS       1

typedef
struct arc_st {
  long             r_cap;     //.. residual capacity
  double           cost;      //.. cost  of the arc
  struct node_st   *head;     //.. head node
  struct arc_st    *sister;   //.. opposite arc
  //added two fields
  int begarc; //beginning node in clear text
  int endarc; //end node in clear text
  //..................
} arc;


typedef
struct node_st {
  /*struct arc_st  *first;    //  first outgoing arc
    double excess;*/
  arc              *first;           /* first outgoing arc */
  arc              *current;         /* current outgoing arc */
  arc              *suspended;
  excess_t         excess;           /* excess of the node */
  double           price;            /* distance from a sink */
  struct node_st   *q_next;          /* next node in push queue */
  struct node_st   *b_next;          /* next node in bucket-list */
  struct node_st   *b_prev;          /* previous node in bucket-list */
  long             rank;             /* bucket number */
  long             inp;              /* temporary number of input arcs */

} node;

typedef /* bucket */
struct bucket_st {
  node   *p_first;         /* 1st node with positive excess
			      or simply 1st node in the buket */
} bucket;


#endif

