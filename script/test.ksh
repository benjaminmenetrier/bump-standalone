#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: test
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------
# Clean
rm -f ../test/test.nc
rm -f ../run/nicas

# Compile
cd ../build
cmake CMakeLists.txt > ../test/cmake.log 2>&1
make clean
make > ../test/make.log 2>&1
if [[ -e "../run/nicas" ]] ; then
   echo -e "\033[32mCompilation successful\033[m"
else
   echo -e "\033[31mCompilation failed\033[m"
   exit
fi

# Execute
export OMP_NUM_THREADS=1
cd ../run
./nicas < namelist_test > ../test/nicas.log  2>&1
if [[ -e "../test/test_param.nc" ]] ; then
   echo -e "\033[32mExecution successful\033[m"
else
   echo -e "\033[31mExecution failed\033[m"
   exit
fi

# Get the differences
cd ../test
ncdump -p 4,7 truth_param.nc | sed -n -E -e '/data:/,$ p' | sed '1 d' > truth.ncdump
ncdump -p 4,7 test_param.nc | sed -n -E -e '/data:/,$ p' | sed '1 d' > test.ncdump
difflength=`diff truth.ncdump test.ncdump  | wc -l`

# Check
if [[ ${difflength} > 0 ]] ; then
   echo -e "\033[31mTest failed\033[m"
   exit
else
   echo -e "\033[32mTest successful\033[m"
fi

# Clean
rm -f test_*.nc *.ncdump
