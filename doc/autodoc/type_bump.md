# Module type_bump

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [bump%] [setup_online](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L79) | online setup |
| subroutine | [bump%] [run_drivers](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L281) | run drivers |
| subroutine | [bump%] [add_member](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L486) | add member into bump0,000000e+00ns[1,2] |
| subroutine | [bump%] [apply_vbal](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L534) | vertical balance application |
| subroutine | [bump%] [apply_vbal_inv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L572) | vertical balance application, inverse |
| subroutine | [bump%] [apply_vbal_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L610) | vertical balance application, adjoint |
| subroutine | [bump%] [apply_vbal_inv_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L648) | vertical balance application, inverse adjoint |
| subroutine | [bump%] [apply_nicas](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L686) | NICAS application |
| subroutine | [bump%] [get_cv_size](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L734) | get control variable size |
| subroutine | [bump%] [apply_nicas_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L757) | NICAS square-root application |
| subroutine | [bump%] [apply_nicas_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L804) | NICAS square-root adjoint application |
| subroutine | [bump%] [randomize](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L848) | NICAS randomization |
| subroutine | [bump%] [apply_obsop](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L885) | observation operator application |
| subroutine | [bump%] [apply_obsop_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L914) | observation operator adjoint application |
| subroutine | [bump%] [get_parameter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L943) | get a parameter |
| subroutine | [bump%] [copy_to_field](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L999) | copy to field |
| subroutine | [bump%] [set_parameter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1150) | set a parameter |
| subroutine | [bump%] [copy_from_field](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1206) | copy from field |
| subroutine | [bump%] [crtm_neighbors_3d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1307) | find nearest neighbors for CRTM, 3D |
| subroutine | [bump%] [crtm_neighbors_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1345) | find nearest neighbors for CRTM, 2D |
| subroutine | [bump%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1381) | release memory (partial) |
| subroutine | [bump%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1408) | release memory (full) |
