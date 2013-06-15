delete('toto.nc');
nccreate('toto.nc','temp','Dimensions',{'lon',10,'lat',20});
nccreate('toto.nc','salt','Dimensions',{'lon',10,'lat',20});
nccreate('toto.nc','u','Dimensions',{'lon','lat'});
u = randn(10,20);
ncwrite('toto.nc','u',u);

u2 = ncread('toto.nc','u');
assert(isequalwithequalnans(u,u2));

u2 = ncread('toto.nc','u',[10 5],[inf inf],[1 1]);
assert(isequalwithequalnans(u(10:end,5:end),u2));

ncwriteatt('toto.nc','temp','units','degree Celsius');
assert(strcmp(ncreadatt('toto.nc','temp','units'),'degree Celsius'));

ncwriteatt('toto.nc','temp','range',[0 10]);
assert(isequal(ncreadatt('toto.nc','temp','range'),[0 10]));

ncwriteatt('toto.nc','temp','float_range',single([0 10]));
assert(isequal(ncreadatt('toto.nc','temp','float_range'),[0 10]));

ncwriteatt('toto.nc','temp','int_range',int32([0 10]));
assert(isequal(ncreadatt('toto.nc','temp','int_range'),[0 10]));

info = ncinfo('toto.nc')
assert(length(info.Variables) == 3)
assert(strcmp(info.Variables(1).Name,'temp'));



delete('toto_64bitoffset.nc');
nccreate('toto_64bitoffset.nc','temp','Dimensions',{'lon',10,'lat',20},'Format','64bit');

delete('toto_classic.nc');
nccreate('toto_classic.nc','temp','Dimensions',{'lon',10,'lat',20},'Format','classic');
info = ncinfo('toto_classic.nc');
assert(strcmp(info.Format,'classic'));

delete('toto_netcdf4.nc');
nccreate('toto_netcdf4.nc','temp','Dimensions',{'lon',10,'lat',20},'Format','netcdf4');

% error in octave:
% Attempting netcdf-4 operation on strict nc3 netcdf-4 file
%ncwriteatt('toto.nc','temp','uint_range',uint32([0 10]));
%assert(isequal(ncreadatt('toto.nc','temp','uint_range'),[0 10]));

info = ncinfo('toto_netcdf4.nc');
assert(strcmp(info.Format,'netcdf4'));



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

filename = 'test_schema.nc';
delete(filename)

ncwriteschema(filename,s);

