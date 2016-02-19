
import_netcdf

% 2 dimensions

fname = [tempname '-octave-netcdf.nc'];

ncid = netcdf.create(fname,'NC_CLOBBER');
dimid = netcdf.defDim(ncid,'time',0);
varidd = netcdf.defVar(ncid,'time','double',[dimid]);
netcdf.close(ncid)


ncid = netcdf.open(fname,'NC_NOWRITE');
varid = netcdf.inqVarID(ncid, 'time');
x = netcdf.getVar(ncid,varid);
netcdf.close(ncid)

