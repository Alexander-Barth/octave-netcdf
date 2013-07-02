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
