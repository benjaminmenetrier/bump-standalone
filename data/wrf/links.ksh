#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: wrf/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Generate grid.nc with ncks and ncwa
ORIGIN_FILE=../../../../data/WRF/wrfda/2008020100/wrfout_d01_2008-02-01_00:00:00.nc
rm -f grid.nc
ncks -O -v XLONG,XLAT ${ORIGIN_FILE} grid.nc
ncwa -O -v PB -a Time,south_north,west_east ${ORIGIN_FILE} pressure.nc
ncks -A -v PB pressure.nc grid.nc
rm -f pressure.nc
