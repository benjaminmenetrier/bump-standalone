#!/bin/bash

# Directories
code=${HOME}/code/bump-standalone
build=${HOME}/build/bump-standalone

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
git clone https://github.com/benjaminmenetrier/bump-standalone.git ${code}

# Build
mkdir -p ${build}
cd ${build}
ecbuild --build=release \
        -DCMAKE_CXX_COMPILER=${CPCcomp} \
        -DCMAKE_C_COMPILER=${CCcomp} \
        -DCMAKE_Fortran_COMPILER=${F90comp} \
        -DNETCDF_PATH=${NETCDF} \
        -DMPIEXEC=${MPIEXEC} \
        ${code}

# Compile (change 4 for the required number of threads)
make -j4

# Test (change 4 for the required number of threads)
ctest -j4
