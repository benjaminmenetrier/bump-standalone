# Running the code

To run the code on a single node, you have to edit a namelist located in the $MAINDIR/run directory, and then:
 
    cd $MAINDIR/run
    export OMP_NUM_THREADS=$NTHREAD
    mpirun -n $NTASK bump namelist_$SUFFIX

where $NTHREAD is the number of OpenMP threads and $NTASK is the number of MPI tasks that are desired.

Some scripts are available for multi-nodes executions:
 - $MAINDIR/script/run_ECMWF.ksh to run on cca/ccb
 - $MAINDIR/script/run_MF.ksh to run on beaufix/prolix
 - $MAINDIR/script/run_NCAR.ksh to run on cheyenne
