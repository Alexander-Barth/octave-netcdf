function ncwriteschema(filename,s)



mode = format2mode(s.Format);
ncid = netcdf_create(filename,mode);
write_group(ncid,s)

netcdf_close(ncid);

end

function write_group(ncid,s)
% normalize schema

if ~isfield(s,'Dimensions')
  s.Dimensions = [];
end
if isempty(s.Dimensions)
  s.Dimensions = struct('Name',{},'Length',{},'Unlimited',{});
end

if ~isfield(s,'Attributes')
  s.Attributes = struct('Name',{},'Value',{});
end

if ~isfield(s,'Variables')
  s.Variables = struct('Name',{},'Dimensions',{},'Datatype',{});;
end

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
    dimids(j) = netcdf_inqDimID(ncid,v.Dimensions(j).Name);
  end

  
  % define variable
  dtype = oct2nctype(v.Datatype);
  varid = netcdf_defVar(ncid,v.Name,dtype,dimids);
  
  % define attributes
  for j = 1:length(v.Attributes)
    netcdf_putAtt(ncid,varid,v.Attributes(j).Name,v.Attributes(j).Value);
  end
  
  % define chunk size
  if isfield(v,'ChunkSize')
    if ~isempty(v.ChunkSize)
      netcdf_defVarChunking(ncid,varid,'chunked',v.ChunkSize);
    end
  end

  % define compression
  shuffle = false;
  deflatelevel = 0;

  if isfield(v,'Shuffle') 
    if ~isempty(v.Shuffle)    
      shuffle = v.Shuffle;
    end
  end
  
  if isfield(v,'DeflateLevel')
    if ~isempty(v.DeflateLevel)
      deflatelevel = v.DeflateLevel;
    end
  end
  
  if shuffle && defaltelevel != 0
    deflate = defaltelevel != 0;
    netcdf_defVarDeflate(ncid,varid,shuffle,deflate,deflatelevel);
  end
    
  % define fill value
  if isfield(v,'FillValue')
    if ~isempty(v.FillValue)
      % leave nofill setting unchanged
      [nofill,fillval] = netcdf_inqVarFill(ncid,varid);      
      netcdf_defVarFill(ncid,varid,nofill,v.FillValue);
    end
  end

  % define checksum
  if isfield(v,'Checksum')
    if ~isempty(v.Checksum)
      netcdf_defVarFletcher32(ncid,varid,v.Checksum);
    end
  end
  
  
end

% groups
if isfield(s,'Groups')
  if ~isempty(s.Groups)
    for i=1:length(s.Groups)
      g = s.Groups(i);
      gid = netcdf_defGrp(ncid,g.Name);
      write_group(gid,g);
    end
  end
end   
end


