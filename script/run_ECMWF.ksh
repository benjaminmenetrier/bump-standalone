#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: run_ECMWF
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------

# Parallel setup
nnodes=1
ntasks_per_node=1
nthreads=1
let ntasks=nnodes*ntasks_per_node
let ncpus_per_node=nthreads*ntasks_per_node
echo "Parallel setup:"
echo "   Number of nodes:          "${nnodes}
echo "   Number of tasks per node: "${ntasks_per_node}
echo "   Number of tasks:          "${ntasks}
echo "   Number of threads:        "${nthreads}
echo "   Number of cpus per nodes: "${ncpus_per_node}

# Define root directory
rootdir=/home/ms/fr/sozi/code/bump

# Define data directory
datadir=${rootdir}/test

# New working directory
workdir=${rootdir}/work
rm -fr ${workdir}
mkdir ${workdir}
cp -f ${rootdir}/run/bump ${workdir}
cp -f ${rootdir}/run/namelist_test ${workdir}/namelist

# Job
#----------------------------------------------------------------------
cat<<EOFNAM >${workdir}/job_bump.ksh
#!/bin/ksh
#PBS -q np
#PBS -l walltime=00:30:00
#PBS -l EC_nodes=${nnodes}
#PBS -l EC_tasks_per_node=${ntasks_per_node}
#PBS -l EC_total_tasks=${ntasks}
#PBS -l EC_threads_per_task=${nthreads}
#PBS -l EC_hyperthreads=1
#PBS -j oe
#PBS -o ${workdir}/output

module load cray-netcdf
export OMP_NUM_THREADS=${nthreads}

cd ${workdir}
aprun -N ${ntasks_per_node} -n ${ntasks} -d $OMP_NUM_THREADS -j 1 ${rootdir}/run/bump namelist

EOFNAM
#----------------------------------------------------------------------

# Execute
qsub ${workdir}/job_bump.ksh
