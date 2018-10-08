#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: callgraph
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------
# Compile in DEBUG mode
echo '--- Compile in DEBUG mode'
cd ..
mkdir -p build
cd build
export BUMP_BUILD=DEBUG
cmake ..
make -j4

# Generate configuration
echo '--- Generate configuration'
cd ../script
cat<<EOFCONFIG >config_fortrancallgraph.py
import os
ASSEMBLER_DIRS = ["${HOME}/build/bump"]
SOURCE_DIRS = ["${HOME}/build/bump"]
SOURCE_FILES_PREPROCESSED = False
SPECIAL_MODULE_FILES = {}
EXCLUDE_MODULES = []
IGNORE_GLOBALS_FROM_MODULES = EXCLUDE_MODULES + []
IGNORE_DERIVED_TYPES = []
CACHE_DIR = os.path.dirname(os.path.realpath(__file__)) + '/cache'

EOFCONFIG

# Call FortranCallGraph
rm -fr ../doc/FortranCallGraph
mkdir -p ../doc/FortranCallGraph
module=type_bump
for subroutine in "bump_setup_offline" "bump_setup_online" "bump_dealloc" ; do
   echo '--- Call FortranCallGraph for '${subroutine}' in module '${module}
   FortranCallGraph.py -p dot ${module} ${subroutine} > ../doc/FortranCallGraph/${module}_${subroutine}.txt
   sed -i -e s/"__"/"\""/g -e s/"_MOD_"/"%"/g -e s/" ->"/"\" ->"/g -e s/";"/"\";"/g -e "/netcdf/d" -e "/-> \"model_interface/p;/model_/d" -e "/tools_/d" -e "/type_mpl/d" -e "/fckit_mpi_module/d" -e "/rand_/d" -e "/destroy_node/d" ../doc/FortranCallGraph/${module}_${subroutine}.txt
   cat ../doc/FortranCallGraph/${module}_${subroutine}.txt | dot -Nshape="box" -Grankdir="LR" -Tps -Tcmapx > ../doc/FortranCallGraph/${module}_${subroutine}.ps
   epstopdf ../doc/FortranCallGraph/${module}_${subroutine}.ps
   rm -f ../doc/FortranCallGraph/${module}_${subroutine}.ps ../doc/FortranCallGraph/${module}_${subroutine}.txt
done
module=type_cmat
for subroutine in "cmat_run_hdiag" ; do
   echo '--- Call FortranCallGraph for '${subroutine}' in module '${module}
   FortranCallGraph.py -p dot ${module} ${subroutine} > ../doc/FortranCallGraph/${module}_${subroutine}.txt
   sed -i -e s/"__"/"\""/g -e s/"_MOD_"/"%"/g -e s/" ->"/"\" ->"/g -e s/";"/"\";"/g -e "/netcdf/d" -e "/-> \"model_interface/p;/model_/d" -e "/tools_/d" -e "/type_mpl/d" -e "/fckit_mpi_module/d" -e "/rand_/d" -e "/destroy_node/d" ../doc/FortranCallGraph/${module}_${subroutine}.txt
   cat ../doc/FortranCallGraph/${module}_${subroutine}.txt | dot -Nshape="box" -Grankdir="LR" -Tps -Tcmapx > ../doc/FortranCallGraph/${module}_${subroutine}.ps
   epstopdf ../doc/FortranCallGraph/${module}_${subroutine}.ps
   rm -f ../doc/FortranCallGraph/${module}_${subroutine}.ps ../doc/FortranCallGraph/${module}_${subroutine}.txt
done
module=type_lct
for subroutine in "lct_run_lct" ; do
   echo '--- Call FortranCallGraph for '${subroutine}' in module '${module}
   FortranCallGraph.py -p dot ${module} ${subroutine} > ../doc/FortranCallGraph/${module}_${subroutine}.txt
   sed -i -e s/"__"/"\""/g -e s/"_MOD_"/"%"/g -e s/" ->"/"\" ->"/g -e s/";"/"\";"/g -e "/netcdf/d" -e "/-> \"model_interface/p;/model_/d" -e "/tools_/d" -e "/type_mpl/d" -e "/fckit_mpi_module/d" -e "/rand_/d" -e "/destroy_node/d" ../doc/FortranCallGraph/${module}_${subroutine}.txt
   cat ../doc/FortranCallGraph/${module}_${subroutine}.txt | dot -Nshape="box" -Grankdir="LR" -Tps -Tcmapx > ../doc/FortranCallGraph/${module}_${subroutine}.ps
   epstopdf ../doc/FortranCallGraph/${module}_${subroutine}.ps
   rm -f ../doc/FortranCallGraph/${module}_${subroutine}.ps ../doc/FortranCallGraph/${module}_${subroutine}.txt
