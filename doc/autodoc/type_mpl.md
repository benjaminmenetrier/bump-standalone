# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl%] [newunit](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L101) | find a free unit |
| subroutine | [mpl%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L131) | initialize MPL object |
| subroutine | [mpl%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L169) | finalize MPI |
| subroutine | [mpl%] [init_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L185) | initialize listings |
| subroutine | [mpl%] [flush](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L293) | flush listings |
| subroutine | [mpl%] [close_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L344) | close listings |
| subroutine | [mpl%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L364) | clean MPI abort |
| subroutine | [mpl%] [warning](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L391) | print warning message |
| subroutine | [mpl%] [prog_init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L409) | initialize progression display |
| subroutine | [mpl%] [prog_print](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L435) | print progression display |
| subroutine | [mpl%] [prog_final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L469) | finalize progression display |
| subroutine | [mpl%] [ncerr](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L497) | handle NetCDF error |
| subroutine | [mpl%] [update_tag](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L515) | update MPL tag |
| subroutine | [mpl%] [bcast_string_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L536) | broadcast 1d string array |
| subroutine | [mpl%] [dot_prod_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L559) | global dot product over local fields, 1d |
| subroutine | [mpl%] [dot_prod_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L589) | global dot product over local fields, 2d |
| subroutine | [mpl%] [dot_prod_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L618) | global dot product over local fields, 3d |
| subroutine | [mpl%] [dot_prod_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L647) | global dot product over local fields, 4d |
| subroutine | [mpl%] [split](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L676) | split array over different MPI tasks |
| subroutine | [mpl%] [share_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L708) | share integer array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_integer_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L745) | share integer array over different MPI tasks, 2d |
| subroutine | [mpl%] [share_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L803) | share real array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_real_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L840) | share real array over different MPI tasks, 4d |
| subroutine | [mpl%] [share_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L908) | share logical array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_logical_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L964) | share logical array over different MPI tasks, 3d |
| subroutine | [mpl%] [glb_to_loc_index](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1037) | communicate global index to local index |
| subroutine | [mpl%] [glb_to_loc_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1100) | global to local, 1d array |
| subroutine | [mpl%] [glb_to_loc_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1161) | global to local, 2d array |
| subroutine | [mpl%] [loc_to_glb_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1239) | local to global, 1d array |
| subroutine | [mpl%] [loc_to_glb_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1304) | local to global, 2d array |
| subroutine | [mpl%] [loc_to_glb_logical_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L1386) | local to global for a logical, 2d array |
