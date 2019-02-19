# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl%] [newunit](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L112) | find a free unit |
| subroutine | [mpl%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L143) | initialize MPL object |
| subroutine | [mpl%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L181) | finalize MPI |
| subroutine | [mpl%] [init_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L197) | initialize listings |
| subroutine | [mpl%] [flush](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L296) | flush listings |
| subroutine | [mpl%] [close_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L347) | close listings |
| subroutine | [mpl%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L367) | clean MPI abort |
| subroutine | [mpl%] [warning](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L396) | print warning message |
| subroutine | [mpl%] [prog_init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L415) | initialize progression display |
| subroutine | [mpl%] [prog_print](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L441) | print progression display |
| subroutine | [mpl%] [prog_final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L475) | finalize progression display |
| subroutine | [mpl%] [ncerr](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L503) | handle NetCDF error |
| subroutine | [mpl%] [update_tag](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L521) | update MPL tag |
| subroutine | [mpl%] [bcast_string_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L542) | broadcast 1d string array |
| subroutine | [mpl%] [dot_prod_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L565) | global dot product over local fields, 1d |
| subroutine | [mpl%] [dot_prod_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L595) | global dot product over local fields, 2d |
| subroutine | [mpl%] [dot_prod_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L624) | global dot product over local fields, 3d |
| subroutine | [mpl%] [dot_prod_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L653) | global dot product over local fields, 4d |
| subroutine | [mpl%] [split](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L682) | split array over different MPI tasks |
| subroutine | [mpl%] [share_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L714) | share integer array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_integer_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L751) | share integer array over different MPI tasks, 2d |
| subroutine | [mpl%] [share_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L809) | share real array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_real_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L846) | share real array over different MPI tasks, 4d |
| subroutine | [mpl%] [share_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L914) | share logical array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_logical_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L971) | share logical array over different MPI tasks, 3d |
| subroutine | [mpl%] [share_logical_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1045) | share logical array over different MPI tasks, 4d |
| subroutine | [mpl%] [glb_to_loc_index](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1124) | communicate global index to local index |
| subroutine | [mpl%] [glb_to_loc_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1187) | global to local, 1d array |
| subroutine | [mpl%] [glb_to_loc_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1249) | global to local, 2d array |
| subroutine | [mpl%] [loc_to_glb_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1328) | local to global, 1d array |
| subroutine | [mpl%] [loc_to_glb_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1394) | local to global, 2d array |
| subroutine | [mpl%] [loc_to_glb_logical_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1477) | local to global for a logical, 2d array |
| subroutine | [mpl%] [write_integer](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1560) | write integer into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_integer_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1598) | write integer array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1650) | write real into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1683) | write real array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1731) | write logical into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1765) | write logical array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1819) | write string into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string_array](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1854) | write string array into a log file or into a NetCDF file |
