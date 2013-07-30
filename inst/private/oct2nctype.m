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

function nctype = oct2nctype(otype)

typemap.int8   = 'byte';
typemap.uint8  = 'ubyte';
typemap.int16  = 'short';
typemap.uint16 = 'ushort';
typemap.int32  = 'int';
typemap.uint32 = 'uint';
typemap.int64  = 'int64';
typemap.uint64 = 'uint64';
typemap.single = 'float';
typemap.double = 'double';
typemap.char   = 'char';

if ischar(otype)
  otype = lower(otype);
  
  if isfield(typemap,otype)    
    nctype = typemap.(otype);
  else
    error('netcdf:unkownType','unknown type %s',otype);
  end
else
  nctype = otype;
end


%typemap.byte   = 'int8';
%typemap.ubyte  = 'uint8';
%typemap.short  = 'int16';
%typemap.ushort = 'uint16';
%typemap.int    = 'int32';
%typemap.uint   = 'uint32';
%typemap.int64  = 'int64';
%typemap.uint64 = 'uint64';
%typemap.float  = 'single';
%typemap.double = 'double';
%typemap.char   = 'char';
