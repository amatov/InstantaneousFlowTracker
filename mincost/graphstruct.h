// Contains Graph Manipulation/Representation Classes
// AM 31.01.2003

#ifndef __GRAPHSTRUCT_H
#define __GRAPHSTRUCT_H

#include <iostream>
#include <string>
#include <stdlib.h>
#include <vector>
#include <fstream>
#include <algorithm>
#include <math.h>
#include <map>
#include <utility>
#include <map>
#include <time.h>

#include <cstdio>

#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "structs.h"   // new 31.01.2003
#include "goldberg.h"  // new 31.01.2003
#include "Array.h"     // new 19.04.2003

using std::vector;
using namespace std;

void errorMsg(char*);

const int M = 256;
const int C = 256;

//############################################################################
// p390 book of Sedgewick

class EDGE {
  int pv, pw, pvx, pvy, pwx, pwy,
  pcap, pflow, pintv, pintw,
  pcost; // pcost added to class edge to solve mincost problem
public:
  EDGE(int v, int w, int cap, int cost = 0,
       int vx = 0, int vy = 0, int wx = 0,
       int wy = 0, int intv = 0, int intw = 0) : //cap: capacity!
      pv(v), pw(w), pvx(vx), pvy(vy),
      pwx(wx), pwy(wy), pcap(cap), pflow(0),
  pcost(cost), pintv(intv), pintw(intw) { } //pcost initialised to 0

  int v() const {
    return pv;
  }
  int w() const {
    return pw;
  }
  int vx() const {
    return pvx;
  }
  int vy() const {
    return pvy;
  }
  int wx() const {
    return pwx;
  }
  int wy() const {
    return pwy;
  }
  int intv() const {
    return pintv;
  }
  int intw() const {
    return pintw;
  }
  int cap() const {
    return pcap;
  }
  int flow() const {
    return pflow;
  }
  int cost() const {
    return pcost;
  }
  bool from (int v) const {
    return pv == v;
  }
  int other(int v) const {
    return from(v) ? pw : pv;
  }
  int capRto(int v) const {	//capacite restante?
    return from(v) ? pflow : pcap - pflow;
  }
  void addflowRto(int v, int d) {
    pflow += from(v) ? -d : d;
  }
  int costRto(int v) {
    return from(v)? -pcost : pcost;
  } //this member function was added to solve the mincost problem p446

  //assignement operator
  EDGE& operator=(const EDGE& rhs) {
    //test self assignment
    if(&rhs != this) {
      this->pcap=rhs.pcap;
      this->pcost=rhs.pcost;
      this->pflow=rhs.pflow;
      this->pv=rhs.pv;
      this->pvx=rhs.pvx;
      this->pvy=rhs.pvy;
      this->pw=rhs.pw;
      this->pwx=rhs.pwx;
      this->pwy=rhs.pwy;
    }

    return *this;
  }

}
; // class EDGE


//############################################################################

