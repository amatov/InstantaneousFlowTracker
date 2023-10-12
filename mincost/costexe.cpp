// costexe.cpp : Defines the entry point for the console application.
//
#include <stdlib.h>
#include <stdio.h>
#include <iostream>

#include "Array.h"
#include "Tracker.h"


typedef Tracker::DArray DArray;


void errorMsg(char* message) {
  printf(message);
  exit(1);
}

DArray readArray(char* filename, int& rows, int& cols) {
  FILE *file = fopen(filename, "r");

  fscanf(file, "%d", &rows);
  fscanf(file, "%d", &cols);

  float x;

  DArray a(rows*cols);

  for (int i = 0; i < rows*cols; i++) {
    fscanf(file, "%f", &x);
    a[i] = x;
  }

  return a;
}

void printArray(DArray& a) {
  for (int i = 0; i < a.getn(); i++) {
    printf("%d ", (int) a[i]);
  }
  printf("\n");
}

//############################################################################

int main(int argc, char* argv[]) {
  if (argc < 3) {
    errorMsg("Provide at least two filenames!\n");
  }

  int rowsX, colsX, rowsY, colsY;

  DArray asifirst = readArray(argv[1], rowsX, colsX);
  DArray asisecond= readArray(argv[2], rowsY, colsY);
  int nbLinks=(rowsX < rowsY ? rowsX : rowsY);
  DArray asiout(8 * nbLinks);
  DArray allcosts(4 * nbLinks);
  DArray costs(nbLinks);
  DArray maxflow(1);

  //printArray(asifirst);
  //printArray(asisecond);

  double indCostFun = 0.0;

  Tracker myTracker(asifirst, asisecond, asiout, allcosts, costs);
  myTracker.trackspeckle((double*) 0, rowsX, rowsY, &indCostFun, 1, maxflow);

  printArray(myTracker.asiout);
  printArray(myTracker.allcosts);
  printArray(myTracker.costs);
  printArray(maxflow);

  return 0;
}
