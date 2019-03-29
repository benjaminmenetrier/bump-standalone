# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl%] [newunit](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L114) | find a free unit |
| subroutine | [mpl%] [init](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L145) | initialize MPL object |
| subroutine | [mpl%] [final](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L200) | finalize MPI |
| subroutine | [mpl%] [flush](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L219) | flush listings |
| subroutine | [mpl%] [abort](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L334) | clean MPI abort |
| subroutine | [mpl%] [warning](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L363) | print warning message |
| subroutine | [mpl%] [prog_init](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L382) | initialize progression display |
| subroutine | [mpl%] [prog_print](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L408) | print progression display |
| subroutine | [mpl%] [prog_final](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L445) | finalize progression display |
| subroutine | [mpl%] [ncerr](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L473) | handle NetCDF error |
| subroutine | [mpl%] [update_tag](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L491) | update MPL tag |
| subroutine | [mpl%] [bcast_string_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L512) | broadcast 1d string array |
| subroutine | [mpl%] [dot_prod_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L535) | global dot product over local fields, 1d |
| subroutine | [mpl%] [dot_prod_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L566) | global dot product over local fields, 2d |
| subroutine | [mpl%] [dot_prod_3d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L597) | global dot product over local fields, 3d |
| subroutine | [mpl%] [dot_prod_4d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L628) | global dot product over local fields, 4d |
| subroutine | [mpl%] [split](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L659) | split array over different MPI tasks |
| subroutine | [mpl%] [share_integer_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L691) | share integer array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_integer_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L728) | share integer array over different MPI tasks, 2d |
| subroutine | [mpl%] [share_real_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L786) | share real array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_real_4d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L823) | share real array over different MPI tasks, 4d |
| subroutine | [mpl%] [share_logical_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L891) | share logical array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_logical_3d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L948) | share logical array over different MPI tasks, 3d |
| subroutine | [mpl%] [share_logical_4d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1022) | share logical array over different MPI tasks, 4d |
| subroutine | [mpl%] [glb_to_loc_index](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1101) | communicate global index to local index |
| subroutine | [mpl%] [glb_to_loc_real_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1164) | global to local, 1d array |
| subroutine | [mpl%] [glb_to_loc_real_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1226) | global to local, 2d array |
| subroutine | [mpl%] [loc_to_glb_real_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1305) | local to global, 1d array |
| subroutine | [mpl%] [loc_to_glb_real_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1371) | local to global, 2d array |
| subroutine | [mpl%] [loc_to_glb_logical_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1454) | local to global for a logical, 2d array |
| subroutine | [mpl%] [write_integer](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1537) | write integer into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_integer_array](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1575) | write integer array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1627) | write real into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real_array](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1660) | write real array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1708) | write logical into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical_array](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1742) | write logical array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1796) | write string into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string_array](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1831) | write string array into a log file or into a NetCDF file |
