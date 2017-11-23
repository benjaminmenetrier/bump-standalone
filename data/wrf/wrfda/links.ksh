#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: wrf/wrfda/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Link members
ln -sf ../../../../../data/WRF/wrfda/2008020100/wrfout_d01_2008-02-01_00:00:00.nc ens1_0001.nc
ln -sf ../../../../../data/WRF/wrfda/2008020100/wrfout_d01_2008-02-01_12:00:00.nc ens1_0002.nc
ln -sf ../../../../../data/WRF/wrfda/2008020100/wrfout_d01_2008-02-02_00:00:00.nc ens1_0003.nc
ln -sf ../../../../../data/WRF/wrfda/2008020112/wrfout_d01_2008-02-01_12:00:00.nc ens1_0004.nc
ln -sf ../../../../../data/WRF/wrfda/2008020112/wrfout_d01_2008-02-02_00:00:00.nc ens1_0005.nc
ln -sf ../../../../../data/WRF/wrfda/2008020112/wrfout_d01_2008-02-02_12:00:00.nc ens1_0006.nc
ln -sf ../../../../../data/WRF/wrfda/2008020200/wrfout_d01_2008-02-02_00:00:00.nc ens1_0007.nc
ln -sf ../../../../../data/WRF/wrfda/2008020200/wrfout_d01_2008-02-02_12:00:00.nc ens1_0008.nc
ln -sf ../../../../../data/WRF/wrfda/2008020200/wrfout_d01_2008-02-03_00:00:00.nc ens1_0009.nc

# Generate grid.nc with ncks and ncwa
ORIGIN_FILE="ens1_0001.nc"
rm -f grid.nc
ncks -O -v XLONG,XLAT ${ORIGIN_FILE} grid.nc
ncwa -O -v PB -a Time,south_north,west_east ${ORIGIN_FILE} pressure.nc
ncks -A -v PB pressure.nc grid.nc
rm -f pressure.nc
