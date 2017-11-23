#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: test
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------
# Output files
output_files="
bdata_common
diag
ndata_common
ndataloc_2_0001-0001_common
sampling"

# Clean
for output_file in ${output_files} ; do
   rm -f ../test/test_${output_file}.nc
done
rm -f ../run/hdiag_nicas

# Compile
cd ../build
cmake CMakeLists.txt > ../test/cmake.log 2>&1
make clean
make > ../test/make.log 2>&1
if [[ -e "../run/hdiag_nicas" ]] ; then
   echo -e "\033[32mCompilation successful\033[m"
else
   echo -e "\033[31mCompilation failed\033[m"
   exit
fi

# Execute
export OMP_NUM_THREADS=1
cd ../run
./hdiag_nicas < namelist_test > ../test/hdiag_nicas.log  2>&1
if [[ -e "../test/test_ndataloc_2_0001-0001_common.nc" ]] ; then
   echo -e "\033[32mExecution successful\033[m"
else
   echo -e "\033[31mExecution failed\033[m"
   exit
fi

# Get the differences
cd ../test
for output_file in ${output_files} ; do
   # NetCDF dump
   ncdump -p 4,7 truth_${output_file}.nc | sed -n -E -e '/data:/,$ p' | sed '1 d' > truth_${output_file}.ncdump
   ncdump -p 4,7 test_${output_file}.nc | sed -n -E -e '/data:/,$ p' | sed '1 d' > test_${output_file}.ncdump
   difflength=`diff truth_${output_file}.ncdump test_${output_file}.ncdump  | wc -l`

   # Check
   if [[ ${difflength} > 0 ]] ; then
      echo -e "\033[31mTest failed for file ${output_file}\033[m"
      exit
   else
      echo -e "\033[32mTest successful for file ${output_file}\033[m"
   fi
done

# Clean
rm -f test_*.nc *.ncdump
