## Copyright (C) 2013 Alexander Barth
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} ncwriteatt(@var{filename},@var{varname},@var{attname},@var{val})
##
## Defines the attribute @var{attname} of the variable @var{varname} in the file
## @var{filename} with the value @var{val}.
##
## Gobal attributes can be defined by using "/" or the group name as 
## @var{varname}. The type of value is mapped to the NetCDF data types.
## (see @code{ncinfo}).
##
## @seealso{ncinfo}
##
## @end deftypefn

function ncwriteatt(filename,varname,attname,val)

ncid = netcdf_open(filename,'NC_WRITE');
netcdf_reDef(ncid);

[gid,varid] = ncloc(ncid,varname);

if isempty(varid)
  varid = netcdf_getConstant('NC_GLOBAL');
endif

netcdf_putAtt(ncid,varid,attname,val);

netcdf_close(ncid);
