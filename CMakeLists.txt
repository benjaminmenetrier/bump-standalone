# (C) Copyright 2017 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

#
# SABER bundle
#

# SABER project
project( saber-bundle C CXX Fortran )

# CMake version requirement
cmake_minimum_required( VERSION 3.3.2 FATAL_ERROR )

# Define CMAKE_MODULE_PATH
set( CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake;${CMAKE_CURRENT_SOURCE_DIR}/ecbuild/cmake;${CMAKE_MODULE_PATH}")
include( ecbuild_bundle )

# Initialize bundle
ecbuild_bundle_initialize()
ecbuild_requires_macro_version( 2.7 )

# Add repositories

# eckit
ecbuild_bundle( PROJECT eckit )

# fckit
ecbuild_bundle( PROJECT fckit )

# atlas
ecbuild_bundle( PROJECT atlas )

# metis
ecbuild_bundle( PROJECT metis )

# saber
ecbuild_bundle( PROJECT saber )

# Finalize bundle
ecbuild_bundle_finalize()
