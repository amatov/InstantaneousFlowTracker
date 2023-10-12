#include<iostream>
#include <string>
#include <stdlib.h>
#include <vector>
#include<fstream>
#include <algorithm>
#include <math.h>
#include <map>
#include <utility>
#include <map>
#include <mex.h>
#include <time.h>

using std::vector;
using namespace std;


#include <ios>
#include <cstdio>

#include <stdio.h>
#include <string.h>
#include <assert.h>

/* defs.h */

#ifdef DOUBLE_EX
typedef double excess_t;
#else
typedef long excess_t;
#endif

	typedef	
     struct arc_st
       {
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
     struct node_st
       {
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

}  node;

typedef /* bucket */
   struct bucket_st
{
   node   *p_first;         /* 1st node with positive excess 
				         or simply 1st node in the buket */
} bucket;


int M=256;
int C=256;

// p390 book of Sedgewick
//____________________________________________________________________________________
class EDGE
{ int pv, pw, pvx,pvy,pwx,pwy, pcap, pflow, pcost,pintv,pintw; // pcost added to class edge to solve mincost problem
public:
  EDGE(int v, int w, int cap, int cost=0,int vx=0, int vy=0, int wx=0, int wy=0,int intv=0,int intw=0) : //cap: capacity! 
      pv(v), pw(w), pvx(vx),pvy(vy),pwx(wx),pwy(wy), pcap(cap), pflow(0), pcost(cost),pintv(intv),pintw(intw) { } //pcost initialised to 0 
  int v() const { return pv; }
  int w() const { return pw; }
  int vx() const{return pvx;}
  int vy() const{return pvy;}
  int wx() const{return pwx;}
  int wy() const{return pwy;}
  int intv() const{return pintv;}
  int intw() const{return pintw;}
  int cap() const { return pcap; }
  int flow() const { return pflow; }
  int cost() const {return pcost; }
  bool from (int v) const 

  { return pv == v; } 
  int other(int v) const 
    { return from(v) ? pw : pv; } 
  int capRto(int v) const	//capacité restante?
    { return from(v) ? pflow : pcap - pflow; }
  void addflowRto(int v, int d) 
    { pflow += from(v) ? -d : d; }
  int costRto(int v)
  {return from(v)? -pcost : pcost; } //this member function was added to solve the mincost problem p446
 
  //assignement operator
  EDGE& operator=(const EDGE& rhs){ 
	  //test self assignment
	  if(&rhs != this){
	    this->pcap=rhs.pcap;
	    this->pcost=rhs.pcost;
	    this->pflow=rhs.pflow;
		this->pv=rhs.pv;
	    this->pvx=rhs.pvx;
		this->pvy=rhs.pvy;
		this->pw=rhs.pw;
		this->pwx=rhs.pwx;
		this->pwy=rhs.pwy;}
	  
	    return *this;
  }

};

//___________________________________________________________________________________________


template <class Edge> class DenseGRAPH
{ int Vcnt, Ecnt; bool digraph;
  vector <vector <Edge *> > adj;
public:
  DenseGRAPH(int V, bool digraph = false) :
    adj(V), Vcnt(V), Ecnt(0), digraph(digraph)
    { 
      for (int i = 0; i < V; i++) 
        adj[i].assign(V, 0);
    }
  int V() const { return Vcnt; }
  int E() const { return Ecnt; }
  bool directed() const { return digraph; }
  void insert(Edge *e)
    { int v = e->v(), w = e->w();
      if (adj[v][w] == 0) Ecnt++;
      adj[v][w] = e;
      if (!digraph) adj[w][v] = e;
    } 
  void remove(Edge *e)
    { int v = e->v(), w = e->w();
      if (adj[v][w] != 0) Ecnt--;
      adj[v][w] = 0;
      if (!digraph) adj[w][v] = 0; 
    } 
  Edge* edge(int v, int w) const 
    { return adj[v][w]; }
  
  class adjIterator;
  friend class adjIterator;
  
  class adjIterator
{ const DenseGRAPH<Edge> &G;
  int i, v;
public:
  adjIterator(const DenseGRAPH<Edge> &G, int v) : 
    G(G), v(v), i(0) { }
  Edge *beg()
    { i = -1; return nxt(); }
  Edge *nxt()
    {
      for (i++; i < G.V(); i++)
        if (G.edge(v, i)) return G.adj[v][i];
      return 0;
    }
  bool end() const
    { return i >= G.V(); }
};
};

//__________________________________________________________________________________

template <class Edge> class SparseMultiGRAPH
{ int Vcnt, Ecnt; bool digraph;
  struct node
    { Edge* e; node* next;
      node(Edge* e, node* next): e(e), next(next) {}
    };
  typedef node* link;
  vector <link> adj;
public:
  SparseMultiGRAPH(int V, bool digraph = false) :
    adj(V), Vcnt(V), Ecnt(0), digraph(digraph) { }
  int V() const { return Vcnt; }
  int E() const { return Ecnt; }
  bool directed() const { return digraph; }
  void insert(Edge *e)
    { 
      //does the edge already exist? if so, replace the previous one by this one. if edge doesn't exist, introduce it.
	  //if the cost is higher, don't introduce the edge for god's sake!
	  int v=e->v();
	  int w=e->w();
      int control=1;

	node *n=adj[v]; 
	if (n!=0){
	  do 
{
    
    if ((n->e->v()==v && n->e->w()==w) && (e->cost()<=n->e->cost())) {n->e=e; control=0; break;} 
	else if((n->e->v()==v && n->e->w()==w) && (e->cost()>n->e->cost())){return;}
	if(n->next!=0) n=n->next;
	} while ( n->next!=0);
	if ((n->e->v()==v && n->e->w()==w) && (e->cost()<=n->e->cost())) {n->e=e; control=0;}
	else if ((n->e->v()==v && n->e->w()==w) && (e->cost()>n->e->cost())){return;}
	}

n=adj[w];
if (n!=0){
do 
{
    
    if ((n->e->v()==v && n->e->w()==w) && (e->cost()<=n->e->cost())) {n->e=e; control=0;break;}
	else if((n->e->v()==v && n->e->w()==w) && (e->cost()>n->e->cost())){return;}
	if(n->next!=0) n=n->next;
} while ( n->next!=0 );
    if ((n->e->v()==v && n->e->w()==w) && (e->cost()<=n->e->cost())) {n->e=e; control=0;}
	else if ((n->e->v()==v && n->e->w()==w) && (e->cost()>n->e->cost())) {return;}
}

		if(control==1){  	  
	  adj[e->v()] = new node(e, adj[e->v()]);
      if (!digraph) 
        adj[e->w()] = new node(e, adj[e->w()]); 
      Ecnt++;}
	     } 
  class adjIterator;
  friend class adjIterator;


  //remove this class if it gets stuck
  class adjIterator
{ const SparseMultiGRAPH &G;
  int v;
  link t;
public:
  adjIterator(const SparseMultiGRAPH &G, int v) : 
    G(G), v(v) { t = 0; }
  Edge *beg()
    { t = G.adj[v]; 
  return t ? t->e : 0; }
  Edge *nxt()
    { if (t) t = t->next; return t ? t->e : 0; }
  bool end()
    { return t == 0; }
};
};
//p47_________________________________________________________________

template<class Graph>
static void randE(Graph &G, int E)
  { 
    for (int i = 0; i < E; i++)
      {
        int v = int(G.V()*rand()/(1.0+RAND_MAX));
        int w = int(G.V()*rand()/(1.0+RAND_MAX));
		int weight = int(G.V()*rand()/(1.0+RAND_MAX));
		int cost = int(G.V()*rand()/(1.0+RAND_MAX));
        //EDGE* e=&EDGE(v,w,weight,cost);
		//G.insert(e);
		G.insert(new EDGE(v, w, weight, cost));
      }
  }

// p51 _________________________________________________________________________________


class ST			//symbol table construction for graph indexing
{ int N, val;
  struct node 
    { int v, d; node* l, *m, *r;
      node(int d) : v(-1), d(d), l(0), m(0), r(0) {}
    };
  typedef node* link;
  link head;
  link indexR(link h, const string &s, int w)
    { int i = s[w];
      if (h == 0) h = new node(i);
      if (i == 0) 
        {
          if (h->v == -1) h->v = N++;
          val = h->v;
          return h;
        }
      if (i < h->d) h->l = indexR(h->l, s, w);
      if (i == h->d) h->m = indexR(h->m, s, w+1);
      if (i > h->d) h->r = indexR(h->r, s, w);
      return h;
    }
public:
  ST() : head(0), N(0) { }
  int index(const string &key)
    { head = indexR(head, key, 0); return val; }
};

//p21________________________________________________________________________________

template <class Graph> 
class IO
{   static map<int,EDGE *> rememberST;
	static map<int,string> remembertemp;
	static int returnsink;
	static int returnsource;
	static int reporter;


public:
      friend void print_solution(node *, arc *, long, double *);
	  friend void trackspeckle1(double *, double *, double *, double*, int , int );

	static void show(const Graph &G){ 
    for (int s = 0; s < G.V(); s++) 
      {
        typename Graph::adjIterator A(G, s);
        for (EDGE* t= A.beg(); !A.end(); t = A.nxt()) 
		{ cout.width(2); cout <<"from:"<<t->from(s) <<" "<< t->v() << "- "<<t->w()<<"  cap:"<<t->cap()<<"  cost:"<<t->cost()<<" flow:"<<t->flow()<<"    caprestanteto "<<s<<": "<<t->capRto(s)<<"   costrestant: "<<t->costRto(s)<<endl; 
	}}
  };
     
static void scanmatlab(Graph &G,double *z1,double *z2, int lz1, int lz2)
	  { string v, w;
int ilin;
int count1=0;
double dummarg;
double line1,line2,line3,line4,line5,line6,line7,line8;
double line1i,line2i,line3i,line4i,line5i,line6i,line7i,line8i;

 ST st;
 # define factor 100     

int count=0,i8=0,j8=0,count8=0,count9=0,i9=0;

EDGE * ptedge1;
EDGE * ptedge2;
EDGE * ptedge3;
EDGE * ptedge4;
EDGE * ptedge1a;
EDGE * ptedge1b;
EDGE * ptedge2a;
EDGE * ptedge2b;
EDGE * ptedge3a;

EDGE * ptedge3b;

EDGE * ptedge11;


	for (i8=0;i8<lz1;i8++) {

		line1=int(*(z1+count8));
		char buf1[20];
    _itoa( line1, buf1, 10 );
string sline1=buf1;
// printf("%7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld\n",((*ptmap)[va]->vx()),((*ptmap)[va]->vy()),((*ptmap)[wa]->vx()),((*ptmap)[wa]->vy()),((*ptmap)[ni]->wx()),((*ptmap)[ni]->wy()), ((*ptmap)[wa]->wx()),((*ptmap)[wa]->wy()))

		line2=int(*(z1+count8+lz1));
	char buf2[20];
    _itoa( line2, buf2, 10 );
string sline2=buf2;



		line3=int(*(z1+count8+2*lz1));
	char buf3[20];
    _itoa( line3, buf3, 10 );
string sline3=buf3;

		line4=int(*(z1+count8+3*lz1));
	char buf4[20];
    _itoa( line4, buf4, 10 );
string sline4=buf4;

		line5=int(*(z1+count8+4*lz1));
	char buf5[20];
    _itoa( line5, buf5, 10 );
string sline5=buf5;

		line6=int(*(z1+count8+5*lz1));
			count8++; 
	char buf6[20];
    _itoa( line6, buf6, 10 );
  string sline6=buf6;
	
  //waste index 0 unsuited for graph algo
	st.index("wasted");

  

		count9=0;
//inner loop
for (i9=0;i9<lz2;i9++) {
		line1i=int(*(z2+count9));
         char buf1i[20];
		 _itoa( line1i, buf1i, 10 );
		 string sline1i=buf1i;

	line2i=int(*(z2+count9+lz2));
   	char buf2i[20];
	_itoa( line2i, buf2i, 10 );
	string sline2i=buf2i;



		line3i=int(*(z2+count9+2*lz2));
   	char buf3i[20];
	 _itoa( line3i, buf3i, 10 );
	string sline3i=buf3i;

		line4i=int(*(z2+count9+3*lz2));
    	char buf4i[20];
	  _itoa( line4i, buf4i, 10 );
	string sline4i=buf4i;



		line5i=int(*(z2+count9+4*lz2));
    	char buf5i[20];
	  _itoa( line5i, buf5i, 10 );
	string sline5i=buf5i;

		line6i=int(*(z2+count9+5*lz2));
			
		
		
		count9++; 
	
    	char buf6i[20];
	  _itoa( line6i, buf6i, 10 );
   string sline6i=buf6i;       




//create the edges t1-t2-t3 if the source coo in z2 are the same as the target coo in z1.
  //line2is x, line1 is y... 

   if(line3==line1i & line4==line2i)
   {
	   




	   //first, calculate the smoothness of the trajectory t1,t2,t3 considered to calculate costs


					double l1x=line4-line2;
					double l1y=line3-line1;
					double l2x=line4i-line2i;
					double l2y=line3i-line1i;
					

					//most probable distance travelled from frame to frame here,2
					double ul12=pow(l1x*l1x+l1y*l1y,0.5);
					double ul23=pow((l2x*l2x+l2y*l2y),0.5);
					double pl1=exp(-1*pow(((ul12-3)/5),2)); //a priori jump size:3, stddev:5
					double pl2=exp(-1*pow(((ul23-3)/5),2));
					double pl=pl1*pl2;

					double anglecij=(l1x*l2x+l1y*l2y)/(pow((l1x*l1x+l1y*l1y),0.5)*pow((l2x*l2x+l2y*l2y),0.5));
					double lengthcij=pow(pow(l1x*l1x+l1y*l1y,0.5)*pow(l2x*l2x+l2y*l2y,0.5),0.5)/(pow(l1x*l1x+l1y*l1y,0.5)+pow(l2x*l2x+l2y*l2y,0.5));
					

					int I1=line5;
					int I2=line6;
					int I3=line6i;
					int maxI=(I1>=I2?I1:I2);
					maxI=(maxI>=I3?maxI:I3);

					double meanI=(I1+I2+I3)/3;
                    double stddevI=pow(pow((I1-meanI),2)+pow((I2-meanI),2)+pow((I3-meanI),2),0.5);
					double costI=stddevI/meanI;
				    double intcons=pow((meanI/256),0.3); 
					double cij=0.6*((1-anglecij))+0.4*((1-2*lengthcij))+0.2*costI;		//cij is a cost function increasing with bad matches						
					int costu=floor(100*cij); //in general, this floor.. is below 50..
					
					if ((cij>=0) & (cij<=1)){		
					
		
		ptedge1=new EDGE(st.index("source"), st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i), 3, 100-costu,int(line2), int(line1), int(line4),int(line3),int(line4i), int(line3i));
		G.insert(ptedge1); 
	    rememberST.insert(make_pair(st.index("source"),ptedge1)); //you should check it only once out of the loop
		returnsource=st.index("source");
		
		//printf("%7ld %7ld %7ld %7ld %7ld %7ld\n",int(line1),int(line2),int(line3),int(line4),st.index("source"), st.index(sline1+"&"+sline2));
					
					} 
					else {

ptedge1=new EDGE(st.index("source"), st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i), 3, 100,int(line2), int(line1), int(line4),int(line3),int(line4i), int(line3i));
		G.insert(ptedge1); 
	    rememberST.insert(make_pair(st.index("source"),ptedge1)); //you should check it only once out of the loop
		returnsource=st.index("source");
	
					}
					 //end of nested if tests
		
	//printf("%7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld\n",costu,int(line1),int(line2),int(line3),int(line4),int(line3i),int(line4i),st.index("source"),st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i));

	   	ptedge1a=new EDGE(st.index(sline1+"&"+sline2),st.index(sline1+"&d"+sline2), 1, 1,0,0,0,0,int(line6), int(line6));
		G.insert(ptedge1a); 
	    rememberST.insert(make_pair(st.index(sline1+"&"+sline2),ptedge1a)); 
	   	ptedge2=new EDGE(st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i),st.index(sline1+"&"+sline2), 1, 1,int(line4),int(line3),int(line4i),int(line3i),int(line5), int(line5));
		G.insert(ptedge2);
		rememberST.insert(make_pair(st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i),ptedge1)); 
//printf("%7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld\n",costu,int(line1),int(line2),int(line3),int(line4),int(line3i),int(line4i),st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i),st.index(sline1+"&"+sline2));

	   	ptedge3=new EDGE(st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i),st.index(sline3+"&"+sline4), 1, 1,int(line4),int(line3),int(line4i),int(line3i),int(line5), int(line5));
		G.insert(ptedge3);
		//rememberST.insert(make_pair(st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i),ptedge1)); 
//printf("%7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld\n",costu,int(line1),int(line2),int(line3),int(line4),int(line3i),int(line4i),st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i),st.index(sline3+"&"+sline4));

ptedge4=new EDGE(st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i),st.index(sline3i+"&"+sline4i), 1, 1,0,0,0,0,int(line4i), int(line3i));
					G.insert(ptedge4);
					//rememberST.insert(make_pair(st.index(sline1+"&"+sline2),ptedge1));
