# Module type_bump

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [bump_create](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L122) | create |
| subroutine | [bump_setup](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L166) | setup |
| subroutine | [bump_setup_online_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L369) | online setup (deprecated) |
| subroutine | [bump_run_drivers](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L509) | run drivers |
| subroutine | [bump_add_member](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L770) | add member into bump%ens[1,2] |
| subroutine | [bump_remove_member](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L860) | remove member into bump%ens[1,2] |
| subroutine | [bump_apply_vbal](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L914) | vertical balance application |
| subroutine | [bump_apply_vbal_inv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L959) | vertical balance application, inverse |
| subroutine | [bump_apply_vbal_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1004) | vertical balance application, adjoint |
| subroutine | [bump_apply_vbal_inv_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1049) | vertical balance application, inverse adjoint |
| subroutine | [bump_apply_stddev](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1094) | standard-deviation application |
| subroutine | [bump_apply_stddev_inv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1141) | standard-deviation application, inverse |
| subroutine | [bump_apply_nicas](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1188) | NICAS application |
| subroutine | [bump_apply_nicas_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1243) | NICAS application (deprecated) |
| subroutine | [bump_get_cv_size](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1295) | get control variable size |
| subroutine | [bump_apply_nicas_sqrt](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1318) | NICAS square-root application |
| subroutine | [bump_apply_nicas_sqrt_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1369) | NICAS square-root application (deprecated) |
| subroutine | [bump_apply_nicas_sqrt_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1419) | NICAS square-root adjoint application |
| subroutine | [bump_randomize](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1467) | NICAS randomization |
| subroutine | [bump_apply_obsop](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1508) | observation operator application |
| subroutine | [bump_apply_obsop_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1546) | observation operator application (deprecated) |
| subroutine | [bump_apply_obsop_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1583) | observation operator adjoint application |
| subroutine | [bump_apply_obsop_ad_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1621) | observation operator adjoint application (deprecated) |
| subroutine | [bump_get_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1658) | get a parameter |
| subroutine | [bump_copy_to_field](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1722) | copy to field |
| subroutine | [bump_test_get_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1899) | test get_parameter |
| subroutine | [bump_set_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1955) | set a parameter |
| subroutine | [bump_set_parameter_deprecated](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2018) | set a parameter (deprecated) |
| subroutine | [bump_copy_from_field](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2081) | copy from field |
| subroutine | [bump_test_set_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2178) | test set_parameter |
| subroutine | [bump_test_apply_interfaces](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2262) | test BUMP apply interfaces |
| subroutine | [bump_partial_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2410) | release memory (partial) |
| subroutine | [bump_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2438) | release memory (full) |
| subroutine | [dummy](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2467) | dummy finalization |
