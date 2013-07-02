
function [gid,varid] = ncvarid(ncid,varname)

if strcmp(varname(1), '/')
  i = find(varname == '/',1,'last');
  groupname = varname(1:i-1);
  varname = varname(i+1:end);
  gid = netcdf_inqGrpFullNcid(ncid,groupname);
else
  gid = ncid;
end

varid = netcdf_inqVarID(gid, varname);

