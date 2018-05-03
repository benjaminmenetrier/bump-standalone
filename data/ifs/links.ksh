#!/bin/ksh
# ----------------------------------------------------------------------
# Korn shell script: ifs/links.ksh
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
# ----------------------------------------------------------------------

# Link members (requested from MARS using a full Gaussian grid, and converted into NetCDF with grib_to_netcdf)
i=1
typeset -RZ4 i
while [[ ${i} -le 25 ]] ; do
   i1=$i
   ln -sf ../../../../data/IFS/ens1_${i1}.nc _${i}.nc
   let i=i+1
done

# Generate grid.nc with ncks
ORIGIN_FILE="ens1_0001.nc"
rm -f grid.nc
ncks -O -v latitude,longitude,level ${ORIGIN_FILE} grid.nc

# Add pressure profile to grid.nc with ncl
# Copy the full array found on http://www.ecmwf.int/en/forecasts/documentation-and-support/${NFLEVG}-model-levels into an ascii file "L${NFLEVG}") where ${NFLEVG} denotes the number of levels
NFLEVG=`ncdump -h grid.nc | grep "level =" | gawk '{print $3}'`
if [[ -e "L${NFLEVG}" ]] ; then
   # Remove level 0 and extract pf
   sed '1d' L${NFLEVG} | gawk '{print $5}' > pf_L${NFLEVG}
   
   # Insert pf into grid.nc
cat<<EOFNAM >pf_into_grid.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

pf = asciiread(\"pf_L${NFLEVG}\",${NFLEVG},\"float\")*1.0e2
data = addfile(\"grid.nc\",\"w\")
level = data->level
pf!0 = \"level\"
pf&level = level
pf@units = \"Pa\"
pf@long_name = \"pressure at full levels\"
pf@missing_value = -999
pf@_FillValue = -999
data->pf = pf

end
EOFNAM
   ncl pf_into_grid.ncl

   # Cleaning
   rm -f pf_into_grid.ncl
   rm -f pf_L${NFLEVG}
else
   echo "Please copy the full array found on http://www.ecmwf.int/en/forecasts/documentation-and-support/"${NFLEVG}"-model-levels into an ascii file \"L"${NFLEVG}"\""
fi
