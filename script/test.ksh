#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: test
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------
# NetCDF files
nc_files='
cmat_common
diag
dirac_gridded
dirac
local_diag_cor_gridded
local_diag_cor
local_diag_cov_gridded
local_diag_cov
local_diag_loc_gridded
local_diag_loc
nicas_2_0001-0001_common
nicas_2_0001-0001_common_summary
sampling
sampling_001'

# Check in DEBUG mode
if [[ $HDIAG_NICAS_BUILD != "DEBUG" ]] ; then
   echo -e "[31mHDIAG_NICAS_BUILD should be set to DEBUG for reproducibility tests[m"
   exit
fi

if [[ ! -e "../test/test_dirac.nc" ]] ; then
   # Execute
   cd ../run
   export OMP_NUM_THREADS=1;./hdiag_nicas namelist_test
   if [[ -e "../test/test_dirac.nc" ]] ; then
      echo -e "[32mExecution successful[m"
   else
      echo -e "[31mExecution failed[m"
      exit
   fi
   newexec=true
else
   newexec=false
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
write_table("${file}.out","w",[/(/"[1mFile: ${file}[m"/)/],"%s")

do ivar=0,nvars-1
   ; Read data
   fld_truth = tofloat(ndtooned(data_truth->\$vars(ivar)\$))
   fld_test = tofloat(ndtooned(data_test->\$vars(ivar)\$))
   n = dimsizes(fld_truth)
   n_test = dimsizes(fld_test)

   if (n.eq.n_test) then
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
                  dist = abs(fld_test(i)-fld_truth(i))/abs(fld_truth(i))*100.0
               else
                  if (abs(fld_test(i)-fld_truth(i)).gt.0.0) then
                     dist = 100.0
                  end if
               end if
               if (dist.gt.0.01) then
                  write_table("${file}.err","a",[/(/"Variable " + vars(ivar) + ", index " + i + ": " + fld_test(i) + " / " + fld_truth(i)/)/],"%s")
               end if
               if (dist.gt.distmax) then
                  distmax = dist
               end if
             end if
         end if
      end do

      ; Print message
      if (truth_test) then
         write_table("${file}.out","a",[/(/"   [31m" + vars(ivar)/),(/": Inconsistent missing values (in truth but not in test)[m"/)/],"%40s%s")
      end if
      if (test_truth) then
         write_table("${file}.out","a",[/(/"   [31m" + vars(ivar)/),(/": Inconsistent missing values (in test but not in truth)[m"/)/],"%40s%s")
      end if
      if (.not.(truth_test.or.test_truth)) then
         if (distmax.gt.0.01) then
            write_table("${file}.out","a",[/(/"   [31m" + vars(ivar)/),(/": " + sprintf("%5.2f",distmax) + "%[m"/)/],"%40s%s")
         else
            write_table("${file}.out","a",[/(/"   [32m" + vars(ivar)/),(/": " + sprintf("%5.2f",distmax) + "%[m"/)/],"%40s%s")
         end if
      end if
   else
      write_table("${file}.out","a",[/(/"   [31m" + vars(ivar)/),(/": Inconsistent sizes[m"/)/],"%40s%s")
   end if

   ; Delete
   delete(fld_truth)
   delete(fld_test)
end do

end
EOFNAM

   # Execute NCL script
   ncl script.ncl > ncl_${file}.out 2>&1
   rm -f script.ncl

   # Check NCL execution
   nl=`wc -l ncl_${file}.out | gawk '{print $1}'`
   if [[ $nl -ne 5 ]]; then
      echo "[1mFile: ${file}[m" > ${file}.out
      echo "   [31mError with the NCL execution[m" >> ${file}.out
   fi

   # Print results
   cat ${file}.out
done

# Clean
rm -f *.out
if $newexec; then
   rm -f test_*.nc
fi
