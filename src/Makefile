LIBS=-lnetcdf
LIBS=$(shell nc-config --libs)

NCHEADER=/home/abarth/Downloads/netcdf-4.2.1.1/include/netcdf.h
NCHEADER=/usr/include/netcdf.h

all: netcdf_package.oct

constants:
	awk '/\#define[ \t]+NC_[0-9a-zA-Z_]*[ \t]+/ { printf "  constants[\"%s\"] = %s;\n",$$2,$$2 }' $(NCHEADER) | grep -v NC_TURN_OFF_LOGGING | fgrep -v NC_FILL_STRING > nc_constants.h

clean:
	rm netcdf_package.oct

netcdf_package.oct: netcdf_package.cc nc_constants.h
	mkoctfile netcdf_package.cc $(LIBS)

PKG_ADD: netcdf_package.cc
	sh PKG_ADD.sh

check: PKG_ADD netcdf_package.oct
	(mkdir tmp; cd tmp; octave --eval "pkg unload octcdf; addpath $$PWD/..; test_netcdf_package")
#	(mkdir tmp; cd tmp; octave --eval "pkg unload octcdf; addpath $$PWD/..; test_netcdf_package")
#	(cd ..; octave --eval "pkg unload octcdf; addpath $$PWD/netcdf; test_netcdf_package")


dynamiclibrary: dynamiclibrary.cc
	g++ -o dynamiclibrary dynamiclibrary.cc -ldl