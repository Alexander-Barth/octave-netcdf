## Copyright (C) 2013 Alexander Barth
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} nccreate(@var{filename},@var{varname})
## @deftypefnx  {Function File} {} nccreate(@var{filename},@var{varname},"property",@var{value},...)
##
## Create the variable @var{varname} in the file @var{filename}.
##
## The following properties can be used:
## @itemize
## @item "Dimensions": a cell array with the dimension names followed by their
## length or Inf if the dimension is unlimited. If the property is ommited, a 
## scalar variable is created.
## @item "Datatype": a string with the Octave data type name 
## (see @code{ncinfo} for the correspondence between Octave and NetCDF data 
## types). The default data type is a "double".
## @item "Format": This can be "netcdf4_classic" (default), "classic", "64bit" 
## or "netcdf4".
## @item "FillValue": the value used for undefined elements of the NetCDF 
## variable.
## @item "ChunkSize": the size of the data chunks. If omited, the variable is 
## not chunked.
## @item "DeflateLevel": The deflate level for compression. It can be the string
## "disable" (default) for no compression or an integer between 0 (no 
## compression) and 9 (maximum compression).
## @item "Shuffle": true for enabling the shuffle filter or false (default) for 
## disabling it.
## @end itemize
##
## Example:
## @example
## nccreate("test.nc","temp","Dimensions",@{"lon",10,"lat",20@},"Format","classic");
## ncdisp("test.nc");
## @end example
## @seealso{ncwrite}
## @end deftypefn


function nccreate(filename,varname,varargin)

dimensions = {};
datatype = 'double';
ncformat = 'netcdf4_classic';
FillValue = [];
ChunkSize = [];
DeflateLevel = 'disable';
Shuffle = false;




for i = 1:2:length(varargin)
  if strcmp(varargin{i},'Dimensions')
    dimensions = varargin{i+1};
  elseif strcmp(varargin{i},'Datatype')
    datatype = varargin{i+1};
  elseif strcmp(varargin{i},'Format')
    ncformat = varargin{i+1};
  elseif strcmp(varargin{i},'FillValue')
    FillValue = varargin{i+1};
  elseif strcmp(varargin{i},'ChunkSize')
    ChunkSize = varargin{i+1};
  elseif strcmp(varargin{i},'DeflateLevel')
    DeflateLevel = varargin{i+1};
  elseif strcmp(varargin{i},'Shuffle')
    Shuffle = varargin{i+1};
  else
    error(['unknown keyword ' varargin{i} '.']);
  end
end

if ~isempty(stat(filename))
  ncid = netcdf_open(filename,'NC_WRITE');
  netcdf_reDef(ncid);
else    
  mode = format2mode(ncformat);
  ncid = netcdf_create(filename,mode);
end

% create dimensions

dimids = [];
i = 1;

while i <= length(dimensions)  
  
  if i == length(dimensions)
    dimids(end+1) = netcdf_inqDimID(ncid,dimensions{i});
    i = i+1;
  elseif ischar(dimensions{i+1})
    dimids(end+1) = netcdf_inqDimID(ncid,dimensions{i});
    i = i+1;
  else
    try
      if isinf(dimensions{i+1})
        dimensions{i+1} = netcdf_getConstant('NC_UNLIMITED');
      end      
      dimids(end+1) = netcdf_defDim(ncid,dimensions{i},dimensions{i+1});
    catch
      dimids(end+1) = netcdf_inqDimID(ncid,dimensions{i});
    end
    i = i+2;
  end
end


varid = netcdf_defVar(ncid,varname,oct2nctype(datatype),dimids);

if ~isempty(ChunkSize)
  netcdf_defVarChunking(ncid,varid,'chunked',ChunkSize);
end

if ~isempty(FillValue)
  % value of nofill?
  netcdf_defVarFill(ncid,varid,false,FillValue);
end

if isnumeric(DeflateLevel)
  netcdf_defVarDeflate(ncid,varid,Shuffle,true,DeflateLevel);
end

netcdf_close(ncid);
