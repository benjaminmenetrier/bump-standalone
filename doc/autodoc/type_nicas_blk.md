# Module type_nicas_blk

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [balldata_alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L233) | allocation |
| subroutine | [balldata_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L251) | release memory |
| subroutine | [balldata_pack](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L269) | pack data into balldata object |
| subroutine | [nicas_blk%] [partial_dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L308) | release memory (partial) |
| subroutine | [nicas_blk%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L421) | release memory (full) |
| subroutine | [nicas_blk%] [compute_parameters](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L474) | compute NICAS parameters |
| subroutine | [nicas_blk%] [compute_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L577) | compute NICAS sampling |
| subroutine | [nicas_blk%] [compute_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1040) | compute basic horizontal interpolation |
| subroutine | [nicas_blk%] [compute_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1070) | compute vertical interpolation |
| subroutine | [nicas_blk%] [compute_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1153) | compute horizontal subsampling interpolation |
| subroutine | [nicas_blk%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1269) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk%] [compute_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L1557) | compute convolution |
| subroutine | [nicas_blk%] [compute_convol_network](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2047) | compute convolution with a network approach |
| subroutine | [nicas_blk%] [compute_convol_distance](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2338) | compute convolution with a distance approach |
| subroutine | [nicas_blk%] [compute_convol_weights](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2514) | compute convolution weights |
| subroutine | [nicas_blk%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2622) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk%] [compute_normalization](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L2750) | compute normalization |
| subroutine | [nicas_blk%] [compute_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3006) | compute advection |
| subroutine | [nicas_blk%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3236) | apply NICAS method |
| subroutine | [nicas_blk%] [apply_from_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3289) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk%] [apply_sqrt](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3314) | apply NICAS method square-root |
| subroutine | [nicas_blk%] [apply_sqrt_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3352) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk%] [apply_interp](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3390) | apply interpolation |
| subroutine | [nicas_blk%] [apply_interp_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3422) | apply interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3455) | apply horizontal interpolation |
| subroutine | [nicas_blk%] [apply_interp_h_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3486) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_v](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3516) | apply vertical interpolation |
| subroutine | [nicas_blk%] [apply_interp_v_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3565) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk%] [apply_interp_s](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3608) | apply subsampling interpolation |
| subroutine | [nicas_blk%] [apply_interp_s_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3645) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk%] [apply_convol](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3679) | apply convolution |
| subroutine | [nicas_blk%] [apply_adv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3697) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3732) | apply advection |
| subroutine | [nicas_blk%] [apply_adv_inv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3767) | apply inverse advection |
| subroutine | [nicas_blk%] [test_adjoint](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L3802) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk%] [test_pos_def](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L4039) | test positive_definiteness |
| subroutine | [nicas_blk%] [test_dirac](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_nicas_blk.F90#L4144) | apply NICAS to diracs |
