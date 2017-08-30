#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: nemo/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Generate grid.nc with ncks
ORIGIN_FILE=../../../../data/NEMO/ENSEMBLES/mesh_mask
rm -f grid.nc
ncks -O -v nav_lat,nav_lon,tmask,e1t,e2t ${ORIGIN_FILE} grid.nc
