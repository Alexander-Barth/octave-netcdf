% test_netcdf
% Test the netcdf interface

function test_netcdf()

import_netcdf

tests = {'test_netcdf_constant',...
         'test_netcdf_create'...
         'test_netcdf_low_level_interface'...
         'test_netcdf_unlim',...         
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

%% Copyright (C) 2013 Alexander Barth
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.




