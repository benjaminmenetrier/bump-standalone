# Module type_nicas

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [nicas%] [alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L71) | allocation |
| subroutine | [nicas%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L115) | release memory (partial) |
| subroutine | [nicas%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L136) | release memory (full) |
| subroutine | [nicas%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L161) | read |
| subroutine | [nicas%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L317) | write |
| subroutine | [nicas%] [write_mpi_summary](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L431) | write MPI related data summary |
| subroutine | [nicas%] [run_nicas](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L514) | NICAS driver |
| subroutine | [nicas%] [run_nicas_tests](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L588) | NICAS tests driver |
| subroutine | [nicas%] [alloc_cv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L732) | allocation |
| subroutine | [nicas%] [random_cv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L785) | generate a random control vector |
| subroutine | [nicas%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L813) | apply NICAS |
| subroutine | [nicas%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1084) | apply NICAS from square-root |
| subroutine | [nicas%] [apply_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1130) | apply NICAS square-root |
| subroutine | [nicas%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1338) | apply NICAS square-root, adjoint |
| subroutine | [nicas%] [randomize](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1569) | randomize NICAS from square-root |
| subroutine | [nicas%] [apply_bens](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1638) | apply localized ensemble covariance |
| subroutine | [nicas%] [test_adjoint](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1697) | test NICAS adjoint |
| subroutine | [nicas%] [test_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1790) | test full/square-root equivalence |
| subroutine | [nicas%] [test_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1913) | apply NICAS to diracs |
| subroutine | [nicas%] [test_randomization](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L1977) | test NICAS randomization method with respect to theoretical error statistics |
| subroutine | [nicas%] [test_consistency](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L2080) | test HDIAG-NICAS consistency with a randomization method |
| subroutine | [nicas%] [test_optimality](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L2228) | test HDIAG localization optimality with a randomization method |
| subroutine | [define_test_vectors](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas.F90#L2372) | define test vectors |
