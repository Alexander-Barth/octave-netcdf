
fname = [tempname '-octave-netcdf-scheme-unlim.nc'];

clear s
s.Name   = '/';
s.Format = 'classic';
s.Dimensions(1).Name   = 'lon';
s.Dimensions(1).Length = 20;
s.Dimensions(2).Name   = 'lat';
s.Dimensions(2).Length = 10;

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

delete(fname);
