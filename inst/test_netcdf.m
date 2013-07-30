function test_netcdf()

import_netcdf

tests = {'test_netcdf_constant',...
         'test_netcdf_create'...
         'test_netcdf_low_level_interface'...
         'test_netcdf_datatypes'...
         'test_netcdf_scalar_variable'...
         'test_netcdf_attributes'...
         'test_netcdf_high_level_interface'...
         'test_netcdf_ncwriteschema'...
         'test_netcdf_ncwriteschema_unlim'...
         'test_netcdf_ncwriteschema_chunking'...
         'test_netcdf_ncwriteschema_group'...
        };

maxlen = max(cellfun(@(s) length(s),tests));

libver = netcdf.inqLibVers();
fprintf('Using NetCDF library version "%s"\n',libver)

for iindex=1:length(tests);

  dots = repmat('.',1,maxlen - length(tests{iindex}));
  fprintf('run %s%s ',tests{iindex},dots);
  try
    eval(tests{iindex});
    disp('  OK  ');
  catch
    disp(' FAIL ');
    disp(lasterr)
  end
end




