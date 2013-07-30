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

function mode = format2mode(format)

mode = netcdf_getConstant("NC_NOCLOBBER");
  
switch lower(format)
 case "classic"
  % do nothing
 case "64bit"
  mode = bitor(mode,netcdf_getConstant("NC_64BIT_OFFSET"));
 case "netcdf4_classic"
  mode = bitor(bitor(mode,netcdf_getConstant("NC_NETCDF4")),...
               netcdf_getConstant("NC_CLASSIC_MODEL"));
  
 case "netcdf4"
    mode = bitor(mode,netcdf_getConstant("NC_NETCDF4"));
 otherwise
  error("netcdf:unkownFormat","unknown format %s",format);
end
