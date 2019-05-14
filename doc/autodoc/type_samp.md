# Module type_samp

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [samp%] [alloc_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L136) | allocation for mask |
| subroutine | [samp%] [alloc_other](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L155) | allocation for other variables |
| subroutine | [samp%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L192) | release memory |
| subroutine | [samp%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L246) | read |
| subroutine | [samp%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L475) | write |
| subroutine | [samp%] [setup_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L684) | setup sampling |
| subroutine | [samp%] [compute_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L982) | compute mask |
| subroutine | [samp%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1118) | compute zero-separation sampling |
| subroutine | [samp%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1258) | compute positive separation sampling |
| subroutine | [samp%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1389) | compute LCT sampling |
| subroutine | [samp%] [check_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1464) | check sampling mask |
| subroutine | [samp%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1539) | compute sampling MPI distribution, halo A |
| subroutine | [samp%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1607) | compute sampling MPI distribution, halos A-B |
| subroutine | [samp%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1775) | compute sampling MPI distribution, halo C |
| subroutine | [samp%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1955) | compute sampling MPI distribution, halo F |
| subroutine | [samp%] [diag_filter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L2029) | filter diagnostics |
| subroutine | [samp%] [diag_fill](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L2169) | fill diagnostics missing values |
