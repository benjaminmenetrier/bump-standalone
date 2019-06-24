# Module type_samp

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [samp%] [alloc_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L141) | allocation for mask |
| subroutine | [samp%] [alloc_other](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L160) | allocation for other variables |
| subroutine | [samp%] [dealloc TODO: update that](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L194) | release memory |
| subroutine | [samp%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L249) | read |
| subroutine | [samp%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L384) | write |
| subroutine | [samp%] [setup_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L525) | setup sampling |
| subroutine | [samp%] [compute_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L758) | compute mask |
| subroutine | [samp%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L894) | compute zero-separation sampling |
| subroutine | [samp%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1019) | compute positive separation sampling |
| subroutine | [samp%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1151) | compute LCT sampling |
| subroutine | [samp%] [check_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1214) | check sampling mask |
| subroutine | [samp%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1286) | compute sampling MPI distribution, halo A |
| subroutine | [samp%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1362) | compute sampling MPI distribution, halos A-B |
| subroutine | [samp%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1609) | compute sampling MPI distribution, halo C |
| subroutine | [samp%] [compute_mpi_d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1789) | compute sampling MPI distribution, halo D |
| subroutine | [samp%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1893) | compute sampling MPI distribution, halo F |
| subroutine | [samp%] [diag_filter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1962) | filter diagnostics |
| subroutine | [samp%] [diag_fill](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L2095) | fill diagnostics missing values |
