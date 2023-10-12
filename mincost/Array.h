#ifndef __ARRAY_H
#define __ARRAY_H

#include <stdlib.h>
#include <assert.h>
#include <string.h>

template <class T>
class Array {

protected:
  T* p;      // pointer to the array
  int n;     // size of the array
  int index; // current index in the array

public:

  Array(int _n) : index(0) {
    n = _n;
    p = new T[n];
    memset(p, 42, n*sizeof(T));
  }

  Array(const Array& that) : index(0) {
    copyArray(that.p, that.n);
  }

  Array(T* thatp, int thatn) : index(0) {
    copyArray(thatp, thatn);
  }

  Array& operator =(const Array& that) {
    delete [n] p;
    copyArray(that.p, that.n);
  }

  ~Array() {
    delete [] p;
  }

  int getn() const {
    return n;
  }

  inline T& operator [](int i) {
    assert(testIndex(i));
    return p[i];
  }

  Array& operator +(int i) {
    assert(testIndex(i));
    assert(testIndex(index+i));
    index = index + i;
    return *this;
  }

  T& operator *() {
    T& tmp = p[index];
    index = 0;
    return tmp;
  }

  void copyTo(T* ptr) {
    memcpy(ptr, p, n*sizeof(T));
  }

  //##############################################################################
  // Auxilliary methods

protected:

  bool testIndex(int i) {
    bool ok = i>=0 && i<n;
    //if (!ok)
    //  cerr<<"Index "<<i<<" out of bounds [0,"<<(n-1)<<"]";
    return ok;
  }

  void copyArray(T* thatp, int thatn) {
    n = thatn;
    p = new T[n];
    memcpy(p, thatp, n*sizeof(T));
  }

};

#endif

