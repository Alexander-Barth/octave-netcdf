
fname = [tempname '-octave-netcdf.nc'];


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
assert(isequal(info.Variables(1).Size,[10 20]));
delete(fname);


nccreate(fname,'temp','Dimensions',{'lon',10,'lat',20},'Format','64bit');
delete(fname);

nccreate(fname,'temp','Dimensions',{'lon',10,'lat',20},'Format','classic');
info = ncinfo(fname);
assert(strcmp(info.Format,'classic'));

delete(fname);

% netcdf4

nccreate(fname,'temp','Dimensions',{'lon',10,'lat',20},'Format','netcdf4');

% error in octave:
% Attempting netcdf-4 operation on strict nc3 netcdf-4 file
%ncwriteatt(fname,'temp','uint_range',uint32([0 10]));
%assert(isequal(ncreadatt(fname,'temp','uint_range'),[0 10]));

info = ncinfo(fname);
assert(strcmp(info.Format,'netcdf4'));
delete(fname)

% scalar variable
nccreate(fname,'temp','Format','netcdf4','Datatype','double');
ncwrite(fname,'temp',123);
assert(ncread(fname,'temp') == 123)
delete(fname)

test_netcdf_ncwriteschema
test_netcdf_ncwriteschema_unlim
test_netcdf_ncwriteschema_chunking

% test unlimited dimension with nccreate
fname = [tempname '-octave-netcdf.nc'];
nccreate(fname,'temp','Dimensions',{'lon',10,'lat',inf});
%system(['ncdump -h ' fname])

info = ncinfo(fname);
assert(~info.Dimensions(1).Unlimited)
assert(info.Dimensions(2).Unlimited)

delete(fname)

