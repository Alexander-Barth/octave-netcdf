%% Copyright (C) 2013 Alexander Barth
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.

function test_netcdf_low_level_interface

import_netcdf

% 2 dimensions

fname = [tempname '-octave-netcdf.nc'];

ncid = netcdf.create(fname,'NC_CLOBBER');
assert(strcmp(netcdf.inqFormat(ncid),'FORMAT_CLASSIC'));

n = 10;
m = 5;

dimid_lon = netcdf.defDim(ncid,'lon',m);
dimid = netcdf.defDim(ncid,'time',n);

varidd = netcdf.defVar(ncid,'double_var','double',[dimid_lon,dimid]);

varid = netcdf.defVar(ncid,'byte_var','byte',[dimid]);

varidf = netcdf.defVar(ncid,'float_var','float',[dimid]);

varidi = netcdf.defVar(ncid,'int_var','int',[dimid]);

varids = netcdf.defVar(ncid,'short_var','short',[dimid]);
assert(varidd == netcdf.inqVarID(ncid,'double_var'))

[numdims, numvars, numglobalatts, unlimdimID] = netcdf.inq(ncid);
assert(numvars == 5)

[varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varidd);
assert(strcmp(varname,'double_var'));

[dimname,len] = netcdf.inqDim(ncid,dimid);
assert(len == n);
assert(strcmp(dimname,'time'));


types = {'double','float','byte','short','int'};


for i=1:length(types)
  vid{i} = netcdf.defVar(ncid,[types{i} '_variable'],types{i},[dimid_lon,dimid]);
end


netcdf.endDef(ncid)


z = randn(m,n);
netcdf.putVar(ncid,varidd,z);

varf = randn(n,1);
netcdf.putVar(ncid,varidf,varf);

vari = floor(randn(n,1));
netcdf.putVar(ncid,varidi,vari);

netcdf.putVar(ncid,varids,[1:n])

z2 = netcdf.getVar(ncid,varidd);
assert(all(all(abs(z2 - z) < 1e-5)))

z2 = netcdf.getVar(ncid,varidd,[0 0]);
assert(z2 == z(1,1))

z2 = netcdf.getVar(ncid,varidd,[2 2],[3 5]);
assert(isequal(z2,z(3:5,3:7)))

z2 = netcdf.getVar(ncid,varidd,[2 2],[3 4],[1 2]);
assert(isequal(z2,z(3:5,3:2:9)))


netcdf.putVar(ncid,varidd,[0 0],123.);
z(1,1) = 123;
z2 = netcdf.getVar(ncid,varidd);
assert(isequal(z,z2))

netcdf.putVar(ncid,varidd,[2 2],[3 3],ones(3,3));
z(3:5,3:5) = 1;
z2 = netcdf.getVar(ncid,varidd);
assert(isequal(z,z2))


netcdf.putVar(ncid,varidd,[0 0],[3 5],[2 2],zeros(3,5));
z(1:2:5,1:2:9) = 0;
z2 = netcdf.getVar(ncid,varidd);
assert(isequal(z,z2))


z2 = netcdf.getVar(ncid,varidf);
assert(all(z2 - varf < 1e-5))


vari2 = netcdf.getVar(ncid,varidi);
assert(all(vari2 == vari))


netcdf.close(ncid);
delete(fname);

% test with different dimensions

for i = 1:5
  nc_test_ndims(i);
end



function nc_test_ndims(ndims)
import_netcdf

fname = [tempname '-octave-netcdf.nc'];

ncid = netcdf.create(fname,'NC_CLOBBER');

sz = ones(1,ndims);
dimids = ones(1,ndims);

for i = 1:ndims
  sz(i) = 10+i;  
  dimids(i) = netcdf.defDim(ncid,sprintf('dim%g',i),sz(i));  
end

varid = netcdf.defVar(ncid,'double_var','double',dimids);

[varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
assert(strcmp(varname,'double_var'));

for i = 1:ndims
  [dimname,len] = netcdf.inqDim(ncid,dimids(i));  
  assert(len == sz(i));
  assert(strcmp(dimname,sprintf('dim%g',i)));
end


netcdf.endDef(ncid)

if ndims == 1
  z = randn(sz,1);
else
  z = randn(sz);
end

netcdf.putVar(ncid,varid,z);


z2 = netcdf.getVar(ncid,varid);
assert(isequal(z,z2))

z2 = netcdf.getVar(ncid,varid,zeros(ndims,1));
assert(z2 == z(1))

start = 2 * ones(1,ndims);
count = 5 * ones(1,ndims);
z2 = netcdf.getVar(ncid,varid,start,count);
idx = scs(start,count);
assert(isequal(z2,z(idx{:})))


start = 2 * ones(1,ndims);
count = 5 * ones(1,ndims);
stride = 2 * ones(1,ndims);
z2 = netcdf.getVar(ncid,varid,start,count,stride);
idx = scs(start,count,stride);
assert(isequal(z2,z(idx{:})))


% put with start
start = zeros(1,ndims);
netcdf.putVar(ncid,varid,start,123.);
z(1) = 123;
z2 = netcdf.getVar(ncid,varid);
assert(isequal(z,z2))


% put with start and count

start = 2 * ones(1,ndims);
count = 5 * ones(1,ndims);
if ndims == 1
    data = ones(count,1);
else
    data = ones(count);
end
netcdf.putVar(ncid,varid,start,count,data);
idx = scs(start,count);
z(idx{:}) = 1;
z2 = netcdf.getVar(ncid,varid);
assert(isequal(z,z2))

% put with start, count and stride

start = 2 * ones(1,ndims);
count = 5 * ones(1,ndims);
stride = 2 * ones(1,ndims);
if ndims == 1
    data = zeros(count,1);
else
    data = zeros(count);
end
netcdf.putVar(ncid,varid,start,count,stride,data);
idx = scs(start,count,stride);
z(idx{:}) = 0;
z2 = netcdf.getVar(ncid,varid);
assert(isequal(z,z2))



netcdf.close(ncid);
delete(fname);

function idx = scs(start,count,stride)
idx = cell(length(start),1);

if nargin == 2
  stride = ones(length(start),1);
end
  
for i = 1:length(start)
  idx{i} = start(i) + 1 + stride(i) * [0:count(i)-1];
end
