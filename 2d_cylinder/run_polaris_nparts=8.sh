#!/bin/bash -l
#PBS -N DSMC_Comet_2D
#PBS -l select=2:system=polaris
#PBS -l place=scatter
#PBS -l walltime=0:10:00
#PBS -A hypersonic01
#PBS -q debug
#PBS -l filesystems=home:grand:eagle
#PBS -j oe

module use /soft/modulefiles
module load PrgEnv-gnu/8.6.0
module load gcc-native/12.3
module load cudatoolkit-standalone/12.5.0 

# Change to working directory
cd ${PBS_O_WORKDIR}

# MPI and OpenMP settings
NNODES=`wc -l < $PBS_NODEFILE`
NRANKS_PER_NODE=$(nvidia-smi -L | wc -l)
NDEPTH=16 # Number of hardware threads per rank (i.e. spacing between MPI ranks)
NTHREADS=1 # Number of software threads per rank to launch (i.e. OMP_NUM_THREADS)

NTOTRANKS=$(( NNODES * NRANKS_PER_NODE ))
echo "NUM_OF_NODES= ${NNODES} TOTAL_NUM_RANKS= ${NTOTRANKS} RANKS_PER_NODE= ${NRANKS_PER_NODE} THREADS_PER_RANK= ${NTHREADS}"

# For applications that internally handle binding MPI/OpenMP processes to GPUs
#mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth --env OMP_NUM_THREADS=${NTHREADS} -env OMP_PLACES=threads ./hello_affinity

# For applications that need mpiexec to bind MPI ranks to GPUs
mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth \
--env OMP_NUM_THREADS=${NTHREADS} -env OMP_PLACES=threads ./set_affinity_gpu_polaris.sh \
./ptn_loading 2d_cylinder.msh 2d_cylinder_8.ptn 1 3