//printf("%7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld\n",costu,int(line1),int(line2),int(line3),int(line4),int(line3i),int(line4i),st.index(sline1+"&"+sline2+"&"+sline1i+"&"+sline2i+"&"+sline3i+"&"+sline4i),st.index(sline3i+"&"+sline4i));

ptedge3a=new EDGE(st.index(sline1i+"&d"+sline2i),st.index("sink"), 1, 1,int(line4), int(line3), int(line4i),int(line3i),int(line6), int(line6i));
				G.insert(ptedge3a); 
				rememberST.insert(make_pair(st.index(sline1i+"&d"+sline2i),ptedge3a)); 

	   	ptedge1b=new EDGE(st.index(sline3+"&"+sline4),st.index(sline3+"&d"+sline4), 1, 1,0,0,0,0,int(line6), int(line6));
		G.insert(ptedge1b); 
	    rememberST.insert(make_pair(st.index(sline3+"&"+sline4),ptedge1b)); 
			   	ptedge2a=new EDGE(st.index(sline3i+"&"+sline4i),st.index(sline3i+"&d"+sline4i), 1, 1,int(line4i),int(line3i),0,0,int(line6i), int(line6i));
				G.insert(ptedge2a);
			   rememberST.insert(make_pair(st.index(sline3i+"&"+sline4i),ptedge2a)); 
			   	ptedge2b=new EDGE(st.index(sline1+"&d"+sline2),st.index("sink"), 1, 1,0,0, 0,0,int(line6i), 0);
				G.insert(ptedge2b); 
				rememberST.insert(make_pair(st.index(sline1+"&d"+sline2),ptedge2b)); 
				returnsink=st.index("sink");
			   	ptedge3b=new EDGE(st.index(sline3i+"&d"+sline4i),st.index("sink"), 1, 1,0,0, 0,0,int(line6i), 0);
				G.insert(ptedge3b); 
				rememberST.insert(make_pair(st.index(sline3i+"&d"+sline4i),ptedge3b)); 
				returnsink=st.index("sink");
		//printf("%7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld %7ld\n",costu,int(line1),int(line2),int(line3),int(line4),int(line3i),int(line4i),st.index(sline3i+"&d"+sline4i),st.index("sink"));

		   }
  	} 
	} 

  };





	static void show2(const Graph &G){ 
	ST sttemp;
		ofstream opi; 
	opi.open("myasiout.txt");
	if (!opi)
	cout<< "file not open";

    for (int s = 0; s < G.V(); s++) 
      {
        typename Graph::adjIterator A(G, s);
        for (EDGE* t= A.beg(); !A.end(); t = A.nxt()) 
		{  if ((t->flow() != 0) ) //modified to -60 bug... come back to 0 soon
			opi<<t->vy()<<"  " <<t->vx()<<"  "<<t->wy()<<"  "<<t->wx()<<" "<<t->cost()<<endl;; 
		}}
	opi.close();

	opi.open("myasiout13.txt");
	if (!opi)
   mexErrMsgTxt("file myasiout1.txt could not open");

int counteredge=0;
for ( s = 0; s < G.V(); s++) 
      {
        typename Graph::adjIterator A(G, s);

		for (EDGE* t= A.beg(); !A.end(); t = A.nxt()) 
		{  if (t->v()!=0 && t->w()!=0 && t->from(s)) {
		
			//opi<<"a"<<" "<<t->v()<<" " <<t->w()<<" "<<0<<" "<<t->cap()<<" "<<t->cost()<<endl; 
			//cout<<"a"<<" "<<t->v()<<" " <<t->w()<<" "<<0<<" "<<t->cap()<<" "<<t->cost()<<endl; 
			++counteredge;}
	}}



opi<<"c"<<endl;
opi<<"c        This is a simple example file to demonstrate the"<<endl;
opi<<"c     input file format for minimum-cost flow problems."<<endl;
opi<<"c"<<endl;
opi<<"c problem line :"<<endl; //here you have to be careful to stuff rememberST with the right crap
opi<<"p min "<<(max_element(myio::rememberST.begin(),myio::rememberST.end()))->first<<" "<<counteredge<<endl;



opi<<"c"<<endl;
opi<<"c node descriptor lines :"<<endl;
   	
 //typedef SparseMultiGRAPH<EDGE> mysp; 
 //check<mysp, EDGE> mycheck;
 //int maxflowfroms=mycheck.flowconst(G, returnsource);


opi<<"n "<< returnsource<<" "<<reporter<<endl;
opi<<"n "<<returnsink<<" "<<-reporter<<endl;
opi<<"c"<<endl;
opi<<"c arc descriptor lines :"<<endl;
    
for ( s = 0; s < G.V(); s++) 
      {
        typename Graph::adjIterator A(G, s);

		for (EDGE* t= A.beg(); !A.end(); t = A.nxt()) 
		{  if (t->v()!=0 && t->w()!=0 && t->from(s)) {
		
			opi<<"a"<<" "<<t->v()<<" " <<t->w()<<" "<<0<<" "<<t->cap()<<" "<<t->cost()<<endl; 
			//cout<<"a"<<" "<<t->v()<<" " <<t->w()<<" "<<0<<" "<<t->cap()<<" "<<t->cost()<<endl; 
			}
	}}
	opi.close();

	}; //check the file
	  
  };


