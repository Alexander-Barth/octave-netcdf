function ncwriteschema(filename,s)

% normalize schema

if ~isfield(s,'Attributes')
  s.Attributes = struct('Name',{},'Value',{});
end

if ~isfield(s,'Variables')
  s.Variables = struct('Name',{},'Dimensions',{},'Datatype',{});;
end


mode = format2mode(s.Format);
ncid = netcdf_create(filename,mode);

% dimension
for i = 1:length(s.Dimensions)
  dim = s.Dimensions(i);

  if ~isfield(dim,'Unlimited')
    dim.Unlimited = false;
  end
  
  len = dim.Length;  
  if dim.Unlimited || isinf(len)
    len = netcdf_getConstant('NC_UNLIMITED');
  end
  
  s.Dimensions(i).id = netcdf_defDim(ncid,dim.Name,len);
end

% global attributes
gid = netcdf_getConstant('NC_GLOBAL');
for j = 1:length(s.Attributes)
  netcdf_putAtt(ncid,gid,s.Attributes(j).Name,s.Attributes(j).Value);
end

% variables
for i = 1:length(s.Variables)  
  v = s.Variables(i);
  %v.Name
  % get dimension id
  dimids = zeros(length(v.Dimensions),1);
  for j = 1:length(v.Dimensions)
    ind = find(strcmp({s.Dimensions.Name},v.Dimensions(j).Name));    
    if isempty(ind)
      error('netcdf:unknownDim','Unkown dimension %s',Dimensions(j).Name);
    end
    
    dimids(j) = s.Dimensions(ind).id;
  end
  
  % define variable
  switch lower(v.Datatype)
   case 'int32'
    dtype = 'int';
   case 'single'
    dtype = 'float';
   case 'double'
    dtype = 'double';
   case 'char'
    dtype = 'char';
   otherwise
    error('netcdf:unkownType','unknown type %s',v.Datatype);
  end  
  
  varid = netcdf_defVar(ncid,v.Name,dtype,dimids);
  
  % define attributes
  for j = 1:length(v.Attributes)
    netcdf_putAtt(ncid,varid,v.Attributes(j).Name,v.Attributes(j).Value);
  end
  
  if isfield(v,'ChunkSize')
    if ~isempty(v.ChunkSize)
      
    end
  end
  
  %vinfo.FillValue
  
end

netcdf_close(ncid);