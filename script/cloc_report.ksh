#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: cloc_report
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------
# Get cloc report
cd ..
cloc --exclude-dir=external --quiet --csv --out=cloc.csv src
cloc --quiet --csv --out=cloc_external.csv src/external

# Write doxygen-compatible report
printf "// This is the CLOC_REPORT.dox file, which can be viewed by browsing the doxygen-generated documentation.\n/*! \page CLOC_REPORT CLOC_REPORT\nCode report obtained with <a target=\"_blank\" href=\"https://github.com/AlDanial/cloc\">CLOC</a>:\n" > doc/CLOC_REPORT.dox
OLDIFS=$IFS
IFS=,
printf "<br><br>Internal code<br><table>\n" >> doc/CLOC_REPORT.dox
i=0
while read files language blank comment code dum ; do
   printf "<tr>" >> doc/CLOC_REPORT.dox
   if [ $i == 0 ] ; then
      printf "<th>"$language"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$files"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$blank"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$comment"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$code"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$comment"/"$code" ratio</th>" >> doc/CLOC_REPORT.dox
   else
      printf "<td align=\"center\">"$language"</td>" >> doc/CLOC_REPORT.dox
      printf "<td align=\"center\">"$files"</td>" >> doc/CLOC_REPORT.dox
      printf "<td align=\"center\">"$blank"</td>" >> doc/CLOC_REPORT.dox
      printf "<td align=\"center\">"$comment"</td>" >> doc/CLOC_REPORT.dox
      printf "<td align=\"center\">"$code"</td>" >> doc/CLOC_REPORT.dox
      let ratio=100*comment/code
      printf "<td align=\"center\">"$ratio" \%</td>" >> doc/CLOC_REPORT.dox
   fi
   printf "</tr>\n" >> doc/CLOC_REPORT.dox
   let i=i+1
done < cloc.csv
printf "</table><br>External code<br><table>\n" >> doc/CLOC_REPORT.dox
i=0
while read files language blank comment code dum ; do
   printf "<tr>" >> doc/CLOC_REPORT.dox
   if [ $i == 0 ] ; then
      printf "<th>"$language"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$files"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$blank"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$comment"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$code"</th>" >> doc/CLOC_REPORT.dox
      printf "<th>"$comment"/"$code" ratio</th>" >> doc/CLOC_REPORT.dox
   else
      printf "<td align=\"center\">"$language"</td>" >> doc/CLOC_REPORT.dox
      printf "<td align=\"center\">"$files"</td>" >> doc/CLOC_REPORT.dox
      printf "<td align=\"center\">"$blank"</td>" >> doc/CLOC_REPORT.dox
      printf "<td align=\"center\">"$comment"</td>" >> doc/CLOC_REPORT.dox
      printf "<td align=\"center\">"$code"</td>" >> doc/CLOC_REPORT.dox
      let ratio=100*comment/code
      printf "<td align=\"center\">"$ratio" \%</td>" >> doc/CLOC_REPORT.dox
   fi
   printf "</tr>\n" >> doc/CLOC_REPORT.dox
   let i=i+1
done < cloc_external.csv
IFS=$OLDIFS
rm -f cloc.csv cloc_external.csv
printf "</table>\n*/" >> doc/CLOC_REPORT.dox
