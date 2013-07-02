LIBS=$(shell nc-config --libs)
AWK=awk
MKOCTFILE=mkoctfile
OCTAVE=octave
NCHEADER=$(shell nc-config --includedir)/netcdf.h

all: netcdf_package.oct

constants:
	$(AWK) -f netcdf_constants.awk $(NCHEADER)  > netcdf_constants.h

clean:
	rm netcdf_package.oct 

netcdf_package.oct: netcdf_package.cc netcdf_constants.h
	$(MKOCTFILE) netcdf_package.cc $(LIBS)

PKG_ADD: netcdf_package.cc
	sh PKG_ADD.sh

check: PKG_ADD netcdf_package.oct
	($(OCTAVE) -f --eval "pkg unload octcdf; addpath $$PWD; addpath $$PWD/../inst; test_netcdf")
