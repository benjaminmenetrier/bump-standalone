# Module type_hdata

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [hdata%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L129) | HDIAG data allocation |
| subroutine | [hdata%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L185) | HDIAG data deallocation |
| subroutine | [hdata%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L233) | read HDIAG data |
| subroutine | [hdata%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L463) | write HDIAG data |
| subroutine | [hdata%] [setup_sampling](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L707) | setup sampling |
| subroutine | [hdata%] [compute_sampling_zs](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L932) | compute zero-separation sampling |
| subroutine | [hdata%] [compute_sampling_ps](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L998) | compute positive separation sampling |
| subroutine | [hdata%] [compute_sampling_lct](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L1131) | compute LCT sampling |
| subroutine | [hdata%] [compute_sampling_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L1328) | compute sampling mask |
| subroutine | [hdata%] [compute_mpi_a](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L1375) | compute HDIAG MPI distribution, halo A |
| subroutine | [hdata%] [compute_mpi_ab](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L1438) | compute HDIAG MPI distribution, halos A-B |
| subroutine | [hdata%] [compute_mpi_d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L1591) | compute HDIAG MPI distribution, halo D |
| subroutine | [hdata%] [compute_mpi_c](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L1662) | compute HDIAG MPI distribution, halo C |
| subroutine | [hdata%] [compute_mpi_f](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L1831) | compute HDIAG MPI distribution, halo F |
| subroutine | [hdata%] [diag_filter](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L1905) | filter diagnostics |
| subroutine | [hdata%] [diag_fill](https://github.com/benjaminmenetrier/bump/tree/master/src/type_hdata.F90#L2022) | fill diagnostics missing values |
