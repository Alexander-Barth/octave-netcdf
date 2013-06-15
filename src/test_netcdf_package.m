import_netcdf

libver = netcdf.inqLibVers();

fname = [tmpnam '-octave-netcdf.nc'];

ncid = netcdf.create(fname,'NC_CLOBBER');
assert(strcmp(netcdf.inqFormat(ncid),'FORMAT_CLASSIC'));

assert(netcdf.getConstant('NC_NOWRITE') == 0)
assert(netcdf.getConstant('NC_WRITE') == 1)

netcdf.getConstantNames();

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

netcdf.putAtt(ncid,varidd,'toto',int8(123));
netcdf.putAtt(ncid,varidd,'toto32',int32(123));
%netcdf.putAtt(ncid,varidd,'toto64',int64(123)); % does not work in octave and matlab
netcdf.putAtt(ncid,varidd,'add_offset',single(123123.123));
netcdf.putAtt(ncid,varidd,'_FillValue',double(123123.123));
netcdf.putAtt(ncid,varidd,'name','this is a name');

assert(isequal(netcdf.getAtt(ncid,varidd,'add_offset'),single(123123.123)));

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

test_netcdf_package_type('byte','int8');
test_netcdf_package_type('ubyte','uint8');
test_netcdf_package_type('short','int16');
test_netcdf_package_type('ushort','uint16');
test_netcdf_package_type('int','int32');
test_netcdf_package_type('uint','uint32');
test_netcdf_package_type('int64','int64');
test_netcdf_package_type('uint64','uint64');

test_netcdf_package_type('double','double');
test_netcdf_package_type('float','single');

test_netcdf_package_type('char','char');


test_scalar_variable
test_netcdf_hl

