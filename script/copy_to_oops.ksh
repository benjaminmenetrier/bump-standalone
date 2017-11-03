#!/bin/ksh

# NICAS source
src=${HOME}/codes/nicas/src

# OOPS directory for NICAS
dst=${HOME}/codes/OOPS/oops/src/oops/generic/nicas

# Sync
rsync -avh --delete --exclude "main.f90" --exclude "tmp" ${src}/* ${dst}

# To copy in OOPS/oops/src/CMakeLists.txt
echo
echo "To copy in OOPS/oops/src/CMakeLists.txt:"
for file in `ls ${HOME}/codes/nicas/src` ; do
   if [ "${file}" != "nicas.f90" ]&&[ "${file}" != "external" ]&&[ "${file}" != "obsop" ]&&[ "${file}" != "tmp" ] ; then
      echo oops/generic/nicas/${file}
   fi
done
for file in `ls ${HOME}/codes/nicas/src/external` ; do
   echo oops/generic/nicas/external/${file}
done
for file in `ls ${HOME}/codes/nicas/src/obsop` ; do
   echo oops/generic/nicas/obsop/${file}
done
