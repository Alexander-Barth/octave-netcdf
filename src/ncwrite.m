% Write a NetCDF variable.
%
% ncwrite(filename,varname,x)
% ncwrite(filename,varname,x,start,stride)
% write the variable varname to file filename.
% The parameter start contains the starting indices 
% and stride the increment between
% two successive elements (default 1).

function ncwrite(filename,varname,x,start,stride)

ncid = netcdf_open(filename,'NC_WRITE');
varid = netcdf_inqVarID(ncid, varname);
[varname_,xtype,dimids,natts] = netcdf_inqVar(ncid,varid);

% number of dimenions
nd = length(dimids);

sz = zeros(1,nd);
count = zeros(1,nd);

for i=1:length(dimids)
  [dimname, sz(i)] = netcdf_inqDim(ncid,dimids(i));
  count(i) = size(x,i);
end

if nargin < 4
  start = ones(1,nd);
end

if nargin < 5
  stride = ones(1,nd);
end


% apply attributes

factor = [];
offset = [];
fv = [];

for i = 0:natts-1
  attname = netcdf_inqAttName(ncid,varid,i);
  attname
  if strcmp(attname,'scale_factor')
    factor = netcdf_getAtt(ncid,varid,'scale_factor');
  elseif strcmp(attname,'add_offset')
    offset = netcdf_getAtt(ncid,varid,'add_offset');
  elseif strcmp(attname,'_FillValue')
    fv = netcdf_getAtt(ncid,varid,'_FillValue');
  end    
end

if ~isempty(fv)
  x(isnan(x)) = fv;
end

if ~isempty(offset)
  x = x - offset;
end

if ~isempty(factor)
  x = x / factor;
end
start 
stride
rg(x)
filename
varid
ncid
netcdf_putVar(ncid,varid,start-1,count,stride,x);
%netcdf_putVar(ncid,varid,x);

netcdf_close(ncid);


%% Copyright (C) 2012-2013 Alexander Barth
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