//__________________________________________________________________________________

template <class keyType> class PQi //priority queue
{ int d, N;
  vector<int> pq, qp; 
  const vector<keyType> &a; 
  void exch(int i, int j)
    { int t = pq[i]; pq[i] = pq[j]; pq[j] = t;
      qp[pq[i]] = i; qp[pq[j]] = j; }
  void fixUp(int k)
    { while (k > 1 && a[pq[(k+d-2)/d]] > a[pq[k]])
        { exch(k, (k+d-2)/d); k = (k+d-2)/d; } }
  void fixDown(int k, int N)
    { int j;
      while ((j = d*(k-1)+2) <= N)
        { 
          for (int i = j+1; i < j+d && i <= N; i++)
            if (a[pq[j]] > a[pq[i]]) j = i;
          if (!(a[pq[k]] > a[pq[j]])) break;
          exch(k, j); k = j;
        }
    }
public:
  PQi(int N, const vector<keyType> &a, int d = 3) : 
    a(a), pq(N+1, 0), qp(N+1, 0), N(0), d(d) { }
  int empty() const { return N == 0; }
  void insert(int v) 
    { pq[++N] = v; qp[v] = N; fixUp(N); }
  int getmin()
    { exch(1, N); fixDown(1, N-1); return pq[N--]; }
  void lower(int k)
    { fixUp(qp[k]); }
};

//p209_______________________________________________________-
template <class Graph> class SC 
{ const Graph &G;
  int cnt, scnt,largest1,largest2; 
  vector<int> postI, postR, id;
  void dfsR(const Graph &G, int w)
  { 
    id[w] = scnt;
	
    typename Graph::adjIterator A(G, w);
    for (EDGE* t = A.beg(); !A.end(); t = A.nxt())
      if (id[t->other(w)] == -1) 
	  {largest1++; dfsR(G, t->other(w));}
    postI[cnt++] = w;
	
	 }
public:
  SC(const Graph &G) : G(G), cnt(0), scnt(0), largest2(0), 
    postI(G.V()), postR(G.V()), id(G.V(), -1)
    { Graph R(G.V(), true);
  reversesedgt(G, R);
typedef SparseMultiGRAPH<EDGE> mysp;         
	typedef IO<mysp> myio;
	//myio::show(R);
      for (int v = 0; v < R.V(); v++)
        if (id[v] == -1) 
			dfsR(R, v);
      postR = postI; cnt = scnt = 0;
      id.assign(G.V(), -1);
      for (v = G.V()-1; v >= 0; v--)
        if (id[postR[v]] == -1)
		{ largest1=0; dfsR(G, postR[v]); scnt++; if(largest1>largest2)
		{largest2=largest1;}}
    }
  int ident(int v) {return id[v];}
  int largestc(){return largest2;} //added to return the largest component
  int count() const { return scnt; }
  bool stronglyreachable(int v, int w) const 
    { return id[v] == id[w]; }
  
};
//p155_________________________________________________________
template <class inGraph, class outGraph> 
void reversesedg(const inGraph &G, outGraph &R)
  { 
    for (int v = 0; v < G.V(); v++) 
      { typename inGraph::adjIterator A(G, v);
	for (EDGE* w = A.beg(); !A.end(); w = A.nxt()){ 
        if(w->capRto(v)>0) R.insert(new EDGE(w->other(v),v, w->cap(), w->cost()));
		else if(w->capRto(w->other(v))>0) R.insert(new EDGE(v,w->other(v), w->cap(), w->cost()));}
      }
  }

// function _______________________________________________________________
template <class inGraph, class outGraph> 
void reversesedgt(const inGraph &G, outGraph &R)
  { 
    for (int v = 0; v < G.V(); v++) 
      { typename inGraph::adjIterator A(G, v);
        for (EDGE* w = A.beg(); !A.end(); w = A.nxt()) 
        R.insert(new EDGE(w->w(),w->v(), w->cap(), w->cost()));
      }
  }


//p353___________________________________________________________________________________


template <class Graph, class Edge> class MAXFLOW
{ const Graph &G;
  int s, t;
  vector<int> wt;
  vector<Edge *> st;
  int ST(int v) const { return st[v]->other(v); }
  void augment(int s, int t)
    { int d = st[t]->capRto(t);
      for (int v = ST(t); v != s; v = ST(v))
        if (st[v]->capRto(v) < d) 
          d = st[v]->capRto(v);
      st[t]->addflowRto(t, d); 
      for (v = ST(t); v != s; v = ST(v))
        st[v]->addflowRto(v, d); 
    }
  bool pfs()
  { PQi<int> pQ(G.V(), wt);
    for (int v = 0; v < G.V(); v++) 
      { wt[v] = 0; st[v] = 0; pQ.insert(v); }
    wt[s] = -M; pQ.lower(s);  
    while (!pQ.empty()) 
    { int v = pQ.getmin(); wt[v] = -M; 
      if (v == t || (v != s && st[v] == 0)) break;  
      typename Graph::adjIterator A(G, v); 
      for (Edge* e = A.beg(); !A.end(); e = A.nxt()) 
        { int w = e->other(v);
          int cap = e->capRto(w);
          int P = cap < -wt[v] ? cap : -wt[v];
          if (cap > 0 && -P < wt[w]) 
            { wt[w] = -P; pQ.lower(w); st[w] = e; }
        }
    }
    return st[t] != 0;
  }
public:
  MAXFLOW(const Graph &G, int s, int t) : G(G),
    s(s), t(t), st(G.V()), wt(G.V())
  { while (pfs()) 
  augment(s, t); }
};
//________________________________________________________________________________________

template <class Graph> class cDFS
{ int cnt;
  const Graph &G;
  vector <int> ord; 
  void searchC(int v)
    { 
      ord[v] = cnt++;
      typename Graph::adjIterator A(G, v);
      for (int t = A.beg(); !A.end(); t = A.nxt()) 
        if (ord[t] == -1) searchC(t);
    }
public:
  cDFS(const Graph &G, int v = 0) : 
    G(G), cnt(0), ord(G.V(), -1) 
    { searchC(v); }
  int count() const { return cnt; }
  int operator[](int v) const { return ord[v]; }
};


// p380check the network for consistency______________________________________________
template <class Graph, class Edge> class check
{
 public:
  static int flow(Graph &G, int v) 
    { int x = 0;
      typename Graph::adjIterator A(G, v);
      for (Edge* e = A.beg(); !A.end(); e = A.nxt()) 
        x += e->from(v) ? e->flow() : -e->flow();
      return x; 
    }
  static int flowconst(const Graph &G, int v) 
    { int x = 0;
      typename Graph::adjIterator A(G, v);
      for (Edge* e = A.beg(); !A.end(); e = A.nxt()) 
        x += e->from(v) ? e->flow() : -e->flow();
      return x; 
    }


  static bool flow(Graph &G, int s, int t) 
    { 
      for (int v = 0; v < G.V(); v++)
        if ((v != s) && (v != t))
          if (flow(G, v) != 0) return false;
      int sflow = flow(G, s);
      if (sflow < 0) return false;
      if (sflow + flow(G, t) != 0) return false;
      return true; 
    }   
  static int cost(const Graph &G)
{ int x = 0;
  for (int v = 0; v < G.V(); v++) 
    { 
      typename Graph::adjIterator A(G, v);
      for (Edge* e = A.beg(); !A.end(); e = A.nxt()) 
        if (e->from(v) && e->costRto(e->w()) < C)
          x += e->flow()*e->costRto(e->w()); 
    }
  return x; 
}
};


//p298_______________________________________________________________________________________

 template <class Graph, class Edge> class SPT //shortest path search. with the bellman change, must contain negative
{ const Graph &G; // path which we can detect by keeping an eye on those vertices which have already appeared in the 
  vector<double> wt; //returned list. wt is the weight to the previous vertice given in spt
  vector<Edge *> spt; //spt is the parent indexed vector
  int s;
public:
// p353 replaced version for implementing the bellman ford algorythm
  SPT(const Graph &G, int s) : G(G), 
    spt(G.V()), wt(G.V(), G.V()*G.V())  //wt is a cost vector (length) which is initialised with a value big enough G.V() replaced by G.v()^2
  { QUEUE<int> Q; int N = 0;
    wt[s] = 0.0; 
    Q.put(s); Q.put(G.V());
    while (!Q.empty())
    { int v;
      while ((v = Q.get()) == G.V()) 
        { if (N++ > G.V()) return; Q.put(G.V()); }
      typename Graph::adjIterator A(G, v); 
      for (Edge* e = A.beg(); !A.end(); e = A.nxt()) 
        { 
		  int w = e->other(v); //replaced e->w() by e->other(v)
           double P = wt[v] + e->costRto(w);//*e->costRto(w); //
		  if (P < wt[w]) //&& e->capRto(w)!=0otherwise there is no edge in the residual network and you can't relax
		  { 
			 
			  wt[w] = P; Q.put(w); spt[w] = e; /* cout<<wt[w]*/; } 
	  }
    }
  }
  vector<double> wtreturn(){return wt;}
  
  int mysign(int number){if (number>0) return 1; else if (number<0) return -1; else return 0;}
  
  //this function returns a vertex which belongs to a negative cycle along which we will augment the flow
  int negcyc()
  {
	  //wt is there as well as spt run an iteration and check whether you fish a w visited twice
	  
	  for (int v=0; v < G.V(); v++) //make one pass more 
	  { typename Graph::adjIterator A(G,v);
	  for (Edge* e=A.beg(); !A.end(); e=A.nxt()){
			cout<<wt[v]<<endl;
			if(wt[e->w()] > wt[v] + e->costRto(e->v()))
				return e->w();
			}
	  }
	  return -1;} //returns -1 if no negative cycles have been detected in the passage.
  
  Edge *pathR(int v) const { return spt[v]; }
  double dist(int v) const { return wt[v]; }
};


//Here comes GoldBerg's code
//_________________________________________________________________________

 
#define  BIGGEST_FLOW  1000000000

int parse(long *n_ad, long *m_ad, node **nodes_ad, arc **arcs_ad, long *node_min_ad, double *m_c_ad, long **cap_ad)

// all parameters are output 
//long    *n_ad;                 / address of the number of nodes 
//long    *m_ad;                 / address of the number of arcs 
//node    **nodes_ad;            / address of the array of nodes 
//arc     **arcs_ad;             / address of the array of arcs 
//long    *node_min_ad;          / address of the minimal node 
//double  *m_c_ad;               / maximal arc cost 
//long    **cap_ad;              / array of capacities 

