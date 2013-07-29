function test_netcdf_low_level_interface

import_netcdf

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
