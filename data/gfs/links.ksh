#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: gfs/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Link members
i=1
typeset -RZ4 i
while [[ ${i} -le 10 ]] ; do
   i3=$i
   typeset -RZ3 i3
   ln -sf ../../../../data/GFS/sfg_2014040100_fhr06s_mem${i3}.nc4 ens1_06_${i}.nc
   let i=i+1
done

# Generate grid with ncks
ORIGIN_FILE="ens1_06_0001.nc"
rm -f grid.nc
ncks -O -v latitude,longitude,level,ak,bk ${ORIGIN_FILE} grid.nc
