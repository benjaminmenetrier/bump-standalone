# Adding a new model

To add a model $MODEL in bump, you need to write a new module containing three routines:
 - model/model_$MODEL_coord to get model coordinates
 - model_$MODEL_read to read a model field

You need also to add three calls to model/model_$MODEL_coord and model/model_$MODEL_read in routines model_coord and model_read respectively, which are contained in the module model_interface.

Finally, you need to add a case for the namelist check in the routine nam_check, contained in type_nam.f90.

For models with a regular grid, you can start from AROME, ARPEGE, FV3, GEM, GEOS, GFS, IFS, NEMO and WRF routines. For models with an unstructured grid, you can start from MPAS routines.
