
fname = [tempname '-octave-netcdf-scheme-group.nc'];

clear s
s.Name   = '/';
s.Format = 'netcdf4';
s.Dimensions(1).Name   = 'lon';
s.Dimensions(1).Length = 20;
s.Dimensions(2).Name   = 'lat';
s.Dimensions(2).Length = 10;

s.Attributes(1).Name = 'institution';
s.Attributes(1).Value = 'GHER, ULg';

s.Variables(1).Name = 'temp_diff';
s.Variables(1).Dimensions = s.Dimensions;
s.Variables(1).Datatype = 'double';
s.Variables(1).Attributes(1).Name = 'long_name';
s.Variables(1).Attributes(1).Value = 'temperature';


s.Groups(1).Name = 'forecast';
s.Groups(1).Variables(1).Name = 'temp';
s.Groups(1).Variables(1).Dimensions = s.Dimensions;
s.Groups(1).Variables(1).Datatype = 'double';
s.Groups(1).Variables(1).Attributes(1).Name = 'long_name';
s.Groups(1).Variables(1).Attributes(1).Value = 'temperature';
s.Groups(1).Attributes(1).Name = 'institution';
s.Groups(1).Attributes(1).Value =  'ULg';

s.Groups(2) = s.Groups(1);
s.Groups(2).Name = 'analysis';

ncwriteschema(fname,s);
%system(['ncdump -h ' fname])

info = ncinfo(fname);
assert(strcmp(info.Attributes(1).Name,s.Attributes(1).Name))
assert(strcmp(info.Attributes(1).Value,s.Attributes(1).Value))

assert(strcmp(s.Groups(1).Name,info.Groups(1).Name))

z = randn(20,10);
ncwrite(fname,'/forecast/temp',z);
z2 = ncread(fname,'/forecast/temp');
assert(isequal(z,z2))

ginfo = ncinfo(fname,'forecast');
assert(strcmp(ginfo.Name,'forecast'));

% read global attribute of root group
val = ncreadatt(fname,'/','institution');
assert(strcmp(val,'GHER, ULg'));

% read global attribute of group forecast
val = ncreadatt(fname,'/forecast','institution');
assert(strcmp(val,'ULg'));

delete(fname);
