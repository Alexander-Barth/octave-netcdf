function ncdisp(filename)

info = ncinfo(filename);

fprintf('Source:\n');
indent = repmat(' ',[1 11]);
fprintf('%s%s\n',indent,fullfile(filename));
fprintf('Format:\n');
fprintf('%s%s\n',indent,info.Format);

printgroup('',info);

function s = fmtattr(val)
if ischar(val)
  s = sprintf('''%s''',val);
else
  s = num2str(val);
end

function s = fmtsize(sz) 
s = sprintf('%gx',sz);
s = s(1:end-1);


function printgroup(indent1,info)

indent2 = [indent1 repmat(' ',[1 11])];
indent3 = [indent2 repmat(' ',[1 11])];

% attributes
if ~isempty(info.Attributes)
  fprintf('%sGlobal Attributes:\n',indent1);
  printattr(indent2,info.Attributes);
end

% dimensions
if ~isempty(info.Dimensions)
  % length of the longest attribute name
  dim = info.Dimensions;
  maxlen = max(cellfun(@length,{dim.Name}));
  fprintf('%sDimensions:\n',indent1);
  for i = 1:length(dim)
    space = repmat(' ',[maxlen-length(dim(i).Name) 1]);
    fprintf('%s%s %s= %d\n',indent2,dim(i).Name,space,dim(i).Length);
  end
end

% variables
if isfield(info,'Variables')
  if ~isempty(info.Variables)
    % length of the longest attribute name
    vars = info.Variables;
    fprintf('%sVariables:\n',indent1);
    for i = 1:length(vars)
      fprintf('%s%s\n',indent2(1:end-7),vars(i).Name);
      %colormsg(sprintf('%s%s\n',indent2(1:end-7),vars(i).Name),'red');
      
      if ~isempty(vars(i).Size)
        sz = fmtsize(vars(i).Size);
        dimname = sprintf('%s,',vars(i).Dimensions.Name);
        dimname = dimname(1:end-1);
      else
        sz = '1x1';
        dimname = '';
      end
      
      fprintf('%sSize:       %s\n',indent2,sz);    
      fprintf('%sDimensions: %s\n',indent2,dimname);
      fprintf('%sDatatype:   %s\n',indent2,vars(i).Datatype);
      
      if ~isempty(vars(i).Attributes);
        fprintf('%sAttributes:\n',indent2);
        printattr(indent3,vars(i).Attributes);
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
    fprintf('%s%s\n',indent2(1:end-7),grps(i).Name);
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



function colormsg (msg,color)

%getenv('TERM')
%if strcmp(getenv('TERM'),'xterm') % && exist('puts') > 1
% only in octave
if exist('puts') > 1
  esc = char(27);          

  % ANSI escape codes
  colors.black   = [esc, '[40m'];
  colors.red     = [esc, '[41m'];
  colors.green   = [esc, '[42m'];
  colors.yellow  = [esc, '[43m'];
  colors.blue    = [esc, '[44m'];
  colors.magenta = [esc, '[45m'];
  colors.cyan    = [esc, '[46m'];
  colors.white   = [esc, '[47m'];

  reset = [esc, '[0m'];
  
  c = getfield(colors,color);
           
  %oldpso = page_screen_output (0);

  try
    fprintf([c, msg, reset]);
    %puts (reset); % reset terminal
  catch
    %page_screen_output (oldpso);
  end
else
  fprintf(msg);
end


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