{

#define MAXLINE       20000	// max line length in the input file //from 100 to 5000
#define ARC_FIELDS      5	// no of fields in arc line  
#define NODE_FIELDS     2	// no of fields in node line  
#define P_FIELDS        3       // no of fields in problem line 
#define PROBLEM_TYPE "min"      // name of problem type
#define ABS( x ) ( (x) >= 0 ) ? (x) : -(x)
#define PRINT_ANS       1

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

long    excess,                 // supply/demand of the node 
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

char    in_line[MAXLINE],       // for reading input line 
        pr_type[3];             // for reading type of the problem 

int     k,                      // temporary 
        err_no;                 // no of detected error 

/* -------------- error numbers & error messages ---------------- */
#define EN1   0
#define EN2   1
#define EN3   2
#define EN4   3
#define EN6   4
#define EN10  5
#define EN7   6
#define EN8   7
#define EN9   8
#define EN11  9
#define EN12 10
#define EN13 11
#define EN14 12
#define EN16 13
#define EN15 14
#define EN17 15
#define EN18 16
#define EN21 17
#define EN19 18
#define EN20 19
#define EN22 20

static char *err_message[] = 
  { 
/* 0*/    "more than one problem line",
/* 1*/    "wrong number of parameters in the problem line",
/* 2*/    "it is not a Min-cost problem line",
/* 3*/    "bad value of a parameter in the problem line",
/* 4*/    "can't obtain enough memory to solve this problem",
/* 5*/    "",
/* 6*/    "can't read problem name",
/* 7*/    "problem description must be before node description",
/* 8*/    "wrong capacity bounds",
/* 9*/    "wrong number of parameters in the node line",
/*10*/    "wrong value of parameters in the node line",
/*11*/    "unbalanced problem",
/*12*/    "node descriptions must be before arc descriptions",
/*13*/    "too many arcs in the input",
/*14*/    "wrong number of parameters in the arc line",
/*15*/    "wrong value of parameters in the arc line",
/*16*/    "unknown line type in the input",
/*17*/    "read error",
/*18*/    "not enough arcs in the input",
/*19*/    "warning: capacities too big - excess overflow possible",
/*20*/    "can't read anything from the input file",
/*21*/    "warning: infinite capacity replaced by BIGGEST_FLOW"
  };
/* --------------------------------------------------------------- */

/* The main loop:
        -  reads the line of the input,
        -  analises its type,
        -  checks correctness of parameters,
        -  puts data to the arrays,
        -  does service functions
*/
double no_lines=0;
double no_plines=0;

	
FILE *stream;
 //stream = fopen( "dimacsexample2.txt", "r" );
 // stream = fopen( "dimacsexample3.txt", "r" );

   stream = fopen( "myasiout13.txt", "r" );
while ( fgets( in_line, 100, stream ) != NULL )
{ cout<< in_line<<endl;
	
	no_lines ++;


  switch (in_line[0])
    {
      case 'c':                  /* skip lines with comments */
      case '\n':                 /* skip empty lines   */
      case '\0':                 /* skip empty lines at the end of file */
                break;

      case 'p':                  /* problem description      */
                if ( no_plines > 0 )
                   /* more than one problem line */
                   { err_no = EN1 ; goto error; }

                no_plines = 1;
   
                if (
        /* reading problem line: type of problem, no of nodes, no of arcs */
                    //sscanf ( in_line, "%*c %3s %ld %ld", pr_type, &n, &m )
					sscanf ( in_line, "%*c %3s %ld %ld", pr_type, &n, &m )
					
					!= P_FIELDS
                   )

                    


		    /*wrong number of parameters in the problem line*/
		    { err_no = EN2; goto error;cout<<pr_type<<n<<m;}

                if ( strcmp ( pr_type, PROBLEM_TYPE ) )
		    /*wrong problem type*/
		    { err_no = EN3; goto error; }

                if ( n <= 0  || m <= 0 )
		    /*wrong value of no of arcs or nodes*/
		    { err_no = EN4; goto error; }


        /* allocating memory for  'nodes', 'arcs'  and internal arrays */
                nodes    = (node*) calloc ( n+2, sizeof(node) );
		arcs     = (arc*)  calloc ( 2*m+1, sizeof(arc) );
	        cap      = (long*) calloc ( 2*m,   sizeof(long) ); 
	        arc_tail = (long*) calloc ( 2*m,   sizeof(long) ); 
		arc_first= (long*) calloc ( n+2, sizeof(long) );
                /* arc_first [ 0 .. n+1 ] = 0 - initialized by calloc */

		for ( in = nodes; in <= nodes + n; in ++ )
		   in -> excess = 0;
		    

                if ( nodes == NULL || arcs == NULL || 
                     arc_first == NULL || arc_tail == NULL )
                    /* memory is not allocated */
		    { err_no = EN6; goto error; }
		     
		/* setting pointer to the first arc */
		arc_current = arcs;
                node_max = 0;
                node_min = n;
		m_c      = 0;
		total_p = total_n = 0;

		for ( ndp = nodes; ndp < nodes + n; ndp ++ )
		  ndp -> excess = 0;

                break;

      case 'n':		         /* node description */
		if ( no_alines > 0 ) 
                  /* there were arc descriptors before  */
                  { err_no = EN14; goto error; }

		if ( no_plines == 0 )
                  /* there was no problem line above */
                  { err_no = EN8; goto error; }

		no_nlines ++;

                /* reading node */
		k = sscanf ( in_line,"%*c %ld %ld", &i, &excess );
 
		if ( k < NODE_FIELDS )
                  /* node line is incorrect */
                  { err_no = EN11; goto error; }

		if ( i < 0 || i > n )
                  /* wrong number of the node */
                  { err_no = EN12; goto error; }

		( nodes + i ) -> excess = excess;
		if ( excess > 0 ) total_p += (double)excess;
		if ( excess < 0 ) total_n -= (double)excess;

		break;

      case 'a':                    /* arc description */

		if ( no_alines >= m )
                  /*too many arcs on input*/
                  { err_no = EN16; goto error; }
		
		if (
                    /* reading an arc description */
                    sscanf ( in_line,"%*c %ld %ld %ld %ld %ld",
                                      &tail, &head, &low, &acap, &cost )
                    != ARC_FIELDS
                   ) 
                    /* arc description is not correct */
                    { err_no = EN15; goto error; }

		if ( tail < 0  ||  tail > n  ||
                     head < 0  ||  head > n  
		   )
                    /* wrong value of nodes */
		    { err_no = EN17; goto error; }

		if ( acap < 0 ) {
		  acap = BIGGEST_FLOW;
		  if (!inf_cap) {
		    inf_cap = 1;
		    fprintf ( stderr, "\n%s\n", err_message[21] );
		  }
		}

		if ( low < 0 || low > acap )
		  { err_no = EN9; goto error; }

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
                if ( head < node_min ) node_min = head;
                if ( tail < node_min ) node_min = tail;
                if ( head > node_max ) node_max = head;
                if ( tail > node_max ) node_max = tail;

		if ( dcost < 0 ) dcost = -dcost;
		if ( dcost > m_c && acap > 0 ) m_c = dcost;

		no_alines   ++;
		arc_current += 2;
		pos_current += 2;

		break;

	default:
		/* unknown type of line */
		err_no = EN18; goto error;
		break;

    } /* end of switch */
}     /* end of input loop */
fclose( stream );



/* first arc from the first node */
( nodes + node_min ) -> first = arcs;

/* before below loop arc_first[i+1] is the number of arcs outgoing from i;
   after this loop arc_first[i] is the position of the first 
   outgoing from node i arcs after they would be ordered;
   this value is transformed to pointer and written to node.first[i]
   */
 
for ( i = node_min + 1; i <= node_max + 1; i ++ ) 
  {
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

    for ( arc_num = arc_first[i]; arc_num < last; arc_num ++ )
      { tail = arc_tail[arc_num];

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

	    if ( arc_new != arc_current -> sister )
	      {
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

for ( ndp = nodes + node_min; ndp <= nodes + node_max; ndp ++ )
{
   cap_in  =   ( ndp -> excess );
   cap_out = - ( ndp -> excess );
   for ( arc_current = ndp -> first; arc_current != (ndp+1) -> first; 
         arc_current ++ )
      {
	arc_num = arc_current - arcs;
	if ( cap[arc_num] > 0 ) cap_out += cap[arc_num];
	if ( cap[arc_num] == 0 ) 
	  cap_in += cap[( arc_current -> sister )-arcs];
      }
#ifndef DOUBLE_EX
   if (cap_in > BIGGEST_FLOW || cap_out > BIGGEST_FLOW)
     { 
       fprintf ( stderr, "\n%s\n", err_message[EN20] );
       break;
     }
#endif
}

/* ----------- assigning output values ------------*/
*m_ad = m;
*n_ad = node_max - node_min + 1;
*node_min_ad = node_min;
*nodes_ad = nodes + node_min;
*arcs_ad = arcs;
*m_c_ad  = m_c;
*cap_ad   = cap;

/* free internal memory */
free ( arc_first ); free ( arc_tail );

return (0);

/* ---------------------------------- */
 error:  /* error found reading input */

//fprintf ( stderr, "\nline %ld of input - %s\n", 
 //        no_lines, err_message[err_no] );
cout<<err_message[err_no];
return 0;
//exit (1); //for any reason, the program returns erro while it does "fine" 

}
/* --------------------   end of parser  -------------------*/


/************************************** constants  &  parameters ********/



/* for measuring time */

/* definitions of types: node & arc */





#define N_NODE( i ) ( ( (i) == NULL ) ? -1 : ( (i) - ndp + nmin ) )
#define N_ARC( a ) ( ( (a) == NULL )? -1 : (a) - arp )

#define PRICE_MAX           1e30
#define BIGGEST_FLOW        1000000000

#define UNFEASIBLE          2
#define ALLOCATION_FAULT    5
#define PRICE_OFL           6

/* parameters */

#define UPDT_FREQ      0.4
#define UPDT_FREQ_S    30

#define SCALE_DEFAULT  12.0

/* PRICE_OUT_START may not be less than 1 */
#define PRICE_OUT_START 1

#define CUT_OFF_POWER    0.44
#define CUT_OFF_COEF     1.5
#define CUT_OFF_POWER2   0.75
#define CUT_OFF_COEF2    1
#define CUT_OFF_GAP      0.8
#define CUT_OFF_MIN      12
#define CUT_OFF_INCREASE 4

/*
#define TIME_FOR_PRICE_IN    5
*/
#define TIME_FOR_PRICE_IN1    2
#define TIME_FOR_PRICE_IN2    4
#define TIME_FOR_PRICE_IN3    6

#define EMPTY_PUSH_COEF      1.0
/*
#define MAX_CYCLES_CANCELLED 10
#define START_CYCLE_CANCEL   3
*/
#define MAX_CYCLES_CANCELLED 0
#define START_CYCLE_CANCEL   100
/************************************************ shared macros *******/

#define MAX( x, y ) ( ( (x) > (y) ) ?  x : y )
#define MIN( x, y ) ( ( (x) < (y) ) ? x : y )

#define OPEN( a )   ( a -> r_cap > 0 )
#define CLOSED( a )   ( a -> r_cap <= 0 )
#define REDUCED_COST( i, j, a ) ( (i->price) + (a->cost) - (j->price) )
#define FEASIBLE( i, j, a )     ( (i->price) + (a->cost) < (j->price) )
#define ADMISSIBLE( i, j, a )   ( OPEN(a) && FEASIBLE( i, j, a ) )


#define INCREASE_FLOW( i, j, a, df )\
{\
   (i) -> excess            -= df;\
   (j) -> excess            += df;\
   (a)            -> r_cap  -= df;\
  ((a) -> sister) -> r_cap  += df;\
}\

/*---------------------------------- macros for excess queue */

#define RESET_EXCESS_Q \
{\
   for ( ; excq_first != NULL; excq_first = excq_last )\
     {\
	excq_last            = excq_first -> q_next;\
        excq_first -> q_next = sentinel_node;\
     }\
}

#define OUT_OF_EXCESS_Q( i )  ( i -> q_next == sentinel_node )

#define EMPTY_EXCESS_Q    ( excq_first == NULL )
#define NONEMPTY_EXCESS_Q ( excq_first != NULL )

#define INSERT_TO_EXCESS_Q( i )\
{\
   if ( NONEMPTY_EXCESS_Q )\
     excq_last -> q_next = i;\
   else\
     excq_first  = i;\
\
   i -> q_next = NULL;\
   excq_last   = i;\
}

#define INSERT_TO_FRONT_EXCESS_Q( i )\
{\
   if ( EMPTY_EXCESS_Q )\
     excq_last = i;\
\
   i -> q_next = excq_first;\
   excq_first  = i;\
}

#define REMOVE_FROM_EXCESS_Q( i )\
{\
   i           = excq_first;\
   excq_first  = i -> q_next;\
   i -> q_next = sentinel_node;\
}

/*---------------------------------- excess queue as a stack */

#define EMPTY_STACKQ      EMPTY_EXCESS_Q
#define NONEMPTY_STACKQ   NONEMPTY_EXCESS_Q

#define RESET_STACKQ  RESET_EXCESS_Q

#define STACKQ_PUSH( i )\
{\
   i -> q_next = excq_first;\
   excq_first  = i;\
}

#define STACKQ_POP( i ) REMOVE_FROM_EXCESS_Q( i )

/*------------------------------------ macros for buckets */

node dnd, *dnode;

#define RESET_BUCKET( b )  ( b -> p_first ) = dnode;

#define INSERT_TO_BUCKET( i, b )\
{\
i -> b_next                  = ( b -> p_first );\
( b -> p_first ) -> b_prev   = i;\
( b -> p_first )             = i;\
}

#define NONEMPTY_BUCKET( b ) ( ( b -> p_first ) != dnode )

#define GET_FROM_BUCKET( i, b )\
{\
i    = ( b -> p_first );\
( b -> p_first ) = i -> b_next;\
}

#define REMOVE_FROM_BUCKET( i, b )\
{\
if ( i == ( b -> p_first ) )\
       ( b -> p_first ) = i -> b_next;\
  else\
    {\
       ( i -> b_prev ) -> b_next = i -> b_next;\
       ( i -> b_next ) -> b_prev = i -> b_prev;\
    }\
}

/*------------------------------------------- misc macros */

#define UPDATE_CUT_OFF \
{\
   if (n_bad_pricein + n_bad_relabel == 0) \
     {\
	cut_off_factor = CUT_OFF_COEF2 * pow ( (double)n, CUT_OFF_POWER2 );\
        cut_off_factor = MAX ( cut_off_factor, CUT_OFF_MIN );\
        cut_off        = cut_off_factor * epsilon;\
        cut_on         = cut_off * CUT_OFF_GAP;\
      }\
     else\
       {\
	cut_off_factor *= CUT_OFF_INCREASE;\
        cut_off        = cut_off_factor * epsilon;\
        cut_on         = cut_off * CUT_OFF_GAP;\
	}\
}

#define TIME_FOR_UPDATE \
( n_rel > n * UPDT_FREQ + n_src * UPDT_FREQ_S )

#define FOR_ALL_NODES_i        for ( i = nodes; i != sentinel_node; i ++ )

#define FOR_ALL_ARCS_a_FROM_i \
for ( a = i -> first, a_stop = ( i + 1 ) -> suspended; a != a_stop; a ++ )

#define FOR_ALL_CURRENT_ARCS_a_FROM_i \
for ( a = i -> current, a_stop = ( i + 1 ) -> suspended; a != a_stop; a ++ )

#define WHITE 0
#define GREY  1
#define BLACK 2

arc     *sa, *sb;
long    d_cap;

#define EXCHANGE( a, b )\
{\
if ( a != b )\
  {\
     sa = a -> sister;\
     sb = b -> sister;\
\
     d_arc.r_cap = a -> r_cap;\
     d_arc.cost  = a -> cost;\
     d_arc.head  = a -> head;\
\
     a -> r_cap  = b -> r_cap;\
     a -> cost   = b -> cost;\
     a -> head   = b -> head;\
\
     b -> r_cap  = d_arc.r_cap;\
     b -> cost   = d_arc.cost;\
     b -> head   = d_arc.head;\
\
     if ( a != sb )\
       {\
	  b -> sister = sa;\
	  a -> sister = sb;\
	  sa -> sister = b;\
	  sb -> sister = a;\
        }\
\
     d_cap       = cap[a-arcs];\
     cap[a-arcs] = cap[b-arcs];\
     cap[b-arcs] = d_cap;\
  }\
}

#define SUSPENDED( i, a ) ( a < i -> first ) 



long n_push      =0,
     n_relabel   =0,
     n_discharge =0,
     n_refine    =0,
     n_update    =0,
     n_scan      =0,
     n_prscan    =0,
     n_prscan1   =0,
     n_prscan2   =0,
     n_bad_pricein = 0,
     n_bad_relabel = 0,
     n_prefine   =0;

long   n,                    /* number of nodes */
       m;                    /* number of arcs */

long   *cap;                 /* array containig capacities */

node   *nodes,               /* array of nodes */
       *sentinel_node,       /* next after last */
       *excq_first,          /* first node in push-queue */
       *excq_last;           /* last node in push-queue */

arc    *arcs,                /* array of arcs */
       *sentinel_arc;        /* next after last */

bucket *buckets,             /* array of buckets */
       *l_bucket;            /* last bucket */
long   linf;                 /* number of l_bucket + 1 */
double dlinf;                /* copy of linf in double mode */

int time_for_price_in;
double epsilon,              /* optimality bound */
       low_bound,            /* lowest bound for epsilon */
       price_min,            /* lowest bound for prices */
       f_scale,              /* scale factor */
       dn,                   /* cost multiplier - number of nodes  + 1 */
       mmc,                  /* multiplied maximal cost */
       cut_off_factor,       /* multiplier to produce cut_on and cut_off
				from n and epsilon */
       cut_on,               /* the bound for returning suspended arcs */
       cut_off;              /* the bound for suspending arcs */

double total_excess;         /* total excess */

long   n_rel,                /* number of relabels from last price update */
       n_ref,                /* current number of refines */
       n_src;                /* current number of nodes with excess */

int   flag_price = 0,        /* if = 1 - signal to start price-in ASAP - 
				maybe there is infeasibility because of
				susoended arcs */
      flag_updt = 0;         /* if = 1 - update failed some sources are 
				unreachable: either the problem is
				unfeasible or you have to return 
                                suspended arcs */

long  empty_push_bound;      /* maximal possible number of zero pushes
                                during one discharge */

int   snc_max;               /* maximal number of cycles cancelled
                                during price refine */

arc   d_arc;                 /* dummy arc - for technical reasons */

node  d_node,                /* dummy node - for technical reasons */
      *dummy_node;           /* the address of d_node */

/************************************************ abnormal finish **********/

void err_end ( int cc )


{
fprintf ( stderr, "\nError %d\n", cc );

/*
2 - problem is unfeasible
5 - allocation fault
6 - price overflow
*/

exit ( cc );
}

/************************************************* initialization **********/

void cs_init (long n_p, long m_p, node *nodes_p, arc  *arcs_p, long f_sc, double max_c,long *cap_p)

//long    n_p,        /* number of nodes */
       // m_p;        /* number of arcs */
//node    *nodes_p;   /* array of nodes */
//arc     *arcs_p;    /* array of arcs */
//long    f_sc;       /* scaling factor */
//double  max_c;      /* maximal cost */
//long    *cap_p;     /* array of capacities */

{
node   *i;          /* current node */
arc    *a;          /* current arc */
arc    *a_stop;
long   df;
bucket *b;          /* current bucket */

n             = n_p;
nodes         = nodes_p;
sentinel_node = nodes + n;

m    = m_p;
arcs = arcs_p;
sentinel_arc  = arcs + m;

cap = cap_p;

FOR_ALL_NODES_i 
  {
    i -> price  = 0;
    i -> suspended = i -> first;
    i -> q_next = sentinel_node;
  }

sentinel_node -> first = sentinel_node -> suspended = sentinel_arc;

/* saturate negative arcs, e.g. in the circulation problem case */
FOR_ALL_NODES_i 
  {
    FOR_ALL_ARCS_a_FROM_i 
      {
	if (a -> cost < 0)
	  {
	    if ( ( df = a -> r_cap ) > 0 )
	      {
		INCREASE_FLOW ( i, a -> head, a, df )
	      }
	  }

      }
  }

f_scale = f_sc;

low_bound = 1.00001;

 dn = (double) n ; 
for ( a = arcs ; a != sentinel_arc ; a ++ )
  a -> cost *= dn;

mmc = max_c * dn;

linf   = n * f_scale + 2;
dlinf  = (double)linf;

buckets = (bucket*) calloc ( linf, sizeof (bucket) );
if ( buckets == NULL ) 
   err_end ( ALLOCATION_FAULT );

l_bucket = buckets + linf;

dnode = &dnd;

for ( b = buckets; b != l_bucket; b ++ )
   RESET_BUCKET ( b );

epsilon = mmc;
if ( epsilon < 1 )
  epsilon = 1;

price_min = - PRICE_MAX;

cut_off_factor = CUT_OFF_COEF * pow ( (double)n, CUT_OFF_POWER );

cut_off_factor = MAX ( cut_off_factor, CUT_OFF_MIN );

n_ref = 0;

flag_price = 0;

dummy_node = &d_node;

excq_first = NULL;

empty_push_bound = n * EMPTY_PUSH_COEF;

} /* end of initialization */

/********************************************** up_node_scan *************/

void up_node_scan ( node *i )

//node *i;                      /* node for scanning */

{
node   *j;                     /* opposite node */
arc    *a,                     /* ( i, j ) */
       *a_stop,                /* first arc from the next node */
       *ra;                    /* ( j, i ) */
bucket *b_old,                 /* old bucket contained j */
       *b_new;                 /* new bucket for j */
long   i_rank,
       j_rank,                 /* ranks of nodes */
       j_new_rank;             
double rc,                     /* reduced cost of (j,i) */
       dr;                     /* rank difference */

n_scan ++;

i_rank = i -> rank;

FOR_ALL_ARCS_a_FROM_i 
  {

    ra = a -> sister;

    if ( OPEN ( ra ) )
      {
	j = a -> head;
	j_rank = j -> rank;

	if ( j_rank > i_rank )
	  {
	    if ( ( rc = REDUCED_COST ( j, i, ra ) ) < 0 ) 
	        j_new_rank = i_rank;
	    else
	      {
		dr = rc / epsilon;
		j_new_rank = ( dr < dlinf ) ? i_rank + (long)dr + 1
		                            : linf;
	      }

	    if ( j_rank > j_new_rank )
	      {
		j -> rank = j_new_rank;
		j -> current = ra;

		if ( j_rank < linf )
		  {
		    b_old = buckets + j_rank;
		    REMOVE_FROM_BUCKET ( j, b_old )
		  }

		b_new = buckets + j_new_rank;
		INSERT_TO_BUCKET ( j, b_new )  
	      }
	  }
      }
  } /* end of scanning arcs */

i -> price -= i_rank * epsilon;
i -> rank = -1;
}


/*************************************************** price_update *******/

void  price_update ()

{

register node   *i;

double remain;                 /* total excess of unscanned nodes with
                                  positive excess */
bucket *b;                     /* current bucket */
double dp;                     /* amount to be subtracted from prices */

n_update ++;

FOR_ALL_NODES_i 
  {

    if ( i -> excess < 0 )
      {
	INSERT_TO_BUCKET ( i, buckets );
	i -> rank = 0;
      }
    else
      {
        i -> rank = linf;
      }
  }

remain = total_excess;
if ( remain < 0.5 ) return;

/* main loop */

for ( b = buckets; b != l_bucket; b ++ )
  {

    while ( NONEMPTY_BUCKET ( b ) )
       {
	 GET_FROM_BUCKET ( i, b )

	 up_node_scan ( i );

	 if ( i -> excess > 0 )
	   {
	     remain -= (double)(i -> excess);
             if ( remain <= 0  ) break; 
	   }

       } /* end of scanning the bucket */

    if ( remain <= 0  ) break; 
  } /* end of scanning buckets */

if ( remain > 0.5 ) flag_updt = 1;

/* finishup */
/* changing prices for nodes which were not scanned during main loop */

dp = ( b - buckets ) * epsilon;

FOR_ALL_NODES_i 
  {

    if ( i -> rank >= 0 )
    {
      if ( i -> rank < linf )
	REMOVE_FROM_BUCKET ( i, (buckets + i -> rank) );

      if ( i -> price > price_min )
	i -> price -= dp;
    }
  }

} /* end of price_update */



/****************************************************** relabel *********/

int relabel ( register node *i )

//register node *i;         /* node for relabelling */

{
register arc    *a,       /* current arc from  i  */
                *a_stop,  /* first arc from the next node */
                *a_max;   /* arc  which provides maximum price */
register double p_max,    /* current maximal price */
                i_price,  /* price of node  i */
                dp;       /* current arc partial residual cost */

p_max = price_min;
i_price = i -> price;

for ( 
      a = i -> current + 1, a_stop = ( i + 1 ) -> suspended;
      a != a_stop;
      a ++
    )
  {
    if ( OPEN ( a )
	 &&
	 ( ( dp = ( ( a -> head ) -> price ) - ( a -> cost ) ) > p_max )
       )
      {
	if ( i_price < dp )
	  {
	    i -> current = a;
	    return ( 1 );
	  }

	p_max = dp;
	a_max = a;
      }
  } /* 1/2 arcs are scanned */


for ( 
      a = i -> first, a_stop = ( i -> current ) + 1;
      a != a_stop;
      a ++
    )
  {
    if ( OPEN ( a )
	 &&
	 ( ( dp = ( ( a -> head ) -> price ) - ( a -> cost ) ) > p_max )
       )
      {
	if ( i_price < dp )
	  {
	    i -> current = a;
	    return ( 1 );
	  }

	p_max = dp;
	a_max = a;
      }
  } /* 2/2 arcs are scanned */

/* finishup */

if ( p_max != price_min )
  {
    i -> price   = p_max - epsilon;
    i -> current = a_max;
  }
else
  { /* node can't be relabelled */
    if ( i -> suspended == i -> first )
      {
	if ( i -> excess == 0 )
	  {
	    i -> price = price_min;
	  }
	else
	  {
	    if ( n_ref == 1 )
	      {
		err_end ( UNFEASIBLE );
	      }
	    else
	      {
		err_end ( PRICE_OFL );
	      }
	  }
      }
    else /* node can't be relabelled because of suspended arcs */
      {
	flag_price = 1;
      }
   }


n_relabel ++;
n_rel ++;

return ( 0 );

} /* end of relabel */


/***************************************************** discharge *********/


void discharge ( register node *i )

//register node *i;         /* node to be discharged */

{

register arc  *a;       /* an arc from  i  */

arc  *b,                /* an arc from j */
     *ra;               /* reversed arc (j,i) */
register node *j;       /* head of  a  */
register long df;       /* amoumt of flow to be pushed through  a  */
excess_t j_exc;             /* former excess of  j  */

int  empty_push;        /* number of unsuccessful attempts to push flow
                           out of  i. If it is too big - it is time for
                           global update */

n_discharge ++;
empty_push = 0;

a = i -> current;
j = a -> head;

if ( !ADMISSIBLE ( i, j, a ) ) 
  { 
    relabel ( i );
    a = i -> current;
    j = a -> head;
  }

while ( 1 )
{
  j_exc = j -> excess;

  if ( j_exc >= 0 )
    {
      b = j -> current;
      if ( ADMISSIBLE ( j, b -> head, b ) || relabel ( j ) )
	{ /* exit from j exists */

	  df = MIN( i -> excess, a -> r_cap );
	  if (j_exc == 0) n_src++;
	  INCREASE_FLOW ( i, j, a, df )
n_push ++;

	  if ( OUT_OF_EXCESS_Q ( j ) )
	    {
	      INSERT_TO_EXCESS_Q ( j );
	    }
	}
      else 
	{ 
	  /* push back */ 
	  ra = a -> sister;
	  df = MIN ( j -> excess, ra -> r_cap );
	  if ( df > 0 )
	    {
	      INCREASE_FLOW ( j, i, ra, df );
	      if (j->excess == 0) n_src--;
n_push ++;
	    }

	  if ( empty_push ++ >= empty_push_bound )
	    {
	      flag_price = 1;
	      return;
	    }
	}
    }
  else /* j_exc < 0 */
    { 
      df = MIN( i -> excess, a -> r_cap );
      INCREASE_FLOW ( i, j, a, df )
n_push ++;

      if ( j -> excess >= 0 )
	{
	  if ( j -> excess > 0 )
	    {
              n_src++;
	      relabel ( j );
	      INSERT_TO_EXCESS_Q ( j );
	    }
	  total_excess += j_exc;
	}
      else
	total_excess -= df;

    }
  
  if (i -> excess <= 0)
    n_src--;
  if ( i -> excess <= 0 || flag_price ) break;

  relabel ( i );

  a = i -> current;
  j = a -> head;
}

i -> current = a;
} /* end of discharge */

/***************************************************** price_in *******/

int price_in ()

{
node     *i,                   /* current node */
         *j;

arc      *a,                   /* current arc from i */
         *a_stop,              /* first arc from the next node */
         *b,                   /* arc to be exchanged with suspended */
         *ra,                  /* opposite to  a  */
         *rb;                  /* opposite to  b  */

double   rc;                   /* reduced cost */

int      n_in_bad,             /* number of priced_in arcs with
				  negative reduced cost */
         bad_found;            /* if 1 we are at the second scan
                                  if 0 we are at the first scan */

excess_t  i_exc,                /* excess of  i  */
          df;                   /* an amount to increase flow */


bad_found = 0;
n_in_bad = 0;

 restart:

FOR_ALL_NODES_i 
  {
    for ( a = ( i -> first ) - 1, a_stop = ( i -> suspended ) - 1; 
    a != a_stop; a -- )
      {
	rc = REDUCED_COST ( i, a -> head, a );

	    if ( (rc < 0) && ( a -> r_cap > 0) )
	      { /* bad case */
		if ( bad_found == 0 )
		  {
		    bad_found = 1;
		    UPDATE_CUT_OFF;
		    goto restart;

		  }
		df = a -> r_cap;
		INCREASE_FLOW ( i, a -> head, a, df );

                ra = a -> sister;
		j  = a -> head;

		b = -- ( i -> first );
		EXCHANGE ( a, b );

		if ( SUSPENDED ( j, ra ) )
		  {
		    rb = -- ( j -> first );
		    EXCHANGE ( ra, rb );
		  }

		    n_in_bad ++; 
	      }
	    else
	    if ( ( rc < cut_on ) && ( rc > -cut_on ) )
	      {
		b = -- ( i -> first );
		EXCHANGE ( a, b );
	      }
      }
  }

if ( n_in_bad != 0 )
  {
    n_bad_pricein ++;

    /* recalculating excess queue */

    total_excess = 0;
    n_src=0;
    RESET_EXCESS_Q;

      FOR_ALL_NODES_i 
	{
	  i -> current = i -> first;
	  i_exc = i -> excess;
	  if ( i_exc > 0 )
	    { /* i  is a source */
	      total_excess += i_exc;
	      n_src++;
	      INSERT_TO_EXCESS_Q ( i );
	    }
	}

    INSERT_TO_EXCESS_Q ( dummy_node );
  }

if (time_for_price_in == TIME_FOR_PRICE_IN2)
  time_for_price_in = TIME_FOR_PRICE_IN3;

if (time_for_price_in == TIME_FOR_PRICE_IN1)
  time_for_price_in = TIME_FOR_PRICE_IN2;

return ( n_in_bad );

} /* end of price_in */

/************************************************** refine **************/

void refine () 

{
node     *i;      /* current node */
excess_t i_exc;   /* excess of  i  */

long   np, nr, ns;  /* variables for additional print */

int    pr_in_int;   /* current number of updates between price_in */

np = n_push; 
nr = n_relabel; 
ns = n_scan;

n_refine ++;
n_ref ++;
n_rel = 0;
pr_in_int = 0;

/* initialize */

total_excess = 0;
n_src=0;
RESET_EXCESS_Q

time_for_price_in = TIME_FOR_PRICE_IN1;

FOR_ALL_NODES_i 
  {
    i -> current = i -> first;
    i_exc = i -> excess;
    if ( i_exc > 0 )
      { /* i  is a source */
	total_excess += i_exc;
        n_src++;
	INSERT_TO_EXCESS_Q ( i )
      }
  }


if ( total_excess <= 0 ) return;

/* main loop */

while ( 1 )
  {
    if ( EMPTY_EXCESS_Q )
      {
	if ( n_ref > PRICE_OUT_START ) 
	  {
	    price_in ();
	  }
	  
	if ( EMPTY_EXCESS_Q ) break;
      }

    REMOVE_FROM_EXCESS_Q ( i );

    /* push all excess out of i */

    if ( i -> excess > 0 )
     {
       discharge ( i );

       if ( TIME_FOR_UPDATE || flag_price )
	 {
	   if ( i -> excess > 0 )
	     {
	       INSERT_TO_EXCESS_Q ( i );
	     }

	   if ( flag_price && ( n_ref > PRICE_OUT_START ) )
	     {
	       pr_in_int = 0;
	       price_in ();
	       flag_price = 0;
	     }

	   price_update();

	   while ( flag_updt )
	     {
	       if ( n_ref == 1 )
		 {
		   err_end ( UNFEASIBLE );
		 }
	       else
		 {
		   flag_updt = 0;
		   UPDATE_CUT_OFF;
		   n_bad_relabel++;

		   pr_in_int = 0;
		   price_in ();

		   price_update ();
		 }
	     }

	   n_rel = 0;

	   if ( n_ref > PRICE_OUT_START && 
	       (pr_in_int ++ > time_for_price_in) 
	       )
	     {
	       pr_in_int = 0;
	       price_in ();
	     }

	 } /* time for update */
     }
  } /* end of main loop */

return;

} /*----- end of refine */


/*************************************************** price_refine **********/

int price_refine ()

{

node   *i,              /* current node */
       *j,              /* opposite node */
       *ir,             /* nodes for passing over the negative cycle */
       *is;
arc    *a,              /* arc (i,j) */
       *a_stop,         /* first arc from the next node */
       *ar;

long   bmax;            /* number of farest nonempty bucket */
long   i_rank,          /* rank of node i */
       j_rank,          /* rank of node j */
       j_new_rank;      /* new rank of node j */
bucket *b,              /* current bucket */
       *b_old,          /* old and new buckets of current node */
       *b_new;
double rc,              /* reduced cost of a */
       dr,              /* ranks difference */
       dp;
int    cc;              /* return code: 1 - flow is epsilon optimal
                                        0 - refine is needed        */
long   df;              /* cycle capacity */

int    nnc,             /* number of negative cycles cancelled during
			   one iteration */
       snc;             /* total number of negative cycle cancelled */

n_prefine ++;

cc=1;
snc=0;

snc_max = ( n_ref >= START_CYCLE_CANCEL ) 
          ? MAX_CYCLES_CANCELLED
          : 0;

/* main loop */

while ( 1 )
{ /* while negative cycle is found or eps-optimal solution is constructed */

nnc=0;

FOR_ALL_NODES_i 
  {
    i -> rank    = 0;
    i -> inp     = WHITE;
    i -> current = i -> first;
  }

RESET_STACKQ

FOR_ALL_NODES_i 
  {
    if ( i -> inp == BLACK ) continue;

    i -> b_next = NULL;

    /* deapth first search */
    while ( 1 )
      {
	i -> inp = GREY;

	/* scanning arcs from node i starting from current */
	FOR_ALL_CURRENT_ARCS_a_FROM_i 
	  {
	    if ( OPEN ( a ) )
	      {
		j = a -> head;
		if ( REDUCED_COST ( i, j, a ) < 0 )
		  {
		    if ( j -> inp == WHITE )
		      { /* fresh node  - step forward */
			i -> current = a;
			j -> b_next  = i;
			i = j;
			a = j -> current;
                        a_stop = (j+1) -> suspended;
			break;
		      }

		    if ( j -> inp == GREY )
		      { /* cycle detected */
			cc = 0;
			nnc++;

			i -> current = a;
			is = ir = i;
			df = BIGGEST_FLOW;

			while ( 1 )
			  {
			    ar = ir -> current;
			    if ( ar -> r_cap <= df )
			      {
				df = ar -> r_cap;
			        is = ir;
			      }
			    if ( ir == j ) break;
			    ir = ir -> b_next;
			  } 


			ir = i;

			while ( 1 )
			  {
			    ar = ir -> current;
 			    INCREASE_FLOW( ir, ar -> head, ar, df)

			    if ( ir == j ) break;
			    ir = ir -> b_next;
			  } 


			if ( is != i )
			  {
			    for ( ir = i; ir != is; ir = ir -> b_next )
			      ir -> inp = WHITE;
			    
			    i = is;
			    a = (is -> current) + 1;
                            a_stop = (is+1) -> suspended;
			    break;
			  }

		      }                     
		  }
		/* if j-color is BLACK - continue search from i */
	      }
	  } /* all arcs from i are scanned */

	if ( a == a_stop )
	  {
	    /* step back */
	    i -> inp = BLACK;
n_prscan1++;
	    j = i -> b_next;
	    STACKQ_PUSH ( i );

	    if ( j == NULL ) break;
	    i = j;
	    i -> current ++;
	  }

      } /* end of deapth first search */
  } /* all nodes are scanned */

/* no negative cycle */
/* computing longest paths with eps-precision */


snc += nnc;

if ( snc<snc_max ) cc = 1;

if ( cc == 0 ) break;

bmax = 0;

while ( NONEMPTY_STACKQ )
  {
n_prscan2++;
    STACKQ_POP ( i );
    i_rank = i -> rank;
    FOR_ALL_ARCS_a_FROM_i 
      {
	if ( OPEN ( a ) )
	  {
	    j  = a -> head;
	    rc = REDUCED_COST ( i, j, a );


	    if ( rc < 0 ) /* admissible arc */
	      {
		dr = ( - rc - 0.5 ) / epsilon;
		if (( j_rank = dr + i_rank ) < dlinf )
		  {
		    if ( j_rank > j -> rank )
		      j -> rank = j_rank;
		  }
	      }
	  }
      } /* all arcs from i are scanned */

    if ( i_rank > 0 )
      {
	if ( i_rank > bmax ) bmax = i_rank;
	b = buckets + i_rank;
	INSERT_TO_BUCKET ( i, b )
      }
  } /* end of while-cycle: all nodes are scanned
           - longest distancess are computed */


if ( bmax == 0 ) /* preflow is eps-optimal */
  { break; }

for ( b = buckets + bmax; b != buckets; b -- )
  {
    i_rank = b - buckets;
    dp     = (double)i_rank * epsilon;

    while ( NONEMPTY_BUCKET( b ) )
      {
	GET_FROM_BUCKET ( i, b );

	n_prscan++;
	FOR_ALL_ARCS_a_FROM_i 
	  {
	    if ( OPEN ( a ) )
	      {
		j = a -> head;
        	j_rank = j -> rank;
        	if ( j_rank < i_rank )
	          {
		    rc = REDUCED_COST ( i, j, a );
 
		    if ( rc < 0 ) 
		        j_new_rank = i_rank;
		    else
		      {
			dr = rc / epsilon;
			j_new_rank = ( dr < dlinf ) ? i_rank - ( (long)dr + 1 )
			                            : 0;
		      }
		    if ( j_rank < j_new_rank )
		      {
			if ( cc == 1 )
			  {
			    j -> rank = j_new_rank;

			    if ( j_rank > 0 )
			      {
				b_old = buckets + j_rank;
				REMOVE_FROM_BUCKET ( j, b_old )
				}

			    b_new = buckets + j_new_rank;
			    INSERT_TO_BUCKET ( j, b_new )  
			  }
			else
			  {
			   df = a -> r_cap;
			    INCREASE_FLOW ( i, j, a, df ) 
			  }
		      }
		  }
	      } /* end if opened arc */
	  } /* all arcs are scanned */

	    i -> price -= dp;

      } /* end of while-cycle: the bucket is scanned */
  } /* end of for-cycle: all buckets are scanned */

if ( cc == 0 ) break;

} /* end of main loop */

/* finish: */

/* if refine needed - saturate non-epsilon-optimal arcs */

if ( cc == 0 )
{ 
FOR_ALL_NODES_i 
  {
    FOR_ALL_ARCS_a_FROM_i 
      {
	if ( REDUCED_COST ( i, a -> head, a ) < -epsilon )
	  {
	    if ( ( df = a -> r_cap ) > 0 )
	      {
		INCREASE_FLOW ( i, a -> head, a, df )
	      }
	  }

      }
  }
}


/*neg_cyc();*/

return ( cc );

} /* end of price_refine */



void compute_prices ()

{

node   *i,              /* current node */
       *j;              /* opposite node */
arc    *a,              /* arc (i,j) */
       *a_stop;         /* first arc from the next node */

long   bmax;            /* number of farest nonempty bucket */
long   i_rank,          /* rank of node i */
       j_rank,          /* rank of node j */
       j_new_rank;      /* new rank of node j */
bucket *b,              /* current bucket */
       *b_old,          /* old and new buckets of current node */
       *b_new;
double rc,              /* reduced cost of a */
       dr,              /* ranks difference */
       dp;
int    cc;              /* return code: 1 - flow is epsilon optimal
                                        0 - refine is needed        */


n_prefine ++;

cc=1;

/* main loop */

while ( 1 )
{ /* while negative cycle is found or eps-optimal solution is constructed */


FOR_ALL_NODES_i 
  {
    i -> rank    = 0;
    i -> inp     = WHITE;
    i -> current = i -> first;
  }

RESET_STACKQ

FOR_ALL_NODES_i 
  {
    if ( i -> inp == BLACK ) continue;

    i -> b_next = NULL;

    /* deapth first search */
    while ( 1 )
      {
	i -> inp = GREY;

	/* scanning arcs from node i */
	FOR_ALL_ARCS_a_FROM_i 
	  {
	    if ( OPEN ( a ) )
	      {
		j = a -> head;
		if ( REDUCED_COST ( i, j, a ) < 0 )
		  {
		    if ( j -> inp == WHITE )
		      { /* fresh node  - step forward */
			i -> current = a;
			j -> b_next  = i;
			i = j;
			a = j -> current;
                        a_stop = (j+1) -> suspended;
			break;
		      }

		    if ( j -> inp == GREY )
		      { /* cycle detected; should not happen */
			cc = 0;
		      }                     
		  }
		/* if j-color is BLACK - continue search from i */
	      }
	  } /* all arcs from i are scanned */

	if ( a == a_stop )
	  {
	    /* step back */
	    i -> inp = BLACK;
	    n_prscan1++;
	    j = i -> b_next;
	    STACKQ_PUSH ( i );

	    if ( j == NULL ) break;
	    i = j;
	    i -> current ++;
	  }

      } /* end of deapth first search */
  } /* all nodes are scanned */

/* no negative cycle */
/* computing longest paths */

if ( cc == 0 ) break;

bmax = 0;

while ( NONEMPTY_STACKQ )
  {
    n_prscan2++;
    STACKQ_POP ( i );
    i_rank = i -> rank;
    FOR_ALL_ARCS_a_FROM_i 
      {
	if ( OPEN ( a ) )
	  {
	    j  = a -> head;
	    rc = REDUCED_COST ( i, j, a );


	    if ( rc < 0 ) /* admissible arc */
	      {
		dr = - rc;
		if (( j_rank = dr + i_rank ) < dlinf )
		  {
		    if ( j_rank > j -> rank )
		      j -> rank = j_rank;
		  }
	      }
	  }
      } /* all arcs from i are scanned */

    if ( i_rank > 0 )
      {
	if ( i_rank > bmax ) bmax = i_rank;
	b = buckets + i_rank;
	INSERT_TO_BUCKET ( i, b )
      }
  } /* end of while-cycle: all nodes are scanned
           - longest distancess are computed */


if ( bmax == 0 )
  { break; }

for ( b = buckets + bmax; b != buckets; b -- )
  {
    i_rank = b - buckets;
    dp     = (double) i_rank;

    while ( NONEMPTY_BUCKET( b ) )
      {
	GET_FROM_BUCKET ( i, b )

	  n_prscan++;
	FOR_ALL_ARCS_a_FROM_i 
	  {
	    if ( OPEN ( a ) )
	      {
		j = a -> head;
        	j_rank = j -> rank;
        	if ( j_rank < i_rank )
	          {
		    rc = REDUCED_COST ( i, j, a );
 
		    if ( rc < 0 ) 
		        j_new_rank = i_rank;
		    else
		      {
			dr = rc;
			j_new_rank = ( dr < dlinf ) ? i_rank - ( (long)dr + 1 )
			                            : 0;
		      }
		    if ( j_rank < j_new_rank )
		      {
			if ( cc == 1 )
			  {
			    j -> rank = j_new_rank;

			    if ( j_rank > 0 )
			      {
				b_old = buckets + j_rank;
				REMOVE_FROM_BUCKET ( j, b_old )
				}

			    b_new = buckets + j_new_rank;
			    INSERT_TO_BUCKET ( j, b_new )  
			  }
		      }
		  }
	      } /* end if opened arc */
	  } /* all arcs are scanned */

	    i -> price -= dp;

      } /* end of while-cycle: the bucket is scanned */
  } /* end of for-cycle: all buckets are scanned */

if ( cc == 0 ) break;

} /* end of main loop */

} /* end of compute_prices */


/***************************************************** price_out ************/

void price_out ()

{
node     *i;                /* current node */

arc      *a,                /* current arc from i */
         *a_stop,           /* first arc from the next node */
         *b;                /* arc to be exchanged with suspended */

double   n_cut_off,         /* -cut_off */
         rc;                /* reduced cost */

n_cut_off = - cut_off;

FOR_ALL_NODES_i 
  {
    FOR_ALL_ARCS_a_FROM_i 
      {
	rc = REDUCED_COST ( i, a -> head, a );

	if (((rc > cut_off) && (CLOSED(a -> sister)))
             ||
             ((rc < n_cut_off) && (CLOSED(a)))
           )
	  { /* suspend the arc */
	    b = ( i -> first ) ++ ;

	    EXCHANGE ( a, b );
	  }
      }
  }

} /* end of price_out */


/**************************************************** update_epsilon *******/
/*----- decrease epsilon after epsilon-optimal flow is constructed */

int update_epsilon()
{

if ( epsilon <= low_bound ) return ( 1 );

epsilon = ceil ( epsilon / f_scale );

cut_off        = cut_off_factor * epsilon;
cut_on         = cut_off * CUT_OFF_GAP;

return ( 0 );
}


/* check complimentary slackness */
int check_cs ()

{
  node *i;
  arc *a, *a_stop;

  FOR_ALL_NODES_i
    FOR_ALL_ARCS_a_FROM_i
    if (OPEN(a) && (REDUCED_COST(i, a->head, a) < 0)) {
      assert(0);
    }

  return(1);
}

/*************************************************** finishup ***********/
void finishup ( double *obj_ad )

//double *obj_ad;       /* objective */

{
arc   *a;            /* current arc */
long  na;            /* corresponding position in capacity array */
double  obj_internal;/* objective */
double cs;           /* actual arc cost */
long   flow;         /* flow through an arc */
node *i;

obj_internal = 0;

for ( a = arcs, na = 0; a != sentinel_arc ; a ++, na ++ )
    {
      cs = a -> cost / dn;

      if ( cap[na]  > 0 && ( flow = cap[na] - (a -> r_cap) ) != 0 )
	obj_internal += cs * (double) flow; 

      a -> cost = cs;
    }

FOR_ALL_NODES_i {
  i->price = (i->price / dn);
}

#ifdef COMP_DUALS
FOR_ALL_NODES_i {
  i->price = floor(i->price);
}
  compute_prices ();
  assert(check_cs());
#endif

*obj_ad = obj_internal;

}

/*********************************************** init_solution ***********/
void init_solution ( )


{
arc   *a;            /* current arc  (i,j) */
node  *i,            /* tail of  a  */
      *j;            /* head of  a  */
long  df;            /* ricidual capacity */

for ( a = arcs; a != sentinel_arc ; a ++ )
    {
      if ( a -> r_cap > 0 && a -> cost < 0 )
	{
	  df = a -> r_cap;
	  i  = ( a -> sister ) -> head;
          j  = a -> head;
	  INCREASE_FLOW ( i, j, a, df );
	}
    }
}

/************************************************* cs2 - main program ***/

void  cs2 (long n_p, long m_p, node *nodes_p, arc  *arcs_p,long f_sc, double  max_c, long *cap_p, double *obj_ad)

//long    n_p,        /* number of nodes */
        //m_p;        /* number of arcs */
//node    *nodes_p;   /* array of nodes */
//arc     *arcs_p;    /* array of arcs */
//long    f_sc;       /* scaling factor */
//double  max_c;      /* maximal cost */
//long    *cap_p;     /* capacities */
//double  *obj_ad;    /* objective */

{

int cc;             /* for storing return code */
cs_init ( n_p, m_p, nodes_p, arcs_p, f_sc, max_c, cap_p );

/*init_solution ( );*/
//printf ("c scale-factor: %8.0f     cut-off-factor: %6.1f\nc\n", f_scale, cut_off_factor );

cc = 0;
update_epsilon ();

do {  /* scaling loop */

    refine ();

    if ( n_ref >= PRICE_OUT_START )
      {
	price_out ( );
      }

    if ( update_epsilon () ) break;

    while ( 1 )
      {
        if ( ! price_refine () ) break;

	if ( n_ref >= PRICE_OUT_START )
	  {
	    if ( price_in () ) 
	      { 
		break; 
	      }
	  }
	if ((cc = update_epsilon ())) break;
      }


  } while ( cc == 0 );


finishup ( obj_ad );

}


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

/******** restart after a cost update ***/

void cs2_cost_restart (obj_ad)
  double *obj_ad;    /* objective */


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

      while ( 1 )
	{
	  if ( ! price_refine () ) break;

	  if ( n_ref >= PRICE_OUT_START )
	    {
	      if ( price_in () ) 
		{ 
		  break; 
		}
	    }
	  if ((cc = update_epsilon ())) break;
	}

      if (cc) break;

      refine ();

      if ( n_ref >= PRICE_OUT_START )
	{
	  price_out ( );
	}

      if ( update_epsilon () ) break;
    } while (cc == 0);
  }

finishup ( obj_ad );

}
#endif



