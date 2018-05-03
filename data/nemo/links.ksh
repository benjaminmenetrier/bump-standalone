#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: nemo/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
# ----------------------------------------------------------------------

# Link to ECMWF members
i=1
while [[ ${i} -le 10 ]] ; do
   i4=$i
   typeset -RZ4 i4
   ln -sf ../../../../data/NEMOVAR/ENSEMBLES/ECMWF/goqu/opa${i}/goqu_20110605_000000_restart.nc ens1_${i4}.nc
   let i=i+1
done

# Generate grid.nc with ncks
ORIGIN_FILE="../../../../data/NEMOVAR/ENSEMBLES/mesh_mask"
rm -f grid.nc
ncks -O -v nav_lat,nav_lon,tmask,e1t,e2t ${ORIGIN_FILE} grid.nc
