#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: pack
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------
# Make a temporary directory
cd ..
rm -fr pack
mkdir pack

# Copy files in the main folder
cp -f .gitignore pack
cp -f CMakeLists.txt pack
cp -f LICENSE pack
cp -f README.md pack

# Copy doc
mkdir pack/doc
cp -f doc/*.dox pack/doc
cp -f doc/Doxyfile pack/doc
cp -f doc/mainpage.h pack/doc

# Copy ncl
mkdir pack/ncl
mkdir pack/ncl/script
cp -f ncl/script/*.ncl pack/ncl/script

# Copy offline
mkdir pack/offline
cp -rf offline/* pack/offline

# Copy run
mkdir pack/run
cp -f run/namelist* pack/run

# Copy script
mkdir pack/script
cp -f script/*.ksh pack/script
cp -f script/namelist.sqlite pack/script

# Copy src
mkdir pack/src
cp -fr src/* pack/src

# Copy test
mkdir pack/test
cp -f test/grid.nc pack/test
cp -f test/ens1_00_*.nc pack/test
cp -f test/truth_*.nc pack/test

# Rename and pack everything
find pack -type f -name '*~' -delete
today=`date +%Y%m%d`
rm -fr bump
mv pack bump
tar -cvzf bump_${today}.tar.gz bump

# Clean
rm -fr bump
