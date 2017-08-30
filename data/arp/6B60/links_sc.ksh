#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: arp/6B60/links_sc.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Generate grid.nc with EPyGrAM
ORIGIN_FILE="/scratch/work/menetrie/data/ARPEGE/6B60/20160928H00A/4dupd1/ICMSHARPE+0000"
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
