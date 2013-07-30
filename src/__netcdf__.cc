// Copyright (C) 2013 Alexander Barth <barth.alexander@gmail.com>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.


#include <octave/oct.h>
#include <octave/ov-cell.h>

#include <netcdf.h>

#include <string>
#include <map>
#include <iostream>
#include <algorithm>
#include <vector>

std::map<std::string, octave_value> netcdf_constants;

void init() {  
  #include "netcdf_constants.h"
}

void check_err(int status) 
{
  if (status != NC_NOERR) error("%s",nc_strerror(status));
}

// convert name to upper-case and add "NC_" prefix if it is missing
std::string normalize_ncname(std::string name) {
  std::string prefix = "NC_";
  std::string ncname = name;
  // to upper case
  std::transform(ncname.begin(), ncname.end(),ncname.begin(), ::toupper);
      
  // add prefix if it is missing
  if (ncname.substr(0, prefix.size()) != prefix) {
    ncname = prefix + ncname;
  }  
  return ncname;
}

octave_value netcdf_get_constant(octave_value ov)
{
  if (netcdf_constants.empty())
    {
      init();
    }

  if (ov.is_scalar_type())
    {
      return ov.scalar_value();
    }

  std::string name = ov.string_value();
  name = normalize_ncname(name);
  std::map<std::string, octave_value>::const_iterator cst = netcdf_constants.find(name);

  if (cst != netcdf_constants.end ())
    {
      return cst->second;
    }
  else
    {
      error("unknown netcdf constant: %s",name.c_str());
      return octave_value();
    }
}


void start_count_stride(int ncid, int varid, octave_value_list args,int len,size_t* start,size_t* count,ptrdiff_t* stride)
{
  int ndims, dimids[NC_MAX_VAR_DIMS];

  check_err(nc_inq_varndims (ncid, varid, &ndims));
  check_err(nc_inq_vardimid (ncid, varid, dimids));

  // default values for start, count and stride
  // i.e. all variable is loaded

  for (int i=0; i<ndims; i++) {
    check_err(nc_inq_dimlen(ncid,dimids[i],&(count[i])));
    start[i] = 0;
    //cout << "count def " << count[i] << " " << i << endl;
    stride[i] = 1;    
  }

  // start argument

  if (len > 2) 
    {
      uint64NDArray tmp = args(2).uint64_array_value();

      if (tmp.dims().numel() != ndims) 
	{
	  error("number of elements of argument %s should match the number "
		"of dimension of the netCDF variable",
		"start");
	}      

      for (int i=0; i<ndims; i++) 
	{      
	  start[i] = (size_t)tmp(ndims-i-1);

	  // if start is specified, the default for count is 1 (how odd!)
	  count[i] = 1;
	  //cout << "start " << start[i] << " " << i << endl;
	}    
    }

  // count argument

  if (len > 3) 
    {
      uint64NDArray tmp = args(3).uint64_array_value();

      if (tmp.dims().numel() != ndims) 
	{
	  error("number of elements of argument %s should match the number "
		"of dimension of the netCDF variable",
		"count");
	}      

      for (int i=0; i<ndims; i++) 
	{      
	  count[i] = (size_t)tmp(ndims-i-1);
	  //count[i] = (size_t)tmp(i);
	  //cout << "count " << count[i] << " " << i << endl;
	}    
    }

  // stride argument

  if (len > 4) 
    {
      int64NDArray tmp = args(4).int64_array_value();

      if (tmp.dims().numel() != ndims) 
	{
	  error("number of elements of argument %s should match the number "
		"of dimension of the netCDF variable",
		"stride");
	}      

      for (int i=0; i<ndims; i++) 
	{      
	  stride[i] = (ptrdiff_t)tmp(ndims-i-1);
	}    
    }

}


DEFUN_DLD(netcdf_getConstant, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{value} =} netcdf_getConstant(@var{name}) \n\
Returns the value of a NetCDF constant called @var{name}.\n\
@seealso{netcdf_getConstantNames}\n\
@end deftypefn")
{
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  return netcdf_get_constant(args(0));
}


DEFUN_DLD(netcdf_getConstantNames, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{value} =} netcdf_getConstantNames() \n\
Returns a list of all constant names.\n\
@end deftypefn\n\
@seealso{netcdf_getConstant}\n")
{

  if (args.length() != 0) 
    {
      print_usage ();
      return octave_value();
    }

  if (netcdf_constants.empty())
    {
      init();
    }

  Cell c = Cell (dim_vector(1,netcdf_constants.size()));

  int i = 0;
  for (std::map<std::string, octave_value>::const_iterator p = netcdf_constants.begin (); 
       p != netcdf_constants.end (); p++) {
    c(i++) = octave_value(p->first);
  }  

  return octave_value(c);

}


DEFUN_DLD(netcdf_inqLibVers, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{vers} =} netcdf_inqLibVers() \n\
Returns the version of the NetCDF library.\n\
@end deftypefn\n\
@seealso{netcdf_open}\n")
{
  if (args.length() != 0) 
    {
      print_usage ();
      return octave_value ();
    }

  return octave_value(std::string(nc_inq_libvers()));
}

DEFUN_DLD(netcdf_setDefaultFormat, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{old_format} =} netcdf_setDefaultFormat(@var{format}) \n\
Sets the default format of the NetCDF library and returns the previous default format (as a numeric value). @var{format} can be \n\
\"format_classic\", \"format_64bit\",  \"format_netcdf4\" or \"format_netcdf4_classic\". \n\
@end deftypefn\n\
@seealso{netcdf_open}\n")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value ();
    }

  int format = netcdf_get_constant(args(0)).int_value();
  int old_format;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_set_default_format(format, &old_format));

  return octave_value(old_format);
}


//      int nc_set_chunk_cache(size_t size, size_t nelems, float preemption);

DEFUN_DLD(netcdf_setChunkCache, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_setChunkCache(@var{size}, @var{nelems}, @var{preemption}) \n\
Sets the default chunk cache settins in the HDF5 library. The settings applies to all files which are subsequently opened or created.\n\
@end deftypefn\n\
@seealso{netcdf_getChunkCache}\n")
{
  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value();
    }
  
  size_t size = args(0).scalar_value();
  size_t nelems = args(1).scalar_value();
  float preemption = args(2).scalar_value();

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_set_chunk_cache(size, nelems, preemption));

  return octave_value();
}


//      int nc_get_chunk_cache(size_t *sizep, size_t *nelemsp, float *preemptionp);

DEFUN_DLD(netcdf_getChunkCache, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{size}, @var{nelems}, @var{preemption}] =} netcdf_getChunkCache() \n\
Gets the default chunk cache settins in the HDF5 library. \n\
@end deftypefn\n\
@seealso{netcdf_setChunkCache}\n")
{
  if (args.length() != 0) 
    {
      print_usage ();
      return octave_value ();
    }
  
  size_t size;
  size_t nelems;
  float preemption;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_get_chunk_cache(&size, &nelems, &preemption));
  octave_value_list retval;
  retval(0) = octave_value(size);
  retval(1) = octave_value(nelems);
  retval(2) = octave_value(preemption);

  return retval;
}



