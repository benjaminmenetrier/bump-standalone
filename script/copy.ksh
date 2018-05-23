#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: copy
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
#----------------------------------------------------------------------
# BUMP source
src=${HOME}/code/bump/src

if [ $1 == "ufo" ] ; then
   # Directory for BUMP
   dst=${HOME}/code/ufo-bundle/oops/src/oops/generic/bump

   # Sync
   mkdir -p ${dst}
   rsync -rtv --delete --exclude "main.F90" ${src}/* ${dst}

   # To copy in ~/code/ufo-bundle/oops/src/CMakeLists.txt
   echo
   echo "To copy in ~/code/ufo-bundle/oops/src/CMakeLists.txt:"
   for file in `ls ${src}` ; do
      if [ "${file}" != "main.F90" ]&&[ "${file}" != "external" ] ; then
         echo oops/generic/bump/${file}
      fi
   done
   for file in `ls ${src}/external` ; do
      echo oops/generic/bump/external/${file}
   done
fi

if [ $1 == "nemovar" ] ; then
   # Directory for BUMP
   dst=${HOME}/code/nemovar/EXTERNAL/bump

   # Sync
   mkdir -p ${dst}
   rsync -rtv --delete ${src}/* ${dst}
fi

if [ $1 == "pack" ] ; then
   # Directory for BUMP
   dst=/home/gmap/mrpa/menetrie/pack/envar-dev.2y/src/local/oops/src/oops/generic/bump

   # Sync
   lftp ftp://menetrie@$2 -e "mirror --delete -X *.lst -X *.mod -X *.o -X *.optrpt -X main.F90 -X yomhook.F90 -e -R $src $dst;quit"
fi

if [ $1 == "sc" ] ; then
   # Directory for BUMP
   dst=/home/gmap/mrpa/menetrie/code/bump/src

   # Sync
   lftp ftp://menetrie@$2 -e "mirror -e -R $src $dst;quit"
fi
