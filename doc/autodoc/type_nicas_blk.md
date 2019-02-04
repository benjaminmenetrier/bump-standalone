# Module type_nicas_blk

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [balldata_alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L230) | allocation |
| subroutine | [balldata_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L248) | release memory |
| subroutine | [balldata_pack](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L266) | pack data into balldata object |
| subroutine | [nicas_blk%] [partial_dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L305) | release memory (partial) |
| subroutine | [nicas_blk%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L417) | release memory (full) |
| subroutine | [nicas_blk%] [compute_parameters](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L470) | compute NICAS parameters |
| subroutine | [nicas_blk%] [compute_sampling](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L573) | compute NICAS sampling |
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L957) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L987) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1066) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1182) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1469) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L1961) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2245) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2409) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2517) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2644) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L2895) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3125) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3178) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3203) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3241) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3279) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3311) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3344) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3371) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3397) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3440) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3483) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3520) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3554) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3572) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3607) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3642) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3677) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L3914) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_sqrt](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L4019) | test full/square-root equivalence |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump/tree/master/src/type_nicas_blk.F90#L4084) | apply NICAS to diracs |
