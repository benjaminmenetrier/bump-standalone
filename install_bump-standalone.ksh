#!/bin/ksh

# Directories
code=${HOME}/code
build=${HOME}/build

# Environment variables
compiler=GNU
export MPIEXEC=`which mpirun`
if test "${compiler}" = "GNU" ; then
   export CPCcomp=`which mpicxx`
   export CCcomp=`which mpicc`
   export F90comp=`which mpifort`
fi
if test "${compiler}" = "Intel" ; then
   export CPCcomp=`which mpiicpc`
   export CCcomp=`which mpiicc`
   export F90comp=`which mpiifort`
fi

# Clone repo
#cd ${code}
#git clone https://github.com/benjaminmenetrier/bump-standalone

# Build ufo-bundle
mkdir -p ${build}/bump-standalone
cd ${build}/bump-standalone

# On ubuntu
ecbuild --build=release \
        -DCMAKE_CXX_COMPILER=${CPCcomp} \
        -DCMAKE_C_COMPILER=${CCcomp} \
        -DCMAKE_Fortran_COMPILER=${F90comp} \
        -DNETCDF_PATH=${NETCDF} \
        -DMPIEXEC=${MPIEXEC} \
        ${code}/bump-standalone

# Compile
#make -j2
