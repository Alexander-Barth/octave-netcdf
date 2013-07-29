function test_netcdf_datatypes()

test_netcdf_type('byte','int8');
test_netcdf_type('ubyte','uint8');
test_netcdf_type('short','int16');
test_netcdf_type('ushort','uint16');
test_netcdf_type('int','int32');
test_netcdf_type('uint','uint32');
test_netcdf_type('int64','int64');
test_netcdf_type('uint64','uint64');

test_netcdf_type('double','double');
test_netcdf_type('float','single');

test_netcdf_type('char','char');