DEFUN_DLD(netcdf_create, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{ncid} =} netcdf_create(@var{filename},@var{mode}) \n\
Creates the file named @var{filename} in the mode @var{mode} which can have the \n\
following values: \n\
\"clobber\" (overwrite existing files), \n\
\"noclobber\" (prevent to overwrite existing files) \n\
\"64bit_offset\" (use the 64bit-offset format), \n\
\"netcdf4\" (use the NetCDF4, i.e. HDF5 format) or \n\
\"share\" (concurrent reading of the dataset). \n\
@var{mode} can also be the numeric value return by netcdf_getConstant. In the later-case it can be combined with a bitwise-or. \n\
@end deftypefn\n\
Example: \n\
@example \n\
mode =  bitor(netcdf.getConstant(\"classic_model\"), ...\n\
               netcdf.getConstant(\"netcdf4\")); \n\
ncid = netcdf.create(\"test.nc\",mode); \n\
@end example \n\
@seealso{netcdf_close}\n")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value ();
    }

  std::string filename = args(0).string_value();
  int mode = netcdf_get_constant(args(1)).int_value();
  int ncid;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_create(filename.c_str(), mode, &ncid));

  return octave_value(ncid);
}

DEFUN_DLD(netcdf_open, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{ncid} =} netcdf_open(@var{filename},@var{mode}) \n\
Opens the file named @var{filename} in the mode @var{mode}.\n\
@end deftypefn\n\
@seealso{netcdf_close}\n")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  std::string filename = args(0).string_value();
  int mode = netcdf_get_constant(args(1)).int_value();
  int ncid;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_open(filename.c_str(), mode, &ncid));

  return octave_value(ncid);
}



DEFUN_DLD(netcdf_abort, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_abort(@var{ncid}) \n\
Aborts all changes since the last time the dataset entered in define mode.\n\
@end deftypefn\n\
@seealso{netcdf_reDef}\n")
{

  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();

  if (error_state) 
    {
      print_usage ();
      return octave_value();    
    }

  check_err(nc_abort(ncid));

  return octave_value();
}


DEFUN_DLD(netcdf_sync, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_sync(@var{ncid}) \n\
Writes all changes to the disk and leaves the file open.\n\
@end deftypefn\n\
@seealso{netcdf_close}\n")
{

  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();

  if (error_state) 
    {
      print_usage ();
      return octave_value();    
    }

  check_err(nc_sync(ncid));

  return octave_value();
}

DEFUN_DLD(netcdf_setFill, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{old_mode} =} netcdf_setFill(@var{ncid},@var{fillmode}) \n\
Change the fill mode (@var{fillmode}) of the data set @var{ncid}. The previous value of the fill mode is returned. @var{fillmode} can be either \"fill\" or \"nofill\".\n\
@end deftypefn\n\
@seealso{netcdf_open}\n")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int fillmode = netcdf_get_constant(args(1)).int_value();
  int old_mode;

  if (error_state) 
    {
      print_usage ();
      return octave_value();    
    }

  check_err (nc_set_fill (ncid, fillmode, &old_mode));

  return octave_value(old_mode);
}


//int nc_inq          (int ncid, int *ndimsp, int *nvarsp, int *ngattsp,
//                          int *unlimdimidp);
DEFUN_DLD(netcdf_inq, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{ndims},@var{nvars},@var{ngatts},@var{unlimdimid}] =} netcdf_inq(@var{ncid}) \n\
Return the number of dimension (@var{ndims}), the number of variables (@var{nvars}), the number of global attributes (@var{ngatts}) and the id of the unlimited dimension (@var{unlimdimid}). \n\
If no unlimited dimension is declared -1 is returned. For NetCDF4 files, one should use \n\
the function netcdf_inqUnlimDims as multiple unlimite dimension exists. \n\
@end deftypefn\n\
@seealso{netcdf_inqUnlimDims}\n")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int ndims, nvars, ngatts, unlimdimid;
  octave_value_list retval;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq(ncid,&ndims,&nvars,&ngatts,&unlimdimid));
    
  retval(0) = octave_value(ndims);
  retval(1) = octave_value(nvars);
  retval(2) = octave_value(ngatts);
  retval(3) = octave_value(unlimdimid);
  return retval;
}

// int nc_inq_unlimdims(int ncid, int *nunlimdimsp, int *unlimdimidsp);
DEFUN_DLD(netcdf_inqUnlimDims, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{unlimdimids} =} netcdf_inqUnlimDims(@var{ncid}) \n\
Return the id of all unlimited dimensions of the NetCDF file @var{ncid}.\n\
@end deftypefn\n\
@seealso{netcdf_inq}\n")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int nunlimdims;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_unlimdims(ncid, &nunlimdims, NULL));
  Array<int> unlimdimids = Array<int>(dim_vector(1,nunlimdims));
  check_err(nc_inq_unlimdims(ncid, &nunlimdims, unlimdimids.fortran_vec()));
    
  return octave_value(unlimdimids);
}


// int nc_inq_format   (int ncid, int *formatp);
DEFUN_DLD(netcdf_inqFormat, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{format} =} netcdf_inqFormat(@var{ncid}) \n\
Return the NetCDF format of the dataset @var{ncid}.\n\
Format might be one of the following \n\
\"FORMAT_CLASSIC\", \"FORMAT_64BIT\", \"FORMAT_NETCDF4\" or \"FORMAT_NETCDF4_CLASSIC\" \n\
@end deftypefn\n\
@seealso{netcdf_inq}\n")
{

  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int format;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_format(ncid, &format));

  if (format == NC_FORMAT_CLASSIC) {
    return octave_value("FORMAT_CLASSIC");
  }
  if (format == NC_FORMAT_64BIT) {
    return octave_value("FORMAT_64BIT");
  }
  if (format == NC_FORMAT_NETCDF4) {
    return octave_value("FORMAT_NETCDF4");
  }

  return octave_value("FORMAT_NETCDF4_CLASSIC");
}

// int nc_def_dim (int ncid, const char *name, size_t len, int *dimidp);

DEFUN_DLD(netcdf_defDim, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{dimid} =} netcdf_defDim(@var{ncid},@var{name},@var{len}) \n\
Define the dimension with the name @var{name} and the length @var{len} in the dataset @var{ncid}. The id of the dimension is returned.\n\
@end deftypefn\n\
@seealso{netcdf_defVar}\n")
{

  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string name = args(1).string_value();
  size_t len = args(2).scalar_value();
  int dimid;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_def_dim (ncid, name.c_str(), len, &dimid));

  return octave_value(dimid);
}


// int nc_rename_dim(int ncid, int dimid, const char* name);


