# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl%] [newunit](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L112) | find a free unit |
| subroutine | [mpl%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L143) | initialize MPL object |
| subroutine | [mpl%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L185) | finalize MPI |
| subroutine | [mpl%] [init_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L201) | initialize listings |
| subroutine | [mpl%] [flush](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L294) | flush listings |
| subroutine | [mpl%] [close_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L345) | close listings |
| subroutine | [mpl%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L366) | clean MPI abort |
| subroutine | [mpl%] [warning](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L395) | print warning message |
| subroutine | [mpl%] [prog_init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L414) | initialize progression display |
| subroutine | [mpl%] [prog_print](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L440) | print progression display |
| subroutine | [mpl%] [prog_final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L477) | finalize progression display |
| subroutine | [mpl%] [ncerr](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L505) | handle NetCDF error |
| subroutine | [mpl%] [update_tag](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L523) | update MPL tag |
| subroutine | [mpl%] [bcast_string_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L544) | broadcast 1d string array |
| subroutine | [mpl%] [dot_prod_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L567) | global dot product over local fields, 1d |
| subroutine | [mpl%] [dot_prod_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L597) | global dot product over local fields, 2d |
| subroutine | [mpl%] [dot_prod_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L626) | global dot product over local fields, 3d |
| subroutine | [mpl%] [dot_prod_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L655) | global dot product over local fields, 4d |
| subroutine | [mpl%] [split](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L684) | split array over different MPI tasks |
| subroutine | [mpl%] [share_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L716) | share integer array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_integer_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L753) | share integer array over different MPI tasks, 2d |
| subroutine | [mpl%] [share_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L811) | share real array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_real_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L848) | share real array over different MPI tasks, 4d |
| subroutine | [mpl%] [share_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L916) | share logical array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_logical_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L973) | share logical array over different MPI tasks, 3d |
| subroutine | [mpl%] [share_logical_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1047) | share logical array over different MPI tasks, 4d |
| subroutine | [mpl%] [glb_to_loc_index](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1126) | communicate global index to local index |
| subroutine | [mpl%] [glb_to_loc_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1189) | global to local, 1d array |
| subroutine | [mpl%] [glb_to_loc_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1251) | global to local, 2d array |
| subroutine | [mpl%] [loc_to_glb_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1330) | local to global, 1d array |
| subroutine | [mpl%] [loc_to_glb_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1396) | local to global, 2d array |
| subroutine | [mpl%] [loc_to_glb_logical_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1479) | local to global for a logical, 2d array |
| subroutine | [mpl%] [write_integer](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1562) | write integer into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_integer_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1600) | write integer array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1652) | write real into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1685) | write real array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1733) | write logical into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1767) | write logical array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1821) | write string into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1856) | write string array into a log file or into a NetCDF file |