template <class Edge>
class SparseMultiGRAPH {
  int Vcnt, Ecnt;
  bool digraph;
  struct node {
    Edge* e;
    node* next;
    node(Edge* e, node* next): e(e), next(next) {}
    ~node() {
      //for (node* elem = next; elem != 0; elem = elem.next)
      if (next != 0)
	delete next;
    }
  }
  ;
  typedef node* link;
  vector <link> adj;
public:
  SparseMultiGRAPH(int V, bool digraph = false) :
  adj(V), Vcnt(V), Ecnt(0), digraph(digraph) { }
  ~SparseMultiGRAPH() {
    for (int i = 0; i < V(); i++)
      if (adj[i] != 0)
	delete adj[i];
  }
  int V() const {
    return Vcnt;
  }
  int E() const {
    return Ecnt;
  }
  bool directed() const {
    return digraph;
  }
  void insert(Edge *e) {
    // does the edge already exist? If so,
    // replace the previous one by this one.
    // If edge doesn't exist, introduce it.
    // If the cost is higher, don't introduce the edge for god's sake!
    int v=e->v();
    int w=e->w();
    int control=1;

    node *n=adj[v];
    if (n!=0) {
      do {

        if ((n->e->v()==v && n->e->w()==w) && (e->cost()<=n->e->cost())) {
          n->e=e;
          control=0;
          break;
        } else if((n->e->v()==v && n->e->w()==w) && (e->cost()>n->e->cost())) {
          return;
        }
        if(n->next!=0)
          n=n->next;
      } while ( n->next!=0);
      if ((n->e->v()==v && n->e->w()==w) && (e->cost()<=n->e->cost())) {
        n->e=e;
        control=0;
      } else if ((n->e->v()==v && n->e->w()==w) && (e->cost()>n->e->cost())) {
        return;
      }
    }

    n=adj[w];
    if (n!=0) {
      do {

        if ((n->e->v()==v && n->e->w()==w) && (e->cost()<=n->e->cost())) {
          n->e=e;
          control=0;
          break;
        } else if((n->e->v()==v && n->e->w()==w) && (e->cost()>n->e->cost())) {
          return;
        }
        if(n->next!=0)
          n=n->next;
      } while ( n->next!=0 );
      if ((n->e->v()==v && n->e->w()==w) && (e->cost()<=n->e->cost())) {
        n->e=e;
        control=0;
      } else if ((n->e->v()==v && n->e->w()==w) && (e->cost()>n->e->cost())) {
        return;
      }
    }

    if(control==1) {
      adj[e->v()] = new node(e, adj[e->v()]);
      if (!digraph)
        adj[e->w()] = new node(e, adj[e->w()]);
      Ecnt++;
    }
  }
  class adjIterator;
  friend class adjIterator;


  //remove this class if it gets stuck
  class adjIterator {
    const SparseMultiGRAPH &G;
    int v;
    link t;
  public:
    adjIterator(const SparseMultiGRAPH &G, int v) :
    G(G), v(v) {
      t = 0;
    }
    Edge *beg() {
      t = G.adj[v];
      return t ? t->e : 0;
    }
    Edge *nxt() {
      if (t)
        t = t->next;
      return t ? t->e : 0;
    }
    bool end() {
      return t == 0;
    }
  };
};



//############################################################################
// p51________________________________________________________________________


class ST			//symbol table construction for graph indexing
{
  int N, val;
  struct node {
    int v, d;
    node* l, *m, *r;
    node(int d) : v(-1), d(d), l(0), m(0), r(0) {}
    ~node() {
      delete l;
      delete m;
      delete r;
    }
  }
  ;
  typedef node* link;
  link head;
  link indexR(link h, const string &s, int w) {
    int i = s[w];
    if (h == 0)
      h = new node(i);
    if (i == 0) {
      if (h->v == -1)
        h->v = N++;
      val = h->v;
      return h;
    }
    if (i < h->d)
      h->l = indexR(h->l, s, w);
    if (i == h->d)
      h->m = indexR(h->m, s, w+1);
    if (i > h->d)
      h->r = indexR(h->r, s, w);
    return h;
  }
public:
ST() : head(0), N(0) { }
  int index(const string &key) {
    head = indexR(head, key, 0);
    return val;
  }
  ~ST() {
    delete head;
  }
};


//############################################################################

