function test_netcdf_create
import_netcdf
fname = [tempname '-octave-netcdf.nc'];

ncid = netcdf.create(fname,'NC_CLOBBER');
assert(strcmp(netcdf.inqFormat(ncid),'FORMAT_CLASSIC'));

netcdf.close(ncid);
delete(fname);
