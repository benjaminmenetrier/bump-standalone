# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl%] [newunit](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L112) | find a free unit |
| subroutine | [mpl%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L143) | initialize MPL object |
| subroutine | [mpl%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L185) | finalize MPI |
| subroutine | [mpl%] [init_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L201) | initialize listings |
| subroutine | [mpl%] [flush](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L300) | flush listings |
| subroutine | [mpl%] [close_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L351) | close listings |
| subroutine | [mpl%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L371) | clean MPI abort |
| subroutine | [mpl%] [warning](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L400) | print warning message |
| subroutine | [mpl%] [prog_init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L419) | initialize progression display |
| subroutine | [mpl%] [prog_print](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L445) | print progression display |
| subroutine | [mpl%] [prog_final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L479) | finalize progression display |
| subroutine | [mpl%] [ncerr](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L507) | handle NetCDF error |
| subroutine | [mpl%] [update_tag](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L525) | update MPL tag |
| subroutine | [mpl%] [bcast_string_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L546) | broadcast 1d string array |
| subroutine | [mpl%] [dot_prod_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L569) | global dot product over local fields, 1d |
| subroutine | [mpl%] [dot_prod_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L599) | global dot product over local fields, 2d |
| subroutine | [mpl%] [dot_prod_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L628) | global dot product over local fields, 3d |
| subroutine | [mpl%] [dot_prod_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L657) | global dot product over local fields, 4d |
| subroutine | [mpl%] [split](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L686) | split array over different MPI tasks |
| subroutine | [mpl%] [share_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L718) | share integer array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_integer_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L755) | share integer array over different MPI tasks, 2d |
| subroutine | [mpl%] [share_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L813) | share real array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_real_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L850) | share real array over different MPI tasks, 4d |
| subroutine | [mpl%] [share_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L918) | share logical array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_logical_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L975) | share logical array over different MPI tasks, 3d |
| subroutine | [mpl%] [share_logical_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1049) | share logical array over different MPI tasks, 4d |
| subroutine | [mpl%] [glb_to_loc_index](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1128) | communicate global index to local index |
| subroutine | [mpl%] [glb_to_loc_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1191) | global to local, 1d array |
| subroutine | [mpl%] [glb_to_loc_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1253) | global to local, 2d array |
| subroutine | [mpl%] [loc_to_glb_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1332) | local to global, 1d array |
| subroutine | [mpl%] [loc_to_glb_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1398) | local to global, 2d array |
| subroutine | [mpl%] [loc_to_glb_logical_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1481) | local to global for a logical, 2d array |
| subroutine | [mpl%] [write_integer](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1564) | write integer into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_integer_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1602) | write integer array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1654) | write real into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1687) | write real array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1735) | write logical into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1769) | write logical array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1823) | write string into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1858) | write string array into a log file or into a NetCDF file |
