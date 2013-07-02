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
