function nccreate(filename,varname,varargin)

dimensions = {};
datatype = 'double';
format = 'netcdf4_classic';
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
    format = varargin{i+1};
  elseif strcmp(varargin{i},'FillValue')
    FillValue = varargin{i+1};
  elseif strcmp(varargin{i},'ChunkSize')
    ChunkSize = varargin{i+1};
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
  mode = format2mode(format);
  ncid = netcdf_create(filename,mode);
end

%
%varid = netcdf_inqVarID(ncid, varname);

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


varid = netcdf_defVar(ncid,varname,datatype,dimids);

% TODO use netcdf4 stuff



netcdf_close(ncid);