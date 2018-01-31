#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: test
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------
# NetCDF files
nc_files='
sampling
sampling_001
diag
bdata_common
local_diag_cor
local_diag_loc
ndata_1_0001-0001_common_summary
ndata_2_0001-0001_common
dirac'

# Clean
for file in ${nc_files} ; do
   rm -f ../test/test_${file}.nc
done

# Execute
export OMP_NUM_THREADS=1
cd ../run
./hdiag_nicas < namelist_test > ../test/hdiag_nicas.log  2>&1
if [[ -e "../test/test_dirac.nc" ]] ; then
   echo -e "\033[32mExecution successful\033[m"
else
   echo -e "\033[31mExecution failed\033[m"
   exit
fi

# Get the differences
cd ../test
for file in ${nc_files} ; do
   # NCL script
cat<<EOFNAM >script.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

; Load files
data_truth = addfile("truth_${file}.nc","r")
data_test = addfile("test_${file}.nc","r")

; Find variables
vars = getfilevarnames(data_truth)
nvars = dimsizes(vars)

; Print file name
write_table("${file}.out","w",[/(/"\033[1mFile: ${file}\033[m"/)/],"%s")

do ivar=0,nvars-1
   ; Read data
   fld_truth = tofloat(ndtooned(data_truth->\$vars(ivar)\$))
   fld_test = tofloat(ndtooned(data_test->\$vars(ivar)\$))
   n = dimsizes(fld_truth)

   ; Compute distance
   distmax = 0.0
   dist = 0.0
   truth_test = False
   test_truth = False
   do i=0,n-1
      if (ismissing(fld_truth(i))) then
         if (.not.ismissing(fld_test(i))) then
            truth_test = True
         end if
      else
         if (ismissing(fld_test(i))) then
            test_truth = True
         else
            if (fld_truth(i).ne.0.0) then
               dist = abs(fld_test(i)-fld_truth(i))/abs(fld_truth(i))
               if (dist.gt.distmax) then
                  distmax = dist
               end if
            end if
          end if
      end if
   end do

   ; Print message
   if (truth_test) then
      write_table("${file}.out","a",[/(/"   \033[31m" + vars(ivar)/),(/": Inconsistent missing values (in truth but not in test)\033[m"/)/],"%40s%s")
   end if
   if (test_truth) then
      write_table("${file}.out","a",[/(/"   \033[31m" + vars(ivar)/),(/": Inconsistent missing values (in test but not in truth)\033[m"/)/],"%40s%s")
   end if
   if (.not.(truth_test.or.test_truth)) then
      dist = dist*100.0
      if (dist.gt.0.01) then
         write_table("${file}.out","a",[/(/"   \033[31m" + vars(ivar)/),(/": " + sprintf("%5.2f",dist) + "%\033[m"/)/],"%40s%s")
      else
         write_table("${file}.out","a",[/(/"   \033[32m" + vars(ivar)/),(/": " + sprintf("%5.2f",dist) + "%\033[m"/)/],"%40s%s")
      end if
   end if

   ; Delete
   delete(fld_truth)
   delete(fld_test)
   delete(dist)
end do

end
EOFNAM

   # Execute NCL script
   ncl script.ncl > ncl.out
   rm -f script.ncl

   # Print results
   value=$(<${file}.out)
   echo "$value"
done

# Clean
rm -f test_*.nc *.out
