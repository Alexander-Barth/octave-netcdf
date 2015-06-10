sinclude Makeconf

AWK ?= awk
MKOCTFILE ?= mkoctfile
OCTAVE ?= octave
NC_CONFIG ?= nc-config
NCHEADER=$(shell $(NC_CONFIG) --includedir)/netcdf.h
SRC=__netcdf__.cc
CFLAGS=$(shell $(NC_CONFIG) --cflags)
LIBS=$(shell $(NC_CONFIG) --libs)

all: __netcdf__.oct

constants:
	$(AWK) -f netcdf_constants.awk $(NCHEADER)  > netcdf_constants.h

clean:
	rm __netcdf__.oct 

real-clean: clean
	rm ../PKG_ADD ../inst/import_netcdf.m 

__netcdf__.oct: $(SRC) netcdf_constants.h
	$(MKOCTFILE) $(CFLAGS) $(SRC) $(LIBS)

../PKG_ADD: $(SRC)
	sh PKG_ADD.sh

check: ../PKG_ADD __netcdf__.oct	
	($(OCTAVE) -f --eval "pkg unload octcdf; addpath $$PWD; addpath $$PWD/../inst; test_netcdf")

check2: ../PKG_ADD __netcdf__.oct	
	($(OCTAVE) -f --eval "addpath $$PWD; addpath $$PWD/../inst; test_netcdf")
