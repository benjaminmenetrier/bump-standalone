# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl%] [newunit](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L86) | find a free unit |
| subroutine | [mpl%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L116) | initialize MPL object |
| subroutine | [mpl%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L154) | finalize MPI |
| subroutine | [mpl%] [init_listing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L170) | initialize listings |
| subroutine | [mpl%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L259) | clean MPI abort |
| subroutine | [mpl%] [warning](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L287) | print warning message |
| subroutine | [prog_init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L305) | initialize progression display |
| subroutine | [mpl%] [prog_print](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L332) | print progression display |
| subroutine | [mpl%] [ncerr](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L362) | handle NetCDF error |
| subroutine | [mpl%] [update_tag](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L380) | update MPL tag |
| subroutine | [mpl%] [bcast_string_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L401) | broadcast 1d string array |
| subroutine | [mpl%] [dot_prod_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L424) | global dot product over local fields, 1d |
| subroutine | [mpl%] [dot_prod_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L454) | global dot product over local fields, 2d |
| subroutine | [mpl%] [dot_prod_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L483) | global dot product over local fields, 3d |
| subroutine | [mpl%] [dot_prod_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L512) | global dot product over local fields, 4d |
| subroutine | [mpl%] [split](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L541) | split array over different MPI tasks |
| subroutine | [mpl%] [glb_to_loc_index](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L576) | communicate global index to local index |
| subroutine | [mpl%] [glb_to_loc_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L639) | global to local, 1d array |
| subroutine | [mpl%] [glb_to_loc_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L700) | global to local, 2d array |
| subroutine | [mpl%] [loc_to_glb_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L774) | local to global, 1d array |
| subroutine | [mpl%] [loc_to_glb_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mpl.F90#L839) | local to global, 2d array |
