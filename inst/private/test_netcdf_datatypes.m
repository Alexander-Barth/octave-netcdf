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
