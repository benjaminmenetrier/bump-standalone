#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: gem/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Generate grid with ncks
ORIGIN_FILE=../../../../data/GEM/2014101706_006_0001.nc
rm -f grid.nc
ncks -O -v lat,lon,lev,ap,b ${ORIGIN_FILE} grid.nc
