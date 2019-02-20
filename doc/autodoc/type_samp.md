# Module type_samp

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [samp%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L131) | allocation |
| subroutine | [samp%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L171) | release memory |
| subroutine | [samp%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L224) | read |
| subroutine | [samp%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L471) | write |
| subroutine | [samp%] [setup_sampling](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L680) | setup sampling |
| subroutine | [samp%] [compute_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L953) | compute mask |
| subroutine | [samp%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1108) | compute zero-separation sampling |
| subroutine | [samp%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1183) | compute positive separation sampling |
| subroutine | [samp%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1314) | compute LCT sampling |
| subroutine | [samp%] [check_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1389) | check sampling mask |
| subroutine | [samp%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1464) | compute sampling MPI distribution, halo A |
| subroutine | [samp%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1532) | compute sampling MPI distribution, halos A-B |
| subroutine | [samp%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1700) | compute sampling MPI distribution, halo C |
| subroutine | [samp%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1880) | compute sampling MPI distribution, halo F |
| subroutine | [samp%] [diag_filter](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L1954) | filter diagnostics |
| subroutine | [samp%] [diag_fill](https://github.com/benjaminmenetrier/bump/tree/master/src/type_samp.F90#L2094) | fill diagnostics missing values |
