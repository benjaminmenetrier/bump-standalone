# Module type_bump

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [bump_create](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L122) | create |
| subroutine | [bump_setup](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L166) | setup |
| subroutine | [bump_setup_online_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L366) | online setup (deprecated) |
| subroutine | [bump_run_drivers](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L506) | run drivers |
| subroutine | [bump_add_member](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L767) | add member into bump%ens[1,2] |
| subroutine | [bump_remove_member](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L857) | remove member into bump%ens[1,2] |
| subroutine | [bump_apply_vbal](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L911) | vertical balance application |
| subroutine | [bump_apply_vbal_inv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L956) | vertical balance application, inverse |
| subroutine | [bump_apply_vbal_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1001) | vertical balance application, adjoint |
| subroutine | [bump_apply_vbal_inv_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1046) | vertical balance application, inverse adjoint |
| subroutine | [bump_apply_stddev](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1091) | standard-deviation application |
| subroutine | [bump_apply_stddev_inv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1138) | standard-deviation application, inverse |
| subroutine | [bump_apply_nicas](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1185) | NICAS application |
| subroutine | [bump_apply_nicas_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1240) | NICAS application (deprecated) |
| subroutine | [bump_get_cv_size](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1292) | get control variable size |
| subroutine | [bump_apply_nicas_sqrt](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1315) | NICAS square-root application |
| subroutine | [bump_apply_nicas_sqrt_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1366) | NICAS square-root application (deprecated) |
| subroutine | [bump_apply_nicas_sqrt_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1416) | NICAS square-root adjoint application |
| subroutine | [bump_randomize](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1464) | NICAS randomization |
| subroutine | [bump_apply_obsop](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1505) | observation operator application |
| subroutine | [bump_apply_obsop_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1543) | observation operator application (deprecated) |
| subroutine | [bump_apply_obsop_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1580) | observation operator adjoint application |
| subroutine | [bump_apply_obsop_ad_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1618) | observation operator adjoint application (deprecated) |
| subroutine | [bump_get_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1655) | get a parameter |
| subroutine | [bump_copy_to_field](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1719) | copy to field |
| subroutine | [bump_test_get_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1896) | test get_parameter |
| subroutine | [bump_set_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1952) | set a parameter |
| subroutine | [bump_set_parameter_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2015) | set a parameter (deprecated) |
| subroutine | [bump_copy_from_field](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2078) | copy from field |
| subroutine | [bump_test_set_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2175) | test set_parameter |
| subroutine | [bump_test_apply_interfaces](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2259) | test BUMP apply interfaces |
| subroutine | [bump_partial_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2407) | release memory (partial) |
| subroutine | [bump_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2435) | release memory (full) |
| subroutine | [dummy](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2464) | dummy finalization |
