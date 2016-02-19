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
## @deftypefn  {Function File} {} ncwrite (@var{filename}, @var{varname}, @var{x})
## @deftypefnx  {Function File} {} ncwrite (@var{filename}, @var{varname}, @var{x}, @var{start}, @var{stride})
##
## Write array @var{x} to the the variable @var{varname} in the NetCDF file 
## @var{filename}.
##
## The variable with the name @var{varname} and the appropriate dimension must 
## already exist in the NetCDF file.
##
## If @var{start} and @var{stride} are present, a subset of the 
## variable is written. The parameter @var{start} contains the starting indices 
## (1-based) and @var{stride} the 
## increment between two successive elements. These parameters are vectors whose
## length is equal to the number of dimension of the variable. 
##
## If the variable has the _FillValue attribute, then the values equal to NaN 
## are replaced by corresponding fill value NetCDF attributes scale_factor 
## (default 1) and add_oddset (default 0) are use the transform the variable 
## during the writting:
##
## x_in_file = (x - add_offset)/scale_factor
##
## @seealso{ncread,nccreate}
##
## @end deftypefn

function ncwrite(filename,varname,x,start,stride)

ncid = netcdf_open(filename,'NC_WRITE');
[gid,varid] = ncvarid(ncid,varname);
[varname_,xtype,dimids,natts] = netcdf_inqVar(gid,varid);

% number of dimenions
nd = length(dimids);

sz = zeros(1,nd);
count = zeros(1,nd);

for i=1:length(dimids)
  [dimname, sz(i)] = netcdf_inqDim(gid,dimids(i));
  count(i) = size(x,i);
end

if nargin < 4
  start = ones(1,nd);
end

if nargin < 5
  stride = ones(1,nd);
end


% apply attributes

factor = [];
offset = [];
fv = [];

for i = 0:natts-1
  attname = netcdf_inqAttName(gid,varid,i);

  if strcmp(attname,'scale_factor')
    factor = netcdf_getAtt(gid,varid,'scale_factor');
  elseif strcmp(attname,'add_offset')
    offset = netcdf_getAtt(gid,varid,'add_offset');
  elseif strcmp(attname,'_FillValue')
    fv = netcdf_getAtt(gid,varid,'_FillValue');
  end    
end

if ~isempty(offset)
  x = x - offset;
end

if ~isempty(factor)
  x = x / factor;
end

if ~isempty(fv)
  x(isnan(x)) = fv;
end

netcdf_putVar(gid,varid,start-1,count,stride,x);

netcdf_close(ncid);
