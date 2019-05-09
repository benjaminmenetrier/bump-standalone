#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: namelist_sql2nam
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------
# Function to save a namelist
save_namelist() {
   #!/bin/ksh
   # Get argument
   if test $# = 0 ; then
      echo "Error: no input argument in save_namelist!"
   else
      echo "Save namelist "${filename}" in database "${dbname}":"

      if test -e namelist.sqlite ; then
         list=`sqlite3 ${dbname} ".tables"`
      else
         list=""
      fi

      # While loop over lines
      i=1
      while IFS= read -r line ; do
         # Check line type
         test=`echo ${line} | cut -c -1`
         if test "${test}" = "&" ; then
            # New block
            block=`echo ${line} | cut -c 2-`
            i2=${i}
            if test ${i} -le 9 ; then
               i2="0"${i2}
            fi
            table="t"${i2}"_"${block}

            # Initialize key/value
            if test "${table#*$list}" = "$table" ; then
               newrecord=`sqlite3 ${dbname} "select * from ${table} where name=='${suffix}'"`
               if test -z  "${newrecord}" ; then
                  # Insert new record
                  keys="name"
                  values="'"${suffix}"'"
               else
                  # Update old record
                  update=""
               fi
            else
               newrecord=""
               # Insert new record
               keys="name"
               values="'"${suffix}"'"
            fi
            let i=i+1
         else
            if test "${test}" = "/" ; then
               # End the block: insert data into database

               # Test recording existence
               if test -z  "${newrecord}" ; then
                  echo "   Insert data into table "${table}
                  sqlite3 ${dbname} "create table if not exists ${table} (${keys},primary key('name')) "
                  sqlite3 ${dbname} "insert into ${table} (${keys}) values (${values})"
               else
                  echo "   Update data of table "${table}
                  sqlite3 ${dbname} "update ${table} set ${update} where name = '"${suffix}"'"
               fi
            else
               if test ! -z  "${test}" ; then
                  # Generate key/value
                  key=`echo ${line} | cut -d"=" -f 1 | cut -d" " -f 1`
                  value=`echo ${line} | cut -d"=" -f 2 | cut -c 2-`
                  value=${value%','}
                  value=`echo ${value} | sed -e "s/'/\\\\\"/g"`
                  if test ${value} == "" ; then
                     value="NULL"
                  fi
                  if test -z  "${newrecord}" ; then
                     keys=${keys}","${key}
                     values=${values}",'"${value}"'"
                  else
                     if test ! -z "${update}" ; then
                        update=${update}","
                     fi
                     update=${update}${key}" = '"${value}"'"
                  fi
               fi
            fi
         fi
      done < ${filename}
   fi
}

# Database
dbname="namelist.sqlite"

if test $# = 0 ; then
   # Save all namelists, starting with default
   suffix="default"
   filename="../run/namelist_"${suffix}
   save_namelist ${filename}
   for namelist in ../run/namelist_* ; do
      suffix=`echo ${namelist} | cut -c 17-`
      filename="../run/namelist_"${suffix}
      save_namelist ${filename}
   done
else
   # Save one namelist
   suffix=$1
   filename="../run/namelist_"${suffix}
   save_namelist ${filename}
fi