template <class keyType>
class PQi //priority queue
{
  int d, N;
  vector<int> pq, qp;
  const vector<keyType> &a;
  void exch(int i, int j) {
    int t = pq[i];
    pq[i] = pq[j];
    pq[j] = t;
    qp[pq[i]] = i;
    qp[pq[j]] = j;
  }
  void fixUp(int k) {
    while (k > 1 && a[pq[(k+d-2)/d]] > a[pq[k]]) {
      exch(k, (k+d-2)/d);
      k = (k+d-2)/d;
    }
  }
  void fixDown(int k, int N) {
    int j;
    while ((j = d*(k-1)+2) <= N) {
      for (int i = j+1; i < j+d && i <= N; i++)
        if (a[pq[j]] > a[pq[i]])
          j = i;
      if (!(a[pq[k]] > a[pq[j]]))
        break;
      exch(k, j);
      k = j;
    }
  }
public:
  PQi(int N, const vector<keyType> &a, int d = 3) :
a(a), pq(N+1, 0), qp(N+1, 0), N(0), d(d) { }
  int empty() const {
    return N == 0;
  }
  void insert(int v) {
    pq[++N] = v;
    qp[v] = N;
    fixUp(N);
  }
  int getmin() {
    exch(1, N);
    fixDown(1, N-1);
    return pq[N--];
  }
  void lower(int k) {
    fixUp(qp[k]);
  }
};


//############################################################################
//p353

template <class Graph, class Edge>
class MAXFLOW {
  const Graph &G;
  int s, t;
  vector<int> wt;
  vector<Edge *> st;
  int ST(int v) const {
    return st[v]->other(v);
  }
  void augment(int s, int t) {
    int d = st[t]->capRto(t);
    int v;
    for (v = ST(t); v != s; v = ST(v))
      if (st[v]->capRto(v) < d)
        d = st[v]->capRto(v);
    st[t]->addflowRto(t, d);
    for (v = ST(t); v != s; v = ST(v))
      st[v]->addflowRto(v, d);
  }
  bool pfs() {
    PQi<int> pQ(G.V(), wt);
    for (int v = 0; v < G.V(); v++) {
      wt[v] = 0;
      st[v] = 0;
      pQ.insert(v);
    }
    wt[s] = -M;
    pQ.lower(s);
    while (!pQ.empty()) {
      int v = pQ.getmin();
      wt[v] = -M;
      if (v == t || (v != s && st[v] == 0))
        break;
      typename Graph::adjIterator A(G, v);
      for (Edge* e = A.beg(); !A.end(); e = A.nxt()) {
        int w = e->other(v);
        int cap = e->capRto(w);
        int P = cap < -wt[v] ? cap : -wt[v];
        if (cap > 0 && -P < wt[w]) {
          wt[w] = -P;
          pQ.lower(w);
          st[w] = e;
        }
      }
    }
    return st[t] != 0;
  }
public:
  MAXFLOW(const Graph &G, int s, int t) : G(G),
  s(s), t(t), st(G.V()), wt(G.V()) {
    while (pfs())
      augment(s, t);
  }
};



//############################################################################
// p380: check the network for consistency

template <class Graph, class Edge>
class check {
public:
  static int flow(Graph &G, int v) {
    int x = 0;
    typename Graph::adjIterator A(G, v);
    for (Edge* e = A.beg(); !A.end(); e = A.nxt())
      x += e->from(v) ? e->flow() : -e->flow();
    return x;
  }
  static int flowconst(const Graph &G, int v) {
    int x = 0;
    typename Graph::adjIterator A(G, v);
    for (Edge* e = A.beg(); !A.end(); e = A.nxt())
      x += e->from(v) ? e->flow() : -e->flow();
    return x;
  }


  static bool flow(Graph &G, int s, int t) {
    for (int v = 0; v < G.V(); v++)
      if ((v != s) && (v != t))
        if (flow(G, v) != 0)
          return false;
    int sflow = flow(G, s);
    if (sflow < 0)
      return false;
    if (sflow + flow(G, t) != 0)
      return false;
    return true;
  }
  static int cost(const Graph &G) {
    int x = 0;
    for (int v = 0; v < G.V(); v++) {
      typename Graph::adjIterator A(G, v);
      for (Edge* e = A.beg(); !A.end(); e = A.nxt())
        if (e->from(v) && e->costRto(e->w()) < C)
          x += e->flow()*e->costRto(e->w());
    }
    return x;
  }
};

//############################################################################
// graphstruct.h

#endif

