# Code auto-documentation

The source code is organized in five categories:

1. The main program main.F90
2. Useful tools for the whole code: tools_[...].F90
3. Derived types and associated methods: type_[...].F90
4. External tools: external/[...].F90
5. Model related routines, to get the coordinates, read and write fields: model/model_[...].F90

| Category | Name | Purpose |
| :------: | :--: | :---------- |
| main | [main](https://github.com/benjaminmenetrier/bump/tree/master/src/main.F90) | command line arguments parsing and offline setup (call to the BUMP routine) |
| tools | [tools_const](autodoc/tools_const.md) | define usual constants and missing values |
| tools | [tools_fit](autodoc/tools_fit.md) | fit-related tools |
| tools | [tools_func](autodoc/tools_func.md) | usual functions |
| tools | [tools_kinds](autodoc/tools_kinds.md) | kinds definition |
| tools | [tools_missing](autodoc/tools_missing.md) | deal with missing values |
| tools | [tools_nc](autodoc/tools_nc.md) | NetCDF routines |
| tools | [tools_repro](autodoc/tools_repro.md) | reproducibility functions |
| tools | [tools_test](autodoc/tools_test.md) | test tools |
| derived_type | [type_avg_blk](autodoc/type_avg_blk.md) | averaged statistics block derived type |
| derived_type | [type_avg](autodoc/type_avg.md) | average routines |
| derived_type | [type_bpar](autodoc/type_bpar.md) | block parameters derived type |
| derived_type | [type_bump](autodoc/type_bump.md) | BUMP derived type |
| derived_type | [type_cmat_blk](autodoc/type_cmat_blk.md) | correlation matrix derived type |
| derived_type | [type_cmat](autodoc/type_cmat.md) | C matrix derived type |
| derived_type | [type_com](autodoc/type_com.md) | communications derived type |
| derived_type | [type_cv_blk](autodoc/type_cv_blk.md) | control vector derived type |
| derived_type | [type_cv](autodoc/type_cv.md) | control vector derived type |
| derived_type | [type_diag_blk](autodoc/type_diag_blk.md) | diagnostic block derived type |
| derived_type | [type_diag](autodoc/type_diag.md) | diagnostic derived type |
| derived_type | [type_displ](autodoc/type_displ.md) | displacement data derived type |
| derived_type | [type_ens](autodoc/type_ens.md) | ensemble derived type |
| derived_type | [type_fckit_mpi_comm](autodoc/type_fckit_mpi_comm.md) | FCKIT emulator for offline execution |
| derived_type | [type_geom](autodoc/type_geom.md) | geometry derived type |
| derived_type | [type_hdata](autodoc/type_hdata.md) | sample data derived type |
| derived_type | [type_io](autodoc/type_io.md) | I/O derived type |
| derived_type | [type_kdtree](autodoc/type_kdtree.md) | KD-tree derived type |
| derived_type | [type_lct_blk](autodoc/type_lct_blk.md) | LCT data derived type |
| derived_type | [type_lct](autodoc/type_lct.md) | LCT data derived type |
| derived_type | [type_linop](autodoc/type_linop.md) | linear operator derived type |
| derived_type | [type_mesh](autodoc/type_mesh.md) | mesh derived type |
| derived_type | [type_minim](autodoc/type_minim.md) | minimization data derived type |
| derived_type | [type_mom_blk](autodoc/type_mom_blk.md) | moments block derived type |
| derived_type | [type_mom](autodoc/type_mom.md) | moments derived type |
| derived_type | [type_mpl](autodoc/type_mpl.md) | MPI parameters derived type |
| derived_type | [type_nam](autodoc/type_nam.md) | namelist derived type |
| derived_type | [type_nicas_blk](autodoc/type_nicas_blk.md) | NICAS data block derived type |
| derived_type | [type_nicas](autodoc/type_nicas.md) | NICAS data derived type |
| derived_type | [type_obsop](autodoc/type_obsop.md) | observation operator data derived type |
| derived_type | [type_rng](autodoc/type_rng.md) | random numbers generator derived type |
| derived_type | [type_timer](autodoc/type_timer.md) | timer data derived type |
| derived_type | [type_vbal_blk](autodoc/type_vbal_blk.md) | vertical balance block derived type |
| derived_type | [type_vbal](autodoc/type_vbal.md) | vertical balance derived type |
| external_tools | [tools_asa007](autodoc/tools_asa007.md) | inverse of symmetric positive definite matrix routines |
| external_tools | [tools_kdtree2](autodoc/tools_kdtree2.md) | K-d tree routines |
| external_tools | [tools_kdtree2_pq](autodoc/tools_kdtree2_pq.md) | K-d tree priority queue routines |
| external_tools | [tools_qsort](autodoc/tools_qsort.md) | qsort routines |
| external_tools | [tools_stripack](autodoc/tools_stripack.md) | STRIPACK routines |
| model | [module_aro](autodoc/module_aro.md) | AROME model routines |
| model | [module_arp](autodoc/module_arp.md) | ARPEGE model routines |
| model | [module_fv3](autodoc/module_fv3.md) | FV3 model routines |
| model | [module_gem](autodoc/module_gem.md) | GEM model routines |
| model | [module_geos](autodoc/module_geos.md) | GEOS model routines |
| model | [module_gfs](autodoc/module_gfs.md) | GFS model routines |
| model | [module_ifs](autodoc/module_ifs.md) | IFS model routines |
| model | [model_interface](autodoc/model_interface.md) | model routines |
| model | [module_mpas](autodoc/module_mpas.md) | MPAS model routines |
| model | [module_nemo](autodoc/module_nemo.md) | NEMO model routines |
| model | [module_wrf](autodoc/module_wrf.md) | WRF model routines |
