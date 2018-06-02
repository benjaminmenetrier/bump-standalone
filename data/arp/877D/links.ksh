#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: arp/877D/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
# ----------------------------------------------------------------------

# Link members (converted into NetCDF using EPyGrAM)
i=1
typeset -RZ4 i
while [[ ${i} -le 50 ]] ; do
   i3=$i
   typeset -RZ3 i3
   ln -sf ../../../../../data/ARPEGE/877D_light/20170114H00A/ensemble4D/${i3}/ICMSHARPE+0000.nc ens1_00_${i}.nc
   ln -sf ../../../../../data/ARPEGE/877D_light/20170114H00A/ensemble4D/${i3}/ICMSHARPE+0003.nc ens1_03_${i}.nc
   ln -sf ../../../../../data/ARPEGE/877D_light/20170114H00A/ensemble4D/${i3}/ICMSHARPE+0006.nc ens1_06_${i}.nc
   let i=i+1
done
exit
# Generate grid.nc with EPyGrAM
ORIGIN_FILE="../../../../../data/ARPEGE/877D_light/20170114H00A/ensemble4D/001/ICMSHARPE+0000"
rm -f grid.nc
cat<<EOFNAM >epygram_request.py
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import epygram
epygram.init_env()
r = epygram.formats.resource("${ORIGIN_FILE}", "r")
T = r.readfield("S001TEMPERATURE")
if T.spectral:
    T.sp2gp()
mapfac = T.geometry.map_factor_field()
rout = epygram.formats.resource("grid.nc", "w", fmt="netCDF")
rout.behave(flatten_horizontal_grids=False)
mapfac.fid["netCDF"]="mapfac"
rout.writefield(mapfac)
rout.close()
EOFNAM
python epygram_request.py
rm -f epygram_request.py
