#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: copy
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
#----------------------------------------------------------------------
if test $1 == "nemovar" ; then
   # BUMP source
   src=${HOME}/code/bump/src_oops

   # Directory for BUMP
   dst=${HOME}/code/nemovar/EXTERNAL/bump

   # Sync
   mkdir -p ${dst}
   rsync -rtv --delete ${src}/* ${dst}
fi

if test $1 == "pack" ; then
   # BUMP source
   src=${HOME}/code/bump/src_oops

   # Directory for BUMP
   dst=/home/gmap/mrpa/menetrie/pack/envar-dev.2y/src/local/oops/src/oops/generic/bump

   # Sync
   lftp ftp://menetrie@$2 -e "mirror --delete -X *.lst -X *.mod -X *.o -X *.optrpt -e -R $src $dst;quit"

   # Directory for BUMP
   dst=/home/gmap/mrpa/menetrie/pack/envar-dev.g/src/local/oops/src/oops/generic/bump

   # Sync
   lftp ftp://menetrie@$2 -e "mirror --delete -X *.lst -X *.mod -X *.o -X *.optrpt -e -R $src $dst;quit"

   # Directory for BUMP
   dst=/home/gmap/mrpa/menetrie/pack/cy43_envar-dev.v05/src/local/oops/src/oops/generic/bump

   # Sync
   lftp ftp://menetrie@$2 -e "mirror --delete -X *.lst -X *.mod -X *.o -X *.optrpt -e -R $src $dst;quit"
fi

if test $1 == "sc" ; then
   # BUMP source
   src=${HOME}/code/bump/src

   # Directory for BUMP
   dst=/home/gmap/mrpa/menetrie/code/bump/src

   # Sync
   lftp ftp://menetrie@$2 -e "mirror -e -R $src $dst;quit"
fi
