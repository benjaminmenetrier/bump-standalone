# Module type_geom

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [geom%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L128) | geometry allocation |
| subroutine | [geom%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L173) | geometry deallocation |
| subroutine | [geom%] [setup_online](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L223) | setup online geometry |
| subroutine | [geom%] [find_sc0](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L426) | find subset Sc0 points |
| subroutine | [geom%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L629) | initialize geometry |
| subroutine | [geom%] [define_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L715) | define mask |
| subroutine | [geom%] [compute_area](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L784) | compute domain area |
| subroutine | [geom%] [define_dirac](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L816) | define dirac indices |
| subroutine | [geom%] [define_distribution](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L876) | define local distribution |
| subroutine | [geom%] [check_arc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1159) | check if an arc is crossing boundaries |
| subroutine | [geom%] [copy_c0a_to_mga](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1210) | copy from subset Sc0 to model grid, halo A |
| subroutine | [geom%] [copy_mga_to_c0a](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1289) | copy from model grid to subset Sc0, halo A |
| subroutine | [geom%] [compute_deltas](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1319) | compute deltas for LCT definition |