#ifdef PRINT_ANS
void print_solution(node *ndp, arc *arp, long nmin, double *z)
{
	node *i;
  arc *a;
  long ni;
  double cost;
  map<int,EDGE *> *ptmap;
	typedef SparseMultiGRAPH<EDGE> mysp; typedef IO<mysp> myio;
	ptmap=& myio::rememberST;
	

 
FILE *stream;
FILE *stream2;
   stream = fopen( "fprintf1.out", "w" );
	stream2 = fopen( "fprintf2.out", "w" );

int counti=0;
double remembva=12345645;
  for ( i = ndp; i < ndp + n; i ++ )
    {
      ni = N_NODE ( i );
		
      for ( a = i -> suspended; a != (i+1)->suspended; a ++ )
	{	
		long va=ni; 
		long wa=N_NODE( a -> head ); 
		int fla=cap[ N_ARC (a) ] - ( a -> r_cap ); 

		  if ( cap[ N_ARC (a) ]> 0){ 
  
	          
			   
			   if((*ptmap)[va]!=0 & (*ptmap)[wa]!=0){
			   }


char    in_line[4];       // for reading input line 


			   if (*(z+counti+3)==0 & fla==3 & (*ptmap)[va]!=0 ){
				   if((*ptmap)[va]->vx()!=0 &(*ptmap)[va]->vy()!=0){
				  
						*(z+counti)= double((*ptmap)[wa]->vx());
			*(z+counti+1)=double((*ptmap)[wa]->vy());
			*(z+counti+2)=double((*ptmap)[wa]->wx());
			*(z+counti+3)=double((*ptmap)[wa]->wy());
			*(z+counti+4)=double((*ptmap)[wa]->wx());
			*(z+counti+5)=double((*ptmap)[wa]->wy());
			*(z+counti+6)=double((*ptmap)[wa]->intv());
			*(z+counti+7)=double((*ptmap)[wa]->intw());
			counti=counti+8;
						
			   }}


	}}}

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
#endif
//  printf("c\n");
  fclose( stream );fclose (stream2);
}
#endif
//===============================================



