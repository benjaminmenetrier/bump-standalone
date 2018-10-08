#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: gendoc
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------

# Directories
src=${HOME}/code/bump/src
doc=${HOME}/code/bump/doc
output=${doc}/code_list.md

# Introduction
cat<<EOFINTRO > ${output}
# Code structure

The source code is organized as follows:

 - The main program main.F90
 - Useful tools for the whole code: tools_[...].F90
 - Derived types and associated methods: type_[...].F90
 - External tools: external/[...].F90
 - Model related routines, to get the coordinates, read and write fields: model/model_[...].F90
EOFINTRO
echo "" >> ${output}
echo "" >> ${output}

# 1. **Main program**
filename=${src}/main.F90
new_purpose=false
while IFS= read -r line ; do
   # Get keywords
   word=`echo ${line} | cut -c -10`
   if test "${word}" = "! Purpose:" ; then
      purpose=`echo ${line} | cut -c 12-`
      new_purpose=true
   fi
   
   if test "${new_purpose}" = "true" ; then
      # New program
     echo "1. **Main program** [main.F90](https://github.com/benjaminmenetrier/bump/tree/master/src/main.F90): "${purpose} >> ${output}
   fi

   # Reset
   new_purpose=false
done < ${filename}
echo "" >> ${output}
echo "" >> ${output}

# 2. Tools
echo "2. **Tools**" >> ${output}
list=`ls ${src}/tools_*.F90`
for filename in ${list} ; do
   # Initialization
   new_module=false
   new_purpose=false
   new_subfunc=false
   i=-2

   # While loop over lines
   while IFS= read -r line ; do
      # Get keywords
      word=`echo ${line} | cut -c -10`
      if test "${word}" = "! Module: " ; then
         module=`echo ${line} | cut -c 11-`
         new_module=true
      fi
      if test "${word}" = "! Purpose:" ; then
         purpose=`echo ${line} | cut -c 12-`
         new_purpose=true
      fi
      if test "${word}" = "! Subrouti" ; then
         subfunc=`echo ${line} | cut -c 15-`
         subfunc_type=subroutine
         new_subfunc=true
      fi
      if test "${word}" = "! Function" ; then
         subfunc=`echo ${line} | cut -c 11-`
         subfunc_type=function
         new_subfunc=true
      fi

      # Increment line index
      let i=i+1
 
      if test "${new_purpose}" = "true" ; then
         # New module
         if test "${new_module}" = "true" ; then
            echo " - module [${module}.F90](https://github.com/benjaminmenetrier/bump/tree/master/src/${module}.F90): "${purpose} >> ${output}
            new_module=false
         fi
   
         # New subroutine/function
         if test "${new_subfunc}" = "true" ; then
            echo "     - ${subfunc_type} [${subfunc}](https://github.com/benjaminmenetrier/bump/tree/master/src/${module}.F90#L${i}): "${purpose} >> ${output}
            new_subfunc=false
         fi
   
         # Reset
         new_purpose=false
      fi
   done < ${filename}
done
echo "" >> ${output}
echo "" >> ${output}

