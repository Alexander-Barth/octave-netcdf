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