DEFUN_DLD(netcdf_renameDim, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_renameDim(@var{ncid},@var{dimid},@var{name}) \n\
Renames the dimension with the id @var{dimid} in the data set @var{ncid}. @var{name} is the new name of the dimension.\n\
@end deftypefn\n\
@seealso{netcdf_defDim}\n")
{

  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int dimid = args(1).scalar_value();
  std::string name = args(2).string_value();

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_rename_dim (ncid, dimid, name.c_str()));

  return octave_value();
}

//  int nc_def_var (int ncid, const char *name, nc_type xtype,
//                     int ndims, const int dimids[], int *varidp);

DEFUN_DLD(netcdf_defVar, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{varid} = } netcdf_defVar(@var{ncid},@var{name},@var{xtype},@var{dimids}) \n\
Defines a variable with the name @var{name} in the dataset @var{ncid}. @var{xtype} can be \"byte\", \"ubyte\", \"short\", \"ushort\", \"int\", \"uint\", \"int64\", \"uint64\", \"float\", \"double\", \"char\" or the corresponding number as returned by netcdf_getConstant. The parameter @var{dimids} define the ids of the dimension. For scalar this parameter is the empty array ([]). The variable id is returned. \n\
@end deftypefn\n\
@seealso{netcdf_open,netcdf_defDim}\n")
{

  if (args.length() != 4) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string name = args(1).string_value (); 
  int xtype = netcdf_get_constant(args(2)).int_value();;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  Array<double> tmp;

  if (!args(3).is_empty()) {
    tmp = args(3).vector_value ();  
  } 

  OCTAVE_LOCAL_BUFFER (int, dimids, tmp.numel());

  for (int i = 0; i < tmp.numel(); i++)
    {
      dimids[i] = tmp(tmp.numel()-i-1);
    }
  
  int varid;

  check_err(nc_def_var (ncid, name.c_str(), xtype, tmp.numel(), dimids, &varid));

  return octave_value(varid);
}


// int nc_rename_var(int ncid, int varid, const char* name);


DEFUN_DLD(netcdf_renameVar, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_renameVar(@var{ncid},@var{varid},@var{name}) \n\
Renames the variable with the id @var{varid} in the data set @var{ncid}. @var{name} is the new name of the variable.\n\
@end deftypefn\n\
@seealso{netcdf_defVar}\n")
{

  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string name = args(2).string_value();

  if (error_state)
    {
      print_usage ();
      return octave_value();
    }

  check_err(nc_rename_var (ncid, varid, name.c_str()));

  return octave_value();
}


// int nc_def_var_fill(int ncid, int varid, int no_fill, void *fill_value);
DEFUN_DLD(netcdf_defVarFill, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_defVarFill(@var{ncid},@var{varid},@var{no_fill},@var{fillvalue}) \n\
Define the fill-value settings of the NetCDF variable @var{varid}.\n\
If @var{no_fill} is false, then the values between no-contiguous writes are filled with the value @var{fill_value}. This is disabled by setting @var{no_fill} to true.\n\
@end deftypefn\n\
@seealso{netcdf_inqVarFill}\n")
{

  if (args.length() != 4) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int no_fill = args(2).scalar_value(); // boolean
  octave_value fill_value = args(3); 
  nc_type xtype;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_vartype (ncid, varid, &xtype));

  switch (xtype)
    {
#define OV_NETCDF_DEF_VAR_FILL(netcdf_type,c_type,method) \
      case netcdf_type:							\
	{								\
        check_err(nc_def_var_fill(ncid, varid, no_fill, fill_value.method().fortran_vec())); \
	  break;							\
	}                                                                       

        OV_NETCDF_DEF_VAR_FILL(NC_BYTE, signed char, int8_array_value)
	OV_NETCDF_DEF_VAR_FILL(NC_UBYTE, unsigned char, uint8_array_value)
	OV_NETCDF_DEF_VAR_FILL(NC_SHORT,      short, int16_array_value)
	OV_NETCDF_DEF_VAR_FILL(NC_USHORT, unsigned short, uint16_array_value)
	OV_NETCDF_DEF_VAR_FILL(NC_INT,  int,  int32_array_value)
	OV_NETCDF_DEF_VAR_FILL(NC_UINT, unsigned int, uint32_array_value)
	OV_NETCDF_DEF_VAR_FILL(NC_INT64,  long long,  int64_array_value)
	OV_NETCDF_DEF_VAR_FILL(NC_UINT64, unsigned long long, uint64_array_value)

	OV_NETCDF_DEF_VAR_FILL(NC_FLOAT, float, float_array_value)
	OV_NETCDF_DEF_VAR_FILL(NC_DOUBLE,double,array_value)

	OV_NETCDF_DEF_VAR_FILL(NC_CHAR, char, char_array_value)
          }

  return octave_value();
}



// int nc_def_var_fill(int ncid, int varid, int no_fill, void *fill_value);
DEFUN_DLD(netcdf_inqVarFill, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{no_fill},@var{fillvalue}] = } netcdf_inqVarFill(@var{ncid},@var{varid}) \n\
Determines the fill-value settings of the NetCDF variable @var{varid}.\n\
If @var{no_fill} is false, then the values between no-contiguous writes are filled with the value @var{fill_value}. This is disabled by setting @var{no_fill} to true.\n\
@end deftypefn\n\
@seealso{netcdf_defVarFill}\n")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int no_fill;
  nc_type xtype;
  octave_value_list retval;
  octave_value data;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_vartype (ncid, varid, &xtype));

  if (error_state)
    {
      return octave_value();      
    }

  switch (xtype)
    {
#define OV_NETCDF_INQ_VAR_FILL(netcdf_type,c_type)	                        \
      case netcdf_type:							        \
      {                                                                         \
        Array< c_type > fill_value = Array< c_type >(dim_vector(1,1));          \
        check_err(nc_inq_var_fill(ncid, varid, &no_fill,                        \
                     fill_value.fortran_vec()));                                \
        data = octave_value(fill_value);                                        \
        break;                                                                  \
      }                                                             

      OV_NETCDF_INQ_VAR_FILL(NC_BYTE,octave_int8)
      OV_NETCDF_INQ_VAR_FILL(NC_UBYTE,octave_uint8)
      OV_NETCDF_INQ_VAR_FILL(NC_SHORT,octave_int16)
      OV_NETCDF_INQ_VAR_FILL(NC_USHORT,octave_uint16)
      OV_NETCDF_INQ_VAR_FILL(NC_INT,octave_int32)
      OV_NETCDF_INQ_VAR_FILL(NC_UINT,octave_uint32)
      OV_NETCDF_INQ_VAR_FILL(NC_INT64,octave_int64)
      OV_NETCDF_INQ_VAR_FILL(NC_UINT64,octave_uint64)

      OV_NETCDF_INQ_VAR_FILL(NC_FLOAT,float)
      OV_NETCDF_INQ_VAR_FILL(NC_DOUBLE,double)

      OV_NETCDF_INQ_VAR_FILL(NC_CHAR,char) 
          }

  //cout << "xtype3 " << xtype << " " << NC_DOUBLE << std::endl;
  retval(0) = octave_value(no_fill);
  retval(1) = data;
  return retval;
}




