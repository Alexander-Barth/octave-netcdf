#!/bin/sh

netcdf_functions=$(awk -F'[(,]' '/DEFUN_DLD/ { print $2 } ' netcdf_package.cc)

outfile=PKG_ADD

rm -f $outfile import_netcdf.m

for i in $netcdf_functions; do
    echo ${i#netcdf_}
    cat >> $outfile <<EOF
autoload ("$i", fullfile (fileparts (mfilename ("fullpath")), "netcdf_package.oct"));
EOF
    cat >> import_netcdf.m <<EOF
netcdf.${i#netcdf_} = @$i;
EOF

done
