# Compilation and dependencies

The compilation of sources uses cmake ([cmake.org](https://cmake.org)). Compilation options (compiler, build type, NetCDF include and library paths) have to be specified in six environment variables:
 - **BUMP_COMPILER**: GNU, Intel or Cray
 - **BUMP_BUILD**: DEBUG or RELEASE
 - **BUMP_NETCDF_INCLUDE**: C NetCDF include path
 - **BUMP_NETCDFF_INCLUDE**: Fortran NetCDF include path
 - **BUMP_NETCDF_LIBPATH**: C NetCDF library path
 - **BUMP_NETCDFF_LIBPATH**: Fotran NetCDF library path

Some examples are given for several supercomputer:
 - at [ECMWF (Cray compiler)](ENV_ECMWF.md)
 - at [Météo-France (GNU and Intel compiler)](ENV_MF.md)
 - at [NCAR (GNU compiler)](ENV_NCAR.md)

Then, to compile in a directory $BUILDDIR, with $N processors (if available):
 
    cd $BUILDDIR
    cmake $MAINDIR/CMakeLists.txt
    make -j$N

An executable file $MAINDIR/run/bump should be created if compilation is successful.

WARNING: for the Intel compiler, it seems that version intel/17.[...].[...] is required.

Input and output files use the NetCDF format. The NetCDF library can be downloaded at: [www.unidata.ucar.edu/software/netcdf](http://www.unidata.ucar.edu/software/netcdf)

