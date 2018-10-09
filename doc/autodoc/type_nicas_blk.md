# Module type_nicas_blk

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [balldata_alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L231) | ball data allocation |
| subroutine | [balldata_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L249) | ball data deallocation |
| subroutine | [balldata_pack](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L267) | pack data into balldata object |
| subroutine | [nicas_blk%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L305) | NICAS block data deallocation |
| subroutine | [nicas_blk%] [compute_parameters](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L454) | compute NICAS parameters |
| subroutine | [nicas_blk%] [compute_sampling](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L542) | compute NICAS sampling |
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L868) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L898) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L977) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1073) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1359) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1859) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2100) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2245) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2354) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2477) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2715) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2943) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2996) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3021) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3059) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3097) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3129) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3162) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3189) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3215) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3258) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3301) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3338) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3372) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3390) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3425) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3460) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3495) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3701) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3804) | test full/square-root equivalence |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3869) | apply NICAS to diracs |
