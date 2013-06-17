function ncdisp(filename)

info = ncinfo(filename);

fprintf('Source:\n');
indent = repmat(' ',[1 11]);
fprintf('%s%s\n',indent,fullfile(filename));
fprintf('Format:\n');
fprintf('%s%s\n',indent,info.Format);

printgroup(indent,info);

function s = fmtattr(val)
if ischar(val)
  s = sprintf('''%s''',val);
else
  s = num2str(val);
end

function s = fmtsize(sz) 
s = sprintf('%gx',sz);
s = s(1:end-1);


function printgroup(indent,info)

indent1 = indent(1:end-11);

% attributes
if ~isempty(info.Attributes)
  fprintf('%sGlobal Attributes:\n',indent1);
  printattr(indent,info.Attributes);
end

% dimensions
if ~isempty(info.Dimensions)
  % length of the longest attribute name
  dim = info.Dimensions;
  maxlen = max(cellfun(@length,{dim.Name}));
  fprintf('%sDimensions:\n',indent1);
  for i = 1:length(dim)
    space = repmat(' ',[maxlen-length(dim(i).Name) 1]);
    fprintf('%s%s %s= %d\n',indent,dim(i).Name,space,dim(i).Length);
  end
end

% variables
if isfield(info,'Variables')
  if ~isempty(info.Variables)
    % length of the longest attribute name
    vars = info.Variables;
    fprintf('%sVariables:\n',indent1);
    for i = 1:length(vars)
      fprintf('%s%s\n',indent(1:end-7),vars(i).Name);
      
      if ~isempty(vars(i).Size)
        sz = fmtsize(vars(i).Size);
        dimname = sprintf('%s,',vars(i).Dimensions.Name);
        dimname = dimname(1:end-1);
      else
        sz = '1x1';
        dimname = '';
      end
      
      fprintf('%sSize:       %s\n',indent,sz);    
      fprintf('%sDimensions: %s\n',indent,dimname);
      fprintf('%sDatatype:   %s\n',indent,vars(i).Datatype);
      
      if ~isempty(vars(i).Attributes);
        indent2 = [indent  '            '];
        fprintf('%sAttributes:\n',indent);
        printattr(indent2,vars(i).Attributes);
      end
    end
  end
end

% groups
if ~isempty(info.Groups)
  % length of the longest attribute name
  grps = info.Groups;
  fprintf('%sGroups:\n',indent1);
  for i = 1:length(grps)
    fprintf('%s%s\n',indent(1:end-7),grps(i).Name);
    indent2 = [indent  '            '];
    printgroup(indent2,grps(i));
  end
end



function printattr(indent,attr)
% length of the longest attribute name
maxlen = max(cellfun(@length,{attr.Name}));
for i = 1:length(attr)
  space = repmat(' ',[maxlen-length(attr(i).Name) 1]);
  fprintf('%s%s %s= %s\n',indent,attr(i).Name,space,fmtattr(attr(i).Value));
end
