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
rm -fr build
mkdir build
cd build
BUMP_BUILD_SAVE=${BUMP_BUILD}
export BUMP_BUILD=DEBUG
cmake ../..
make -j3
export BUMP_BUILD=${BUMP_BUILD_SAVE}
cd ..

# Recompute truth
echo '--- Recompute truth'
rm -f ../test/truth_*
cd ../run
export OMP_NUM_THREADS=1
./bump namelist_truth

# Execute test
echo '--- Execute test'
cd ../test
rm -f test*
cd ../script
./test.ksh

# Remove build directory
rm -fr build

# Execute cloc_report
echo '--- Execute cloc_report'
cd ../script
./cloc_report.ksh

# Recompile documentation
echo '--- Recompile documentation'
./autodoc.ksh
./architecture.ksh

# Save all namelists
echo '--- Save all namelists'
cd ../script
./namelist_nam2sql.ksh

# Git commands
echo 'git status'
echo 'git add --all'
echo 'git commit -m "... revision"'
echo 'git push origin master'
