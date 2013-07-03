% resolves a location (variable or group) by name

function [gid,varid] = ncloc(ncid,name)

try
  # try if name is a group
  gid = netcdf_inqGrpFullNcid(ncid,name);
  varid = [];
catch
  # assume that name is a variable
  [gid,varid] = ncvarid(ncid,name);
end_try_catch
