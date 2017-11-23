#!/bin/ksh

# HDIAG_NICAS source
src=${HOME}/codes/hdiag_nicas/src

# OOPS directory for HDIAG_NICAS
dst=${HOME}/codes/OOPS/oops/src/oops/generic/hdiag_nicas

# Sync
mkdir -p ${dst}
rsync -avh --delete --exclude "main.f90" --exclude "tmp" ${src}/* ${dst}

# To copy in OOPS/oops/src/CMakeLists.txt
echo
echo "To copy in OOPS/oops/src/CMakeLists.txt:"
for file in `ls ${HOME}/codes/hdiag_nicas/src` ; do
   if [ "${file}" != "main.f90" ]&&[ "${file}" != "external" ]&&[ "${file}" != "obsop" ]&&[ "${file}" != "tmp" ] ; then
      echo oops/generic/hdiag_nicas/${file}
   fi
done
for file in `ls ${HOME}/codes/hdiag_nicas/src/external` ; do
   echo oops/generic/hdiag_nicas/external/${file}
done
for file in `ls ${HOME}/codes/hdiag_nicas/src/obsop` ; do
   echo oops/generic/hdiag_nicas/obsop/${file}
done
for file in `ls ${HOME}/codes/hdiag_nicas/src/type_ctree` ; do
   echo oops/generic/hdiag_nicas/type_ctree/${file}
done
for file in `ls ${HOME}/codes/hdiag_nicas/src/type_randgen` ; do
   echo oops/generic/hdiag_nicas/type_randgen/${file}
done
