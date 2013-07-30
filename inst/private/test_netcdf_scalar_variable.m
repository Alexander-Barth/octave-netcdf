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

function test_netcdf_scalar_variable()
import_netcdf

fname = [tempname '-octave-netcdf.nc'];
ncid = netcdf.create(fname,'NC_CLOBBER');
varidd_scalar = netcdf.defVar(ncid,'double_scalar','double',[]);
netcdf.close(ncid);
delete(fname);
