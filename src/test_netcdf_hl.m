
fname = [tmpnam '-octave-netcdf.nc'];


nccreate(fname,'temp','Dimensions',{'lon',10,'lat',20});
nccreate(fname,'salt','Dimensions',{'lon',10,'lat',20});
nccreate(fname,'u','Dimensions',{'lon','lat'});
u = randn(10,20);
ncwrite(fname,'u',u);

u2 = ncread(fname,'u');
assert(isequalwithequalnans(u,u2));

u2 = ncread(fname,'u',[10 5],[inf inf],[1 1]);
assert(isequalwithequalnans(u(10:end,5:end),u2));

ncwriteatt(fname,'temp','units','degree Celsius');
assert(strcmp(ncreadatt(fname,'temp','units'),'degree Celsius'));

ncwriteatt(fname,'temp','range',[0 10]);
assert(isequal(ncreadatt(fname,'temp','range'),[0 10]));

ncwriteatt(fname,'temp','float_range',single([0 10]));
assert(isequal(ncreadatt(fname,'temp','float_range'),[0 10]));

ncwriteatt(fname,'temp','int_range',int32([0 10]));
assert(isequal(ncreadatt(fname,'temp','int_range'),[0 10]));

info = ncinfo(fname);
assert(length(info.Variables) == 3)
assert(strcmp(info.Variables(1).Name,'temp'));
delete(fname);


nccreate(fname,'temp','Dimensions',{'lon',10,'lat',20},'Format','64bit');

delete(fname);
nccreate(fname,'temp','Dimensions',{'lon',10,'lat',20},'Format','classic');
info = ncinfo(fname);
assert(strcmp(info.Format,'classic'));

delete(fname);
nccreate(fname,'temp','Dimensions',{'lon',10,'lat',20},'Format','netcdf4');

% error in octave:
% Attempting netcdf-4 operation on strict nc3 netcdf-4 file
%ncwriteatt(fname,'temp','uint_range',uint32([0 10]));
%assert(isequal(ncreadatt(fname,'temp','uint_range'),[0 10]));

info = ncinfo(fname);
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


delete(fname)

ncwriteschema(fname,s);

delete(fname);
