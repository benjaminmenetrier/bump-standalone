# Module type_linop

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [linop%] [alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L64) | allocation |
| subroutine | [linop%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L94) | release memory |
| subroutine | [linop%] [copy](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L113) | copy |
| subroutine | [linop%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L155) | read |
| subroutine | [linop%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L211) | write |
| subroutine | [linop%] [reorder](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L269) | reorder linear operator |
| subroutine | [linop%] [apply](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L328) | apply linear operator |
| subroutine | [linop%] [apply_ad](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L418) | apply linear operator, adjoint |
| subroutine | [linop%] [apply_sym](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L474) | apply linear operator, symmetric |
| subroutine | [linop%] [add_op](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L541) | add operation |
| subroutine | [linop%] [gather](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L586) | gather data from OpenMP threads |
| subroutine | [linop%] [interp_from_lat_lon](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L625) | compute horizontal interpolation from source latitude/longitude |
| subroutine | [linop%] [interp_from_mesh_tree](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L701) | compute horizontal interpolation from source mesh and tree |
| subroutine | [linop%] [interp_grid](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L915) | compute horizontal grid interpolation |
| subroutine | [linop%] [check_mask](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L1060) | check mask boundaries for linear operators |
| subroutine | [linop%] [interp_missing](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_linop.F90#L1128) | deal with missing interpolation points |
