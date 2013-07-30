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
