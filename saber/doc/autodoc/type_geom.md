# Module type_geom

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [geom_partial_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L164) | release memory (partial) |
| subroutine | [geom_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L230) | release memory |
| subroutine | [geom_setup](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L249) | setup geometry |
| subroutine | [geom_from_atlas](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L367) | set geometry from ATLAS fieldset |
| subroutine | [geom_setup_universe](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L515) | setup universe |
| subroutine | [geom_setup_c0](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L641) | setup subset Sc0 |
| subroutine | [geom_setup_tree](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1060) | setup tree |
| subroutine | [geom_setup_meshes](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1083) | setup meshes |
| subroutine | [geom_setup_independent_levels](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1184) | setup independent levels |
| subroutine | [geom_setup_mask_distance](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1231) | setup minimum distance to mask |
| subroutine | [geom_setup_mask_check](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1290) | setup mask checking tool |
| subroutine | [geom_index_from_lonlat](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1354) | get nearest neighbor index from longitude/latitude/level |
| subroutine | [geom_setup_dirac](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1432) | setup dirac indices |
| subroutine | [geom_check_arc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1492) | check if an arc is crossing boundaries |
| subroutine | [geom_copy_c0a_to_mga](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1546) | copy from subset Sc0 to model grid, halo A |
| subroutine | [geom_copy_mga_to_c0a_real](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1585) | copy from model grid to subset Sc0, halo A, real |
| subroutine | [geom_copy_mga_to_c0a_logical](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1619) | copy from model grid to subset Sc0, halo A, logical |
| subroutine | [geom_compute_deltas](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1660) | compute deltas for LCT definition |
| subroutine | [geom_rand_point](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1687) | select random valid point on the horizontal grid |
| function | [geom_mg_to_proc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1732) | conversion from global to processor on model grid |
| function | [geom_c0_to_c0a](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1754) | conversion from global to halo A on subset Sc0 |
| function | [geom_c0_to_proc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1780) | conversion from global to processor on subset Sc0 |
| function | [geom_c0_to_c0u](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_geom.F90#L1802) | conversion from global to universe on subset Sc0 |