done
module=type_nicas
for subroutine in "nicas_run_nicas" "nicas_run_nicas_tests"; do
   echo '--- Call FortranCallGraph for '${subroutine}' in module '${module}
   FortranCallGraph.py -p dot ${module} ${subroutine} > ../doc/FortranCallGraph/${module}_${subroutine}.txt
   sed -i -e s/"__"/"\""/g -e s/"_MOD_"/"%"/g -e s/" ->"/"\" ->"/g -e s/";"/"\";"/g -e "/netcdf/d" -e "/-> \"model_interface/p;/model_/d" -e "/tools_/d" -e "/type_mpl/d" -e "/fckit_mpi_module/d" -e "/rand_/d" -e "/destroy_node/d" ../doc/FortranCallGraph/${module}_${subroutine}.txt
   cat ../doc/FortranCallGraph/${module}_${subroutine}.txt | dot -Nshape="box" -Grankdir="LR" -Tps -Tcmapx > ../doc/FortranCallGraph/${module}_${subroutine}.ps
   epstopdf ../doc/FortranCallGraph/${module}_${subroutine}.ps
   rm -f ../doc/FortranCallGraph/${module}_${subroutine}.ps ../doc/FortranCallGraph/${module}_${subroutine}.txt
done
module=type_obsop
for subroutine in "obsop_run_obsop"; do
   echo '--- Call FortranCallGraph for '${subroutine}' in module '${module}
   FortranCallGraph.py -p dot ${module} ${subroutine} > ../doc/FortranCallGraph/${module}_${subroutine}.txt
   sed -i -e s/"__"/"\""/g -e s/"_MOD_"/"%"/g -e s/" ->"/"\" ->"/g -e s/";"/"\";"/g -e "/netcdf/d" -e "/-> \"model_interface/p;/model_/d" -e "/tools_/d" -e "/type_mpl/d" -e "/fckit_mpi_module/d" -e "/rand_/d" -e "/destroy_node/d" ../doc/FortranCallGraph/${module}_${subroutine}.txt
   cat ../doc/FortranCallGraph/${module}_${subroutine}.txt | dot -Nshape="box" -Grankdir="LR" -Tps -Tcmapx > ../doc/FortranCallGraph/${module}_${subroutine}.ps
   epstopdf ../doc/FortranCallGraph/${module}_${subroutine}.ps
   rm -f ../doc/FortranCallGraph/${module}_${subroutine}.ps ../doc/FortranCallGraph/${module}_${subroutine}.txt
done
module=type_vbal
for subroutine in "vbal_run_vbal" "vbal_run_vbal_tests"; do
   echo '--- Call FortranCallGraph for '${subroutine}' in module '${module}
   FortranCallGraph.py -p dot ${module} ${subroutine} > ../doc/FortranCallGraph/${module}_${subroutine}.txt
   sed -i -e s/"__"/"\""/g -e s/"_MOD_"/"%"/g -e s/" ->"/"\" ->"/g -e s/";"/"\";"/g -e "/netcdf/d" -e "/-> \"model_interface/p;/model_/d" -e "/tools_/d" -e "/type_mpl/d" -e "/fckit_mpi_module/d" -e "/rand_/d" -e "/destroy_node/d" ../doc/FortranCallGraph/${module}_${subroutine}.txt
   cat ../doc/FortranCallGraph/${module}_${subroutine}.txt | dot -Nshape="box" -Grankdir="LR" -Tps -Tcmapx > ../doc/FortranCallGraph/${module}_${subroutine}.ps
   epstopdf ../doc/FortranCallGraph/${module}_${subroutine}.ps
   rm -f ../doc/FortranCallGraph/${module}_${subroutine}.ps ../doc/FortranCallGraph/${module}_${subroutine}.txt
done

# Clean files
rm -f config_fortrancallgraph.py

# Remove build directory
cd ..
#rm -fr build

