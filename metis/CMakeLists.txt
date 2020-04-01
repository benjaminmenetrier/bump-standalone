# (C) Copyright 2017-2019 UCAR.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

################################################################################
# METIS
################################################################################

cmake_minimum_required( VERSION 3.3.2 FATAL_ERROR )

project( metis C CXX Fortran )

set( CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake;${CMAKE_MODULE_PATH})

set( CMAKE_DIRECTORY_LABELS "metis" )

set( ECBUILD_DEFAULT_BUILD_TYPE Release )
set( ENABLE_OS_TESTS           OFF CACHE BOOL "Disable OS tests" FORCE )
set( ENABLE_LARGE_FILE_SUPPORT OFF CACHE BOOL "Disable testing of large file support" FORCE )
set( BUILD_BUMP_DOC OFF )

include( ecbuild_system NO_POLICY_SCOPE )

ecbuild_requires_macro_version( 2.5 )

################################################################################
# Project
################################################################################

ecbuild_declare_project()

ecbuild_enable_fortran( REQUIRED MODULE_DIRECTORY ${PROJECT_BINARY_DIR}/module )
ecbuild_add_cxx11_flags()

set( METIS_LINKER_LANGUAGE CXX )


################################################################################
# Standard compiler flags
################################################################################

include( metis_compiler_flags )
include( metis_extra_macros )

################################################################################
# Dependencies
################################################################################

# OpenMP
ecbuild_add_option( FEATURE OMP
                    DESCRIPTION "Support for OpenMP threaded parallelism"
                    REQUIRED_PACKAGES "OMP COMPONENTS CXX Fortran" )
if( HAVE_OMP )
  ecbuild_enable_omp()
else()
  ecbuild_enable_ompstubs()
endif()

################################################################################
# Export package info
################################################################################

list( APPEND METIS_TPLS )

list( APPEND METIS_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}/src
    ${CMAKE_Fortran_MODULE_DIRECTORY})

set( METIS_LIBRARIES metis )

get_directory_property( METIS_DEFINITIONS COMPILE_DEFINITIONS )

foreach( _tpl ${METIS_TPLS} )
  string( TOUPPER ${_tpl} TPL )
  list( APPEND METIS_EXTRA_DEFINITIONS   ${${TPL}_DEFINITIONS}  ${${TPL}_TPL_DEFINITIONS}  )
  list( APPEND METIS_EXTRA_INCLUDE_DIRS  ${${TPL}_INCLUDE_DIRS} ${${TPL}_TPL_INCLUDE_DIRS} )
  list( APPEND METIS_EXTRA_LIBRARIES     ${${TPL}_LIBRARIES}    ${${TPL}_TPL_LIBRARIES}    )
endforeach()

################################################################################
# Sources
################################################################################

include_directories( ${METIS_INCLUDE_DIRS}
                     ${METIS_EXTRA_INCLUDE_DIRS}
                     ${CMAKE_CURRENT_SOURCE_DIR}/src )

add_subdirectory( src )

if( ECBUILD_INSTALL_FORTRAN_MODULES )
    install( DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/${CMAKE_CFG_INTDIR}
             DESTINATION module/fckit
             COMPONENT modules )
endif()

################################################################################
# Finalise configuration
################################################################################

# prepares a tar.gz of the sources and/or binaries
ecbuild_install_project( NAME metis )

# print the summary of the configuration
ecbuild_print_summary()
