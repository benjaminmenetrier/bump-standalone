# Module type_nicas_blk

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [balldata_alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L229) | allocation |
| subroutine | [balldata_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L247) | release memory |
| subroutine | [balldata_pack](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L265) | pack data into balldata object |
| subroutine | [nicas_blk%] [partial_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L304) | release memory (partial) |
| subroutine | [nicas_blk%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L416) | release memory (full) |
| subroutine | [nicas_blk%] [compute_parameters](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L469) | compute NICAS parameters |
| subroutine | [nicas_blk%] [compute_sampling](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L572) | compute NICAS sampling |
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L956) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L986) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1065) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1181) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1469) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1961) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2240) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2412) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2520) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2648) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2899) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3129) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3182) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3207) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3245) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3283) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3315) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3348) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3375) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3401) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3444) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3487) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3524) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3558) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3576) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3611) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3646) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3681) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3918) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L4023) | test full/square-root equivalence |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L4088) | apply NICAS to diracs |