//nc_def_var_deflate(int ncid, int varid, int shuffle, int deflate,
//                        int deflate_level);
DEFUN_DLD(netcdf_defVarDeflate, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_defVarDeflate (@var{ncid},@var{varid},@var{shuffle},@var{deflate},@var{deflate_level}) \n\
Define the compression settings NetCDF variable @var{varid}.\n\
If @var{deflate} is true, then the variable is compressed. The compression level @var{deflate_level} is an integer between 0 (no compression) and 9 (maximum compression).\n\
@end deftypefn\n\
@seealso{netcdf_inqVarDeflate}\n")
{

  if (args.length() != 5) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int shuffle = args(2).scalar_value(); // boolean
  int deflate = args(3).scalar_value(); // boolean
  int deflate_level = args(4).scalar_value();

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_def_var_deflate (ncid, varid, shuffle, deflate, deflate_level));
  return octave_value();
}


//nc_inq_var_deflate(int ncid, int varid, int *shufflep,
//                        int *deflatep, int *deflate_levelp);
DEFUN_DLD(netcdf_inqVarDeflate, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{shuffle},@var{deflate},@var{deflate_level}] = } netcdf_inqVarDeflate (@var{ncid},@var{varid}) \n\
Determines the compression settings NetCDF variable @var{varid}.\n\
If @var{deflate} is true, then the variable is compressed. The compression level @var{deflate_level} is an integer between 0 (no compression) and 9 (maximum compression).\n\
@end deftypefn\n\
@seealso{netcdf_defVarDeflate}\n")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int shuffle, deflate, deflate_level;
  octave_value_list retval;

  if (! error_state) {
    int format;
    check_err(nc_inq_format(ncid, &format));

    // nc_inq_var_deflate returns garbage for classic or 64bit files
    if (format == NC_FORMAT_CLASSIC || format == NC_FORMAT_64BIT) {
      shuffle = 0;
      deflate = 0; 
      deflate_level = 0;
    }
    else {
      check_err(nc_inq_var_deflate(ncid, varid, 
                                   &shuffle,&deflate,&deflate_level));
    }

    retval(0) = octave_value(shuffle);
    retval(1) = octave_value(deflate);
    retval(2) = octave_value(deflate_level);
  }

  return retval;
}

//int nc_def_var_chunking(int ncid, int varid, int storage, size_t *chunksizesp);
//chunksizes can be ommited if storage is \"CONTIGUOUS\"
DEFUN_DLD(netcdf_defVarChunking, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_defVarChunking (@var{ncid},@var{varid},@var{storage},@var{chunkSizes}) \n\
Define the chunking settings of NetCDF variable @var{varid}.\n\
If @var{storage} is the string \"chunked\", the variable is stored by chunk of the size @var{chunkSizes}.\n\
If @var{storage} is the string \"contiguous\", the variable is stored in a contiguous way.\n\
@end deftypefn\n\
@seealso{netcdf_inqVarChunking}\n")
{

  if (args.length() != 3 && args.length() != 4) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string storagestr = args(2).string_value();
  int storage;

  if (! error_state) {
    std::transform(storagestr.begin(), storagestr.end(),storagestr.begin(), ::toupper);

    if (storagestr == "CHUNKED") {
      storage = NC_CHUNKED;
    }
    else if (storagestr == "CONTIGUOUS") {
      storage = NC_CONTIGUOUS;
    }
    else  {
      error("unknown storage %s",storagestr.c_str());
      return octave_value();
    }

    if (args.length() == 4) {
      Array<double> tmp = args(3).vector_value();

      OCTAVE_LOCAL_BUFFER (size_t, chunksizes, tmp.numel());
      for (int i = 0; i < tmp.numel(); i++)
        {
          chunksizes[i] = tmp(tmp.numel()-i-1);
        }

      check_err(nc_def_var_chunking(ncid, varid, storage, chunksizes));
    }
    else {
      check_err(nc_def_var_chunking(ncid, varid, storage, NULL));
    }
  }

  return octave_value();
}

//int nc_inq_var_chunking(int ncid, int varid, int *storagep, size_t *chunksizesp);
DEFUN_DLD(netcdf_inqVarChunking, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{storage},@var{chunkSizes}] = } netcdf_inqVarChunking (@var{ncid},@var{varid}) \n\
Determines the chunking settings of NetCDF variable @var{varid}.\n\
If @var{storage} is the string \"chunked\", the variable is stored by chunk of the size @var{chunkSizes}.\n\
If @var{storage} is the string \"contiguous\", the variable is stored in a contiguous way.\n\
@end deftypefn\n\
@seealso{netcdf_defVarChunking}\n")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int storage;
  int ndims;
  octave_value_list retval;

  check_err(nc_inq_varndims (ncid, varid, &ndims));
  OCTAVE_LOCAL_BUFFER (size_t, chunksizes, ndims);

  if (! error_state) {
    check_err(nc_inq_var_chunking(ncid, varid, &storage, chunksizes));

    if (storage == NC_CHUNKED) {
      retval(0) = octave_value("chunked");
      Array<int> chunkSizes = Array<int>(dim_vector(1,ndims));

      for (int i = 0; i < ndims; i++)
        {
          chunkSizes(ndims-i-1) = chunksizes[i];
        }
      retval(1) = octave_value(chunkSizes);
    }
    else {
      retval(0) = octave_value("contiguous");
      retval(1) = octave_value(Array<double>());
    }

  }

  return retval;
}

// nc_def_var_fletcher32(int ncid, int varid, int checksum);
DEFUN_DLD(netcdf_defVarFletcher32, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_defVarFletcher32(@var{ncid},@var{varid},@var{checksum}) \n\
Defines the checksum settings of the variable with the id @var{varid} in the data set @var{ncid}. If @var{checksum} is the string \"FLETCHER32\", then fletcher32 checksums will be turned on for this variable. If @var{checksum} is \"NOCHECKSUM\", then checksums will be disabled. \n\
@end deftypefn\n\
@seealso{netcdf_defVar,netcdf_inqVarFletcher32}\n")
{

  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int checksum = netcdf_get_constant(args(2)).int_value();

  if (error_state)
    {
      print_usage ();
      return octave_value();
    }

  check_err(nc_def_var_fletcher32(ncid, varid, checksum));

  return octave_value();
}



DEFUN_DLD(netcdf_inqVarFletcher32, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{checksum} =} netcdf_inqVarFletcher32(@var{ncid},@var{varid}) \n\
Determines the checksum settings of the variable with the id @var{varid} in the data set @var{ncid}. If fletcher32 checksums is turned on for this variable, then @var{checksum} is the string \"FLETCHER32\". Otherwise it is the string \"NOCHECKSUM\". \n\
@end deftypefn\n\
@seealso{netcdf_defVar,netcdf_inqVarFletcher32}\n")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int checksum;

  if (error_state)
    {
      print_usage ();
      return octave_value();
    }

  check_err(nc_inq_var_fletcher32(ncid, varid, &checksum));

  if (checksum == NC_FLETCHER32) 
    {
      return octave_value("FLETCHER32");
    }
  else 
    {
      return octave_value("NOCHECKSUM");
    }  
}



