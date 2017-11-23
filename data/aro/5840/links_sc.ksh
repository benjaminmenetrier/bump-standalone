#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: aro/5840/links_sc.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
# ----------------------------------------------------------------------

# Link members (converted into NetCDF using EPyGrAM)
for date in 20160206H00A;  do
   i=1
   typeset -RZ4 i
   while [[ ${i} -le 25 ]] ; do
      i3=$i
      typeset -RZ3 i3
      ln -sf /scratch/work/menetrie/data/AROME/5840/${date}/member_${i3}/forecast_GP/ICMSHAROM+0003.nc ens1_03_${i}.nc
      let i=i+1
   done
done

# Generate grid.nc with EPyGrAM
ORIGIN_FILE="/scratch/work/menetrie/data/AROME/5840/20160206H00A/member_001/forecast_GP/ICMSHAROM+0003"
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
gd = T.geometry.dimensions
tab = T.getdata()
tab[...] = 0.0
tab[gd['Y_CIoffset']:
gd['Y_CIoffset']+2*gd['Y_Iwidth']+gd['Y_Czone'],
gd['X_CIoffset']:
gd['X_CIoffset']+2*gd['X_Iwidth']+gd['X_Czone']] = 0.5
tab[gd['Y_CIoffset']+gd['Y_Iwidth']:
gd['Y_CIoffset']+gd['Y_Iwidth']+gd['Y_Czone'],
gd['X_CIoffset']+gd['X_Iwidth']:
gd['X_CIoffset']+gd['X_Iwidth']+gd['X_Czone']] = 1.0
T.setdata(tab)
mapfac = T.geometry.map_factor_field()
rout = epygram.formats.resource("grid.nc", "w", fmt="netCDF")
T.fid["netCDF"]="cmask"
mapfac.fid["netCDF"]="mapfac"
rout.behave(flatten_horizontal_grids=False)
rout.writefield(T)
rout.writefield(mapfac)
rout.close()
EOFNAM
python epygram_request.py
rm -f epygram_request.py
