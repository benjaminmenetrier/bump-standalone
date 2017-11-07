#----------------------------------------------------------------------
# CMake project file for nicas
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------
#
# Set your Fortran/C/C++ compiler (GNU or Intel):
set (COMPILER "$ENV{NICAS_COMPILER}")
#
# Set your build type (DEBUG or RELEASE):
set (BUILD_TYPE "$ENV{NICAS_BUILD}")
#
# Set your NetCDF include directory
set (EXTERN_NETCDF_INCLUDE $ENV{NICAS_NETCDF_INCLUDE})
#
# Set your NetCDF lib directory
set (EXTERN_NETCDF_LIBPATH $ENV{NICAS_NETCDF_LIBPATH})
#
#----------------------------------------------------------------------
# Check
#----------------------------------------------------------------------
#
# Check compiler
if (NOT ${COMPILER} MATCHES GNU AND NOT ${COMPILER} MATCHES Intel)
   message (FATAL_ERROR  "Wrong compiler, abort!")
endif (NOT ${COMPILER} MATCHES GNU AND NOT ${COMPILER} MATCHES Intel)
#
# Check build type
if (NOT ${BUILD_TYPE} MATCHES DEBUG AND NOT ${BUILD_TYPE} MATCHES RELEASE)
   message (FATAL_ERROR  "Wrong build type, abort!")
endif (NOT ${BUILD_TYPE} MATCHES DEBUG AND NOT ${BUILD_TYPE} MATCHES RELEASE)
#
#----------------------------------------------------------------------
# Setup compiler
#----------------------------------------------------------------------
#
# GNU compiler
if (${COMPILER} MATCHES "GNU")
   set (CMAKE_Fortran_COMPILER mpifort)
   set (CMAKE_C_COMPILER mpicc)
   set (CMAKE_CXX_COMPILER mpicxx)
endif (${COMPILER} MATCHES "GNU")
#
# Intel compiler
if (${COMPILER} MATCHES "Intel")
   set (CMAKE_Fortran_COMPILER mpif90)
   set (CMAKE_C_COMPILER mpicc)
   set (CMAKE_C++_COMPILER mpicxx)
endif (${COMPILER} MATCHES "Intel")
#
#----------------------------------------------------------------------
# Setup project
#----------------------------------------------------------------------
#
cmake_minimum_required (VERSION 2.6)
project (nicas Fortran C CXX)
file (GLOB NICAS_SRC
    "../src/*.f90"
    "../src/external/*.f90"
    "../src/external/*.c"
    "../src/external/*.cpp"
    "../src/obsop/*.f90"
    "../src/type_ctree/*.cpp"
    "../src/type_randgen/*.cpp"
)
add_executable (nicas ${NICAS_SRC})
include_directories (${EXTERN_NETCDF_INCLUDE})
target_link_libraries(nicas netcdf netcdff)
#
#----------------------------------------------------------------------
# Define compiler flags
#----------------------------------------------------------------------
#
# GNU compiler
if (${COMPILER} MATCHES "GNU")
   set (CMAKE_Fortran_FLAGS_RELEASE "-g -funroll-all-loops -O3 -fopenmp")
   set (CMAKE_Fortran_FLAGS_DEBUG   "-g -Og -Wextra -Wall -pedantic -fbacktrace -ftrapv -fall-intrinsics -fcheck=all -fimplicit-none -ffpe-trap=invalid,zero,overflow -fopenmp")
endif (${COMPILER} MATCHES "GNU")
#
# Intel compiler
if (${COMPILER} MATCHES "Intel")
   set (CMAKE_Fortran_FLAGS_RELEASE "-O3 -nowarn -qopenmp")
   set (CMAKE_Fortran_FLAGS_DEBUG   "-g -O0 -nowarn -g -traceback -fpe0 -check all,noarg_temp_created -qopenmp")
endif (${COMPILER} MATCHES "Intel")
#
# C++ compiler options
set (CMAKE_CXX_FLAGS_RELEASE "-O3 -std=c++0x")
set (CMAKE_CXX_FLAGS_DEBUG "-Wall -g -O0 -std=c++0x")
#
# Set linker flags
set (LINKER_FLAGS "-L${EXTERN_NETCDF_LIBPATH} -Wl,-rpath,${EXTERN_NETCDF_LIBPATH} -lnetcdff -lnetcdf -fopenmp -lstdc++")
set_target_properties (nicas PROPERTIES LINKER_LANGUAGE Fortran)
set (CMAKE_EXE_LINKER_FLAGS ${LINKER_FLAGS})
#
# Set build type
set (CMAKE_BUILD_TYPE ${BUILD_TYPE} CACHE STRING "Choose the type of build, options are: Debug/Release" FORCE)
#
#----------------------------------------------------------------------
# Define building directories
#----------------------------------------------------------------------
#
set (CMAKE_FILES_DIRECTORY ${PROJECT_BINARY_DIR})
set (EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/../run)
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/../run)
