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
## @deftypefn  {Function File} {@var{info} =} ncinfo (@var{filename})
## @deftypefnx  {Function File} {@var{info} =} ncinfo (@var{filename}, @var{varname})
## @deftypefnx  {Function File} {@var{info} =} ncinfo (@var{filename}, @var{groupname})
## return information about an entire NetCDF file @var{filename} (i.e. the root 
## group "/"), about the variable called @var{varname} or the group called 
## @var{groupname}.
##
## The structure @var{info} has always the following fields:
## @itemize
## @item @var{Filename}: the name of the NetCDF file
## @item @var{Format}: one of the strings "CLASSIC", "64BIT", "NETCDF4"
## or "NETCDF4_CLASSIC"
## @end itemize
##
## The structure @var{info} has additional fields depending on wether a 
## group of variable is queried.
##
## Groups
##
## Groups are returned as an array structure with the following fields:
##
## @itemize
## @item @var{Name}: the group name. The root group is named "/".
## @item @var{Dimensions}: a array structure with the dimensions.
## @item @var{Variables}: a array structure with the variables.
## @item @var{Attributes}: a array structure with global attributes.  
## @item @var{Groups}: a array structure (one for each group) with the 
## same fields as this structure.
## @end itemize
##
## Dimensions
##
## Dimensions are returned as an array structure with the following fields:
## @itemize
##   @item @var{Name}: the name of the dimension
##   @item @var{Length}: the length of the dimension
##   @item @var{Unlimited}: true of the dimension has no fixed limited, false 
## @end itemize
##
## Variables
##
## Variables are returned as an array structure with the following fields:
## @itemize
##   @item @var{Name}: the name of the dimension
##   @item @var{Dimensions}: array structure of all dimensions of this variable 
## with the same structure as above.
##   @item @var{Size}: array with the size of the variable
##   @item @var{Datatype}: string with the corresponding octave data-type 
## (see below)
##   @item @var{Attributes}: a array structure of attributes
##   @item @var{FillValue}: the NetCDF fill value of the variable. If the fill 
## value is not defined, then this attribute is an empty array ([]).
##   @item @var{DeflateLevel}: the NetCDF deflate level between 0 (no 
##   compression) and 9 (maximum compression).
##   @item @var{Shuffle}: is true if the shuffle filter is activated to improve 
##   compression, otherwise false.
##   @item @var{CheckSum}: is set to "fletcher32", if check-sums are used, 
#    otherwise this field is not defined.
## @end itemize
##
## Attributes
##
## Attributes are returned as an array structure with the following fields: 
## @itemize
##   @item @var{Name}: the name of the attribute
##   @item @var{Value}: the value of the attribute (with the corresponding type)
##   @item @var{Unlimited}: true of the dimension has no fixed limited, false 
## @end itemize
##
## Data-types
##
## The following the the correspondence between the Octave and NetCDF 
## data-types:
## 
## @multitable @columnfractions .5 .5
## @headitem Octave type @tab NetCDF type
## @item @code{int8}    @tab @code{NC_BYTE}   
## @item @code{uint8}   @tab @code{NC_UBYTE}  
## @item @code{int16}   @tab @code{NC_SHORT}  
## @item @code{uint16}  @tab @code{NC_USHORT} 
## @item @code{int32}   @tab @code{NC_INT}    
## @item @code{uint32}  @tab @code{NC_UINT}   
## @item @code{int64}   @tab @code{NC_INT64}  
## @item @code{uint64}  @tab @code{NC_UINT64} 
## @item @code{single}  @tab @code{NC_FLOAT}  
## @item @code{double}  @tab @code{NC_DOUBLE} 
## @item @code{char}    @tab @code{NC_CHAR}   
## @end multitable
##
## The output of @code{ncinfo} can be used to create a NetCDF file with the same
## meta-data using @code{ncwriteschema}.
##
## Note: If there are no attributes (or variable or groups), the corresponding 
## field is an empty matrix and not an empty struct array for compability
## with matlab.
##
## @seealso{ncread,nccreate,ncwriteschema,ncdisp}
##
## @end deftypefn