# 3. Derived types
echo "3. **Derived types**" >> ${output}
list=`ls ${src}/type_*.F90`
for filename in ${list} ; do
   # Initialization
   new_module=false
   new_purpose=false
   new_subfunc=false
   class=${filename#*type_}
   class=${class%.*}
   i=-2

   # While loop over lines
   while IFS= read -r line ; do
      # Get keywords
      word=`echo ${line} | cut -c -10`
      if test "${word}" = "! Module: " ; then
         module=`echo ${line} | cut -c 11-`
         new_module=true
      fi
      if test "${word}" = "! Purpose:" ; then
         purpose=`echo ${line} | cut -c 12-`
         new_purpose=true
      fi
      if test "${word}" = "! Subrouti" ; then
         subfunc=`echo ${line} | cut -c 15-`
         subfunc=${subfunc/"${class}_"/"${class}%"}
         subfunc_type=subroutine
         new_subfunc=true
      fi
      if test "${word}" = "! Function" ; then
         subfunc=`echo ${line} | cut -c 11-`
         subfunc=${subfunc/"${class}_"/"${class}%"}
         subfunc_type=function
         new_subfunc=true
      fi
   
      # Increment line index
      let i=i+1
 
      if test "${new_purpose}" = "true" ; then
         # New module
         if test "${new_module}" = "true" ; then
            echo " - module [${module}.F90](https://github.com/benjaminmenetrier/bump/tree/master/src/${module}.F90): "${purpose} >> ${output}
            new_module=false
         fi
   
         # New subroutine/function
         if test "${new_subfunc}" = "true" ; then
            echo "     - ${subfunc_type} [${subfunc}](https://github.com/benjaminmenetrier/bump/tree/master/src/${module}.F90#L${i}): "${purpose} >> ${output}
            new_subfunc=false
         fi
   
         # Reset
         new_purpose=false
      fi
   done < ${filename}
done
echo "" >> ${output}
echo "" >> ${output}

# 4. External tools
echo "4. **External tools**" >> ${output}
list=`ls ${src}/external/tools_*.F90`
for filename in ${list} ; do
   # Initialization
   new_module=false
   new_purpose=false
   new_subfunc=false
   i=-2

   # While loop over lines
   while IFS= read -r line ; do
      # Get keywords
      word=`echo ${line} | cut -c -10`
      if test "${word}" = "! Module: " ; then
         module=`echo ${line} | cut -c 11-`
         new_module=true
      fi
      if test "${word}" = "! Purpose:" ; then
         purpose=`echo ${line} | cut -c 12-`
         new_purpose=true
      fi
      if test "${word}" = "! Subrouti" ; then
         subfunc=`echo ${line} | cut -c 15-`
         subfunc_type=subroutine
         new_subfunc=true
      fi
      if test "${word}" = "! Function" ; then
         subfunc=`echo ${line} | cut -c 11-`
         subfunc_type=function
         new_subfunc=true
      fi
   
      # Increment line index
      let i=i+1
 
      if test "${new_purpose}" = "true" ; then
         # New module
         if test "${new_module}" = "true" ; then
            echo " - module [${module}.F90](https://github.com/benjaminmenetrier/bump/tree/master/src/external/${module}.F90): "${purpose} >> ${output}
            new_module=false
         fi
   
         # New subroutine/function
         if test "${new_subfunc}" = "true" ; then
            echo "     - ${subfunc_type} [${subfunc}](https://github.com/benjaminmenetrier/bump/tree/master/src/external/${module}.F90#L${i}): "${purpose} >> ${output}
            new_subfunc=false
         fi
   
         # Reset
         new_purpose=false
      fi
   done < ${filename}
done
echo "" >> ${output}
echo "" >> ${output}

# 5. Model-related routines
echo "5. **Model-related routines**" >> ${output}
list=`ls ${src}/model/model_*.F90`
for filename in ${list} ; do
   # Initialization
   new_module=false
   new_purpose=false
   new_subfunc=false
   i=-2

   # While loop over lines
   while IFS= read -r line ; do
      # Get keywords
      word=`echo ${line} | cut -c -10`
      if test "${word}" = "! Module: " ; then
         module=`echo ${line} | cut -c 11-`
         new_module=true
      fi
      if test "${word}" = "! Purpose:" ; then
         purpose=`echo ${line} | cut -c 12-`
         new_purpose=true
      fi
      if test "${word}" = "! Subrouti" ; then
         subfunc=`echo ${line} | cut -c 15-`
         subfunc_type=subroutine
         new_subfunc=true
      fi
      if test "${word}" = "! Function" ; then
         subfunc=`echo ${line} | cut -c 11-`
         subfunc_type=function
         new_subfunc=true
      fi

      # Increment line index
      let i=i+1
 
      if test "${new_purpose}" = "true" ; then
         # New module
         if test "${new_module}" = "true" ; then
            echo " - module [${module}.F90](https://github.com/benjaminmenetrier/bump/tree/master/src/model/${module}.F90): "${purpose} >> ${output}
            new_module=false
         fi
   
         # New subroutine/function
         if test "${new_subfunc}" = "true" ; then
            echo "     - ${subfunc_type} [${subfunc}](https://github.com/benjaminmenetrier/bump/tree/master/src/model/${module}.F90#L${i}): "${purpose} >> ${output}
            new_subfunc=false
         fi
   
         # Reset
         new_purpose=false
      fi
   done < ${filename}
done
echo "" >> ${output}
echo "" >> ${output}
