#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
# ----------------------------------------------------------------------

# Select directories and model
datadir=${HOME}/data
#datadir=/scratch/work/menetrie/data
bumpdir=${HOME}/data/bump
#bumpdir=/scratch/work/menetrie/data/bump
testdir=${HOME}/bump/test
#testdir=/home/menetrie/bump/test
model=res

# Link members
i=0
ne=1
while [ ${i} -lt ${ne} ] ; do
   # Update
   let i=i+1

   # Copy and typeset
   i3=$i
   typeset -RZ3 i3
   i4=$i
   typeset -RZ4 i4

   # AROME
   if test ${model} = "aro" ; then
      ne=50
      xp=7G0N
#      xp=7H8H
      date=20131221H00P
      mkdir -p ${bumpdir}/${model}/${xp}
      for timeslot in "02" "03" "04" ; do
         ln -sf ${datadir}/${model}/${xp}/${date}/member_${i3}/forecast/ICMSHAROM+00${timeslot}.nc ${bumpdir}/${model}/${xp}/ens1_${timeslot}_${i4}.nc
      done
   fi

   # ARPEGE
   if test ${model} = "arp" ; then
      ne=50
      xp=877D
#      xp=86SV
      date=20170114H00A
#      date=20131220H12A
      mkdir -p ${bumpdir}/${model}/${xp}
      for timeslot in "00" "06" ; do
         ln -sf ${datadir}/${model}/${xp}/${date}/ensemble4D/${i3}/ICMSHARPE+00${timeslot}.nc ${bumpdir}/${model}/${xp}/ens1_${timeslot}_${i4}.nc
      done
   fi

   # FV3
   if test ${model} = "fv3" ; then
      ne=10
      date=20170801.000000
      mkdir -p ${bumpdir}/${model}
      ln -sf ${datadir}/${model}/ens1_00_${i4}.nc ${bumpdir}/${model}/ens1_01_${i4}.nc
   fi

   # GEM
   if test ${model} = "gem" ; then
      ne=256
      date=2014101706
      mkdir -p ${bumpdir}/${model}
      ln -sf ${datadir}/${model}/${date}_006_${i4}.nc ${bumpdir}/${model}/ens1_00_${i4}.nc

      if test ${i} = 1 ; then
         j4=1
         typeset -RZ4 j4
         for string in 'kfc' 'kuo' ; do
            for string2 in 'BLAC62' 'BOUJO' ; do
               k4=1
               typeset -RZ4 k4
               while [ ${k4} -le 64 ] ; do
                  ln -sf  ${datadir}/${model}/member_${string}_${string2}_${k4}.nc ${bumpdir}/${model}/ens1_00_${j4}_${k4}.nc
                  let k4=k4+1
               done
               let j4=j4+1
            done
         done
      fi
   fi

   # GEOS
   if test ${model} = "geos" ; then
      ne=32
      mkdir -p ${bumpdir}/${model}
      ts=0
      typeset -RZ2 ts
      while [ ${ts} -lt 24 ] ; do
         ln -sf ${datadir}/${model}/mem${i3}/x34.prog.43.20180415_${ts}z_00.nc4 ${bumpdir}/${model}/ens1_${ts}_${i4}.nc
         let ts=ts+1
      done
      ln -sf ${datadir}/${model}/mem${i3}/x34.prog.43.20180416_00z_00.nc4 ${bumpdir}/${model}/ens1_${ts}_${i4}.nc
   fi

   # GFS
   if test ${model} = "gfs" ; then
      ne=10
      date=2014040100
      mkdir -p ${bumpdir}/${model}
      ln -sf ${datadir}/${model}/sfg_${date}_fhr06s_mem${i3}.nc4 ${bumpdir}/${model}/ens1_00_${i4}.nc
   fi

   # IFS
   if test ${model} = "ifs" ; then
      ne=25
      mkdir -p ${bumpdir}/${model}
      ln -sf ${datadir}/${model}/member_${i}.nc ${bumpdir}/${model}/ens1_01_${i4}.nc
   fi

   # MPAS
   if test ${model} = "mpas" ; then
      ne=10
      mkdir -p ${bumpdir}/${model}
      ln -sf ${datadir}/${model}/x1.40962.output.2012-06-25_21.00.00.e${i}.nc ${bumpdir}/${model}/ens1_01_${i4}.nc
   fi

   # NEMO
   if test ${model} = "nemo" ; then
      xp=nemovar
