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


if nargin == 1    
    info.Filename = filename;

    % format
    format = netcdf_inqFormat(ncid);
    info.Format = lower(strrep(format,'FORMAT_',''));
    
    % dimensions
    unlimdimIDs = netcdf_inqUnlimDims(ncid);
    [ndims,nvars,ngatts] = netcdf_inq(ncid);
    
    % need to check if this is necessary?
    info.Dimensions = [];
    for i=0:ndims-1
      tmp = struct();
      [tmp.Name,tmp.Length] = netcdf_inqDim(ncid,i);
      tmp.Unlimited = any(unlimdimIDs == i);
      
      if isempty(info.Dimensions) 
        info.Dimensions = [tmp];
      else
        info.Dimensions(i+1) = tmp;
      end
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
    
    nvars = netcdf_inqNVars(ncid);
    
    for i=1:nvars
        info.Variables(i) = ncinfo_var(ncid,filename,i-1);
    end
elseif nargin == 2
    varid = netcdf_inqVarID(ncid, varname);
    info = ncinfo_var(ncid,filename,varid);
end

netcdf_close(ncid);
end

function vinfo = ncinfo_var(ncid,filename,varid)


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

for i=1:length(dimids)
  tmp = struct();

  [tmp.Name, tmp.Length] = netcdf_inqDim(ncid,dimids(i));
  vinfo.Size(i) = tmp.Length;
  
  %tmp.Unlimited = ??
    
  if isempty(vinfo.Dimensions)
    vinfo.Dimensions = [tmp];
  else
    vinfo.Dimensions(i) = tmp;
  end
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
    
    if strcmp(tmp.Name,'_FillValue')
      vinfo.FillValue = tmp.Value;
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
