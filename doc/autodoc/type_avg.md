# Module type_avg

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [avg%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L51) | allocation |
| subroutine | [avg%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L86) | release memory |
| function | [avg%] [copy](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L112) | copy |
| subroutine | [avg%] [gather](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L146) | gather averaged statistics data |
| subroutine | [avg%] [normalize](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L283) | normalize averaged statistics data |
| subroutine | [avg%] [gather_lr](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L349) | gather low-resolution averaged statistics data |
| subroutine | [avg%] [normalize_lr](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L427) | normalize low-resolution averaged statistics data |
| subroutine | [avg%] [var_filter](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L481) | filter variance |
| subroutine | [avg%] [compute](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L606) | compute averaged statistics |
| subroutine | [avg%] [compute_hyb](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L683) | compute hybrid averaged statistics |
| function | [avg%] [copy_wgt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L767) | averaged statistics data copy for weight definition |
| subroutine | [avg%] [compute_bwavg](https://github.com/benjaminmenetrier/bump/tree/master/src/type_avg.F90#L800) | compute block-averaged statistics |
