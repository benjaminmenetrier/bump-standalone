# Module type_nicas

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [nicas%] [alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L70) | allocation |
| subroutine | [nicas%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L114) | release memory (partial) |
| subroutine | [nicas%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L135) | release memory (full) |
| subroutine | [nicas%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L160) | read |
| subroutine | [nicas%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L316) | write |
| subroutine | [nicas%] [write_mpi_summary](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L430) | write MPI related data summary |
| subroutine | [nicas%] [run_nicas](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L513) | NICAS driver |
| subroutine | [nicas%] [run_nicas_tests](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L587) | NICAS tests driver |
| subroutine | [nicas%] [alloc_cv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L710) | allocation |
| subroutine | [nicas%] [random_cv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L763) | generate a random control vector |
| subroutine | [nicas%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L791) | apply NICAS |
| subroutine | [nicas%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1062) | apply NICAS from square-root |
| subroutine | [nicas%] [apply_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1108) | apply NICAS square-root |
| subroutine | [nicas%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1316) | apply NICAS square-root, adjoint |
| subroutine | [nicas%] [randomize](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1547) | randomize NICAS from square-root |
| subroutine | [nicas%] [apply_bens](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1616) | apply localized ensemble covariance |
| subroutine | [nicas%] [test_adjoint](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1675) | test NICAS adjoint |
| subroutine | [nicas%] [test_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1768) | apply NICAS to diracs |
| subroutine | [nicas%] [test_randomization](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1832) | test NICAS randomization method with respect to theoretical error statistics |
| subroutine | [nicas%] [test_consistency](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1935) | test HDIAG-NICAS consistency with a randomization method |
| subroutine | [nicas%] [test_optimality](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L2083) | test HDIAG localization optimality with a randomization method |
| subroutine | [define_test_vectors](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L2229) | define test vectors |
