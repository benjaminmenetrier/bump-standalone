#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: gfs/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Generate grid with ncks
ORIGIN_FILE=../../../../data/GFS/sfg_2014040100_fhr06s_mem001.nc4
rm -f grid.nc
ncks -O -v latitude,longitude,level,ak,bk ${ORIGIN_FILE} grid.nc
