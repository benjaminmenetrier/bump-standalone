#!/bin/ksh

for file in `ls *.f90`;do
   cp -f ../src_copy/${file} ${file}
done

for file in `ls *.f90`;do
   index_in="ic"
   index_out="jc3"
   sed -i -e "s/\b${index_in}\b/${index_out}/g" ${file}

   sed -i -e "s/ic1_to_ic0/c1_to_c0/g" ${file}
done
sed -i -e "s/\bncmax\b/nc3max/g" type_nam.f90
