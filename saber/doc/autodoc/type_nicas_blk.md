# Module type_nicas_blk

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [balldata_alloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L266) | allocation |
| subroutine | [balldata_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L284) | release memory |
| subroutine | [balldata_pack](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L302) | pack data into balldata object |
| subroutine | [nicas_blk_partial_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L341) | release memory (partial) |
| subroutine | [nicas_blk_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L425) | release memory (full) |
| subroutine | [nicas_blk_read](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L491) | read |
| subroutine | [nicas_blk_write](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L649) | write |
| subroutine | [nicas_blk_write_grids](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L771) | write NICAS grids |
| subroutine | [nicas_blk_buffer_size](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L829) | buffer size |
| subroutine | [nicas_blk_serialize](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L919) | serialize |
| subroutine | [nicas_blk_deserialize](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L1121) | deserialize |
| subroutine | [nicas_blk_compute_parameters](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L1379) | compute NICAS parameters |
| subroutine | [nicas_blk_compute_parameters_horizontal_smoother](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L1522) | compute NICAS parameters for a horizontal smoother |
| subroutine | [nicas_blk_compute_sampling_c1](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L1597) | compute NICAS sampling, subset Sc1 |
| subroutine | [nicas_blk_compute_sampling_v](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L1751) | compute NICAS sampling, vertical dimension |
| subroutine | [nicas_blk_compute_mpi_a](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L1847) | compute NICAS MPI distribution, halos A |
| subroutine | [nicas_blk_compute_sampling_c2](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L1917) | compute NICAS sampling, subset Sc2 |
| subroutine | [nicas_blk_compute_mpi_ab](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L2045) | compute NICAS MPI distribution, halos A-B |
| subroutine | [nicas_blk_compute_interp_v](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L2309) | compute vertical interpolation |
| subroutine | [nicas_blk_compute_convol](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L2392) | compute convolution |
| subroutine | [nicas_blk_compute_convol_network](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L2816) | compute convolution with a network approach |
| subroutine | [nicas_blk_compute_convol_distance](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L3062) | compute convolution with a distance approach |
| subroutine | [nicas_blk_compute_convol_weights](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L3248) | compute convolution weights |
| subroutine | [nicas_blk_compute_mpi_c](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L3354) | compute NICAS MPI distribution, halo C |
| subroutine | [nicas_blk_compute_internal_normalization](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L3504) | compute internal normalization |
| subroutine | [nicas_blk_compute_normalization](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L3574) | compute normalization |
| subroutine | [nicas_blk_compute_grids](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L3823) | compute grids |
| subroutine | [nicas_blk_compute_adv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L3892) | compute advection |
| subroutine | [nicas_blk_apply](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4035) | apply NICAS method |
| subroutine | [nicas_blk_apply_from_sqrt](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4114) | apply NICAS method from its square-root formulation |
| subroutine | [nicas_blk_apply_sqrt](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4139) | apply NICAS method square-root |
| subroutine | [nicas_blk_apply_sqrt_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4183) | apply NICAS method square-root adjoint |
| subroutine | [nicas_blk_apply_interp](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4230) | apply interpolation |
| subroutine | [nicas_blk_apply_interp_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4259) | apply interpolation adjoint |
| subroutine | [nicas_blk_apply_interp_h](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4288) | apply horizontal interpolation |
| subroutine | [nicas_blk_apply_interp_h_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4319) | apply horizontal interpolation adjoint |
| subroutine | [nicas_blk_apply_interp_v](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4349) | apply vertical interpolation |
| subroutine | [nicas_blk_apply_interp_v_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4398) | apply vertical interpolation adjoint |
| subroutine | [nicas_blk_apply_interp_s](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4441) | apply subsampling interpolation |
| subroutine | [nicas_blk_apply_interp_s_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4478) | apply subsampling interpolation adjoint |
| subroutine | [nicas_blk_apply_convol](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4512) | apply convolution |
| subroutine | [nicas_blk_apply_adv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4546) | apply advection |
| subroutine | [nicas_blk_apply_adv_ad](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4581) | apply advection |
| subroutine | [nicas_blk_apply_adv_inv](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4616) | apply inverse advection |
| subroutine | [nicas_blk_test_adjoint](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4651) | test NICAS adjoint accuracy |
| subroutine | [nicas_blk_test_dirac](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_nicas_blk.F90#L4887) | apply NICAS to diracs |
