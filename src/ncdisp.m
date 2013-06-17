function ncdisp(filename)

info = ncinfo(filename);

fprintf('Source:\n');
ident = repmat(' ',[1 11]);
fprintf('%s%s\n',ident,fullfile(filename));
fprintf('Format:\n');
fprintf('%s%s\n',ident,info.Format);

printgroup(ident,info);
end

function s = fmtattr(val)
if ischar(val)
  s = sprintf('''%s''',val);
else
  s = num2str(val);
end
end

function s = fmtsize(sz)
 
 s = sprintf('%gx',sz);
 s = s(1:end-1);
end


function printgroup(ident,info)
% attributes
if ~isempty(info.Attributes)
  fprintf('Global Attributes:\n');
  printattr(ident,info.Attributes);
end

% dimensions
if ~isempty(info.Dimensions)
  % length of the longest attribute name
  dim = info.Dimensions;
  maxlen = max(cellfun(@length,{dim.Name}));
  fprintf('Dimensions:\n');
  for i = 1:length(dim)
    space = repmat(' ',[maxlen-length(dim(i).Name) 1]);
    fprintf('%s%s %s= %d\n',ident,dim(i).Name,space,dim(i).Length);
  end
end

% variables
if ~isempty(info.Variables)
  % length of the longest attribute name
  vars = info.Variables;
  fprintf('Variables:\n');
  for i = 1:length(vars)
    fprintf('%s%s\n',ident(1:4),vars(i).Name);
    
    if ~isempty(vars(i).Size)
      sz = fmtsize(vars(i).Size);
      dimname = sprintf('%s,',vars(i).Dimensions.Name);
      dimname = dimname(1:end-1);
    else
      sz = '1x1';
      dimname = '';
    end
      
    fprintf('%sSize:       %s\n',ident,sz);    
    fprintf('%sDimensions: %s\n',ident,dimname);
    fprintf('%sDatatype:   %s\n',ident,vars(i).Datatype);
    
    if ~isempty(vars(i).Attributes);
      ident2 = [ident  '            '];
      fprintf('%sAttributes:\n',ident);
      printattr(ident2,vars(i).Attributes);
    end
%    fprintf('\n');
  end
end


end

function printattr(ident,attr)
  % length of the longest attribute name
maxlen = max(cellfun(@length,{attr.Name}));
  for i = 1:length(attr)
    space = repmat(' ',[maxlen-length(attr(i).Name) 1]);
    fprintf('%s%s %s= %s\n',ident,attr(i).Name,space,fmtattr(attr(i).Value));
  end
end