DEFUN_DLD(netcdf_endDef, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_endDef (@var{ncid}) \n\
Leaves define-mode of NetCDF file @var{ncid}.\n\
@end deftypefn\n\
@seealso{netcdf_reDef}\n")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_enddef (ncid));
  
  return octave_value();
}

DEFUN_DLD(netcdf_reDef, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_reDef (@var{ncid}) \n\
Enter define-mode of NetCDF file @var{ncid}.\n\
@end deftypefn\n\
@seealso{netcdf_endDef}\n")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_redef (ncid));
  
  return octave_value();
}

// http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-c/nc_005fput_005fvar_005f-type.html#nc_005fput_005fvar_005f-type

DEFUN_DLD(netcdf_putVar, args,, 
"-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {} netcdf_putVar (@var{ncid},@var{varid},@var{data}) \n\
@deftypefnx {Loadable Function} {} netcdf_putVar (@var{ncid},@var{varid},@var{start},@var{data}) \n\
@deftypefnx {Loadable Function} {} netcdf_putVar (@var{ncid},@var{varid},@var{start},@var{count},@var{data}) \n\
@deftypefnx {Loadable Function} {} netcdf_putVar (@var{ncid},@var{varid},@var{start},@var{count},@var{stride},@var{data}) \n\
Put data in a NetCDF variable.\n\
The data @var{data} is stored in the variable @var{varid} of the NetCDF file @var{ncid}. \n\
@var{start} is the start index of each dimension (0-based and defaults to a vector of zeros), \n\
@var{count} is the number of elements of to be written along each dimension (default all elements)\n\
 and @var{stride} is the sampling interval.\n\
@end deftypefn\n\
@seealso{netcdf_endDef}\n")
{
  if (args.length() < 3 || args.length() > 6) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value (); 
  octave_value data = args(args.length()-1);
  size_t start[NC_MAX_VAR_DIMS];
  size_t count[NC_MAX_VAR_DIMS];
  ptrdiff_t stride[NC_MAX_VAR_DIMS];
  nc_type xtype;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_vartype (ncid, varid, &xtype));
  //int sliced_numel = tmp.numel();

  if (error_state)
    {
      return octave_value();      
    }

  start_count_stride(ncid, varid, args, args.length()-1, start, count, stride);

  // check if count matched size(data)

  switch (xtype)
    {
#define OV_NETCDF_PUT_VAR(netcdf_type,c_type,method) \
      case netcdf_type:							\
	{								\
	  check_err(nc_put_vars (ncid, varid, start, count, stride, (c_type*)data.method().fortran_vec())); \
	  break;							\
	}                                                                       

      OV_NETCDF_PUT_VAR(NC_BYTE, signed char, int8_array_value)
	OV_NETCDF_PUT_VAR(NC_UBYTE, unsigned char, uint8_array_value)
	OV_NETCDF_PUT_VAR(NC_SHORT,      short, int16_array_value)
	OV_NETCDF_PUT_VAR(NC_USHORT, unsigned short, uint16_array_value)
	OV_NETCDF_PUT_VAR(NC_INT,  int,  int32_array_value)
	OV_NETCDF_PUT_VAR(NC_UINT, unsigned int, uint32_array_value)
	OV_NETCDF_PUT_VAR(NC_INT64,  long long,  int64_array_value)
	OV_NETCDF_PUT_VAR(NC_UINT64, unsigned long long, uint64_array_value)

	OV_NETCDF_PUT_VAR(NC_FLOAT, float, float_array_value)
	OV_NETCDF_PUT_VAR(NC_DOUBLE,double,array_value)

	OV_NETCDF_PUT_VAR(NC_CHAR, char, char_array_value)
      default: 
	{
	  error("unknown type %d" ,xtype);
	}	
    }
  return octave_value();
}



DEFUN_DLD(netcdf_getVar, args,, 	  
"-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {@var{data} =} netcdf_getVar (@var{ncid},@var{varid}) \n\
@deftypefnx {Loadable Function} {@var{data} =} netcdf_getVar (@var{ncid},@var{varid},@var{start}) \n\
@deftypefnx {Loadable Function} {@var{data} =} netcdf_getVar (@var{ncid},@var{varid},@var{start},@var{count}) \n\
@deftypefnx {Loadable Function} {@var{data} =} netcdf_getVar (@var{ncid},@var{varid},@var{start},@var{count},@var{stride}) \n\
Get the data from a NetCDF variable.\n\
The data @var{data} is loaded from the variable @var{varid} of the NetCDF file @var{ncid}. \n\
@var{start} is the start index of each dimension (0-based and defaults to a vector of zeros), \n\
@var{count} is the number of elements of to be written along each dimension (default all elements)\n\
 and @var{stride} is the sampling interval.\n\
@end deftypefn\n\
@seealso{netcdf_putVar}\n")
{
  if (args.length() < 2 || args.length() > 5) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value ();   
  std::list<Range> ranges;
  int ndims;
  size_t start[NC_MAX_VAR_DIMS];
  size_t count[NC_MAX_VAR_DIMS];
  ptrdiff_t stride[NC_MAX_VAR_DIMS];

  octave_value data;
  nc_type xtype;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_vartype (ncid, varid, &xtype));

  if (error_state)
    {
      return octave_value();      
    }

  check_err(nc_inq_varndims (ncid, varid, &ndims));

  if (error_state)
    {
      return octave_value();      
    }

  int sz = 1;

  dim_vector sliced_dim_vector;

  if (ndims < 2) 
    {
      sliced_dim_vector.resize(2);
      sliced_dim_vector(0) = 1;
      sliced_dim_vector(1) = 1;
    }
  else
    {
      sliced_dim_vector.resize(ndims);
    }

  start_count_stride(ncid, varid, args, args.length(), start, count, stride);

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }


  // total size sz
  for (int i=0; i<ndims; i++) {
    sz = sz * count[i];
    sliced_dim_vector(i) = count[ndims-i-1];
    //sliced_dim_vector(i) = count[i];
  }


  //cout << "start " << start[0] << endl;
  // need to take count and stride



  //cout << "sz " << sz << endl;
  //cout << "sliced_dim_vector " << sliced_dim_vector(0) << " x " << sliced_dim_vector(1) << endl;

  switch (xtype)
    {
#define OV_NETCDF_GET_VAR_CASE(netcdf_type,c_type)	                        \
      case netcdf_type:							\
      {                                                                                 \
	Array < c_type > arr = Array < c_type >(sliced_dim_vector);                     \
	check_err(nc_get_vars(ncid, varid, start, count, stride, arr.fortran_vec()));   \
	data = octave_value(arr);                                                       \
	break;                                                                          \
      }                                                                                 

      OV_NETCDF_GET_VAR_CASE(NC_BYTE,octave_int8)
      OV_NETCDF_GET_VAR_CASE(NC_UBYTE,octave_uint8)
      OV_NETCDF_GET_VAR_CASE(NC_SHORT,octave_int16)
      OV_NETCDF_GET_VAR_CASE(NC_USHORT,octave_uint16)
      OV_NETCDF_GET_VAR_CASE(NC_INT,octave_int32)
      OV_NETCDF_GET_VAR_CASE(NC_UINT,octave_uint32)
      OV_NETCDF_GET_VAR_CASE(NC_INT64,octave_int64)
      OV_NETCDF_GET_VAR_CASE(NC_UINT64,octave_uint64)

      OV_NETCDF_GET_VAR_CASE(NC_FLOAT,float)
      OV_NETCDF_GET_VAR_CASE(NC_DOUBLE,double)

      OV_NETCDF_GET_VAR_CASE(NC_CHAR, char) 

      default: 
	{
	  error("unknown type %d" ,xtype);
	}	

    }

  return data;
}

