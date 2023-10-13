CXXFLAGS	 = -g	# generate debugging info
CXXFLAGS	+= -I$(MATLAB_INCDIR)

HFILES		 = Array.h graphstruct.h structs.h

OBJFILES	 = costFunctions.o Tracker.o goldberg.o

MEX_TARGET	 = mincost.mexglx
MATLAB_INCDIR	 = /mnt/matlab/extern/include
MATLAB_LIBDIR	 = /mnt/matlab/extern/lib/glnx86

all: costexe

mex: $(MEX_TARGET)

costexe: costexe.o $(OBJFILES)
	$(CXX) -lstdc++ -o $@ $^

$(OBJFILES): $(HFILES)

$(MEX_TARGET): main.o $(OBJFILES)
	$(CXX) -shared -L$(MATLAB_LIBDIR) -lstdc++ -lmat -lmx  -o $@ $^

clean:
	rm -f *.o
	rm -f costexe
	rm -f $(MEX_TARGET)

distclean: clean
	rm -f *~

force: clean all

.PHONY: all clean distclean force
