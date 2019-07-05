# Module type_samp

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [samp%] [alloc_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L126) | allocation for mask |
| subroutine | [samp%] [alloc_other](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L145) | allocation for other variables |
| subroutine | [samp%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L178) | release memory (partial) |
| subroutine | [samp%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L210) | release memory |
| subroutine | [samp%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L275) | read |
| subroutine | [samp%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L410) | write |
| subroutine | [samp%] [setup_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L551) | setup sampling |
| subroutine | [samp%] [compute_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L775) | compute mask |
| subroutine | [samp%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L911) | compute zero-separation sampling |
| subroutine | [samp%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1036) | compute positive separation sampling |
| subroutine | [samp%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1168) | compute LCT sampling |
| subroutine | [samp%] [check_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1231) | check sampling mask |
| subroutine | [samp%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1303) | compute sampling MPI distribution, halo A |
| subroutine | [samp%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1372) | compute sampling MPI distribution, halos A-B |
| subroutine | [samp%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1614) | compute sampling MPI distribution, halo C |
| subroutine | [samp%] [compute_mpi_d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1799) | compute sampling MPI distribution, halo D |
| subroutine | [samp%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1913) | compute sampling MPI distribution, halo F |
| subroutine | [samp%] [diag_filter](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L1985) | filter diagnostics |
| subroutine | [samp%] [diag_fill](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_samp.F90#L2118) | fill diagnostics missing values |
