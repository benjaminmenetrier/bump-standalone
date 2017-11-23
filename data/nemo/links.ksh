#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: nemo/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Link to ECMWF members
i=1
typeset -RZ4 i
while [[ ${i} -le 19 ]] ; do
   i3=$i
   typeset -RZ3 i3
   ln -sf ../../../../data/NEMO/ENSEMBLES/ECMWF/member_${i}.nc ens1_${i}.nc
   let i=i+1
done

# Generate grid.nc with ncks
ORIGIN_FILE="../../../../data/NEMO/ENSEMBLES/mesh_mask"
rm -f grid.nc
ncks -O -v nav_lat,nav_lon,tmask,e1t,e2t ${ORIGIN_FILE} grid.nc
