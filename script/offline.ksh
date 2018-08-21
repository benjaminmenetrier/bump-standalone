#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: offline
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
#----------------------------------------------------------------------
# Parameters
repo="https://github.com/JCSDA/oops.git"
branch="feature/bump"
src_oops="${HOME}/code/bump/src_oops"
src_ufo="${HOME}/code/ufo-bundle/oops/src/oops/generic/bump"
src_tmp="${HOME}/code/bump/src_tmp"
src="${HOME}/code/bump/src"
offline="${HOME}/code/bump/offline"

# Get src_oops
if test "$1" = "git" ; then
   git clone ${repo}
   cd oops
   git checkout ${branch}
   cd src/oops/generic
   rm -fr ${src_oops}
   mv bump ${src_oops}
   cd ../../../..
   rm -fr oops/
elif test "$1" = "ufo" ; then
   mkdir -p ${src_oops}
   rsync -rtv --delete ${src_ufo}/* ${src_oops}
else
   echo "Wrong source"
   exit
fi

# Copy src_oops into src, exclude type_bump.F90 and type_ens.F90
mkdir -p ${src}
rsync -rtv --delete --exclude "type_bump.F90" --exclude "type_ens.F90" ${src_oops}/* ${src}

# Copy src_oops (type_bump.F90 and type_ens.F90) into src_tmp
mkdir -p ${src_tmp}
rsync -rtv --delete ${src_oops}/"type_bump.F90" ${src_oops}/"type_ens.F90" ${src_tmp}

# Modify type_bump.F90
filename="type_bump.F90"
rm -f ${src_tmp}/${filename}"_tmp"
while IFS= read -r line
do
   # Insert "   procedure :: setup_offline => bump_setup_offline" before "   procedure :: setup_generic => bump_setup_generic"
   add="   procedure :: setup_offline => bump_setup_offline"
   tag="   procedure :: setup_generic => bump_setup_generic"
   test "${line#*$tag}" != "$line" && echo "${add}" >> ${src_tmp}/${filename}"_tmp"

   # Write existing line
   echo "${line}" >> ${src_tmp}/${filename}"_tmp"

   # Insert "use model_interface, only: model_coord" after "use netcdf"
   add="use model_interface, only: model_coord"
   tag="use netcdf"
   test "${line#*$tag}" != "$line" && echo "${add}" >> ${src_tmp}/${filename}"_tmp"

   # Insert bump_setup_offline.F90 after "end subroutine bump_setup_online"
   add=bump_setup_offline.F90
   tag="end subroutine bump_setup_online"
   test "${line#*$tag}" != "$line" && cat ${offline}/${add} >> ${src_tmp}/${filename}"_tmp"
done < ${src_oops}/${filename}

# Check whether the modified file should be updated
if test ! -e ${src}/${filename} ; then
   mv -f ${src_tmp}/${filename}"_tmp" ${src}/${filename}
else
   if test "`cmp ${src}/${filename} ${src_tmp}/${filename}"_tmp"`" = '' ; then
      rm -f ${src_tmp}/${filename}"_tmp"
   else
      mv -f ${src_tmp}/${filename}"_tmp" ${src}/${filename}
   fi
fi

# Modify type_ens.F90
filename="type_ens.F90"
rm -f ${src_tmp}/${filename}"_tmp"
while IFS= read -r line
do
   # Insert "use model_interface, only: model_read" before "use tools_kinds"
   add="use model_interface, only: model_read"
   tag="use tools_kinds"
   test "${line#*$tag}" != "$line" && echo "${add}" >> ${src_tmp}/${filename}"_tmp"

   # Write existing line
   echo "${line}" >> ${src_tmp}/${filename}"_tmp"

   # Insert "   procedure :: load => ens_load" after ""
   add="   procedure :: load => ens_load"
   tag="   procedure :: dealloc => ens_dealloc"
   test "${line#*$tag}" != "$line" && echo "${add}" >> ${src_tmp}/${filename}"_tmp"

   # Insert ens_load.F90 after "end subroutine ens_dealloc"
   add=ens_load.F90
   tag="end subroutine ens_dealloc"
   test "${line#*$tag}" != "$line" && cat ${offline}/${add} >> ${src_tmp}/${filename}"_tmp"
done < ${src_oops}/${filename}

# Check whether the modified file should be updated
if test ! -e ${src}/${filename} ; then
   mv -f ${src_tmp}/${filename}"_tmp" ${src}/${filename}
else
   if test "`cmp ${src}/${filename} ${src_tmp}/${filename}"_tmp"`" = '' ; then
      rm -f ${src_tmp}/${filename}"_tmp"
   else
      mv -f ${src_tmp}/${filename}"_tmp" ${src}/${filename}
   fi
fi

# Add main
rsync -rtv --delete ${offline}/main.F90 ${src}

# Add model
rsync -rtv --delete ${offline}/model ${src}

# Remove src_tmp
rm -fr ${src_tmp}
