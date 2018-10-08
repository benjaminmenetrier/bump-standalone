#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: namelist_sql2json
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
      echo "Generate json "${filename}" from database "${dbname}":"

      # Create file
      printf "{" > ${filename}
      printf "\n" >> ${filename}
      newline=false

      # List over tables
      for table in ${tables} ; do
         echo "   Write block for table "${table}

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
            if [[ ${values[$i]} != "NULL" ]; then
               # New line
               if ${newline} ; then
                  printf "," >> ${filename}
                  printf "\n" >> ${filename}
               fi

               # Count number of values
               nval=`echo ${values[$i]} | gawk -F',' 'NF{print NF-1}'`
               let nval=nval+1

               list=`echo ${values[$i]} | tr "," "\n"`
               ival=1
               for value in ${list} ; do
                  if [[ ${nval} -gt 1 ]; then
                     # Split values
                     typeset -RZ3 ival
                     key=${keys[$i]}"("${ival}")"
                  else
                     # Single value
                     key=${keys[$i]}
                  fi

                  # Change .true. into 1 and .false into 0
                  if [[ ${value} == ".true." ]; then
                     printf "   "\"${key}\"" : 1" >> ${filename}
                  elif [[ ${value} == ".false." ]; then
                     printf "   "\"${key}\"" : 0" >> ${filename}
                  else
                     printf "   "\"${key}\"" : "${value} >> ${filename}
                  fi
                  newline=true
                  let ival=ival+1
               done
            fi
            let i=i+1
         done
      done
      printf "\n" >> ${filename}
      printf "}" >> ${filename}
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
      filename="../run/"${suffix}".json"
      generate_namelist ${filename}
   done
else
   # Generate one namelist
   suffix=$1
   filename="../run/"${suffix}".json"
   generate_namelist ${filename}
fi
