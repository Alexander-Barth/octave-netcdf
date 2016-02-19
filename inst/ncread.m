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
## @deftypefn  {Function File} {@var{x} =} ncread (@var{filename}, @var{varname})
## @deftypefnx  {Function File} {@var{x} =} ncread (@var{filename}, @var{varname},@var{start},@var{count},@var{stride})
##
## Read the variable @var{varname} from the NetCDF file @var{filename}.
##
## If @var{start},@var{count} and @var{stride} are present, a subset of the 
## variable is loaded. The parameter @var{start} contains the starting indices 
## (1-based), @var{count} is the number of elements and @var{stride} the 
## increment between two successive elements. These parameters are vectors whose
## length is equal to the number of dimension of the variable. Elements of 
## @var{count} might be Inf which means that as many values as possible are 
## loaded.
##
## If the variable has the _FillValue attribute, then the corresponding values
## are replaced by NaN (except for characters). NetCDF attributes scale_factor 
## (default 1) and add_offset (default 0) are use the transform the variable 
## during the loading:
##
## x = scale_factor * x_in_file + add_offset
##
## The output data type matches the NetCDF datatype, except when the attributes
## _FillValue, add_offset or scale_factor are defined in which case the output 
## is a array in double precision.
##
## Note that values equal to the attribute missing_value are not replaced by 
## NaN (for compatibility).
##
## @seealso{ncwrite,ncinfo,ncdisp}
##
## @end deftypefn

function x = ncread(filename,varname,start,count,stride)

ncid = netcdf_open(filename,'NC_NOWRITE');
[gid,varid] = ncvarid(ncid,varname);
[varname_,xtype,dimids,natts] = netcdf_inqVar(gid,varid);

% number of dimenions
nd = length(dimids);

sz = zeros(1,nd);
for i=1:length(dimids)
  [dimname, sz(i)] = netcdf_inqDim(gid,dimids(i));
end

if nargin < 3
  start = ones(1,nd);
end

if nargin < 4
  count = inf*ones(1,nd);
end

if nargin < 5
  stride = ones(1,nd);
end

% replace inf in count
i = count == inf;
count(i) = (sz(i)-start(i))./stride(i) + 1;

x = netcdf_getVar(gid,varid,start-1,count,stride);

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

netcdf_close(ncid);

# the scaling does not make sense of characters
if xtype == netcdf_getConstant('char') || ...
   xtype == netcdf_getConstant('string')

   return;
end

if !isempty(fv) || !isempty(factor) || !isempty(offset)
  if !isa(x,'double')
    x = double(x);
  end
end

if !isempty(fv)
  x(x == fv) = NaN;
end

if !isempty(factor)
  x = x * factor;
end

if !isempty(offset)
  x = x + offset;
end

