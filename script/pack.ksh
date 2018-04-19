#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: pack
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------
# Make a temporary directory
cd ..
rm -fr pack
mkdir pack

# Copy files in the main folder
cp -f .gitignore pack
cp -f CMakeLists.txt pack

# Copy data
mkdir pack/data
links_list=`find data -name '*.ksh'`
for links in ${links_list} ; do
  cp --parents ${links} pack
done
obs_in_list=`find data -name '*obs_in.dat'`
for obs_in in ${obs_in_list} ; do
  cp --parents ${obs_in} pack
done

# Copy doc
mkdir pack/doc
cp -f doc/*.dox pack/doc
cp -f doc/Doxyfile pack/doc
cp -f doc/mainpage.h pack/doc

# Copy ncl
mkdir pack/ncl
mkdir pack/ncl/script
cp -f ncl/script/*.ncl pack/ncl/script

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
cp -f test/links.ksh pack/test
cp -f test/truth_*.nc pack/test

# Rename and pack everything
find pack -type f -name '*~' -delete
today=`date +%Y%m%d`
rm -fr hdiag_nicas
mv pack hdiag_nicas
tar -cvzf hdiag_nicas_${today}.tar.gz hdiag_nicas

# Clean
rm -fr hdiag_nicas
