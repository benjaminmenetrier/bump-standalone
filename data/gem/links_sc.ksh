#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: gem/links_sc.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
# ----------------------------------------------------------------------

# Link members
i=1
typeset -RZ4 i
while [[ ${i} -le 256 ]] ; do
   ln -sf /scratch/work/menetrie/data/GEM/2014101706_006_${i}.nc ens1_06_${i}.nc
   let i=i+1
done

i=1
typeset -RZ4 i
for string in 'kfc' 'kuo' ; do
   for string2 in 'BLAC62' 'BOUJO' ; do
      j=1
      typeset -RZ4 j
      while [[ ${j} -le 64 ]] ; do
         ln -sf /scratch/work/menetrie/data/GEM/member_${string}_${string2}_${j}.nc ens1_06_${i}_${j}.nc
         let j=j+1
      done
      let i=i+1
   done
done

# Generate grid with ncks
ORIGIN_FILE="ens1_06_0001.nc"
rm -f grid.nc
ncks -O -v lat,lon,lev,ap,b ${ORIGIN_FILE} grid.nc
