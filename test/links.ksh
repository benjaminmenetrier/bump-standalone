#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Reduce members size with ncks
i=1
typeset -RZ4 i
while [[ ${i} -le 10 ]] ; do
   ncks -O -v ps,ta,ap,b -d lev,0,12,6 -d lat,50,99 -d lon,600,699 ../../../data/GEM/member_kfc_BLAC62_${i}.nc ens1_00_${i}.nc
   let i=i+1
done

# Generate grid with ncks
ORIGIN_FILE=ens1_00_0001.nc
rm -f grid.nc
ncks -O -v lat,lon,lev,ap,b ${ORIGIN_FILE} grid.nc
