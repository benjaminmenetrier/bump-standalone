# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl_newunit](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L119) | find a free unit |
| subroutine | [mpl_init](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L150) | initialize MPL object |
| subroutine | [mpl_final](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L209) | finalize MPI |
| subroutine | [mpl_flush](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L225) | flush listings |
| subroutine | [mpl_abort](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L340) | clean MPI abort |
| subroutine | [mpl_warning](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L362) | print warning message |
| subroutine | [mpl_update_tag](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L381) | update MPI tag |
| subroutine | [mpl_broadcast_string_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L402) | broadcast 1d string array |
| subroutine | [mpl_dot_prod_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L425) | global dot product over local fields, 1d |
| subroutine | [mpl_dot_prod_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L456) | global dot product over local fields, 2d |
| subroutine | [mpl_dot_prod_3d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L487) | global dot product over local fields, 3d |
| subroutine | [mpl_dot_prod_4d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L518) | global dot product over local fields, 4d |
| subroutine | [mpl_glb_to_loc_index](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L549) | communicate global index to local index |
| subroutine | [mpl_glb_to_loc_integer_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L638) | global to local, 1d array |
| subroutine | [mpl_glb_to_loc_integer_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L715) | global to local, 2d array |
| subroutine | [mpl_glb_to_loc_real_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L825) | global to local, 1d array |
| subroutine | [mpl_glb_to_loc_real_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L903) | global to local, 2d array |
| subroutine | [mpl_glb_to_loc_logical_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1014) | global to local, 1d array |
| subroutine | [mpl_glb_to_loc_logical_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1092) | global to local, 2d array |
| subroutine | [mpl_loc_to_glb_integer_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1203) | local to global, 1d array |
| subroutine | [mpl_loc_to_glb_integer_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1289) | local to global, 2d array |
| subroutine | [mpl_loc_to_glb_real_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1390) | local to global, 1d array |
| subroutine | [mpl_loc_to_glb_real_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1477) | local to global, 2d array |
| subroutine | [mpl_loc_to_glb_logical_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1579) | local to global, 1d array |
| subroutine | [mpl_loc_to_glb_logical_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1666) | local to global for a logical, 2d array |
| subroutine | [mpl_prog_init](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1768) | initialize progression display |
| subroutine | [mpl_prog_print](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1801) | print progression display |
| subroutine | [mpl_prog_final](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1838) | finalize progression display |
| function | [mpl_nc_file_create_or_open](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1881) | create or open NetCDF file |
| function | [mpl_nc_group_define_or_get](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1928) | define or get group |
| function | [mpl_nc_dim_define_or_get](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1956) | define or get (and check) NetCDF dimension |
| function | [mpl_nc_dim_inquire](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1993) | inquire NetCDF file dimension size |
| subroutine | [mpl_nc_dim_check](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2023) | check if NetCDF file dimension exists and has the right size |
| function | [mpl_nc_var_define_or_get](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2052) | define or get NetCDF variable |
| subroutine | [mpl_ncerr](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2097) | handle NetCDF error |
| subroutine | [mpl_write_integer](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2115) | write integer into a log file or into a NetCDF file |
| subroutine | [mpl_write_integer_array](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2154) | write integer array into a log file or into a NetCDF file |
| subroutine | [mpl_write_real](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2206) | write real into a log file or into a NetCDF file |
| subroutine | [mpl_write_real_array](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2240) | write real array into a log file or into a NetCDF file |
| subroutine | [mpl_write_logical](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2288) | write logical into a log file or into a NetCDF file |
| subroutine | [mpl_write_logical_array](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2323) | write logical array into a log file or into a NetCDF file |
| subroutine | [mpl_write_string](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2377) | write string into a log file or into a NetCDF file |
| subroutine | [mpl_write_string_array](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2413) | write string array into a log file or into a NetCDF file |
