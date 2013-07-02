function ncwriteatt(filename,varname,attname,val)

ncid = netcdf_open(filename,'NC_WRITE');
netcdf_reDef(ncid);

if strcmp(varname,'/')
  varid = 0;
else
  varid = netcdf_inqVarID(ncid, varname);
end

netcdf_putAtt(ncid,varid,attname,val);

netcdf_close(ncid);