#      xp=cera-20c
      if test ${xp} = "nemovar" ; then
         ne=11
         mkdir -p ${bumpdir}/${model}/nemovar
         ln -sf ${datadir}/${model}/ENSEMBLES/ECMWF/goqu/opa${i}/goqu_20110605_000000_restart.nc ${bumpdir}/${model}/${xp}/ens1_01_${i4}.nc
      fi
      if test ${xp} = "cera-20c" ; then
         ne=9
         mkdir -p ${bumpdir}/${model}/cera-20c
         j4=$i
         typeset -RZ4 j4
         for date in "20090215" "20090216" "20090217" "20090218" "20090219" "20090221" "20090222" "20090223" "20090224" ; do
            ln -sf ${datadir}/${model}/CERA-20C/member_${date}+00_${i}.nc ${bumpdir}/${model}/${xp}/ens1_01_${j4}.nc
            let j4=j4+9
         done
      fi
   fi

   # RES
   if test ${model} = "res" ; then
      ne=10
      mkdir -p ${bumpdir}/${model}
      ln -sf ${datadir}/${model}/Ens_${i}.nc ${bumpdir}/${model}/ens1_01_${i4}.nc
   fi

   # Test
   if test ${model} = "test" ; then
      ne=10
      mkdir -p ${testdir}
      ncks -O -v ps,ta,ap,b -d lev,0,12,6 -d lat,50,99 -d lon,600,699 ${datadir}/gem/member_kfc_BLAC62_${i4}.nc ${testdir}/ens1_00_${i4}.nc
   fi

   # WRF
   if test ${model} = "wrf" ; then
      ne=8
      date=2017-07-28_06:00:00
      mkdir -p ${bumpdir}/${model}
      ln -sf ${datadir}/${model}/wrfout_d01_${date}.${i3} ${bumpdir}/${model}/ens1_01_${i4}.nc
   fi

   # Exit
   if test ${i} = ${ne} ; then
      break
   fi
done

# AROME
if test ${model} = "aro" ; then
   grid=${bumpdir}/${model}/${xp}/grid.nc
   saved_grid=${datadir}/${model}/${xp}/grid.nc
   if test -e ${saved_grid} ; then
      # Copy grid.nc from data
      ln -sf ${saved_grid} ${grid}
   else
      # Generate grid.nc with EPyGrAM
      origin=${datadir}/${model}/${xp}/${date}/member_001/forecast/ICMSHAROM+0003
      grid=${bumpdir}/${model}/${xp}/grid.nc
      rm -f ${grid}
      cat<<EOFNAM >epygram_request.py
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import epygram
epygram.init_env()
r = epygram.formats.resource("${origin}", "r")
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
rout = epygram.formats.resource("${grid}", "w", fmt="netCDF")
T.fid["netCDF"]="cmask"
mapfac.fid["netCDF"]="mapfac"
rout.behave(flatten_horizontal_grids=False)
rout.writefield(T)
rout.writefield(mapfac)
rout.close()
EOFNAM
      python epygram_request.py
      rm -f epygram_request.py
   fi
fi

# ARPEGE
if test ${model} = "arp" ; then
   grid=${bumpdir}/${model}/${xp}/grid.nc
   saved_grid=${datadir}/${model}/${xp}/grid.nc
   if test -e ${saved_grid} ; then
      # Copy grid.nc from data
      ln -sf ${saved_grid} ${grid}
   else
      # Generate grid.nc with EPyGrAM
      origin=${datadir}/${model}/${xp}/${date}/ensemble4D/001/ICMSHARPE+0000
      rm -f ${grid}
      cat<<EOFNAM >epygram_request.py
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import epygram
epygram.init_env()
r = epygram.formats.resource("${origin}", "r")
T = r.readfield("S001TEMPERATURE")
if T.spectral:
    T.sp2gp()
mapfac = T.geometry.map_factor_field()
rout = epygram.formats.resource("${grid}", "w", fmt="netCDF")
rout.behave(flatten_horizontal_grids=False)
mapfac.fid["netCDF"]="mapfac"
rout.writefield(mapfac)
rout.close()
EOFNAM
      python epygram_request.py
      rm -f epygram_request.py
   fi
fi

# FV3
if test ${model} = "fv3" ; then
   # Copy grid.nc
   origin=${datadir}/${model}/grid.nc
   grid=${bumpdir}/${model}/grid.nc
   rm -f ${grid}
   cp -f ${origin} ${grid}
fi

# GEM
if test ${model} = "gem" ; then
   # Generate grid with ncks
   origin=${bumpdir}/${model}/ens1_00_0001.nc
   grid=${bumpdir}/${model}/grid.nc
   rm -f ${grid}
   ncks -O -v lat,lon,lev,ap,b ${origin} ${grid}
fi

# GEOS
if test ${model} = "geos" ; then
   # Generate grid with ncks and ncwa
   origin=${bumpdir}/${model}/ens1_00_0001.nc
   grid=${bumpdir}/${model}/grid.nc
   resol=180
   rm -f ${grid}
   cat<<EOFNAM >ncl_script.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

