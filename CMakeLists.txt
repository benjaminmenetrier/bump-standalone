#----------------------------------------------------------------------
# CMake project file for BUMP
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
#----------------------------------------------------------------------
#
# Set Fortran/C/C++ compiler (GNU / Intel or Cray):
set (COMPILER "$ENV{BUMP_COMPILER}")
#
# Set build type (DEBUG or RELEASE):
set (BUILD_TYPE "$ENV{BUMP_BUILD}")
#
# Set NetCDF include directory
set (EXTERN_NETCDF_INCLUDE $ENV{BUMP_NETCDF_INCLUDE})
set (EXTERN_NETCDFF_INCLUDE $ENV{BUMP_NETCDFF_INCLUDE})
#
# Set NetCDF lib directory
set (EXTERN_NETCDF_LIBPATH $ENV{BUMP_NETCDF_LIBPATH})
set (EXTERN_NETCDFF_LIBPATH $ENV{BUMP_NETCDFF_LIBPATH})
#
#----------------------------------------------------------------------
# Check
#----------------------------------------------------------------------
#
# Check compiler
if (NOT ${COMPILER} MATCHES GNU AND NOT ${COMPILER} MATCHES Intel AND NOT ${COMPILER} MATCHES Cray)
   message (FATAL_ERROR  "Wrong compiler, abort!")
endif (NOT ${COMPILER} MATCHES GNU AND NOT ${COMPILER} MATCHES Intel AND NOT ${COMPILER} MATCHES Cray)
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
endif (${COMPILER} MATCHES "GNU")
#
# Intel compiler
if (${COMPILER} MATCHES "Intel")
   set (CMAKE_Fortran_COMPILER mpiifort)
endif (${COMPILER} MATCHES "Intel")
#
# Cray compiler
if (${COMPILER} MATCHES "Cray")
   set (CMAKE_Fortran_COMPILER ftn)
endif (${COMPILER} MATCHES "Cray")
#
#----------------------------------------------------------------------
# Setup project
#----------------------------------------------------------------------
#
cmake_minimum_required (VERSION 2.6)
project (bump Fortran)
file (GLOB BUMP_SRC
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.F90"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/external/*.F90"
)
add_executable (bump ${BUMP_SRC})
include_directories (${EXTERN_NETCDFF_INCLUDE} ${EXTERN_NETCDF_INCLUDE})
target_link_libraries(bump netcdf netcdff)
#
#----------------------------------------------------------------------
# Define compiler flags
#----------------------------------------------------------------------
#
# GNU compiler
if (${COMPILER} MATCHES "GNU")
   set (CMAKE_Fortran_FLAGS_RELEASE "-g -funroll-all-loops -O3 -fopenmp")
   set (CMAKE_Fortran_FLAGS_DEBUG   "-g -Og -Wextra -Wall -pedantic -fbacktrace -ftrapv -fall-intrinsics -fcheck=all -fimplicit-none -ffpe-trap=invalid,zero,underflow,overflow,denormal -fopenmp")
endif (${COMPILER} MATCHES "GNU")
#
# Intel compiler
if (${COMPILER} MATCHES "Intel")
   set (CMAKE_Fortran_FLAGS_RELEASE "-g -O3 -xAVX -openmp")
   set (CMAKE_Fortran_FLAGS_DEBUG   "-g -O0 -traceback -fpe0 -check all,noarg_temp_created -openmp")
endif (${COMPILER} MATCHES "Intel")
#
# Cray compiler
if (${COMPILER} MATCHES "Cray")
   set (CMAKE_Fortran_FLAGS_RELEASE "-g -O3")
   set (CMAKE_Fortran_FLAGS_DEBUG   "-g -O0 -R b -K trap=fp")
endif (${COMPILER} MATCHES "Cray")
#
# Set linker flags
set (LINKER_FLAGS "-L${EXTERN_NETCDF_LIBPATH} -Wl,-rpath,${EXTERN_NETCDF_LIBPATH} -L${EXTERN_NETCDFF_LIBPATH} -Wl,-rpath,${EXTERN_NETCDFF_LIBPATH} -lnetcdff -lnetcdf -fopenmp")
set_target_properties (bump PROPERTIES LINKER_LANGUAGE Fortran)
set (CMAKE_EXE_LINKER_FLAGS ${LINKER_FLAGS})
#
# Set build type
set (CMAKE_BUILD_TYPE ${BUILD_TYPE} CACHE STRING "Choose the type of build, options are: DEBUG/RELEASE" FORCE)
#
#----------------------------------------------------------------------
# Define building directories
#----------------------------------------------------------------------
#
set (EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/run)
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/run)
