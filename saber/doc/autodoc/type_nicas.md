# Module type_nicas

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [nicas_alloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L73) | allocation |
| subroutine | [nicas_partial_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L122) | release memory (partial) |
| subroutine | [nicas_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L143) | release memory (full) |
| subroutine | [nicas_read](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L168) | read |
| subroutine | [nicas_write](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L268) | write |
| subroutine | [nicas_send](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L388) | send |
| subroutine | [nicas_receive](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L456) | receive |
| subroutine | [nicas_run_nicas](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L516) | NICAS driver |
| subroutine | [nicas_run_nicas_tests](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L581) | NICAS tests driver |
| subroutine | [nicas_alloc_cv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L681) | allocation |
| subroutine | [nicas_random_cv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L734) | generate a random control vector |
| subroutine | [nicas_apply](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L799) | apply NICAS |
| subroutine | [nicas_apply_from_sqrt](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1067) | apply NICAS from square-root |
| subroutine | [nicas_apply_sqrt](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1113) | apply NICAS square-root |
| subroutine | [nicas_apply_sqrt_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1321) | apply NICAS square-root, adjoint |
| subroutine | [nicas_randomize](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1554) | randomize NICAS from square-root |
| subroutine | [nicas_apply_bens](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1631) | apply localized ensemble covariance |
| subroutine | [nicas_test_adjoint](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1690) | test NICAS adjoint |
| subroutine | [nicas_test_dirac](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1783) | apply NICAS to diracs |
| subroutine | [nicas_test_randomization](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1844) | test NICAS randomization method with respect to theoretical error statistics |
| subroutine | [nicas_test_consistency](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L1975) | test HDIAG-NICAS consistency with a randomization method |
| subroutine | [nicas_test_optimality](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L2102) | test HDIAG localization optimality with a randomization method |
| subroutine | [define_test_vectors](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas.F90#L2283) | define test vectors |
