#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: mpas/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Link members
i=1
typeset -RZ4 i
while [[ ${i} -le 10 ]] ; do
   i1=$i
   ln -sf ../../../../data/MPAS/x1.40962.output.2012-06-25_21.00.00.e${i1}.nc ens1_${i}.nc
   let i=i+1
done

# Generate grid.nc with ncks and ncwa
ORIGIN_FILE="../../../../data/MPAS/x1.40962.restart.2012-06-25_21.00.00.nc"
rm -f grid.nc
ncks -O -v latCell,lonCell ${ORIGIN_FILE} grid.nc
ncwa -O -v pressure_base -a Time,nCells ${ORIGIN_FILE} pressure.nc
ncks -A -v pressure_base pressure.nc grid.nc
rm -f pressure.nc