DEFUN_DLD(netcdf_close, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_close(@var{ncid}) \n\
Close the NetCDF file with the id @var{ncid}.\n\
@end deftypefn\n\
@seealso{netcdf_open}\n")
{

  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_close(ncid));
  return octave_value ();
}



//  int nc_inq_attname(int ncid, int varid, int attnum, char *name);

DEFUN_DLD(netcdf_inqAttName, args,, 
"-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {@var{name} =} netcdf_inqAttName (@var{ncid},@var{varid},@var{attnum}) \n\
Get the name of a NetCDF attribute.\n\
This function returns the name of the attribute with the id @var{attnum} of the variable \n\
@var{varid} in the NetCDF file @var{ncid}. For global attributes @var{varid} can be \n\
netcdf_getConstant(\"global\").\n\
@seealso{netcdf_inqAttName}\n\
@end deftypefn")
{
  if (args.length() != 3) {
    print_usage ();
    return octave_value();
  }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int attnum = args(2).scalar_value();
  char name[NC_MAX_NAME+1];

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_attname(ncid, varid, attnum, name));

  return octave_value(std::string(name));  
}


DEFUN_DLD(netcdf_inqAttID, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{attnum} =} netcdf_inqAttID(@var{ncid},@var{varid},@var{attname}) \n\
Return the attribute id @var{attnum} of the attribute named @var{attname} of the variable @var{varid} in the dataset @var{ncid}. \n\
For global attributes @var{varid} can be \n\
netcdf_getConstant(\"global\").\n\
@seealso{netcdf_inqAttName}\n\
@end deftypefn")
{
  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value ();
    }
  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string attname = args(2).string_value();
  int attnum;

  if (error_state)
    {
      print_usage ();
      return octave_value ();
    }

  check_err (nc_inq_attid (ncid, varid, attname.c_str(), &attnum));

  return octave_value(attnum);
}


//int nc_inq_att    (int ncid, int varid, const char *name,
//                        nc_type *xtypep, size_t *lenp);

DEFUN_DLD(netcdf_inqAtt, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{xtype},@var{len}] = } netcdf_inqAtt(@var{ncid},@var{varid},@var{name}) \n\
Get attribute type and length.\n\
@seealso{netcdf_inqAttName}\n\
@end deftypefn")
{
  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string name = args(2).string_value();
  int xtype;
  size_t len;
  octave_value_list retval;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_att(ncid, varid, name.c_str(), &xtype, &len));
  
  retval(0) = octave_value(xtype);
  retval(1) = octave_value(len);
  return retval;
}


DEFUN_DLD(netcdf_getAtt, args,, 
"-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {@var{data} =} netcdf_getAtt (@var{ncid},@var{varid},@var{name}) \n\
Get the value of a NetCDF attribute.\n\
This function returns the value of the attribute called @var{name} of the variable \n\
@var{varid} in the NetCDF file @var{ncid}. For global attributes @var{varid} can be \n\
netcdf_getConstant(\"global\").\n\
@seealso{netcdf_putAtt}\n\
@end deftypefn")
{
  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string attname = args(2).string_value();
  nc_type xtype;
  size_t len;
  octave_value data;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_att(ncid, varid, attname.c_str(), &xtype, &len));

  if (error_state)
    {
      return octave_value();      
    }

#define OV_NETCDF_GET_ATT_CASE(netcdf_type,c_type)	                        \
  if (xtype == netcdf_type)						        \
      {                                                                         \
        Array< c_type > arr = Array< c_type >(dim_vector(1,len));               \
        check_err(nc_get_att(ncid, varid, attname.c_str(), arr.fortran_vec())); \
        data = octave_value(arr);                                               \
      }                                                                                 
      OV_NETCDF_GET_ATT_CASE(NC_BYTE,octave_int8)
      OV_NETCDF_GET_ATT_CASE(NC_UBYTE,octave_uint8)
      OV_NETCDF_GET_ATT_CASE(NC_SHORT,octave_int16)
      OV_NETCDF_GET_ATT_CASE(NC_USHORT,octave_uint16)
      OV_NETCDF_GET_ATT_CASE(NC_INT,octave_int32)
      OV_NETCDF_GET_ATT_CASE(NC_UINT,octave_uint32)
      OV_NETCDF_GET_ATT_CASE(NC_INT64,octave_int64)
      OV_NETCDF_GET_ATT_CASE(NC_UINT64,octave_uint64)

      OV_NETCDF_GET_ATT_CASE(NC_FLOAT,float)
      OV_NETCDF_GET_ATT_CASE(NC_DOUBLE,double)

      OV_NETCDF_GET_ATT_CASE(NC_CHAR, char) 

	    
  return data;
}


