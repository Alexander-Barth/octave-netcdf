% Information about complete NetCDF file or variable.
%
% finfo = ncinfo(filename)
% vinfo = ncinfo(filename,varname)
% return information about complete NetCDF file (filename) or about
% the specific variable varname.
%
% vinfo.Size: the size of the netcdf variable. For vectors the Size field
%   has only one element.
%
%
function info = ncinfo(filename,varname)

ncid = netcdf_open(filename,'NC_NOWRITE');
unlimdimIDs = netcdf_inqUnlimDims(ncid);

if nargin == 1    
    info.Filename = filename;
    info.Name = '/';
    
    % format
    format = netcdf_inqFormat(ncid);
    info.Format = lower(strrep(format,'FORMAT_',''));
    
    % dimensions
    [ndims,nvars,ngatts] = netcdf_inq(ncid);
    
    % need to check if this is necessary?
    info.Dimensions = ncinfo_dim(ncid,0:ndims-1,unlimdimIDs);

    
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
    
    nvars = netcdf_inqNVars(ncid);
    
    for i=1:nvars
        info.Variables(i) = ncinfo_var(ncid,filename,i-1,unlimdimIDs);
    end
elseif nargin == 2
    varid = netcdf_inqVarID(ncid, varname);
    info = ncinfo_var(ncid,filename,varid,unlimdimIDs);
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


function vinfo = ncinfo_var(ncid,filename,varid,unlimdimIDs)


%varid = netcdf_inqVarID(ncid, varname)
[vinfo.Name,xtype,dimids,natts] = netcdf_inqVar(ncid,varid);

%vinfo.Filename = filename;

% number of dimenions
nd = length(dimids);


if nd == 0
  vinfo.Size = 1;
else
  vinfo.Size = zeros(1,nd);
end

vinfo.Dimensions = [];
vinfo.FillValue = [];

% Data type

if xtype == netcdf_getConstant('NC_CHAR')
  vinfo.Datatype = 'char';
elseif xtype == netcdf_getConstant('NC_FLOAT')
  vinfo.Datatype = 'float';
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

% Information about dimension

vinfo.Dimensions = ncinfo_dim(ncid,dimids,unlimdimIDs);
if isempty(vinfo.Dimensions)
  vinfo.Size = [];
else
  vinfo.Size = cat(2,vinfo.Dimensions.Length);
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
%[nofill,vinfo.FillValue] = netcdf_inqVarFill(ncid,varid);

[vinfo.Shuffle,deflate,vinfo.DeflateLevel] = ...
    netcdf_inqVarDeflate(ncid,varid);

if ~deflate
  vinfo.DeflateLevel = [];
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
