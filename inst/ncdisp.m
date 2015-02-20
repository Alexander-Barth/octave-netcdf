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
## @deftypefn {Function File} {} ncdisp (@var{filename})
## display meta-data of the NetCDF file @var{filename}
##
## @seealso{ncinfo}
## @end deftypefn

function ncdisp(filename)

info = ncinfo(filename);

fprintf("Source:\n");
indent = repmat(" ",[1 11]);
fprintf("%s%s\n",indent,fullfile(filename));
fprintf("Format:\n");
fprintf("%s%s\n",indent,info.Format);

colors.var = "red";
colors.att = "cyan";
colors.dim = "blue";
group_color = "green";

printgroup("",info,colors);

function s = fmtattr(val)
if ischar(val)
  s = sprintf("""%s""",val);
else
  s = num2str(val);
end

function s = fmtsize(sz) 
s = sprintf("%gx",sz);
s = s(1:end-1);


function printgroup(indent1,info,colors)

indent2 = [indent1 repmat(" ",[1 11])];
indent3 = [indent2 repmat(" ",[1 11])];

% attributes
if ~isempty(info.Attributes)
  fprintf("%sGlobal Attributes:\n",indent1);
  printattr(indent2,info.Attributes,colors);
end

% dimensions
if ~isempty(info.Dimensions)
  % length of the longest attribute name
  dim = info.Dimensions;
  maxlen = max(cellfun(@length,{dim.Name}));
  fprintf("%sDimensions:\n",indent1);
  for i = 1:length(dim)
    space = repmat(" ",[maxlen-length(dim(i).Name) 1]);
    fprintf("%s",indent2);
    colormsg(sprintf("%s %s= %d",dim(i).Name,space,dim(i).Length),colors.dim);
    fprintf("\n");
  end
end

% variables
if isfield(info,"Variables")
  if ~isempty(info.Variables)
    % length of the longest attribute name
    vars = info.Variables;
    fprintf("%sVariables:\n",indent1);
    for i = 1:length(vars)
      %fprintf("%s%s\n",indent2(1:end-7),vars(i).Name);
      colormsg(sprintf("%s%s\n",indent2(1:end-7),vars(i).Name),colors.var);
      
      if ~isempty(vars(i).Size)
        sz = fmtsize(vars(i).Size);
        dimname = sprintf("%s,",vars(i).Dimensions.Name);
        dimname = dimname(1:end-1);
      else
        sz = "1x1";
        dimname = "";
      end
      
      fprintf("%sSize:       %s\n",indent2,sz);    
      fprintf("%sDimensions: %s\n",indent2,dimname);
      fprintf("%sDatatype:   %s\n",indent2,vars(i).Datatype);
      
      if ~isempty(vars(i).Attributes);
        fprintf("%sAttributes:\n",indent2);
        printattr(indent3,vars(i).Attributes,colors);
      end
    end
  end
end

% groups
if ~isempty(info.Groups)
  % length of the longest attribute name
  grps = info.Groups;
  fprintf("%sGroups:\n",indent1);
  for i = 1:length(grps)
    fprintf("%s%s\n",indent2(1:end-7),grps(i).Name);
    printgroup(indent2,grps(i),colors);
  end
end



function printattr(indent,attr,colors)
% length of the longest attribute name
maxlen = max(cellfun(@length,{attr.Name}));
for i = 1:length(attr)
  space = repmat(" ",[maxlen-length(attr(i).Name) 1]);
  %fprintf("%s%s %s= %s\n",indent,attr(i).Name,space,fmtattr(attr(i).Value));
  fprintf("%s",indent);
  colormsg(sprintf("%s %s= %s\n",attr(i).Name,space,fmtattr(attr(i).Value)),colors.att);
end



function colormsg (msg,color)

if strcmp(getenv("TERM"),"xterm")
  esc = char(27);          

  % ANSI escape codes
  colors.black   = [esc, "[30m"];
  colors.red     = [esc, "[31m"];
  colors.green   = [esc, "[32m"];
  colors.yellow  = [esc, "[33m"];
  colors.blue    = [esc, "[34m"];
  colors.magenta = [esc, "[35m"];
  colors.cyan    = [esc, "[36m"];
  colors.white   = [esc, "[37m"];

  reset = [esc, "[0m"];
  
  c = getfield(colors,color);

  fprintf('%s',[c, msg, reset]);
else
  fprintf('%s',msg);
end
