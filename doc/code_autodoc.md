# Code auto-documentation

The source code is organized in six categories:

1. The main program main.F90
2. Useful tools for the whole code: tools_[...].F90
3. Derived types and associated methods: type_[...].F90
4. External tools: external/[...].F90
5. Emulator for the fckit routines: fckit/[...].F90
6. Model related routines, to get the coordinates and read fields: model/model_[...].inc

| Category | Name | Purpose |
| :------: | :--: | :---------- |
| main | [main](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/main.F90) | command line arguments parsing and offline setup (call to the BUMP routine) |
| tools | [tools_const](autodoc/tools_const.md) | define usual constants and missing values |
| tools | [tools_fit](autodoc/tools_fit.md) | fit-related tools |
| tools | [tools_func](autodoc/tools_func.md) | usual functions |
| tools | [tools_kinds](autodoc/tools_kinds.md) | kinds definition |
| tools | [tools_repro](autodoc/tools_repro.md) | reproducibility functions |
| derived_type | [type_adv](autodoc/type_adv.md) | advection derived type |
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
| derived_type | [type_ens](autodoc/type_ens.md) | ensemble derived type |
| derived_type | [type_geom](autodoc/type_geom.md) | geometry derived type |
