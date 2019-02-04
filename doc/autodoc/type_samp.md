# Module type_samp

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [samp%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L130) | allocation |
| subroutine | [samp%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L168) | release memory |
| subroutine | [samp%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L219) | read |
| subroutine | [samp%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L466) | write |
| subroutine | [samp%] [setup_sampling](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L675) | setup sampling |
| subroutine | [samp%] [compute_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L943) | compute mask |
| subroutine | [samp%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1098) | compute zero-separation sampling |
| subroutine | [samp%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1173) | compute positive separation sampling |
| subroutine | [samp%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1304) | compute LCT sampling |
| subroutine | [samp%] [check_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1424) | check sampling mask |
| subroutine | [samp%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1499) | compute sampling MPI distribution, halo A |
| subroutine | [samp%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1567) | compute sampling MPI distribution, halos A-B |
| subroutine | [samp%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1726) | compute sampling MPI distribution, halo C |
| subroutine | [samp%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1903) | compute sampling MPI distribution, halo F |
| subroutine | [samp%] [diag_filter](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1977) | filter diagnostics |
| subroutine | [samp%] [diag_fill](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L2116) | fill diagnostics missing values |
