
function val = ncreadatt(filename,varname,attname)

ncid = netcdf_open(filename,'NC_NOWRITE');

if strcmp(varname,'/') %varname for global attributes
    varid=netcdf_getConstant('NC_GLOBAL');
    [~,~,natts]=netcdf_inq(ncid);
else
    varid = netcdf_inqVarID(ncid, varname);
    [~,~,~,natts] = netcdf_inqVar(ncid,varid);
end;


val = [];
found = 0;

for i = 0:natts-1
  if strcmp(netcdf_inqAttName(ncid,varid,i),attname)    
    val = netcdf_getAtt(ncid,varid,attname);
    found = 1;
    break
  end
end

netcdf_close(ncid);

if ~found
  error('netcdf:readAttrib','attribute not found');
end

