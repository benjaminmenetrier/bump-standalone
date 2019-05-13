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
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1041) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1071) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1154) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1270) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1558) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2048) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2339) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2515) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2623) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2751) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3007) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3237) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3290) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3315) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3353) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3391) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3423) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3456) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3487) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3517) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3566) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3609) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3646) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3680) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3698) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3733) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3768) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3803) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L4040) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L4145) | apply NICAS to diracs |
