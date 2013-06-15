function test_netcdf_package_type(nctype,octtype);

import_netcdf

%fprintf('\n%s\n',nctype)

m = 5;
n = 10;

fname = sprintf('foo-%s.nc',nctype);
delete(fname);
mode =  bitor(netcdf.getConstant('NC_CLOBBER'),netcdf.getConstant('NC_NETCDF4'));
ncid = netcdf.create(fname,mode);

dimid_lon = netcdf.defDim(ncid,'lon',m);
dimid = netcdf.defDim(ncid,'time',n);


varid = netcdf.defVar(ncid,'variable',nctype,[dimid_lon,dimid]);
netcdf.endDef(ncid)

if strcmp(octtype,'char')
  z = char(floor(26*rand(m,n)) + 65);

  netcdf.putVar(ncid,varid,z);
  z2 = netcdf.getVar(ncid,varid);
  
  assert(isequal(z,z2))
else
  
 z = zeros(m,n,octtype);
 z(:) = randn(m,n);

 netcdf.putVar(ncid,varid,z);
 z2 = netcdf.getVar(ncid,varid);

 assert(all(all(abs(z2 - z) < 1e-5)))
end



netcdf.close(ncid);
