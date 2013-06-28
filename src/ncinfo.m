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
## @deftypefn  {Function File} @var{finfo} = ncinfo (@var{filename})
## @deftypefnx  {Function File} @var{vinfo} = ncinfo (@var{filename}, @var{varname})
## return information about complete NetCDF file @var{filename} or about
## the specific variable @var{varname}.
##
## vinfo.Size: the size of the netcdf variable. For vectors the Size field
##   has only one element.
##
## Note: If there are no attributes (or variable or groups), the corresponding 
## field is an empty matrix and not an empty struct array for compability
## with matlab.
##
## @seealso{ncread,nccreate}
##
## @end deftypefn

function info = ncinfo(filename,varname)

ncid = netcdf_open(filename,'NC_NOWRITE');

if nargin == 1    
    info.Filename = filename;    
    info = ncinfo_group(ncid,info);
    
    % format
    format = netcdf_inqFormat(ncid);
    info.Format = lower(strrep(format,'FORMAT_',''));    
elseif nargin == 2
    unlimdimIDs = netcdf_inqUnlimDims(ncid);
    varid = netcdf_inqVarID(ncid, varname);
    info = ncinfo_var(ncid,varid,unlimdimIDs);
end

netcdf_close(ncid);
end

function dims = ncinfo_dim(ncid,dimids,unlimdimIDs)

dims = [];
for i=1:length(dimids)
  tmp = struct();

  [tmp.Name, tmp.Length] = netcdf_inqDim(ncid,dimids(i));
  tmp.Unlimited = any(unlimdimIDs == dimids(i));
    
  if isempty(dims)
    dims = [tmp];
  else
    dims(i) = tmp;
  end
end
end


function vinfo = ncinfo_var(ncid,varid,unlimdimIDs)

[vinfo.Name,xtype,dimids,natts] = netcdf_inqVar(ncid,varid);

% Information about dimension

vinfo.Dimensions = ncinfo_dim(ncid,dimids,unlimdimIDs);
if isempty(vinfo.Dimensions)
  vinfo.Size = [];
else
  vinfo.Size = cat(2,vinfo.Dimensions.Length);
end

% Data type

if xtype == netcdf_getConstant('NC_CHAR')
  vinfo.Datatype = 'char';
elseif xtype == netcdf_getConstant('NC_FLOAT')
  vinfo.Datatype = 'single';
elseif xtype == netcdf_getConstant('NC_DOUBLE')
  vinfo.Datatype = 'double';
elseif xtype == netcdf_getConstant('NC_BYTE')
  vinfo.Datatype = 'int8';
elseif xtype == netcdf_getConstant('NC_SHORT')
  vinfo.Datatype = 'int16';
elseif xtype == netcdf_getConstant('NC_INT')
  vinfo.Datatype = 'int32';
elseif xtype == netcdf_getConstant('NC_INT64')
  vinfo.Datatype = 'int64';
elseif xtype == netcdf_getConstant('NC_UBYTE')
  vinfo.Datatype = 'uint8';
elseif xtype == netcdf_getConstant('NC_USHORT')
  vinfo.Datatype = 'uint16';
elseif xtype == netcdf_getConstant('NC_UINT')
  vinfo.Datatype = 'uint32';
elseif xtype == netcdf_getConstant('NC_UINT64')
  vinfo.Datatype = 'uint64';
else
  error('netcdf:unknownDataType','unknown data type %d',xtype)
end


% Attributes

vinfo.Attributes = [];

for i = 0:natts-1  
    tmp = struct();
    tmp.Name = netcdf_inqAttName(ncid,varid,i);
    tmp.Value = netcdf_getAtt(ncid,varid,tmp.Name);
    
    if isempty(vinfo.Attributes)      
      vinfo.Attributes = [tmp];
    else
      vinfo.Attributes(i+1) = tmp;
    end    
end

% chunking, fillvalue, compression

[storage,vinfo.ChunkSize] = netcdf_inqVarChunking(ncid,varid);

[nofill,vinfo.FillValue] = netcdf_inqVarFill(ncid,varid);
if nofill
  vinfo.FillValue = [];
end

[shuffle,deflate,vinfo.DeflateLevel] = ...
    netcdf_inqVarDeflate(ncid,varid);

if ~deflate
  vinfo.DeflateLevel = [];
end
vinfo.Shuffle = shuffle;

# add checksum information if defined (unlike matlab)
checksum = netcdf_inqVarFletcher32(ncid,varid);
if ~strcmp(checksum,'nochecksum');
  vinfo.Checksum = checksum;
end

end


function info = ncinfo_group(ncid,info)
if nargin == 1
  info = struct();
end

info.Name = netcdf_inqGrpName(ncid);
unlimdimIDs = netcdf_inqUnlimDims(ncid);

[ndims,nvars,ngatts] = netcdf_inq(ncid);

% dimensions

dimids = netcdf_inqDimIDs(ncid);
info.Dimensions = ncinfo_dim(ncid,dimids,unlimdimIDs);

% variables
for i=1:nvars
  info.Variables(i) = ncinfo_var(ncid,i-1,unlimdimIDs);
end

% global attributes
info.Attributes = [];
gid = netcdf_getConstant('NC_GLOBAL');
for i = 0:ngatts-1  
  tmp = struct();
  tmp.Name = netcdf_inqAttName(ncid,gid,i);
  tmp.Value = netcdf_getAtt(ncid,gid,tmp.Name);
  
  if isempty(info.Attributes)      
    info.Attributes = [tmp];
  else
    info.Attributes(i+1) = tmp;
  end
end

info.Groups = [];
gids = netcdf_inqGrps(ncid);
for i = 1:length(gids)
  tmp = ncinfo_group(gids(i));
  
  if isempty(info.Groups)      
    info.Groups = [tmp];
  else
    info.Groups(i) = tmp;
  end
end

end


%% Copyright (C) 2013 Alexander Barth
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.