DEFUN_DLD(netcdf_putAtt, args,, 
"-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {} netcdf_putAtt (@var{ncid},@var{varid},@var{name},@var{data}) \n\
Defines a NetCDF attribute.\n\
This function defines the attribute called @var{name} of the variable \n\
@var{varid} in the NetCDF file @var{ncid}. The value of the attribute will be @var{data}. \n\
For global attributes @var{varid} can be \n\
netcdf_getConstant(\"global\").\n\
@seealso{netcdf_getAtt}\n\
@end deftypefn")
{
  if (args.length() != 4) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string attname = args(2).string_value();
  octave_value data = args(3);

  nc_type xtype;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  // get matching netcdf type

  if (data.is_string())
    xtype = NC_CHAR;
  else if (data.is_int8_type())
    xtype = NC_BYTE;
  else if (data.is_uint8_type())
    xtype = NC_UBYTE;
  else if (data.is_int16_type())
    xtype = NC_SHORT;
  else if (data.is_uint16_type())
    xtype = NC_USHORT;
  else if (data.is_int32_type())
    xtype = NC_INT;
  else if (data.is_uint32_type())
    xtype = NC_UINT;
  else if (data.is_int64_type())
    xtype = NC_INT64;
  else if (data.is_uint64_type())
    xtype = NC_UINT64;
  else if (data.is_single_type())
    xtype = NC_FLOAT;
  else
    xtype = NC_DOUBLE;

  //cout << "xtype " << xtype << endl;
  size_t len = data.numel();

  switch (xtype)
    {
#define OV_NETCDF_PUT_ATT(netcdf_type,c_type,method) \
      case netcdf_type:							\
	{								\
	  check_err(nc_put_att (ncid, varid, attname.c_str(), xtype, len, data.method().fortran_vec())); \
	  break;							\
	}                                                                       

      OV_NETCDF_PUT_ATT(NC_BYTE, signed char, int8_array_value)
	OV_NETCDF_PUT_ATT(NC_UBYTE, unsigned char, uint8_array_value)
	OV_NETCDF_PUT_ATT(NC_SHORT,      short, int16_array_value)
	OV_NETCDF_PUT_ATT(NC_USHORT, unsigned short, uint16_array_value)
	OV_NETCDF_PUT_ATT(NC_INT,  int,  int32_array_value)
	OV_NETCDF_PUT_ATT(NC_UINT, unsigned int, uint32_array_value)
	OV_NETCDF_PUT_ATT(NC_INT64,  long long,  int64_array_value)
	OV_NETCDF_PUT_ATT(NC_UINT64, unsigned long long, uint64_array_value)

	OV_NETCDF_PUT_ATT(NC_FLOAT, float, float_array_value)
	OV_NETCDF_PUT_ATT(NC_DOUBLE,double,array_value)

	OV_NETCDF_PUT_ATT(NC_CHAR, char, char_array_value)
   }

  /*  check_err(nc_put_att           (int ncid, int varid, const char *name, nc_type xtype,
      size_t len, const void *op));*/

  return octave_value();

}


DEFUN_DLD(netcdf_copyAtt, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_copyAtt (@var{ncid},@var{varid},@var{name},@var{ncid_out},@var{varid_out}) \n\
Copies the attribute named @var{old_name} of the variable @var{varid} in the data set @var{ncid} \n\
to the variable @var{varid_out} in the data set @var{ncid_out}. \n\
To copy a global attribute use netcdf_getConstant(\"global\") for @var{varid} or @var{varid_out}.\n\
@seealso{netcdf_getAtt,netcdf_getConstant}\n\
@end deftypefn")
{

  if (args.length() != 5) 
    {
      print_usage ();
      return octave_value ();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string name = args(2).string_value();
  int ncid_out = args(3).scalar_value();
  int varid_out = args(4).scalar_value();

  if (error_state)
    {
      print_usage ();
      return octave_value ();
    }

  check_err (nc_copy_att (ncid, varid, name.c_str(),
			  ncid_out, varid_out));

  return octave_value ();
}


DEFUN_DLD(netcdf_renameAtt, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_renameAtt(@var{ncid},@var{varid},@var{old_name},@var{new_name}) \n\
Renames the attribute named @var{old_name} of the variable @var{varid} in the data set @var{ncid}. @var{new_name} is the new name of the attribute.\n\
To rename a global attribute use netcdf_getConstant(\"global\") for @var{varid}.\n\
@seealso{netcdf_copyAtt,netcdf_getConstant}\n\
@end deftypefn")
{

  if (args.length() != 4) 
    {
      print_usage ();
      return octave_value ();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string old_name = args(2).string_value();
  std::string new_name = args(3).string_value();

  if (error_state)
    {
      print_usage ();
      return octave_value ();
    }

  check_err(nc_rename_att (ncid, varid, old_name.c_str(), new_name.c_str()));

  return octave_value ();
}


DEFUN_DLD(netcdf_delAtt, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} netcdf_delAtt(@var{ncid},@var{varid},@var{name}) \n\
Deletes the attribute named @var{name} of the variable @var{varid} in the data set @var{ncid}. \n\
To delete a global attribute use netcdf_getConstant(\"global\") for @var{varid}.\n\
@seealso{netcdf_defAtt,netcdf_getConstant}\n\
@end deftypefn")
{

  if (args.length() != 3) 
    {
      print_usage ();
      return octave_value ();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string name = args(2).string_value();

  if (error_state)
    {
      print_usage ();
      return octave_value ();
    }

  check_err(nc_del_att (ncid, varid, name.c_str()));

  return octave_value ();
}


DEFUN_DLD(netcdf_inqVarID, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{varid} = } netcdf_inqVarID (@var{ncid},@var{name}) \n\
Return the id of a variable based on its name.\n\
@seealso{netcdf_defVar,netcdf_inqVarIDs}\n\
@end deftypefn")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string varname = args(1).string_value();
  int varid;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_varid(ncid,varname.c_str(), &varid));

  return octave_value(varid);
}

DEFUN_DLD(netcdf_inqVarIDs, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{varids} = } netcdf_inqVarID (@var{ncid}) \n\
Return all variable ids.\n\
This functions returns all variable ids in a NetCDF file or NetCDF group.\n\
@seealso{netcdf_inqVarID}\n\
@end deftypefn")
{

  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value ();
    }

  int ncid = args(0).scalar_value();
  int nvars;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_varids(ncid, &nvars, NULL));

  if (error_state)
    {
      return octave_value();      
    }

  Array<int> varids = Array<int>(dim_vector(1,nvars));
  check_err(nc_inq_varids(ncid, &nvars, varids.fortran_vec()));

  return octave_value(varids);
}

DEFUN_DLD(netcdf_inqVar, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{name},@var{nctype},@var{dimids},@var{nattr}] = } netcdf_inqVarID (@var{ncid},@var{varid}) \n\
Inquires information about a NetCDF variable.\n\
This functions returns the @var{name}, the NetCDF type @var{nctype}, an array of dimension ids \n\
@var{dimids} and the number of attributes @var{nattr} of the NetCDF variable. @var{nctype} in an \n\
integer corresponding NetCDF constants.\n\
@seealso{netcdf_inqVarID,netcdf_getConstant}\n\
@end deftypefn")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  char name[NC_MAX_NAME+1];
  int ndims, dimids[NC_MAX_VAR_DIMS], natts;
  nc_type xtype;
  octave_value_list retval;

  if (error_state) 
    {
      print_usage ();      
      return octave_value();
    }
    
  check_err(nc_inq_varndims(ncid, varid, &ndims));
    
  if (error_state) 
    {
      return octave_value();
    }

  check_err(nc_inq_var(ncid, varid, name, &xtype,
		       &ndims, dimids, &natts));
    
  retval(0) = octave_value(std::string(name));
  retval(1) = octave_value(xtype);

  // copy output arguments
  Array<double> dimids_ = Array<double>(dim_vector(1,ndims));
  for (int i = 0; i < ndims; i++) 
    {
      dimids_(i) = dimids[ndims-i-1];
    }

  retval(2) = octave_value(dimids_);
  retval(3) = octave_value(natts);

  return retval;
}



