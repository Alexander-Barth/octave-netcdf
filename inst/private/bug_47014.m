% test case for bug  47014
% https://savannah.gnu.org/bugs/?func=detailitem&item_id=47014

fname = [tempname '-octave-netcdf.nc'];
nccreate(fname,'var','Dimensions',{'x',10},...
         'FillValue',-32767,'Datatype','int16')

var = ones(10,1);
var(1) = NaN;
ncwrite(fname,'var',var);
var2 = ncread(fname,'var');
assert(isequaln(var,var2))
delete(fname)
