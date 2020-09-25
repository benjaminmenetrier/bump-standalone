# Module type_bump

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [bump_create](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L111) | create |
| subroutine | [bump_setup](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L155) | setup |
| subroutine | [bump_run_drivers](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L358) | run drivers |
| subroutine | [bump_add_member](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L619) | add member into bump%ens[1,2] |
| subroutine | [bump_remove_member](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L709) | remove member into bump%ens[1,2] |
| subroutine | [bump_apply_vbal](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L763) | vertical balance application |
| subroutine | [bump_apply_vbal_inv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L808) | vertical balance application, inverse |
| subroutine | [bump_apply_vbal_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L853) | vertical balance application, adjoint |
| subroutine | [bump_apply_vbal_inv_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L898) | vertical balance application, inverse adjoint |
| subroutine | [bump_apply_stddev](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L943) | standard-deviation application |
| subroutine | [bump_apply_stddev_inv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L990) | standard-deviation application, inverse |
| subroutine | [bump_apply_nicas](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1037) | NICAS application |
| subroutine | [bump_get_cv_size](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1092) | get control variable size |
| subroutine | [bump_apply_nicas_sqrt](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1115) | NICAS square-root application |
| subroutine | [bump_apply_nicas_sqrt_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1166) | NICAS square-root adjoint application |
| subroutine | [bump_randomize](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1214) | NICAS randomization |
| subroutine | [bump_apply_obsop](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1255) | observation operator application |
| subroutine | [bump_apply_obsop_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1293) | observation operator adjoint application |
| subroutine | [bump_get_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1331) | get a parameter |
| subroutine | [bump_copy_to_field](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1395) | copy to field |
| subroutine | [bump_test_get_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1572) | test get_parameter |
| subroutine | [bump_set_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1628) | set a parameter |
| subroutine | [bump_copy_from_field](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1691) | copy from field |
| subroutine | [bump_test_set_parameter](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1788) | test set_parameter |
| subroutine | [bump_test_apply_interfaces](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L1872) | test BUMP apply interfaces |
| subroutine | [bump_partial_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2020) | release memory (partial) |
| subroutine | [bump_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2048) | release memory (full) |
| subroutine | [dummy](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_bump.F90#L2077) | dummy finalization |
