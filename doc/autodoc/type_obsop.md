# Module type_obsop

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [obsop%] [partial_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L68) | release memory (partial) |
| subroutine | [obsop%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L85) | release memory (full) |
| subroutine | [obsop%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L104) | read observations locations |
| subroutine | [obsop%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L142) | write observations locations |
| subroutine | [obsop%] [generate](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L185) | generate observations locations |
| subroutine | [obsop%] [from](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L292) | copy observation operator data |
| subroutine | [obsop%] [run_obsop](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L324) | observation operator driver |
| subroutine | [obsop%] [run_obsop_tests](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L725) | observation operator tests driver |
| subroutine | [obsop%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L757) | observation operator interpolation |
| subroutine | [obsop%] [apply_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L790) | observation operator interpolation adjoint |
| subroutine | [obsop%] [test_adjoint](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L826) | test observation operator adjoints accuracy |
| subroutine | [obsop%] [test_accuracy](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L869) | test observation operator accuracy |
