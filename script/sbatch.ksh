#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: sbatch
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2017 METEO-FRANCE
#----------------------------------------------------------------------

# Parallel setup
nnodes=1
ntasks_per_node=36
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
rootdir=/home/gmap/mrpa/menetrie/codes/hdiag_nicas

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
#!/bin/bash
#SBATCH -N ${nnodes}
#SBATCH -n ${ntasks}
#SBATCH -c ${nthreads}
#SBATCH -t 00:30:00
#SBATCH -p normal64,huge256
#SBATCH --exclusiv
#SBATCH -e ${workdir}/output
#SBATCH -o ${workdir}/output

module purge
module load gcc netcdf openmpi
export OMP_NUM_THREADS=${nthreads}

cd ${workdir}
srun --mpi=pmi2 ${rootdir}/run/hdiag_nicas < namelist
EOFNAM

#----------------------------------------------------------------------

# Execute
sbatch ${workdir}/job_hdiag_nicas.ksh