DEFUN_DLD(netcdf_inqDim, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{name},@var{length}] =} netcdf_inqDim(@var{ncid},@var{dimid}) \n\
Returns the name and length of a NetCDF dimension.\n\
@seealso{netcdf_inqDimID}\n\
@end deftypefn")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int dimid = args(1).scalar_value();
  octave_value_list retval;

  if (! error_state) 
    {
      char name[NC_MAX_NAME+1];
      size_t length;
      check_err(nc_inq_dim(ncid, dimid, name, &length));
      
      retval(0) = octave_value(std::string(name));
      retval(1) = octave_value(length);
    }

  return retval;
}


DEFUN_DLD(netcdf_inqDimID, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{dimid} =} netcdf_inqDimID(@var{ncid},@var{dimname}) \n\
Return the id of a NetCDF dimension.\n\
@seealso{netcdf_inqDim}\n\
@end deftypefn")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string dimname = args(1).string_value();
  int id;
  octave_value_list retval;

  if (! error_state) 
    {
      check_err(nc_inq_dimid(ncid, dimname.c_str(), &id));      
      retval(0) = octave_value(id);
    }

  return retval;
}

// int nc_inq_dimids(int ncid, int *ndims, int *dimids, int include_parents);
DEFUN_DLD(netcdf_inqDimIDs, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{dimids} =} netcdf_inqDimID(@var{ncid}) \n\
@deftypefnx {Loadable Function} {@var{dimids} =} netcdf_inqDimID(@var{ncid},@var{include_parents}) \n\
Return the dimension ids defined in a NetCDF file.\n\
If @var{include_parents} is 1, the dimension ids of the parent group are also returned.\n\
Per default this is not the case (@var{include_parents} is 0).\n\
@seealso{netcdf_inqDim}\n\
@end deftypefn")
{
  if (args.length() != 1 && args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int include_parents = 0;
  if (args.length() == 2) 
    {
      include_parents = args(0).scalar_value();  
    }

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  int ndims;
  check_err(nc_inq_ndims(ncid, &ndims));
  Array<int> dimids = Array<int>(dim_vector(1,ndims));
  check_err(nc_inq_dimids(ncid, &ndims, dimids.fortran_vec(),include_parents));
    
  return octave_value(dimids);
}



// groups

//int nc_def_grp(int parent_ncid, const char *name, int *new_ncid);

DEFUN_DLD(netcdf_defGrp, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{new_ncid} =} netcdf_defGrp(@var{ncid},@var{name}) \n\
Define a group in a NetCDF file.\n\
@seealso{netcdf_inqGrps}\n\
@end deftypefn")
{

  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int parent_ncid = args(0).scalar_value();
  std::string name = args(1).string_value();
  int new_ncid;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_def_grp(parent_ncid, name.c_str(), &new_ncid));
  return octave_value(new_ncid);
}


// int nc_inq_grps(int ncid, int *numgrps, int *ncids);
DEFUN_DLD(netcdf_inqGrps, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{ncids} =} netcdf_inqGrps(@var{ncid}) \n\
Return all groups ids in a NetCDF file.\n\
@seealso{netcdf_inqGrps}\n\
@end deftypefn")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int numgrps;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_grps(ncid, &numgrps, NULL));

  if (error_state)
    {
      return octave_value();      
    }

  Array<int> ncids = Array<int>(dim_vector(1,numgrps));
  check_err(nc_inq_grps(ncid, NULL, ncids.fortran_vec()));
    
  return octave_value(ncids);
}

//int nc_inq_grpname(int ncid, char *name);
DEFUN_DLD(netcdf_inqGrpName, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{name} =} netcdf_inqGrpName(@var{ncid}) \n\
Return group name in a NetCDF file.\n\
@seealso{netcdf_inqGrps}\n\
@end deftypefn")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  char name[NC_MAX_NAME+1];

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_grpname(ncid, name));    

  if (error_state)
    {
      return octave_value();      
    }

  return octave_value(std::string(name));
}

//int nc_inq_grpname_full(int ncid, size_t *lenp, char *full_name);
DEFUN_DLD(netcdf_inqGrpNameFull, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{name} =} netcdf_inqGrpNameFull(@var{ncid}) \n\
Return full name of group in NetCDF file.\n\
@seealso{netcdf_inqGrpName}\n\
@end deftypefn")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  size_t len;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_grpname_len(ncid,&len));

  if (error_state)
    {
      return octave_value();      
    }

  char* name = new char[len+1];
  octave_value retval;
  check_err(nc_inq_grpname_full(ncid, &len, name));

  if (error_state)
    {
      delete name;
      return octave_value();      
    }

  retval = octave_value(std::string(name));
  delete name;
  return retval;
}

// int nc_inq_grp_parent(int ncid, int *parent_ncid);
DEFUN_DLD(netcdf_inqGrpParent, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{parent_ncid} =} netcdf_inqGrpParent(@var{ncid}) \n\
Return id of the parent group\n\
@seealso{netcdf_inqGrpName}\n\
@end deftypefn")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int parent_ncid;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_grp_parent(ncid, &parent_ncid));
  return octave_value(parent_ncid);
}

// int nc_inq_grp_full_ncid(int ncid, char *full_name, int *grp_ncid);
DEFUN_DLD(netcdf_inqGrpFullNcid, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{grp_ncid} =} netcdf_inqGrpFullNcid(@var{ncid},@var{name}) \n\
Return the group id based on the full group name.\n\
@seealso{netcdf_inqGrpName}\n\
@end deftypefn")
{
  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string name = args(1).string_value();
  int grp_ncid;

  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  int format;
  check_err(nc_inq_format(ncid, &format));

  if (error_state)
    {
      return octave_value();      
    }

  if (format == NC_FORMAT_CLASSIC || format == NC_FORMAT_64BIT) 
    {
      if (name == "/") 
        {
          return octave_value(ncid);
        }
      else 
        {
          error("groups are not supported in this format");
          return octave_value();
        }
    }

  // nc_inq_grp_full_ncid makes a segmentation fault if
  // file is in non-HDF5 format
  check_err(nc_inq_grp_full_ncid(ncid, name.c_str(),&grp_ncid));
  return octave_value(grp_ncid);
}



// int nc_inq_ncid(int ncid, const char *name, int *grp_ncid);
DEFUN_DLD(netcdf_inqNcid, args,, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{grp_ncid} =} netcdf_inqNcid(@var{ncid},@var{name}) \n\
Return group id based on its name\n\
@seealso{netcdf_inqGrpFullNcid}\n\
@end deftypefn")
{
  if (args.length() != 2) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string name = args(1).string_value();
  int grp_ncid;
  
  if (error_state)
    {
      print_usage ();
      return octave_value();      
    }

  check_err(nc_inq_ncid(ncid, name.c_str(), &grp_ncid));    
  return octave_value(grp_ncid);
}
