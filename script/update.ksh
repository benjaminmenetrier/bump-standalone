#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: update
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------
# Clean temporary files
echo '--- Clean temporary files'
cd ..
find . -type f -name '*~' -delete
cd script

# Remove blanks at end of lines
echo '--- Remove blanks at end of lines'
cd ../src
source=`find . -type f -exec egrep -l " +$" {} \;`
for file in ${source} ; do
   sed -i 's/ *$//' ${file}
done
cd ../script
source=`find . -type f -exec egrep -l " +$" {} \;`
for file in ${source} ; do
   sed -i 's/ *$//' ${file}
done
cd ../ncl/script
source=`find . -type f -exec egrep -l " +$" {} \;`
for file in ${source} ; do
   sed -i 's/ *$//' ${file}
done
cd ../../doc
source=`find . -type f -exec egrep -l " +$" {} \;`
for file in ${source} ; do
   sed -i 's/ *$//' ${file}
done

# Compile in DEBUG mode
echo '--- Compile in DEBUG mode'
cd ../build
rm -fr CMakeCache.txt CMakeFiles cmake_install.cmake Makefile *.mod
export NICAS_COMPILER=GNU
export NICAS_BUILD=DEBUG
export NICAS_NETCDF=$NETCDF
cmake CMakeLists.txt
make

# Save and regenerate all namelists
echo '--- Save and regenerate all namelists'
cd ../run
rm -fr old
mkdir old
mv namelist_* old
cd ../script
./namelist_sql2nam.ksh

# Recompute truth
echo '--- Recompute truth'
cd ../run
export OMP_NUM_THREADS=1
./nicas < namelist_truth

# Pack everything
echo '--- Pack everything'
cd ../script
./pack.ksh
mkdir -p ../versions
mv -f ../nicas_*.tar.gz ../versions

# Execute test
echo '--- Execute test'
cd ../script
./test.ksh

# Execute cloc_report
echo '--- Execute cloc_report'
cd ../script
./cloc_report.ksh

# Recompile documentation
echo '--- Recompile documentation'
cd ../doc
rm -fr html
doxygen Doxyfile

# Copy doc directory on ftp
echo '--- Copy doc directory on ftp'
cd ..
lftp ftp://$1:$2@ftpperso.free.fr -e "mirror -e -R doc nicas;quit"
cd script

# Git commands
echo 'git status'
echo 'git add --all'
echo 'git commit -m "... revision"'
echo 'git push origin master'
