function mode = format2mode(format)

mode = netcdf_getConstant("NC_NOCLOBBER");
  
switch lower(format)
 case "classic"
  % do nothing
 case "64bit"
  mode = bitor(mode,netcdf_getConstant("NC_64BIT_OFFSET"));
 case "netcdf4_classic"
  mode = bitor(bitor(mode,netcdf_getConstant("NC_NETCDF4")),...
               netcdf_getConstant("NC_CLASSIC_MODEL"));
  
 case "netcdf4"
    mode = bitor(mode,netcdf_getConstant("NC_NETCDF4"));
 otherwise
  error("netcdf:unkownFormat","unknown format %s",format);
end
