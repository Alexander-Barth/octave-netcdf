#!/bin/sh
# Copyright (C) 2013 Alexander Barth
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; If not, see <http://www.gnu.org/licenses/>.
if [ "x$AWK" = "x" ]; then
	AWK=awk
fi

netcdf_functions=$($AWK -F'[(,]' '/DEFUN_DLD/ { print $2 } ' __netcdf__.cc)

outfile=../PKG_ADD
outfile_del=../PKG_DEL
importfile=../inst/import_netcdf.m

rm -f $outfile $outfile_del $importfile

echo '% File automatically generated by PKG_ADD.sh' > $importfile
echo '% File automatically generated by PKG_ADD.sh' > $outfile

for i in $netcdf_functions; do
    #echo ${i#netcdf_}
    cat >> $outfile <<EOF
autoload ("$i", fullfile (fileparts (mfilename ("fullpath")), "__netcdf__.oct"));
EOF
    cat >> $importfile <<EOF
netcdf.${i#netcdf_} = @$i;
EOF

done


echo '% File automatically generated by PKG_ADD.sh' > $outfile_del

for i in $netcdf_functions; do
    #echo ${i#netcdf_}
    cat >> $outfile_del <<EOF
autoload ("$i", fullfile (fileparts (mfilename ("fullpath")), "__netcdf__.oct"),"remove");
EOF
done
