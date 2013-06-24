import_netcdf

libver = netcdf.inqLibVers();

fname = [tempname '-octave-netcdf.nc'];

ncid = netcdf.create(fname,'NC_CLOBBER');
assert(strcmp(netcdf.inqFormat(ncid),'FORMAT_CLASSIC'));

unlimdimIDs = netcdf.inqUnlimDims(ncid);
assert(isempty(unlimdimIDs));

assert(netcdf.getConstant('NC_NOWRITE') == 0)
assert(netcdf.getConstant('NC_WRITE') == 1)

assert(netcdf.getConstant('NC_64BIT_OFFSET') == ...
       netcdf.getConstant('64BIT_OFFSET'))

assert(netcdf.getConstant('NC_64BIT_OFFSET') == ...
       netcdf.getConstant('64bit_offset'))

assert(isa(netcdf.getConstant('fill_byte'),'int8'))
assert(isa(netcdf.getConstant('fill_ubyte'),'uint8'))
assert(isa(netcdf.getConstant('fill_float'),'single'))


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

[xtype,len] = netcdf.inqAtt(ncid,varidd,'name');
assert(xtype == netcdf.getConstant('NC_CHAR'))
assert(len == length('this is a name'))

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


% test one unlimited dimensions
fname = [tempname '-octave-netcdf-unlimdim.nc'];
ncid = netcdf.create(fname,'NC_CLOBBER');
dimID = netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
unlimdimIDs = netcdf.inqUnlimDims(ncid);
assert(dimID == unlimdimIDs);
netcdf.close(ncid);
delete(fname)


% test two unlimited dimensions
fname = [tempname '-octave-netcdf-2unlimdim.nc'];
mode =  bitor(netcdf.getConstant('NC_CLOBBER'),netcdf.getConstant('NC_NETCDF4'));
ncid = netcdf.create(fname,mode);
dimID = netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
dimID2 = netcdf.defDim(ncid,'time2',netcdf.getConstant('NC_UNLIMITED'));
unlimdimIDs = netcdf.inqUnlimDims(ncid);
assert(isequal(sort([dimID,dimID2]),sort(unlimdimIDs)));
netcdf.close(ncid);
delete(fname);


% deflate for 64bit_offset files
fname = [tempname '-octave-netcdf-deflate.nc'];
ncid = netcdf.create(fname,'64BIT_OFFSET');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','double',dimids);
[shuffle,deflate,deflateLevel] = netcdf.inqVarDeflate(ncid,varid);
assert(shuffle == 0)
assert(deflate == 0)
assert(deflateLevel == 0)
netcdf.close(ncid);
%system(['ncdump -h ' fname])
delete(fname);


% deflate
fname = [tempname '-octave-netcdf-deflate.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','double',dimids);
netcdf.defVarDeflate(ncid,varid,true,true,9);
[shuffle,deflate,deflateLevel] = netcdf.inqVarDeflate(ncid,varid);
assert(shuffle)
assert(deflate)
assert(deflateLevel == 9)
netcdf.close(ncid);
%system(['ncdump -h ' fname])
delete(fname);



% chunking - contiguous storage
fname = [tempname '-octave-netcdf-chunking.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','double',dimids);
netcdf.defVarChunking(ncid,varid,'contiguous');
[storage,chunksize] = netcdf.inqVarChunking(ncid,varid);
assert(strcmp(storage,'contiguous'))
assert(isempty(chunksize))
netcdf.close(ncid);
%system(['ncdump -h ' fname])
delete(fname);


% chunking - chunked storage
fname = [tempname '-octave-netcdf-chunking.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','double',dimids);
netcdf.defVarChunking(ncid,varid,'chunked',[3 4]);
[storage,chunksize] = netcdf.inqVarChunking(ncid,varid);
assert(strcmp(storage,'chunked'))
assert(isequal(chunksize,[3 4]))
netcdf.close(ncid);
%system(['ncdump -h ' fname])
delete(fname);


% variable fill
fname = [tempname '-octave-netcdf-fill.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','double',dimids);
netcdf.defVarFill(ncid,varid,false,-99999.);
[nofill,fillval] = netcdf.inqVarFill(ncid,varid);
assert(isequal(nofill,false))
assert(fillval == -99999.)
netcdf.close(ncid);
%system(['ncdump -h ' fname])
delete(fname);

% variable fill single
fname = [tempname '-octave-netcdf-fill.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'single_var','float',dimids);
netcdf.defVarFill(ncid,varid,false,single(-99999.));
[nofill,fillval] = netcdf.inqVarFill(ncid,varid);
assert(isequal(nofill,false))
assert(fillval == -99999.)
netcdf.close(ncid);
%system(['ncdump -h ' fname])
delete(fname);


% variable fill char
fname = [tempname '-octave-netcdf-fill-char.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','char',dimids);
netcdf.defVarFill(ncid,varid,false,'X');
[fill,fillval] = netcdf.inqVarFill(ncid,varid);
assert(~fill)
assert(fillval == 'X')
netcdf.close(ncid);
delete(fname);



% check default state of fill
fname = [tempname '-octave-netcdf-fill.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','double',dimids);
[nofill,fillval] = netcdf.inqVarFill(ncid,varid);
assert(isequal(nofill,false))
netcdf.close(ncid);
%system(['ncdump -h ' fname])
delete(fname);


% create groups
fname = [tempname '-octave-netcdf-groups.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
id1 = netcdf.defGrp(ncid,'group1');
id2 = netcdf.defGrp(ncid,'group2');
id3 = netcdf.defGrp(id1,'subgroup');
ids = netcdf.inqGrps(ncid);
assert(isequal(sort([id1,id2]),sort(ids)));

id4 = netcdf.inqNcid(ncid,'group1');
assert(id1 == id4)

name = netcdf.inqGrpName(id3);
assert(strcmp(name,'subgroup'))

name = netcdf.inqGrpNameFull(id3);
assert(strcmp(name,'/group1/subgroup'))

parentid = netcdf.inqGrpParent(id3);
assert(id1 == parentid);

if 0
  id3bis = netcdf.inqGrpFullNcid(ncid,'/group1/subgroup');
  assert(id3 == id3bis);
end

netcdf.close(ncid);
%system(['ncdump -h ' fname])
delete(fname);



% check rename dimension
fname = [tempname '-octave-rename-dim.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimid = netcdf.defDim(ncid,'x',123);
[name,len] = netcdf.inqDim(ncid,dimid);
assert(strcmp(name,'x'));
netcdf.renameDim(ncid,dimid,'y');
[name,len] = netcdf.inqDim(ncid,dimid);
assert(strcmp(name,'y'));
delete(fname);


% rename variable
fname = [tempname '-octave-netcdf-rename-var.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','char',dimids);
[varname] = netcdf.inqVar(ncid,varid);
assert(strcmp(varname,'double_var'));
netcdf.renameVar(ncid,varid,'doublev');
[varname] = netcdf.inqVar(ncid,varid);
assert(strcmp(varname,'doublev'));
netcdf.close(ncid);
delete(fname);

test_netcdf_hl

