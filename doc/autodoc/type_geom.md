# Module type_geom

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [geom%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L114) | geometry allocation |
| subroutine | [geom%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L159) | geometry deallocation |
| subroutine | [geom%] [setup_online](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L209) | setup online geometry |
| subroutine | [geom%] [find_redundant](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L415) | find redundant model grid points |
| subroutine | [geom%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L497) | initialize geometry |
| subroutine | [geom%] [define_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L583) | define mask |
| subroutine | [geom%] [compute_area](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L652) | compute domain area |
| subroutine | [geom%] [compute_mask_boundaries](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L684) | compute domain area |
| subroutine | [geom%] [define_distribution](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L756) | define local distribution |
| subroutine | [geom%] [check_arc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1019) | check if an arc is crossing boundaries |
| subroutine | [geom%] [copy_c0a_to_mga](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1070) | copy from subset Sc0 to model grid, halo A |
| subroutine | [geom%] [copy_mga_to_c0a](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1149) | copy from model grid to subset Sc0, halo A |
| subroutine | [geom%] [compute_deltas](https://github.com/benjaminmenetrier/bump/tree/master/src/type_geom.F90#L1179) | compute deltas for LCT definition |
