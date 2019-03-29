# Module type_samp

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [samp%] [alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L135) | allocation |
| subroutine | [samp%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L175) | release memory |
| subroutine | [samp%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L229) | read |
| subroutine | [samp%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L480) | write |
| subroutine | [samp%] [setup_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L689) | setup sampling |
| subroutine | [samp%] [compute_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L962) | compute mask |
| subroutine | [samp%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1087) | compute zero-separation sampling |
| subroutine | [samp%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1225) | compute positive separation sampling |
| subroutine | [samp%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1356) | compute LCT sampling |
| subroutine | [samp%] [check_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1431) | check sampling mask |
| subroutine | [samp%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1506) | compute sampling MPI distribution, halo A |
| subroutine | [samp%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1574) | compute sampling MPI distribution, halos A-B |
| subroutine | [samp%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1742) | compute sampling MPI distribution, halo C |
| subroutine | [samp%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1922) | compute sampling MPI distribution, halo F |
| subroutine | [samp%] [diag_filter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1996) | filter diagnostics |
| subroutine | [samp%] [diag_fill](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L2136) | fill diagnostics missing values |
