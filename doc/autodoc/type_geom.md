# Module type_geom

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [geom%] [alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L115) | allocation |
| subroutine | [geom%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L141) | release memory |
| subroutine | [geom%] [setup](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L190) | setup geometry |
| subroutine | [geom%] [find_sc0](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L519) | find subset Sc0 points |
| subroutine | [geom%] [define_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L625) | define dirac indices |
| subroutine | [geom%] [reorder_points](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L680) | reorder Sc0 points based on lon/lat |
| subroutine | [geom%] [check_arc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L734) | check if an arc is crossing boundaries |
| subroutine | [geom%] [copy_c0a_to_mga](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L787) | copy from subset Sc0 to model grid, halo A |
| subroutine | [geom%] [copy_mga_to_c0a](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L826) | copy from model grid to subset Sc0, halo A |
| subroutine | [geom%] [compute_deltas](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_geom.F90#L888) | compute deltas for LCT definition |
