%% Copyright (C) 2013-2014 Alexander Barth
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

function test_netcdf_attributes()
import_netcdf


% rename attributes

fname = [tempname '-octave-netcdf-rename-attrib.nc'];
ncid = netcdf.create(fname,'NC_CLOBBER');
gid = netcdf.getConstant('global');
netcdf.putAtt(ncid,gid,'toto',int8(123));
name = netcdf.inqAttName(ncid,gid,0);
assert(strcmp(name,'toto'));
netcdf.renameAtt(ncid,gid,'toto','lala');
name = netcdf.inqAttName(ncid,gid,0);
assert(strcmp(name,'lala'));
netcdf.close(ncid);
delete(fname)


% delete attributes

fname = [tempname '-octave-netcdf-delete-attrib.nc'];
ncid = netcdf.create(fname,'NC_CLOBBER');
gid = netcdf.getConstant('global');
netcdf.putAtt(ncid,gid,'toto',int8(123));
varid = netcdf.defVar(ncid,'double_var','double',[]);
[ndims,nvars,natts] = netcdf.inq(ncid);
assert(natts == 1);
netcdf.delAtt(ncid,gid,'toto');
[ndims,nvars,natts] = netcdf.inq(ncid);
assert(natts == 0);
netcdf.close(ncid);
delete(fname)

% copy attributes

fname = [tempname '-octave-netcdf-copy-attrib.nc'];
ncid = netcdf.create(fname,'NC_CLOBBER');
gid = netcdf.getConstant('global');
netcdf.putAtt(ncid,gid,'toto',int8(123));
varid = netcdf.defVar(ncid,'double_var','double',[]);
netcdf.copyAtt(ncid,gid,'toto',ncid,varid);
[ndims,nvars,natts] = netcdf.inq(ncid);
assert(natts == 1);
[varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
val = netcdf.getAtt(ncid,varid,'toto');
assert(isequal(val,123));
netcdf.close(ncid);
delete(fname)

% attributes id

fname = [tempname '-octave-netcdf-delete-attrib.nc'];
ncid = netcdf.create(fname,'NC_CLOBBER');
gid = netcdf.getConstant('global');
netcdf.putAtt(ncid,gid,'toto',int8(123));
attnum = netcdf.inqAttID(ncid,gid,'toto');
name = netcdf.inqAttName(ncid,gid,attnum);
assert(strcmp(name,'toto'))
netcdf.close(ncid);
delete(fname)



% test one unlimited dimensions
fname = [tempname '-octave-netcdf-unlimdim.nc'];
ncid = netcdf.create(fname,'NC_CLOBBER');
dimID = netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
unlimdimIDs = netcdf.inqUnlimDims(ncid);
assert(dimID == unlimdimIDs);
netcdf.close(ncid);
delete(fname)


% test netcdf_classic format
fname = [tempname '-octave-netcdf-classic-model.nc'];
mode =  bitor(netcdf.getConstant('classic_model'),netcdf.getConstant('netcdf4'));
ncid = netcdf.create(fname,mode);
netcdf.close(ncid);
info = ncinfo(fname);
assert(strcmp(info.Format,'netcdf4_classic'));
delete(fname);


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


% test fill mode
fname = [tempname '-octave-netcdf-fill-mode.nc'];
mode =  bitor(netcdf.getConstant('NC_CLOBBER'),netcdf.getConstant('NC_NETCDF4'));
ncid = netcdf.create(fname,mode);
old_mode = netcdf.setFill(ncid,'nofill');
old_mode = netcdf.setFill(ncid,'nofill');
assert(old_mode == netcdf.getConstant('nofill'))
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


% checksum
fname = [tempname '-octave-netcdf-checksum.nc'];
ncid = netcdf.create(fname,'NC_NETCDF4');
dimids = [netcdf.defDim(ncid,'x',123) netcdf.defDim(ncid,'y',12)];
varid = netcdf.defVar(ncid,'double_var','double',dimids);
checksum = netcdf.inqVarFletcher32(ncid,varid);
assert(strcmp(checksum,'NOCHECKSUM'))
netcdf.defVarFletcher32(ncid,varid,'fletcher32');
checksum = netcdf.inqVarFletcher32(ncid,varid);
assert(strcmp(checksum,'FLETCHER32'))
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
netcdf.close(ncid);
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
