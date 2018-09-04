# ENV_NCAR

GNU compiler on [cheyenne](https://www2.cisl.ucar.edu/resources/computational-systems/cheyenne):

    module purge
    module load cmake/3.9.1 gnu/6.3.0 openmpi/3.0.0 netcdf/4.4.1.1 ncl
    export BUMP_COMPILER=GNU
    export BUMP_BUILD=DEBUG
    export BUMP_NETCDF_INCLUDE=${NETCDF}/include
    export BUMP_NETCDF_LIBPATH=${NETCDF}/lib
    export BUMP_NETCDFF_INCLUDE=${NETCDF}/include
    export BUMP_NETCDFF_LIBPATH=${NETCDF}/lib
