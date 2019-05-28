# Adding a new model

To add a model $MODEL in bump, you need to write a new module model/model_$MODEL.inc containing two routines:
 - model_$MODEL_coord to get the model coordinates
 - model_$MODEL_read to read a model field

You need also to add corresponding calls in type_model.F90.

Finally, you need to add a case for the namelist check in the routine nam_check, contained in type_nam.f90.

For models with a regular grid, you can start from AROME, ARPEGE, FV3, GEM, GEOS, GFS, IFS, NEMO and WRF routines. For models with an unstructured grid, you can start from MPAS and RES routines.
