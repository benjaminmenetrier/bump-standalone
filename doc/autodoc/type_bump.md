# Module type_bump

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [bump%] [setup_online](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L76) | online setup |
| subroutine | [bump%] [run_drivers](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L274) | run drivers |
| subroutine | [bump%] [add_member](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L487) | add member into bump0,000000e+00ns[1,2] |
| subroutine | [bump%] [apply_vbal](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L535) | vertical balance application |
| subroutine | [bump%] [apply_vbal_inv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L573) | vertical balance application, inverse |
| subroutine | [bump%] [apply_vbal_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L611) | vertical balance application, adjoint |
| subroutine | [bump%] [apply_vbal_inv_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L649) | vertical balance application, inverse adjoint |
| subroutine | [bump%] [apply_nicas](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L687) | NICAS application |
| subroutine | [bump%] [get_cv_size](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L735) | get control variable size |
| subroutine | [bump%] [apply_nicas_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L758) | NICAS square-root application |
| subroutine | [bump%] [apply_nicas_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L805) | NICAS square-root adjoint application |
| subroutine | [bump%] [randomize](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L849) | NICAS randomization |
| subroutine | [bump%] [apply_obsop](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L886) | observation operator application |
| subroutine | [bump%] [apply_obsop_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L915) | observation operator adjoint application |
| subroutine | [bump%] [get_parameter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L944) | get a parameter |
| subroutine | [bump%] [copy_to_field](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1000) | copy to field |
| subroutine | [bump%] [set_parameter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1151) | set a parameter |
| subroutine | [bump%] [copy_from_field](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1207) | copy from field |
| subroutine | [bump%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1308) | release memory (partial) |
| subroutine | [bump%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_bump.F90#L1335) | release memory (full) |
