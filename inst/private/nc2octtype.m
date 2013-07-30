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

function otype = nc2octtype(nctype)

if nctype == netcdf_getConstant("NC_CHAR")
  otype = "char";
elseif nctype == netcdf_getConstant("NC_FLOAT")
  otype = "single";
elseif nctype == netcdf_getConstant("NC_DOUBLE")
  otype = "double";
elseif nctype == netcdf_getConstant("NC_BYTE")
  otype = "int8";
elseif nctype == netcdf_getConstant("NC_SHORT")
  otype = "int16";
elseif nctype == netcdf_getConstant("NC_INT")
  otype = "int32";
elseif nctype == netcdf_getConstant("NC_INT64")
  otype = "int64";
elseif nctype == netcdf_getConstant("NC_UBYTE")
  otype = "uint8";
elseif nctype == netcdf_getConstant("NC_USHORT")
  otype = "uint16";
elseif nctype == netcdf_getConstant("NC_UINT")
  otype = "uint32";
elseif nctype == netcdf_getConstant("NC_UINT64")
  otype = "uint64";
else
  error("netcdf:unknownDataType","unknown data type %d",xtype)
endif
