% test netcdf constants
function test_netcdf_constant()
import_netcdf

names = netcdf.getConstantNames();
assert(any(strcmp(names,'NC_WRITE')));

assert(netcdf.getConstant('NC_NOWRITE') == 0)
assert(netcdf.getConstant('NC_WRITE') == 1)

assert(netcdf.getConstant('NC_64BIT_OFFSET') == ...
       netcdf.getConstant('64BIT_OFFSET'))

assert(netcdf.getConstant('NC_64BIT_OFFSET') == ...
       netcdf.getConstant('64bit_offset'))

assert(isa(netcdf.getConstant('fill_byte'),'int8'))
assert(isa(netcdf.getConstant('fill_ubyte'),'uint8'))
assert(isa(netcdf.getConstant('fill_float'),'single'))

failed = 0;
try
  % should trow exception
  netcdf.getConstant('not_found')
  % should never be reached
  failed = 1;
catch  
end
assert(~failed);
