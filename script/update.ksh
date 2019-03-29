#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: update
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------
# Clean
echo '--- Clean'
./clean.ksh

# Compile in DEBUG mode
echo '--- Compile in DEBUG mode'
cd ..
mkdir -p build
cd build
rm -fr CMakeCache.txt CMakeFiles cmake_install.cmake Makefile *.mod
export BUMP_BUILD=DEBUG
cmake ..
make -j4

# Save all namelists
echo '--- Save all namelists'
cd ../script
./namelist_nam2sql.ksh

# Recompute truth
echo '--- Recompute truth'
rm -f ../test/truth_*
cd ../run
export OMP_NUM_THREADS=1;./bump namelist_truth

# Execute test
echo '--- Execute test'
cd ../test
rm -f test*
cd ../script
./test.ksh

# Execute cloc_report
echo '--- Execute cloc_report'
cd ../script
./cloc_report.ksh

# Recompile documentation
echo '--- Recompile documentation'
./autodoc.ksh
./architecture.ksh

# Remove build directory
cd ..
rm -fr build

# Git commands
echo 'git status'
echo 'git add --all'
echo 'git commit -m "... revision"'
echo 'git push origin master'
