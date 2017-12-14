#!/bin/ksh

# HDIAG_NICAS source
src=${HOME}/codes/hdiag_nicas/src

# OOPS directory for HDIAG_NICAS
dst=${HOME}/codes/jedi/code/jedi-bundle/oops/src/oops/generic/hdiag_nicas
#dst=${HOME}/pack/envar-dev/src/local/oops/src/oops/generic/hdiag_nicas

# Sync
mkdir -p ${dst}
rsync -avh --delete --exclude "main.f90" ${src}/* ${dst}

# To copy in OOPS/oops/src/CMakeLists.txt
echo
echo "To copy in OOPS/oops/src/CMakeLists.txt:"
for file in `ls ${HOME}/codes/hdiag_nicas/src` ; do
   if [ "${file}" != "main.f90" ]&&[ "${file}" != "external" ] ; then
      echo oops/generic/hdiag_nicas/${file}
   fi
done
for file in `ls ${HOME}/codes/hdiag_nicas/src/external` ; do
   echo oops/generic/hdiag_nicas/external/${file}
done