//__________


void trackspeckle1(double *z, double *x, double *y, double *flow, int rowx, int rowy)
{
	int i,j,count=0;
	int v=0;
	int costu;
	
	
	SparseMultiGRAPH<EDGE> G(50000); 
	
	typedef SparseMultiGRAPH<EDGE> mysp; typedef IO<mysp> myio;       
	
	myio::scanmatlab(G,x,y,rowx,rowy);	
	
	
	MAXFLOW<mysp, EDGE>(G, myio::returnsource, myio::returnsink);
	check<mysp, EDGE> mycheck;
	//cout<<mycheck.cost(G)<<endl;
	int maxflowfroms=mycheck.flow(G, myio::returnsource);


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

#ifdef PRINT_ANS
print_solution(ndp, arp, nmin,z);
#endif


}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// Initialize pointers
	double *x,*y,*z,*flow;
	
	int	mrowsX,ncolsX,mrowsY,ncolsY; 

	// Check for input number
	if (nrhs!=3) {
		mexErrMsgTxt("The function requires three inputs.");
	}

    // Dimensions of the input
	mrowsX=mxGetM(prhs[0]);
	ncolsX=mxGetN(prhs[0]);
	mrowsY=mxGetM(prhs[1]);
	ncolsY=mxGetN(prhs[1]);

	// Create matrix for the return argument
	plhs[0]=mxCreateDoubleMatrix(mrowsX,ncolsX,mxREAL);

	// Assign pointers to each input and output
	x=mxGetPr(prhs[0]);
	y=mxGetPr(prhs[1]);
	flow=mxGetPr(prhs[2]);

	z=mxGetPr(plhs[0]);

	// call tracker
	trackspeckle1(z,x,y,flow,mrowsX,mrowsY); 
}

//declaration of static variables out of their classes

typedef SparseMultiGRAPH<EDGE> mysp; typedef IO<mysp> myio;

map<int,EDGE *> myio::rememberST;
int myio::returnsink;
int myio::returnsource;
int myio::reporter;
