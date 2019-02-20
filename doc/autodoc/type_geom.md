# Module type_geom

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [geom%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L125) | allocation |
| subroutine | [geom%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L154) | release memory |
| subroutine | [geom%] [setup_online](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L204) | setup online geometry |
| subroutine | [geom%] [find_sc0](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L388) | find subset Sc0 points |
| subroutine | [geom%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L494) | initialize geometry |
| subroutine | [geom%] [define_dirac](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L656) | define dirac indices |
| subroutine | [geom%] [define_distribution](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L712) | define local distribution |
| subroutine | [geom%] [reorder_points](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L940) | reorder Sc0 points based on lon/lat |
| subroutine | [geom%] [check_arc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L995) | check if an arc is crossing boundaries |
| subroutine | [geom%] [copy_c0a_to_mga](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1047) | copy from subset Sc0 to model grid, halo A |
| subroutine | [geom%] [copy_mga_to_c0a](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1071) | copy from model grid to subset Sc0, halo A |
| subroutine | [geom%] [compute_deltas](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1133) | compute deltas for LCT definition |
