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
import_netcdf

fname = [tempname '-octave-netcdf.nc'];


nccreate(fname,'temp','Dimensions',{'lon',10,'lat',20});
nccreate(fname,'salt','Dimensions',{'lon',10,'lat',20});
nccreate(fname,'u','Dimensions',{'lon','lat'});
u = randn(10,20);
ncwrite(fname,'u',u);

% for octave prior to 3.8.0
if isempty(which('isequaln'))
  isequaln = @(x,y) isequalwithequalnans(x,y);
end

u2 = ncread(fname,'u');
assert(isequaln(u,u2));

u2 = ncread(fname,'u',[10 5],[inf inf],[1 1]);
assert(isequaln(u(10:end,5:end),u2));

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
ncwriteatt(fname,'temp','uint_range',uint32([0 10]));
assert(isequal(ncreadatt(fname,'temp','uint_range'),[0 10]));

info = ncinfo(fname);
assert(strcmp(info.Format,'netcdf4'));
delete(fname)

% scalar variable
nccreate(fname,'temp','Format','netcdf4','Datatype','double');
ncwrite(fname,'temp',123);
assert(ncread(fname,'temp') == 123)
delete(fname)


% test unlimited dimension with nccreate
fname = [tempname '-octave-netcdf.nc'];
nccreate(fname,'temp','Dimensions',{'lon',10,'lat',inf});
%system(['ncdump -h ' fname])

info = ncinfo(fname);
assert(~info.Dimensions(1).Unlimited)
assert(info.Dimensions(2).Unlimited)

delete(fname)


% test double with _FillValue

fname = [tempname '-octave-netcdf.nc'];
fv = 99999.;
nccreate(fname,'flag','Dimensions',{'lon',10,'lat',10},'Datatype','double',...
         'FillValue',fv);

%system(['ncdump -h ' fname])
data = zeros(10,10);
data(1,2) = fv;
ncid = netcdf.open(fname,'NC_WRITE');
varid = netcdf.inqVarID(ncid, 'flag');
netcdf.putVar(ncid,varid,data);
netcdf.close(ncid)

data2 = ncread(fname,'flag');
data(data == fv) = NaN;
assert(isequaln(data,data2))
delete(fname)


% test char with _FillValue

fname = [tempname '-octave-netcdf.nc'];
fv = '*';
nccreate(fname,'flag','Dimensions',{'lon',10,'lat',10},'Datatype','char',...
         'FillValue',fv);
data = repmat('.',[10 10]);
data(1,2) = fv;

ncid = netcdf.open(fname,'NC_WRITE');
varid = netcdf.inqVarID(ncid, 'flag');
netcdf.putVar(ncid,varid,data);
netcdf.close(ncid)

data2 = ncread(fname,'flag');
assert(isequal(data,data2))
delete(fname)



% test case for bug  47014

bug_47014