function info = ncinfo(filename,name)

ncid = netcdf_open(filename,"NC_NOWRITE");
info.Filename = filename;    

if nargin == 1    
  name = "/";
endif

[gid,varid] = ncloc(ncid,name);

if isempty(varid)
  info = ncinfo_group(info,gid);
else
  unlimdimIDs = netcdf_inqUnlimDims(gid);
  info = ncinfo_var(info,gid,varid,unlimdimIDs);
endif

# NetCDF format
ncformat = netcdf_inqFormat(ncid);
info.Format = lower(strrep(ncformat,'FORMAT_',''));    

netcdf_close(ncid);
endfunction

function dims = ncinfo_dim(ncid,dimids,unlimdimIDs)

dims = [];
for i=1:length(dimids)
  tmp = struct();

  [tmp.Name, tmp.Length] = netcdf_inqDim(ncid,dimids(i));
  tmp.Unlimited = any(unlimdimIDs == dimids(i));
    
  if isempty(dims)
    dims = [tmp];
  else
    dims(i) = tmp;
  endif
endfor
endfunction


function vinfo = ncinfo_var(vinfo,ncid,varid,unlimdimIDs)

[vinfo.Name,xtype,dimids,natts] = netcdf_inqVar(ncid,varid);

% Information about dimension

vinfo.Dimensions = ncinfo_dim(ncid,dimids,unlimdimIDs);
if isempty(vinfo.Dimensions)
  vinfo.Size = [];
else
  vinfo.Size = cat(2,vinfo.Dimensions.Length);
end

% Data type

vinfo.Datatype = nc2octtype(xtype);

% Attributes

vinfo.Attributes = [];

for i = 0:natts-1  
    tmp = struct();
    tmp.Name = netcdf_inqAttName(ncid,varid,i);
    tmp.Value = netcdf_getAtt(ncid,varid,tmp.Name);
    
    if isempty(vinfo.Attributes)      
      vinfo.Attributes = [tmp];
    else
      vinfo.Attributes(i+1) = tmp;
    endif
endfor

% chunking, fillvalue, compression

[storage,vinfo.ChunkSize] = netcdf_inqVarChunking(ncid,varid);

[nofill,vinfo.FillValue] = netcdf_inqVarFill(ncid,varid);
if nofill
  vinfo.FillValue = [];
endif

[shuffle,deflate,vinfo.DeflateLevel] = ...
    netcdf_inqVarDeflate(ncid,varid);

if ~deflate
  vinfo.DeflateLevel = [];
endif
vinfo.Shuffle = shuffle;

# add checksum information if defined (unlike matlab)
checksum = netcdf_inqVarFletcher32(ncid,varid);
if ~strcmp(checksum,'nochecksum');
  vinfo.Checksum = checksum;
endif

endfunction


function info = ncinfo_group(info,ncid)

info.Name = netcdf_inqGrpName(ncid);
unlimdimIDs = netcdf_inqUnlimDims(ncid);

[ndims,nvars,ngatts] = netcdf_inq(ncid);

% dimensions

dimids = netcdf_inqDimIDs(ncid);
info.Dimensions = ncinfo_dim(ncid,dimids,unlimdimIDs);

% variables
for i=1:nvars
  info.Variables(i) = ncinfo_var(struct(),ncid,i-1,unlimdimIDs);
endfor

% global attributes
info.Attributes = [];
gid = netcdf_getConstant('NC_GLOBAL');
for i = 0:ngatts-1  
  tmp = struct();
  tmp.Name = netcdf_inqAttName(ncid,gid,i);
  tmp.Value = netcdf_getAtt(ncid,gid,tmp.Name);
  
  if isempty(info.Attributes)      
    info.Attributes = [tmp];
  else
    info.Attributes(i+1) = tmp;
  endif
endfor

info.Groups = [];
gids = netcdf_inqGrps(ncid);
for i = 1:length(gids)
  tmp = ncinfo_group(struct(),gids(i));
  
  if isempty(info.Groups)      
    info.Groups = [tmp];
  else
    info.Groups(i) = tmp;
  endif
endfor

endfunction