strs = asciiread("${datadir}/${model}/c${resol}.txt",-1,"string")
np = dimsizes(strs)
i = toint(str_get_field(strs,1," "))
j = toint(str_get_field(strs,2," "))
tile = toint(str_get_field(strs,3," "))
lat_vec = tofloat(str_get_field(strs,4," "))
lon_vec = tofloat(str_get_field(strs,5," "))
ni = max(i)
nj = max(j)
ntile = max(tile)
lat = new((/ntile*nj,ni/),float)
lon = new((/ntile*nj,ni/),float)
do ip=0,np-1
   lat((tile(ip)-1)*nj+j(ip)-1,i(ip)-1) = lat_vec(ip)
   lon((tile(ip)-1)*nj+j(ip)-1,i(ip)-1) = lon_vec(ip)
end do
lat!0 = "lat"
lat!1 = "lon"
lat@long_name = "latitude"
lat@units = "degrees_north"
lon!0 = "lat"
lon!1 = "lon"
lon@long_name = "longitude"
lon@units = "degrees_east"

data_in = addfile("${origin}","r")
delp = data_in->delp(0,:,:,:)*1.0
delp!0 = "lev"
delp!1 = "lat"
delp!2 = "lon"
delp@long_name = "pressure_thickness"
delp@units = "Pa"

data_out = addfile("${grid}","c")
data_out->lat = lat
data_out->lon = lon
data_out->delp = delp

end
EOFNAM
   ncl ncl_script.ncl
   rm -f ncl_script.ncl
fi

# GFS
if test ${model} = "gfs" ; then
   # Generate grid with ncks
   origin=${bumpdir}/${model}/ens1_00_0001.nc
   grid=${bumpdir}/${model}/grid.nc
   rm -f ${grid}
   ncks -O -v latitude,longitude,level,ak,bk ${origin} ${grid}
fi

# IFS
if test ${model} = "ifs" ; then
   # Generate grid.nc with ncks
   origin=${bumpdir}/${model}/ens1_01_0001.nc
   grid=${bumpdir}/${model}/grid.nc
   rm -f ${grid}
   ncks -O -v latitude,longitude,level ${origin} ${grid}

   # Add pressure profile to grid.nc with ncl
   # Copy the full array found on http://www.ecmwf.int/en/forecasts/documentation-and-support/${nflevg}-model-levels into an ascii file "L${nflevg}") where ${nflevg} denotes the number of levels
   nflevg=`ncdump -h ${grid} | grep "level =" | gawk '{print $3}'`
   if test -e "${datadir}/${model}/L${nflevg}" ; then
      # Remove level 0 and extract pf
      sed '1d' ${datadir}/${model}/L${nflevg} | gawk '{print $5}' > pf_L${nflevg}

      # Insert pf into grid.nc
      cat<<EOFNAM >pf_into_grid.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

pf = asciiread("pf_L${nflevg}",${nflevg},"float")*1.0e2
data = addfile("${grid}","w")
level = data->level
pf!0 = "level"
pf&level = level
pf@units = "Pa"
pf@long_name = "pressure at full levels"
pf@missing_value = -999
pf@_FillValue = -999
data->pf = pf

end
EOFNAM
      ncl pf_into_grid.ncl

      # Cleaning
      rm -f pf_into_grid.ncl
      rm -f pf_L${nflevg}
   else
      echo "Please copy the full array found on http://www.ecmwf.int/en/forecasts/documentation-and-support/"${nflevg}"-model-levels into an ascii file \"L"${nflevg}"\""
   fi
fi

# MPAS
if test ${model} = "mpas" ; then
   origin=${datadir}/${model}/x1.40962.restart.2012-06-25_21.00.00.nc
   grid=${bumpdir}/${model}/grid.nc
   rm -f ${grid}
   ncks -O -v latCell,lonCell ${origin} ${grid}
   ncwa -O -v pressure_base -a Time,nCells ${origin} pressure.nc
   ncks -A -v pressure_base pressure.nc ${grid}
   rm -f pressure.nc
fi

# NEMO
if test ${model} = "nemo" ; then
   origin=${datadir}/${model}/mesh_mask
   grid=${bumpdir}/${model}/${xp}/grid.nc
   rm -f ${grid}
   ncks -O -v nav_lat,nav_lon,tmask,e1t,e2t ${origin} ${grid}
fi

# RES
if test ${model} = "res" ; then
   origin=${datadir}/${model}/MyGrid.nc
   grid=${bumpdir}/${model}/${xp}/grid.nc
   rm -f ${grid}
   cp -f ${origin} ${grid}
fi

# Test
if test ${model} = "test" ; then
   origin=${testdir}/ens1_00_0001.nc
   grid=${testdir}/grid.nc
   rm -f grid.nc
   ncks -O -v lat,lon,lev,ap,b ${origin} ${grid}
fi

# WRF
if test ${model} = "wrf" ; then
   origin=${bumpdir}/${model}/ens1_01_0001.nc
   grid=${bumpdir}/${model}/grid.nc
   rm -f ${grid}
   ncks -O -v XLONG,XLAT ${origin} ${grid}
   ncwa -O -v PB -a Time,south_north,west_east ${origin} pressure.nc
   ncks -A -v PB pressure.nc ${grid}
   rm -f pressure.nc
fi
