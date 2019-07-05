# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl%] [newunit](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L115) | find a free unit |
| subroutine | [mpl%] [init](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L146) | initialize MPL object |
| subroutine | [mpl%] [final](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L201) | finalize MPI |
| subroutine | [mpl%] [flush](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L220) | flush listings |
| subroutine | [mpl%] [abort](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L335) | clean MPI abort |
| subroutine | [mpl%] [warning](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L363) | print warning message |
| subroutine | [mpl%] [prog_init](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L382) | initialize progression display |
| subroutine | [mpl%] [prog_print](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L415) | print progression display |
| subroutine | [mpl%] [prog_final](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L452) | finalize progression display |
| subroutine | [mpl%] [ncdimcheck](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L495) | check if NetCDF file dimension exists and has the right size |
| subroutine | [mpl%] [ncerr](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L563) | handle NetCDF error |
| subroutine | [mpl%] [update_tag](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L581) | update MPL tag |
| subroutine | [mpl%] [bcast_string_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L602) | broadcast 1d string array |
| subroutine | [mpl%] [dot_prod_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L625) | global dot product over local fields, 1d |
| subroutine | [mpl%] [dot_prod_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L656) | global dot product over local fields, 2d |
| subroutine | [mpl%] [dot_prod_3d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L687) | global dot product over local fields, 3d |
| subroutine | [mpl%] [dot_prod_4d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L718) | global dot product over local fields, 4d |
| subroutine | [mpl%] [split](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L749) | split array over different MPI tasks |
| subroutine | [mpl%] [share_integer_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L781) | share integer array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_integer_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L818) | share integer array over different MPI tasks, 2d |
| subroutine | [mpl%] [share_real_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L876) | share real array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_real_4d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L913) | share real array over different MPI tasks, 4d |
| subroutine | [mpl%] [share_logical_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L981) | share logical array over different MPI tasks, 1d |
| subroutine | [mpl%] [share_logical_3d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1038) | share logical array over different MPI tasks, 3d |
| subroutine | [mpl%] [share_logical_4d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1112) | share logical array over different MPI tasks, 4d |
| subroutine | [mpl%] [glb_to_loc_index](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1191) | communicate global index to local index |
| subroutine | [mpl%] [glb_to_loc_real_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1261) | global to local, 1d array |
| subroutine | [mpl%] [glb_to_loc_real_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1323) | global to local, 2d array |
| subroutine | [mpl%] [loc_to_glb_real_1d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1402) | local to global, 1d array |
| subroutine | [mpl%] [loc_to_glb_real_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1468) | local to global, 2d array |
| subroutine | [mpl%] [loc_to_glb_logical_2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1551) | local to global for a logical, 2d array |
| subroutine | [mpl%] [write_integer](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1634) | write integer into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_integer_array](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1672) | write integer array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1724) | write real into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_real_array](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1757) | write real array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1805) | write logical into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_logical_array](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1839) | write logical array into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1893) | write string into a log file or into a NetCDF file |
| subroutine | [mpl%] [write_string_array](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mpl.F90#L1928) | write string array into a log file or into a NetCDF file |
