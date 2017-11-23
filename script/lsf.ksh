#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: lsf
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------

# Parallel setup
nnodes=1
ntasks_per_node=16
nthreads=1
let ntasks=nnodes*ntasks_per_nodes
let ncpus_per_node=nthreads*ntasks_per_node
echo "Parallel setup:"
echo "   Number of nodes:          "${nnodes}
echo "   Number of tasks per node: "${ntasks_per_node}
echo "   Number of tasks:          "${ntasks}
echo "   Number of threads:        "${nthreads}
echo "   Number of cpus per nodes: "${ncpus_per_node}

# Define root directory
rootdir=/glade/u/home/menetrie/hdiag_nicas

# Define model and xp
model=arp
xp=6B60

# Define resolution
resol=8
typeset -RZ3 resol

# Define mpicom
mpicom=2

# Define nproc
nproc="0008"

# Define data directory
datadir=${rootdir}/data/${model}/${xp}

# Define file name
filename=${model}_${xp}_resol-${resol}

# New working directory
workdir=${rootdir}/${filename}
rm -fr ${workdir}
mkdir ${workdir}

# Link to the distribution file
ln -sf ${datadir}/${model}_${xp}_distribution_${nproc}.nc ${datadir}/${model}_${xp}_resol-${resol}_distribution_${nproc}.nc

#----------------------------------------------------------------------
# Compute HDIAG_NICAS parameters
#----------------------------------------------------------------------

# Namelist
prefix=${filename}
sed -e "s|_DATADIR_|${datadir}|g" -e "s|_PREFIX_|${prefix}|g" -e "s|_RESOL_|${resol}|g" -e "s|_NPROC_|${nproc}|g" -e "s|_MPICOM_|${mpicom}|g" ${rootdir}/run/namelist_${model}_${xp}_sc > ${workdir}/namelist

# Job
#----------------------------------------------------------------------
cat<<EOFNAM >${workdir}/job_hdiag_nicas.ksh
#!/bin/ksh
#set -ex
#BSUB -a poe
#BSUB -q regular
#BSUB -n ${ntasks}
#BSUB -R "span[ptile=${ntasks_per_node}]"
#BSUB -W 00:30
#BSUB -e ${workdir}/output
#BSUB -o ${workdir}/output
#BSUB -P NSAP0003

source /glade/u/apps/opt/lmod/4.2.1/init/ksh
module purge
module load gnu netcdf ncarenv ncarcompilers ncl
export OMP_NUM_THREADS=${nthreads}
export MP_TASK_AFFINITY=core:$OMP_NUM_THREADS

cd ${workdir}
mpirun.lsf ${rootdir}/run/hdiag_nicas < namelist
EOFNAM

#----------------------------------------------------------------------

# Execute
bsub < ${workdir}/job_hdiag_nicas.ksh
