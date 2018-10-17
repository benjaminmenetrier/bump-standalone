# Module type_nicas_blk

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [balldata_alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L230) | ball data allocation |
| subroutine | [balldata_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L248) | ball data deallocation |
| subroutine | [balldata_pack](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L266) | pack data into balldata object |
| subroutine | [nicas_blk%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L304) | NICAS block data deallocation |
| subroutine | [nicas_blk%] [compute_parameters](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L453) | compute NICAS parameters |
| subroutine | [nicas_blk%] [compute_sampling](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L541) | compute NICAS sampling |
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L867) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L897) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L976) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1092) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1378) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1878) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2119) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2264) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2373) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2496) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2734) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2962) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3015) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3040) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3078) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3116) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3148) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3181) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3208) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3234) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3277) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3320) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3357) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3391) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3409) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3444) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3479) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3514) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3720) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3823) | test full/square-root equivalence |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3888) | apply NICAS to diracs |
