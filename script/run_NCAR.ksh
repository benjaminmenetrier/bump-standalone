#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: pbs
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
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
rootdir=/glade/u/home/menetrie/codes/hdiag_nicas

# Define model and xp
model=arp
xp=877D

# Define data directory
datadir=${rootdir}/data/${model}/${xp}

# New working directory
workdir=${rootdir}/${model}_${xp}
rm -fr ${workdir}
mkdir ${workdir}
cp -f ${rootdir}/run/hdiag_nicas ${workdir}
cp -f ${rootdir}/run/namelist_${model}_${xp}_sc ${workdir}/namelist

# Job
#----------------------------------------------------------------------
cat<<EOFNAM >${workdir}/job_hdiag_nicas.ksh
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
module load cmake/3.9.1 gnu/6.3.0 openmpi/3.0.0 netcdf/4.4.1.1 ncl
export OMP_NUM_THREADS=${nthreads}

cd ${workdir}
mpirun ${rootdir}/run/hdiag_nicas < namelist
EOFNAM

#----------------------------------------------------------------------

# Execute
qsub ${workdir}/job_hdiag_nicas.ksh
