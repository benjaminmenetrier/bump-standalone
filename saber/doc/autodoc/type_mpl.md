# Module type_mpl

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mpl_newunit](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L118) | find a free unit |
| subroutine | [mpl_init](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L149) | initialize MPL object |
| subroutine | [mpl_final](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L205) | finalize MPI |
| subroutine | [mpl_flush](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L221) | flush listings |
| subroutine | [mpl_abort](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L336) | clean MPI abort |
| subroutine | [mpl_warning](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L358) | print warning message |
| subroutine | [mpl_update_tag](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L378) | update MPI tag |
| subroutine | [mpl_broadcast_string_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L399) | broadcast 1d string array |
| subroutine | [mpl_dot_prod_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L422) | global dot product over local fields, 1d |
| subroutine | [mpl_dot_prod_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L453) | global dot product over local fields, 2d |
| subroutine | [mpl_dot_prod_3d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L484) | global dot product over local fields, 3d |
| subroutine | [mpl_dot_prod_4d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L515) | global dot product over local fields, 4d |
| subroutine | [mpl_glb_to_loc_index](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L546) | communicate global index to local index |
| subroutine | [mpl_glb_to_loc_integer_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L635) | global to local, 1d array |
| subroutine | [mpl_glb_to_loc_integer_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L712) | global to local, 2d array |
| subroutine | [mpl_glb_to_loc_real_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L822) | global to local, 1d array |
| subroutine | [mpl_glb_to_loc_real_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L900) | global to local, 2d array |
| subroutine | [mpl_glb_to_loc_logical_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1011) | global to local, 1d array |
| subroutine | [mpl_glb_to_loc_logical_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1089) | global to local, 2d array |
| subroutine | [mpl_loc_to_glb_integer_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1200) | local to global, 1d array |
| subroutine | [mpl_loc_to_glb_integer_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1286) | local to global, 2d array |
| subroutine | [mpl_loc_to_glb_real_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1387) | local to global, 1d array |
| subroutine | [mpl_loc_to_glb_real_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1474) | local to global, 2d array |
| subroutine | [mpl_loc_to_glb_logical_1d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1576) | local to global, 1d array |
| subroutine | [mpl_loc_to_glb_logical_2d](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1663) | local to global for a logical, 2d array |
| subroutine | [mpl_prog_init](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1765) | initialize progression display |
| subroutine | [mpl_prog_print](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1798) | print progression display |
| subroutine | [mpl_prog_final](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1835) | finalize progression display |
| function | [mpl_nc_file_create_or_open](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1878) | create or open NetCDF file |
| function | [mpl_nc_group_define_or_get](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1921) | define or get group |
| function | [mpl_nc_dim_define_or_get](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1949) | define or get (and check) NetCDF dimension |
| function | [mpl_nc_dim_inquire](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L1986) | inquire NetCDF file dimension size |
| subroutine | [mpl_nc_dim_check](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2016) | check if NetCDF file dimension exists and has the right size |
| function | [mpl_nc_var_define_or_get](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2045) | define or get NetCDF variable |
| subroutine | [mpl_ncerr](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2090) | handle NetCDF error |
| subroutine | [mpl_write_integer](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2108) | write integer into a log file or into a NetCDF file |
| subroutine | [mpl_write_integer_array](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2147) | write integer array into a log file or into a NetCDF file |
| subroutine | [mpl_write_real](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2199) | write real into a log file or into a NetCDF file |
| subroutine | [mpl_write_real_array](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2233) | write real array into a log file or into a NetCDF file |
| subroutine | [mpl_write_logical](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2281) | write logical into a log file or into a NetCDF file |
| subroutine | [mpl_write_logical_array](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2316) | write logical array into a log file or into a NetCDF file |
| subroutine | [mpl_write_string](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2370) | write string into a log file or into a NetCDF file |
| subroutine | [mpl_write_string_array](https://github.com/JCSDA/saber/tree/develop/src/saber/util/type_mpl.F90#L2406) | write string array into a log file or into a NetCDF file |
