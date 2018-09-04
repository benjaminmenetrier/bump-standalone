# Input data

A "grid.nc" file containing the coordinates of the model grid is used in every model/model_$MODEL_coord routine and should be placed in $DATADIR. The script "links.ksh" located in the $DATADIR folder can help you to generate it.

For the MPI splitting, a file $DATADIR/$PREFIX_distribution_$NPROC.nc is required, where $PREFIX and $NPROC is the number of MPI tasks formatted with 4 digits, both specified in the namelist.
