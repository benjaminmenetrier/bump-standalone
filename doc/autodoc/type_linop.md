# Module type_linop

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [linop%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L67) | linear operator allocation |
| subroutine | [linop%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L108) | linear operator deallocation |
| function | [linop%] [copy](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L127) | linear operator copy |
| subroutine | [linop%] [reorder](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L167) | reorder linear operator |
| subroutine | [linop%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L225) | read linear operator from a NetCDF file |
| subroutine | [linop%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L285) | write linear operator to a NetCDF file |
| subroutine | [linop%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L343) | apply linear operator |
| subroutine | [linop%] [apply_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L429) | apply linear operator, adjoint |
| subroutine | [linop%] [apply_sym](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L483) | apply linear operator, symmetric |
| subroutine | [linop%] [add_op](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L549) | add operation |
| subroutine | [linop%] [gather](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L594) | gather data from OpenMP threads |
| subroutine | [linop%] [interp_from_lat_lon](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L628) | compute horizontal interpolation from source latitude/longitude |
| subroutine | [linop%] [interp_from_mesh_kdtree](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L697) | compute horizontal interpolation from source mesh and kdtree |
| subroutine | [linop%] [interp_grid](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L916) | compute horizontal grid interpolation |
| subroutine | [interp_check_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L1042) | check mask boundaries for interpolations |
| subroutine | [linop%] [interp_missing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L1120) | deal with missing interpolation points |
