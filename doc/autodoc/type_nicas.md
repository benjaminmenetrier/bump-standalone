# Module type_nicas

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [nicas%] [alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L70) | allocation |
| subroutine | [nicas%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L114) | release memory (partial) |
| subroutine | [nicas%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L135) | release memory (full) |
| subroutine | [nicas%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L160) | read |
| subroutine | [nicas%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L312) | write |
| subroutine | [nicas%] [write_mpi_summary](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L426) | write MPI related data summary |
| subroutine | [nicas%] [run_nicas](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L509) | NICAS driver |
| subroutine | [nicas%] [run_nicas_tests](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L583) | NICAS tests driver |
| subroutine | [nicas%] [alloc_cv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L706) | allocation |
| subroutine | [nicas%] [random_cv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L759) | generate a random control vector |
| subroutine | [nicas%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L787) | apply NICAS |
| subroutine | [nicas%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1058) | apply NICAS from square-root |
| subroutine | [nicas%] [apply_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1104) | apply NICAS square-root |
| subroutine | [nicas%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1312) | apply NICAS square-root, adjoint |
| subroutine | [nicas%] [randomize](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1543) | randomize NICAS from square-root |
| subroutine | [nicas%] [apply_bens](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1612) | apply localized ensemble covariance |
| subroutine | [nicas%] [test_adjoint](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1671) | test NICAS adjoint |
| subroutine | [nicas%] [test_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1764) | apply NICAS to diracs |
| subroutine | [nicas%] [test_randomization](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1828) | test NICAS randomization method with respect to theoretical error statistics |
| subroutine | [nicas%] [test_consistency](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1931) | test HDIAG-NICAS consistency with a randomization method |
| subroutine | [nicas%] [test_optimality](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L2080) | test HDIAG localization optimality with a randomization method |
| subroutine | [define_test_vectors](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L2216) | define test vectors |
