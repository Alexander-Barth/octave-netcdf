function test_netcdf_type(nctype,octtype)
import_netcdf

m = 5;
n = 10;

fname = [tempname '-octave-netcdf- ' nctype '.nc'];

mode =  bitor(netcdf.getConstant('NC_CLOBBER'),...
              netcdf.getConstant('NC_NETCDF4'));

ncid = netcdf.create(fname,mode);

dimids = [netcdf.defDim(ncid,'lon',m) ...
          netcdf.defDim(ncid,'time',n)];


varid = netcdf.defVar(ncid,'variable',nctype,dimids);
netcdf.endDef(ncid)

if strcmp(octtype,'char')
  z = char(floor(26*rand(m,n)) + 65);

  testvals = 'a';
  testvalv = 'this is a name';
else  
  z = zeros(m,n,octtype);
  z(:) = randn(m,n);
  
  testvals = zeros(1,1,octtype);
  testvals(:) = rand(1,1);
  
  testvalv = zeros(1,5,octtype);
  testvalv(:) = rand(size(testvalv));
  
end

netcdf.putVar(ncid,varid,z);
z2 = netcdf.getVar(ncid,varid);

assert(isequal(z,z2))

netcdf.putAtt(ncid,varid,'scalar_attribute',testvals);
val = netcdf.getAtt(ncid,varid,'scalar_attribute');
assert(isequal(val,testvals));
assert(strcmp(class(val),octtype))

[xtype,len] = netcdf.inqAtt(ncid,varid,'scalar_attribute');
assert(xtype == netcdf.getConstant(nctype))
assert(len == numel(testvals));

netcdf.putAtt(ncid,varid,'vector_attribute',testvalv);
val = netcdf.getAtt(ncid,varid,'vector_attribute');
assert(isequal(val,testvalv));
assert(strcmp(class(val),octtype))

[xtype,len] = netcdf.inqAtt(ncid,varid,'vector_attribute');
assert(xtype == netcdf.getConstant(nctype))
assert(len == numel(testvalv));

netcdf.close(ncid);
delete(fname);

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
