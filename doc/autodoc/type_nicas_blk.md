# Module type_nicas_blk

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [balldata_alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L223) | allocation |
| subroutine | [balldata_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L241) | release memory |
| subroutine | [balldata_pack](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L259) | pack data into balldata object |
| subroutine | [nicas_blk%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L298) | release memory (partial) |
| subroutine | [nicas_blk%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L398) | release memory (full) |
| subroutine | [nicas_blk%] [compute_parameters](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L453) | compute NICAS parameters |
| subroutine | [nicas_blk%] [compute_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L559) | compute NICAS sampling |
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L953) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L983) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1066) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1182) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1478) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1988) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2279) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2455) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2565) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2691) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2947) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3174) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3227) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3252) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3290) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3328) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3360) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3393) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3424) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3454) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3503) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3546) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3583) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3617) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3635) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3670) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3705) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3740) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3977) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L4082) | apply NICAS to diracs |
