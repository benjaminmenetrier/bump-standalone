#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: geos/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Link members
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160724_00+20160727_0000.V01.nc4 ens1_0001.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160725_18+20160727_0000.V01.nc4 ens1_0002.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160726_18+20160727_0000.V01.nc4 ens1_0003.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160724_12+20160727_0000.V01.nc4 ens1_0004.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160726_00+20160727_0000.V01.nc4 ens1_0005.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160727_00+20160727_0000.V01.nc4 ens1_0006.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160725_00+20160727_0000.V01.nc4 ens1_0007.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160726_06+20160727_0000.V01.nc4 ens1_0008.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160725_12+20160727_0000.V01.nc4 ens1_0009.nc
ln -sf ../../../../data/GEOS/GEOS.fp.fcst.inst3_3d_asm_Nv.20160726_12+20160727_0000.V01.nc4 ens1_0010.nc

# Generate grid with ncks and ncwa
ORIGIN_FILE="ens1_0001.nc"
rm -f grid.nc
ncks -O -v lat,lon ${ORIGIN_FILE} grid.nc
ncwa -O -v PL -a time,lat,lon ${ORIGIN_FILE} pressure.nc
ncks -A -v PL pressure.nc grid.nc
rm -f pressure.nc
