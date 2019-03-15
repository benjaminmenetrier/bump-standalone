# Module type_samp

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [samp%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L136) | allocation |
| subroutine | [samp%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L176) | release memory |
| subroutine | [samp%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L230) | read |
| subroutine | [samp%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L477) | write |
| subroutine | [samp%] [setup_sampling](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L686) | setup sampling |
| subroutine | [samp%] [compute_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L958) | compute mask |
| subroutine | [samp%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1113) | compute zero-separation sampling |
| subroutine | [samp%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1246) | compute positive separation sampling |
| subroutine | [samp%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1377) | compute LCT sampling |
| subroutine | [samp%] [check_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1452) | check sampling mask |
| subroutine | [samp%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1527) | compute sampling MPI distribution, halo A |
| subroutine | [samp%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1595) | compute sampling MPI distribution, halos A-B |
| subroutine | [samp%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1763) | compute sampling MPI distribution, halo C |
| subroutine | [samp%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1943) | compute sampling MPI distribution, halo F |
| subroutine | [samp%] [diag_filter](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L2017) | filter diagnostics |
| subroutine | [samp%] [diag_fill](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L2157) | fill diagnostics missing values |
