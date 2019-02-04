# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl%] [newunit](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L102) | find a free unit |
| subroutine | [mpl%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L132) | initialize MPL object |
| subroutine | [mpl%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L170) | finalize MPI |
| subroutine | [mpl%] [init_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L186) | initialize listings |
| subroutine | [mpl%] [flush](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L285) | flush listings |
| subroutine | [mpl%] [close_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L336) | close listings |
| subroutine | [mpl%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L356) | clean MPI abort |
| subroutine | [mpl%] [warning](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L383) | print warning message |
| subroutine | [mpl%] [prog_init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L401) | initialize progression display |
| subroutine | [mpl%] [prog_print](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L427) | print progression display |
| subroutine | [mpl%] [prog_final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L461) | finalize progression display |
| subroutine | [mpl%] [ncerr](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L489) | handle NetCDF error |
| subroutine | [mpl%] [update_tag](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L507) | update MPL tag |
| subroutine | [mpl%] [bcast_string_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L528) | broadcast 1d string array |
| subroutine | [mpl%] [dot_prod_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L551) | global dot product over local fields, 1d |
| subroutine | [mpl%] [dot_prod_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L581) | global dot product over local fields, 2d |
| subroutine | [mpl%] [dot_prod_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L610) | global dot product over local fields, 3d |
| subroutine | [mpl%] [dot_prod_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L639) | global dot product over local fields, 4d |
| subroutine | [mpl%] [split](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L668) | split array over different MPI tasks |
| subroutine | [mpl%] [share_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L700) | share integer array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_integer_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L737) | share integer array over different MPI tasks, 2d |
| subroutine | [mpl%] [share_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L795) | share real array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_real_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L832) | share real array over different MPI tasks, 4d |
| subroutine | [mpl%] [share_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L900) | share logical array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_logical_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L956) | share logical array over different MPI tasks, 3d |
| subroutine | [mpl%] [share_logical_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1029) | share logical array over different MPI tasks, 4d |
| subroutine | [mpl%] [glb_to_loc_index](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1107) | communicate global index to local index |
| subroutine | [mpl%] [glb_to_loc_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1170) | global to local, 1d array |
| subroutine | [mpl%] [glb_to_loc_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1231) | global to local, 2d array |
| subroutine | [mpl%] [loc_to_glb_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1309) | local to global, 1d array |
| subroutine | [mpl%] [loc_to_glb_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1374) | local to global, 2d array |
| subroutine | [mpl%] [loc_to_glb_logical_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1456) | local to global for a logical, 2d array |
