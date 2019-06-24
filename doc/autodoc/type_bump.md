# Module type_bump

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [bump%] [setup_online](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L76) | online setup |
| subroutine | [bump%] [run_drivers](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L274) | run drivers |
| subroutine | [bump%] [add_member](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L478) | add member into bump0,000000e+00ns[1,2] |
| subroutine | [bump%] [apply_vbal](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L526) | vertical balance application |
| subroutine | [bump%] [apply_vbal_inv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L564) | vertical balance application, inverse |
| subroutine | [bump%] [apply_vbal_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L602) | vertical balance application, adjoint |
| subroutine | [bump%] [apply_vbal_inv_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L640) | vertical balance application, inverse adjoint |
| subroutine | [bump%] [apply_nicas](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L678) | NICAS application |
| subroutine | [bump%] [get_cv_size](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L726) | get control variable size |
| subroutine | [bump%] [apply_nicas_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L749) | NICAS square-root application |
| subroutine | [bump%] [apply_nicas_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L796) | NICAS square-root adjoint application |
| subroutine | [bump%] [randomize](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L840) | NICAS randomization |
| subroutine | [bump%] [apply_obsop](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L877) | observation operator application |
| subroutine | [bump%] [apply_obsop_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L906) | observation operator adjoint application |
| subroutine | [bump%] [get_parameter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L935) | get a parameter |
| subroutine | [bump%] [copy_to_field](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L991) | copy to field |
| subroutine | [bump%] [set_parameter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1142) | set a parameter |
| subroutine | [bump%] [copy_from_field](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1198) | copy from field |
| subroutine | [bump%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1299) | release memory (partial) |
| subroutine | [bump%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1326) | release memory (full) |
