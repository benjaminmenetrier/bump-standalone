# Module type_nicas

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [nicas%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L72) | allocation |
| subroutine | [nicas%] [partial_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L116) | release memory (partial) |
| subroutine | [nicas%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L137) | release memory (full) |
| subroutine | [nicas%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L162) | read |
| subroutine | [nicas%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L305) | write |
| subroutine | [nicas%] [write_mpi_summary](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L412) | write MPI related data summary |
| subroutine | [nicas%] [run_nicas](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L495) | NICAS driver |
| subroutine | [nicas%] [run_nicas_tests](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L567) | NICAS tests driver |
| subroutine | [nicas%] [alloc_cv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L711) | allocation |
| subroutine | [nicas%] [random_cv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L764) | generate a random control vector |
| subroutine | [nicas%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L792) | apply NICAS |
| subroutine | [nicas%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1063) | apply NICAS from square-root |
| subroutine | [nicas%] [apply_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1108) | apply NICAS square-root |
| subroutine | [nicas%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1326) | apply NICAS square-root, adjoint |
| subroutine | [nicas%] [randomize](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1567) | randomize NICAS from square-root |
| subroutine | [nicas%] [apply_bens](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1636) | apply localized ensemble covariance |
| subroutine | [nicas%] [test_adjoint](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1695) | test NICAS adjoint |
| subroutine | [nicas%] [test_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1788) | test full/square-root equivalence |
| subroutine | [nicas%] [test_dirac](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1911) | apply NICAS to diracs |
| subroutine | [nicas%] [test_randomization](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L1974) | test NICAS randomization method with respect to theoretical error statistics |
| subroutine | [nicas%] [test_consistency](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L2077) | test HDIAG-NICAS consistency with a randomization method |
| subroutine | [nicas%] [test_optimality](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L2227) | test HDIAG localization optimality with a randomization method |
| subroutine | [define_test_vectors](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas.F90#L2371) | define test vectors |
