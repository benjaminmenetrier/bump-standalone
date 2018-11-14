#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: run_NCAR
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------

# Parallel setup
nnodes=1
ntasks_per_node=9
nthreads=4
let ntasks=nnodes*ntasks_per_node
let ncpus_per_node=nthreads*ntasks_per_node
echo "Parallel setup:"
echo "   Number of nodes:          "${nnodes}
echo "   Number of tasks per node: "${ntasks_per_node}
echo "   Number of tasks:          "${ntasks}
echo "   Number of threads:        "${nthreads}
echo "   Number of cpus per nodes: "${ncpus_per_node}

# Define root directory
rootdir=/glade/u/home/menetrie/code/bump

# Define model
model=geos

# Define data directory
datadir=${rootdir}/data/${model}

# New working directory
workdir=${rootdir}/${model}_workdir
rm -fr ${workdir}
mkdir ${workdir}
cp -f ${rootdir}/run/bump ${workdir}
cp -f ${rootdir}/run/namelist_${model} ${workdir}/namelist

# Job
#----------------------------------------------------------------------
cat<<EOFNAM >${workdir}/job_bump.ksh
#!/bin/ksh
#set -ex
#PBS -q regular
#PBS -l walltime=00:30:00
#PBS -l select=${nnodes}:ncpus=${ncpus_per_node}:mpiprocs=${ntasks_per_node}:ompthreads=${nthreads}
#PBS -j oe
#PBS -o ${workdir}/output
#PBS -m n
#PBS -A NSAP0003

source /glade/u/apps/ch/opt/Lmod/7.3.14/lmod/7.3.14/init/ksh
module purge
module load  gnu/7.3.0 openblas/0.2.20 openmpi/3.0.1
export OMP_NUM_THREADS=${nthreads}

cd ${workdir}
mpirun ${rootdir}/run/bump namelist
EOFNAM

#----------------------------------------------------------------------

# Execute
qsub ${workdir}/job_bump.ksh
