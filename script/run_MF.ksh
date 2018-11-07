#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: run_MF
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------

# Parallel setup
nnodes=2
ntasks_per_node=4
nthreads=10
let ntasks=nnodes*ntasks_per_node
let ncpus_per_node=nthreads*ntasks_per_node
echo "Parallel setup:"
echo "   Number of nodes:          "${nnodes}
echo "   Number of tasks per node: "${ntasks_per_node}
echo "   Number of tasks:          "${ntasks}
echo "   Number of threads:        "${nthreads}
echo "   Number of cpus per nodes: "${ncpus_per_node}

# Define root directory
rootdir=/home/gmap/mrpa/menetrie/code/bump

# Define model and xp
model=arp
xp=86SV

# Define data directory
datadir=${rootdir}/data/${model}/${xp}

# New working directory
workdir=${rootdir}/${model}_${xp}
rm -fr ${workdir}
mkdir -p ${workdir}
cp -f ${rootdir}/run/bump ${workdir}
cp -f ${rootdir}/run/namelist_${model}_${xp}_sc ${workdir}/namelist

# Job
#----------------------------------------------------------------------
cat<<EOFNAM >${workdir}/job_bump.ksh
#!/bin/bash
#SBATCH -N ${nnodes}
#SBATCH -n ${ntasks}
#SBATCH -c ${nthreads}
#SBATCH -t 00:30:00
#SBATCH -p normal64,huge256
#SBATCH --exclusiv
#SBATCH -e ${workdir}/output
#SBATCH -o ${workdir}/output

export OMP_NUM_THREADS=${nthreads}

cd ${workdir}
srun --mpi=pmi2 ${rootdir}/run/bump namelist
EOFNAM

#----------------------------------------------------------------------

# Execute
sbatch ${workdir}/job_bump.ksh
