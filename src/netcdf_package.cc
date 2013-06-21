#include <octave/oct.h>
#include <octave/ov-cell.h>

#include <netcdf.h>

#include <string>
#include <map>
#include <iostream>
#include <algorithm>
#include <vector>

using namespace std;

typedef std::map<std::string, long long>::const_iterator map_const_iterator;
std::map<std::string, long long> constants;

void init() {  
  #include "nc_constants.h"
}

void check_err(int status) 
{
  if (status != NC_NOERR) error("%s",nc_strerror(status));
}


int _get_constant(std::string name)
{
  if (constants.empty())
    {
      init();
    }
  
  map_const_iterator cst = constants.find(name);

  if (cst != constants.end ())
    return cst->second;
  else
    error("unknown netcdf constant: %s",name.c_str());
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

int _get_type(std::string name) 
{
  return _get_constant(normalize_ncname(name));
}

int netcdf_constants_int(octave_value ov) 
{
  if (ov.is_scalar_type())
    {
      return ov.scalar_value();
    }
  else
    {
      std::string name = normalize_ncname(ov.string_value());
      return _get_constant(name);
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
"")
{
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  octave_value ov = args(0);
  if (ov.is_scalar_type())
    {
      return ov;
    }

  std::string name = ov.string_value();

  name = normalize_ncname(name);

#define OV_NETCDF_CONST(nctype,octtype)                 \
  if (name == std::string("NC_FILL_") + #nctype) \
  return octave_value(octave_ ## octtype(NC_FILL_ ## nctype));

  OV_NETCDF_CONST(BYTE,   int8)
  OV_NETCDF_CONST(UBYTE,  uint8)
  OV_NETCDF_CONST(SHORT,  int16)
  OV_NETCDF_CONST(USHORT, uint16)
  OV_NETCDF_CONST(INT,    int32)
  OV_NETCDF_CONST(UINT,   uint32)
  OV_NETCDF_CONST(INT64,  int64)
  OV_NETCDF_CONST(UINT64, uint64)

  if (name == "NC_FILL_FLOAT") return octave_value((float)(NC_FILL_FLOAT));
  if (name == "NC_FILL_DOUBLE") return octave_value((double)(NC_FILL_DOUBLE));
  if (name == "NC_FILL_STRING") return octave_value(std::string(NC_FILL_STRING));
  if (name == "NC_FILL_CHAR") return octave_value(std::string(NC_FILL_CHAR));

  return octave_value(_get_constant(name));
}


DEFUN_DLD(netcdf_getConstantNames, args,, 
"")
{


  if (args.length() != 0) {
      print_usage ();
      return octave_value();
    }

  Cell c = Cell (dim_vector(1,constants.size()));
  //Cell c = Cell ();
  int i = 0;
  for (map_const_iterator p = constants.begin (); p != constants.end (); p++) {
    //std::cout << "val " << p->first << p->second << std::endl;
    c(i++) = octave_value(p->first);
  }

  

  return octave_value(c);

}


DEFUN_DLD(netcdf_inqLibVers, args,, 
"")
{
  if (args.length() != 0) {
      print_usage ();
      return octave_value();
    }

  return octave_value(string(nc_inq_libvers()));
}

DEFUN_DLD(netcdf_setDefaultFormat, args,, 
"")
{
  if (args.length() != 0) {
      print_usage ();
      return octave_value();
    }
  int format = netcdf_constants_int(args(0));
  int old_format;

  check_err(nc_set_default_format(format, &old_format));

  return octave_value(old_format);
}



DEFUN_DLD(netcdf_create, args,, 
"")
{

  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  std::string filename = args(0).string_value();
  int mode = netcdf_constants_int(args(1));
  int ncid;

  check_err(nc_create(filename.c_str(), mode, &ncid));

  return octave_value(ncid);
}

DEFUN_DLD(netcdf_open, args,, 
"")
{

  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  std::string filename = args(0).string_value();
  int mode = netcdf_constants_int(args(1));
  int ncid;

  check_err(nc_open(filename.c_str(), mode, &ncid));

  return octave_value(ncid);
}




//int nc_inq          (int ncid, int *ndimsp, int *nvarsp, int *ngattsp,
//                          int *unlimdimidp);
DEFUN_DLD(netcdf_inq, args,, 
"")
{
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int ndims, nvars, ngatts, unlimdimid;
  octave_value_list retval;

  check_err(nc_inq(ncid,&ndims,&nvars,&ngatts,&unlimdimid));
    
  retval(0) = octave_value(ndims);
  retval(1) = octave_value(nvars);
  retval(2) = octave_value(ngatts);
  retval(3) = octave_value(unlimdimid);
  return retval;
}

// int nc_inq_unlimdims(int ncid, int *nunlimdimsp, int *unlimdimidsp);
DEFUN_DLD(netcdf_inqUnlimDims, args,, 
"")
{
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int nunlimdims;

  check_err(nc_inq_unlimdims(ncid, &nunlimdims, NULL));
  Array<int> unlimdimids = Array<int>(dim_vector(1,nunlimdims));
  check_err(nc_inq_unlimdims(ncid, &nunlimdims, unlimdimids.fortran_vec()));
    
  return octave_value(unlimdimids);
}


// int nc_inq_format   (int ncid, int *formatp);
DEFUN_DLD(netcdf_inqFormat, args,, 
"")
{

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int format;
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
"")
{

  if (args.length() != 3) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string name = args(1).string_value();
  size_t len = args(2).scalar_value();
  int dimid;

  check_err(nc_def_dim (ncid, name.c_str(), len, &dimid));

  return octave_value(dimid);
}

//  int nc_def_var (int ncid, const char *name, nc_type xtype,
//                     int ndims, const int dimids[], int *varidp);

DEFUN_DLD(netcdf_defVar, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{varid} = } netcdf_defVar(@var{ncid},@var{varid},@var{name},@var{xtype},@{dimids}) \n\
Defines a variable with the name @var{name}. @var{xtype} can be \"byte\", \"ubyte\", \"short\", \"ushort\", \"int\", \"uint\", \"int64\", \"uint64\", \"float\", \"double\", \"char\" or the corresponding number as returned by netcdf_getConstant. \n\
@end deftypefn\n\
@seealso{netcdf_open}\n")
{

  if (args.length() != 4) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string name = args(1).string_value (); 
  int xtype;
  Array<double> tmp;

  if (args(2).is_scalar_type()) {
    xtype = args(2).scalar_value();
  }
  else {
    xtype = _get_type(args(2).string_value());
  }


  if (!args(3).is_empty()) {
    tmp = args(3).vector_value ();  
  } 

  OCTAVE_LOCAL_BUFFER (int, dimids, tmp.numel());

  for (int i = 0; i < tmp.numel(); i++)
    {
      dimids[i] = tmp(tmp.numel()-i-1);
    }
  
  int varid;

  //cout << "nc " << _get_type(xtype) << endl;
  check_err(nc_def_var (ncid, name.c_str(), xtype, tmp.numel(), dimids, &varid));

  return octave_value(varid);
}


// int nc_def_var_fill(int ncid, int varid, int no_fill, void *fill_value);
DEFUN_DLD(netcdf_defVarFill, args,, 
"")
{

  if (args.length() != 4) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int no_fill = args(2).scalar_value(); // boolean
  octave_value fill_value = args(3); 
  nc_type xtype;
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
"")
{

  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int no_fill;
  nc_type xtype;
  octave_value_list retval;
  octave_value data;
  check_err(nc_inq_vartype (ncid, varid, &xtype));

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
"")
{

  if (args.length() != 5) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int shuffle = args(2).scalar_value(); // boolean
  int deflate = args(3).scalar_value(); // boolean
  int deflate_level = args(4).scalar_value();

  check_err(nc_def_var_deflate (ncid, varid, shuffle, deflate, deflate_level));
  return octave_value();
}


//nc_inq_var_deflate(int ncid, int varid, int *shufflep,
//                        int *deflatep, int *deflate_levelp);
DEFUN_DLD(netcdf_inqVarDeflate, args,, 
"")
{

  if (args.length() != 2) {
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
"")
{

  if (args.length() != 3 && args.length() != 4) {
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
"")
{

  if (args.length() != 2) {
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


DEFUN_DLD(netcdf_endDef, args,, 
"")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  check_err(nc_enddef (ncid));
  
  return octave_value();
}

DEFUN_DLD(netcdf_reDef, args,, 
"")
{
  if (args.length() != 1) 
    {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  check_err(nc_redef (ncid));
  
  return octave_value();
}

// http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-c/nc_005fput_005fvar_005f-type.html#nc_005fput_005fvar_005f-type

DEFUN_DLD(netcdf_putVar, args,, 
"")
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

  check_err(nc_inq_vartype (ncid, varid, &xtype));
  //int sliced_numel = tmp.numel();

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




// http://www.mathworks.com/help/techdoc/ref/netcdf.getvar.html

DEFUN_DLD(netcdf_getVar, args,, 	  
"data = netcdf_getVar(ncid,varid,start,count,stride) \n\
start: 0-based indexes \n\
")
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

  check_err(nc_inq_vartype (ncid, varid, &xtype));
  check_err(nc_inq_varndims (ncid, varid, &ndims));
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

  /*
  if (xtype == NC_DOUBLE)
    {
      Array < double > arr = Array < double >(sliced_dim_vector);
      check_err(nc_get_vars_double(ncid, varid, start, count, stride, arr.fortran_vec()));
      data = octave_value(arr);
    }
  else if (xtype == NC_FLOAT)
    {
      Array < float > arr = Array < float >(sliced_dim_vector);
      check_err(nc_get_vars_float(ncid, varid, start, count, stride, arr.fortran_vec()));
      data = octave_value(arr);
    }
  */
  return data;
}

DEFUN_DLD(netcdf_close, args,, 
"")
{

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  check_err(nc_close(ncid));
  return octave_value(ncid);
}

//  int nc_inq_attname(int ncid, int varid, int attnum, char *name);

DEFUN_DLD(netcdf_inqAttName, args,, 
"")
{
  if (args.length() != 3) {
    print_usage ();
    return octave_value();
  }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  int attnum = args(2).scalar_value();
  char name[NC_MAX_NAME+1];

  check_err(nc_inq_attname(ncid, varid, attnum, name));

  return octave_value(std::string(name));  
}

//int nc_inq_att    (int ncid, int varid, const char *name,
//                        nc_type *xtypep, size_t *lenp);

DEFUN_DLD(netcdf_inqAtt, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{xtype},@var{len}] = } netcdf_inqAtt(@var{ncid},@var{varid},@var{name}) \n\
Get attribute type and length.\n\
@end deftypefn\n\
@seealso{netcdf_inqAttName}\n")
{
  if (args.length() != 3) {
    print_usage ();
    return octave_value();
  }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string name = args(2).string_value();
  int xtype;
  size_t len;
  octave_value_list retval;
  
  if (error_state) {
    return octave_value();    
  }

  check_err(nc_inq_att(ncid, varid, name.c_str(), &xtype, &len));
  
  retval(0) = octave_value(xtype);
  retval(1) = octave_value(len);
  return retval;
}


DEFUN_DLD(netcdf_getAtt, args,, 
"")
{
  if (args.length() != 3) {
    print_usage ();
    return octave_value();
  }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string attname = args(2).string_value();
  nc_type xtype;
  size_t len;
  octave_value data;

  check_err(nc_inq_att(ncid, varid, attname.c_str(), &xtype, &len));

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
"")
{
  if (args.length() != 4) {
    print_usage ();
    return octave_value();
  }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  std::string attname = args(2).string_value();
  octave_value data = args(3);

  nc_type xtype;
  xtype = NC_BYTE;

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


DEFUN_DLD(netcdf_inqVarID, args,, 
"")
{

  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string varname = args(1).string_value();
  int varid;

  check_err(nc_inq_varid(ncid,varname.c_str(), &varid));

  return octave_value(varid);
}



DEFUN_DLD(netcdf_inqVar, args,, 
"")
{

  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int varid = args(1).scalar_value();
  char name[NC_MAX_NAME+1];
  int ndims, dimids[NC_MAX_VAR_DIMS], natts;
  nc_type xtype;
  octave_value_list retval;

  if (! error_state) {

    check_err(nc_inq_varndims(ncid, varid, &ndims));
    
    check_err(nc_inq_var(ncid, varid, name, &xtype,
			 &ndims, dimids, &natts));
    
    retval(0) = octave_value(std::string(name));
    retval(1) = octave_value(xtype);

    // copy output arguments
    Array<double> dimids_ = Array<double>(dim_vector(1,ndims));
    for (int i = 0; i < ndims; i++) {
      dimids_(i) = dimids[ndims-i-1];
    }

    retval(2) = octave_value(dimids_);
    retval(3) = octave_value(natts);
  }

  return retval;
}



DEFUN_DLD(netcdf_inqDim, args,, 
"")
{

  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int dimid = args(1).scalar_value();
  octave_value_list retval;

  if (! error_state) {
    char name[NC_MAX_NAME+1];
    size_t length;
    check_err(nc_inq_dim(ncid, dimid, name, &length));
    
    retval(0) = octave_value(std::string(name));
    retval(1) = octave_value(length);
  }

  return retval;
}


DEFUN_DLD(netcdf_inqDimID, args,, 
"")
{

  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string dimname = args(1).string_value();
  int id;
  octave_value_list retval;

  if (! error_state) {
    check_err(nc_inq_dimid(ncid, dimname.c_str(), &id));
    
    retval(0) = octave_value(id);
  }

  return retval;
}

// int nc_inq_dimids(int ncid, int *ndims, int *dimids, int include_parents);
DEFUN_DLD(netcdf_inqDimIDs, args,, 
"")
{
  if (args.length() != 1 && args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int include_parents = 0;
  if (args.length() == 2) {
    include_parents = args(0).scalar_value();  
  }

  int ndims;
  check_err(nc_inq_ndims(ncid, &ndims));
  Array<int> dimids = Array<int>(dim_vector(1,ndims));
  check_err(nc_inq_dimids(ncid, &ndims, dimids.fortran_vec(),include_parents));
    
  return octave_value(dimids);
}


DEFUN_DLD(netcdf_inqNVars, args,, 
"")
{

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  octave_value_list retval;

  if (! error_state) {
    char name[NC_MAX_NAME+1];
    size_t length;
    int nvars;

    check_err(nc_inq_nvars(ncid, &nvars));
    retval(0) = octave_value(nvars);
  }

  return retval;
}


// groups

//int nc_def_grp(int parent_ncid, const char *name, int *new_ncid);

DEFUN_DLD(netcdf_defGrp, args,, 
"")
{

  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int parent_ncid = args(0).scalar_value();
  std::string name = args(1).string_value();
  int new_ncid;

  check_err(nc_def_grp(parent_ncid, name.c_str(), &new_ncid));
  return octave_value(new_ncid);
}


// int nc_inq_grps(int ncid, int *numgrps, int *ncids);
DEFUN_DLD(netcdf_inqGrps, args,, 
"")
{
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int numgrps;

  check_err(nc_inq_grps(ncid, &numgrps, NULL));
  Array<int> ncids = Array<int>(dim_vector(1,numgrps));
  check_err(nc_inq_grps(ncid, NULL, ncids.fortran_vec()));
    
  return octave_value(ncids);
}

//int nc_inq_grpname(int ncid, char *name);
DEFUN_DLD(netcdf_inqGrpName, args,, 
"")
{
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  char name[NC_MAX_NAME+1];

  check_err(nc_inq_grpname(ncid, name));    
  return octave_value(std::string(name));
}

//int nc_inq_grpname_full(int ncid, size_t *lenp, char *full_name);
DEFUN_DLD(netcdf_inqGrpNameFull, args,, 
"")
{
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  size_t len;
  check_err(nc_inq_grpname_len(ncid,&len));
  char* name = new char[len+1];
  octave_value retval;

  check_err(nc_inq_grpname_full(ncid, &len, name));
  retval = octave_value(std::string(name));
  delete name;
  return retval;
}

// int nc_inq_grp_parent(int ncid, int *parent_ncid);
DEFUN_DLD(netcdf_inqGrpParent, args,, 
"")
{
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  int parent_ncid;

  check_err(nc_inq_grp_parent(ncid, &parent_ncid));
  return octave_value(parent_ncid);
}

// int nc_inq_grp_full_ncid(int ncid, char *full_name, int *grp_ncid);
DEFUN_DLD(netcdf_inqGrpFullNcid, args,, 
"")
{
  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string name = args(1).string_value();
  int grp_ncid;

  check_err(nc_inq_grp_full_ncid(ncid, name.c_str(),&grp_ncid));
  return octave_value(grp_ncid);
}



// int nc_inq_ncid(int ncid, const char *name, int *grp_ncid);
DEFUN_DLD(netcdf_inqNcid, args,, 
"")
{
  if (args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  int ncid = args(0).scalar_value();
  std::string name = args(1).string_value();
  int grp_ncid;
  
  check_err(nc_inq_ncid(ncid, name.c_str(), &grp_ncid));    
  return octave_value(grp_ncid);
}
