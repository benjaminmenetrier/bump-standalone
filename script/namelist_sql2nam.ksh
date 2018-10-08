#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: namelist_sql2nam
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------
# Function to generate a namelist
generate_namelist() {
   # Get argument
   if test $# = 0 ; then
      echo "Error: no input argument in generate_namelist!"
   else
      echo "Generate namelist "${filename}" from database "${dbname}":"

      # Create file
      printf "" > ${filename}

      # List over tables
      for table in ${tables} ; do
         echo "   Write block for table "${table}

         # Print block header
         block=`echo ${table} | cut -c 5-`
         printf "&"${block}"\n" >> ${filename}

         # Get keys
         list=`sqlite3 -header -column ${dbname}  "select * from ${table} where name=='${suffix}'" | sed -n 1p`
         set -A keys ${list}

         # Get values
         list=`sqlite3 -header -column ${dbname}  "select * from ${table} where name=='${suffix}'" | sed -n 3p`
         set -A values ${list}

         # Count keys/values
         n=${#keys[@]}

         # Loop over keys/values
         i=1
         while [[ ${i} -lt ${n} ]] ; do
            printf ${keys[$i]}" = "${values[$i]}"," >> ${filename}
            printf "\n" >> ${filename}
            let i=i+1
         done

         # Print block footer
         printf "/" >> ${filename}
         printf "\n" >> ${filename}
         printf "\n" >> ${filename}
      done
   fi
}

# Database
dbname="namelist.sqlite"

# Get tables and order them alphabetically
list=`sqlite3 ${dbname} ".tables"`
tables=`for t in ${list};do echo ${t};done | sort`

if test $# = 0 ; then
   # Generate all namelists
   table=`echo ${tables} | gawk '{print $1}'`
   suffixes=`sqlite3 namelist.sqlite "select name from ${table}"`
   for suffix in ${suffixes} ; do
      filename="../run/namelist_"${suffix}
      generate_namelist ${filename}
   done
else
   # Generate one namelist
   suffix=$1
   filename="../run/namelist_"${suffix}
   generate_namelist ${filename}
fi
