LIBS=$(shell nc-config --libs)
AWK=awk
MKOCTFILE=mkoctfile
OCTAVE=octave
NCHEADER=$(shell nc-config --includedir)/netcdf.h
#SRC=netcdf_package.cc
SRC=__netcdf__.cc

all: __netcdf__.oct

constants:
	$(AWK) -f netcdf_constants.awk $(NCHEADER)  > netcdf_constants.h

clean:
	rm __netcdf__.oct 

real-clean: clean
	rm ../PKG_ADD ../inst/import_netcdf.m 

__netcdf__.oct: $(SRC) netcdf_constants.h
	$(MKOCTFILE) $(SRC) $(LIBS)

../PKG_ADD: $(SRC)
	sh PKG_ADD.sh

check: ../PKG_ADD __netcdf__.oct	
	($(OCTAVE) -f --eval "pkg unload octcdf; addpath $$PWD; addpath $$PWD/../inst; test_netcdf")
