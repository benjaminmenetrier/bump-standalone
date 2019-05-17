# Module type_nicas_blk

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [balldata_alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L234) | allocation |
| subroutine | [balldata_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L252) | release memory |
| subroutine | [balldata_pack](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L270) | pack data into balldata object |
| subroutine | [nicas_blk%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L309) | release memory (partial) |
| subroutine | [nicas_blk%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L421) | release memory (full) |
| subroutine | [nicas_blk%] [compute_parameters](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L475) | compute NICAS parameters |
| subroutine | [nicas_blk%] [compute_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L578) | compute NICAS sampling |
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L985) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1015) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1098) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1214) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1502) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1992) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2283) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2459) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2567) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2695) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2951) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3178) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3231) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3256) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3294) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3332) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3364) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3397) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3428) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3458) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3507) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3550) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3587) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3621) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3639) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3674) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3709) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3744) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3981) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L4086) | apply NICAS to diracs |
