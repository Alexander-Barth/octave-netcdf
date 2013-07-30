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


fname = [tempname '-octave-netcdf-scheme-unlim.nc'];

clear s
s.Name   = '/';
s.Format = 'classic';
s.Dimensions(1).Name   = 'lon';
s.Dimensions(1).Length = 20;
s.Dimensions(2).Name   = 'lat';
s.Dimensions(2).Length = 10;
s.Dimensions(3).Name   = 'time';
s.Dimensions(3).Length = Inf;
%s.Dimensions(3).Unlimited = true;

s.Attributes(1).Name = 'institution';
s.Attributes(1).Value = 'GHER, ULg';

s.Variables(1).Name = 'temp';
s.Variables(1).Dimensions = s.Dimensions;
s.Variables(1).Datatype = 'double';
s.Variables(1).Attributes(1).Name = 'long_name';
s.Variables(1).Attributes(1).Value = 'temperature';

ncwriteschema(fname,s);

info = ncinfo(fname);
assert(strcmp(info.Attributes(1).Name,s.Attributes(1).Name))
assert(strcmp(info.Attributes(1).Value,s.Attributes(1).Value))
assert(info.Dimensions(3).Unlimited);

delete(fname);
