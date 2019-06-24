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
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L980) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1010) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1093) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1209) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1497) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2007) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2298) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2474) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2584) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2712) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2968) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3195) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3248) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3273) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3311) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3349) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3381) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3414) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3445) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3475) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3524) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3567) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3604) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3638) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3656) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3691) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3726) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3761) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3998) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L4103) | apply NICAS to diracs |
