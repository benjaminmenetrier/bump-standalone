# Code structure

The source code is organized in modules:
 - main.F90: main program
 - tools_[...].F90: useful tools for the whole code
 - type_[...].F90: derived types
 - external/[...].F90: external tools
 - model/model_[...].F90: model related routines, to get the coordinates, read and write fields

1. Main program main.F90 is simple:
 - MPI intialization
 - command line arguments parsing
 - offline setup (call to the BUMP routines)
 - MPI finalization

2. Tools
 - tools_const.F90:
 - tools_fit.F90:
 - tools_func.F90:
 - tools_icos.F90:
 - tools_kinds.F90:
 - tools_missing.F90:
 - tools_nc.F90:
 - tools_repro.F90:
 - tools_test.F90:

3. Derived types
 - type_avg: contains blocks of averaged and asymptotic statistics
   + type_avg\%avg_alloc : allocation
 - type_avg_blk:
 - type_bpar.F90:
 - type_bump.F90:
 - type_cmat_blk.F90:
 - type_cmat.F90:
 - type_com.F90:
 - type_cv_blk.F90:
 - type_cv.F90:
 - type_diag_blk.F90:
 - type_diag.F90:
 - type_displ.F90:
 - type_ens.F90:
 - type_geom.F90:
 - type_hdata.F90:
 - type_io.F90:
 - type_kdtree.F90:
 - type_lct_blk.F90:
 - type_lct.F90:
 - type_linop.F90:
 - type_mesh.F90:
 - type_minim.F90:
 - type_mom_blk.F90:
 - type_mom.F90:
 - type_mpl.F90:
 - type_nam.F90:
 - type_nicas_blk.F90:
 - type_nicas.F90:
 - type_obsop.F90:
 - type_rng.F90:
 - type_timer.F90:
 - type_vbal_blk.F90:
 - type_vbal.F90:

4. External tools
 - tools_asa007.F90:
 - tools_kdtree2.F90:
 - tools_kdtree2_pq.F90:
 - tools_qsort.F90:
 - tools_stripack.F90:

5. Model related routines
 - model_interface.F90:
 - model_[...].F90:
