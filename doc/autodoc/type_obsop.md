# Module type_obsop

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [obsop%] [partial_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L69) | release memory (partial) |
| subroutine | [obsop%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L86) | release memory (full) |
| subroutine | [obsop%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L105) | read observations locations |
| subroutine | [obsop%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L143) | write observations locations |
| subroutine | [obsop%] [generate](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L186) | generate observations locations |
| subroutine | [obsop%] [from](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L292) | copy observation operator data |
| subroutine | [obsop%] [run_obsop](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L324) | observation operator driver |
| subroutine | [obsop%] [run_obsop_tests](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L724) | observation operator tests driver |
| subroutine | [obsop%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L756) | observation operator interpolation |
| subroutine | [obsop%] [apply_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L789) | observation operator interpolation adjoint |
| subroutine | [obsop%] [test_adjoint](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L825) | test observation operator adjoints accuracy |
| subroutine | [obsop%] [test_accuracy](https://github.com/benjaminmenetrier/bump/tree/master/src/type_obsop.F90#L868) | test observation operator accuracy |
