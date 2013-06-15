fname = [tempname '-octave-netcdf.nc'];
ncid = netcdf.create(fname,'NC_CLOBBER');
varidd_scalar = netcdf.defVar(ncid,'double_scalar','double',[]);
netcdf.close(ncid);
delete(fname);
