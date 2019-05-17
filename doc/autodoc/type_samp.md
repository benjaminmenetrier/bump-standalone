# Module type_samp

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [samp%] [alloc_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L132) | allocation for mask |
| subroutine | [samp%] [alloc_other](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L151) | allocation for other variables |
| subroutine | [samp%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L188) | release memory |
| subroutine | [samp%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L242) | read |
| subroutine | [samp%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L471) | write |
| subroutine | [samp%] [setup_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L680) | setup sampling |
| subroutine | [samp%] [compute_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L979) | compute mask |
| subroutine | [samp%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1114) | compute zero-separation sampling |
| subroutine | [samp%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1231) | compute positive separation sampling |
| subroutine | [samp%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1362) | compute LCT sampling |
| subroutine | [samp%] [check_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1437) | check sampling mask |
| subroutine | [samp%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1512) | compute sampling MPI distribution, halo A |
| subroutine | [samp%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1580) | compute sampling MPI distribution, halos A-B |
| subroutine | [samp%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1748) | compute sampling MPI distribution, halo C |
| subroutine | [samp%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1928) | compute sampling MPI distribution, halo F |
| subroutine | [samp%] [diag_filter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L2002) | filter diagnostics |
| subroutine | [samp%] [diag_fill](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L2142) | fill diagnostics missing values |
