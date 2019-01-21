# Module type_linop

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [linop%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L65) | allocation |
| subroutine | [linop%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L95) | release memory |
| function | [linop%] [copy](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L114) | copy |
| subroutine | [linop%] [read](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L150) | read |
| subroutine | [linop%] [write](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L206) | write |
| subroutine | [linop%] [reorder](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L264) | reorder linear operator |
| subroutine | [linop%] [apply](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L322) | apply linear operator |
| subroutine | [linop%] [apply_ad](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L411) | apply linear operator, adjoint |
| subroutine | [linop%] [apply_sym](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L465) | apply linear operator, symmetric |
| subroutine | [linop%] [add_op](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L531) | add operation |
| subroutine | [linop%] [gather](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L576) | gather data from OpenMP threads |
| subroutine | [linop%] [interp_from_lat_lon](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L610) | compute horizontal interpolation from source latitude/longitude |
| subroutine | [linop%] [interp_from_mesh_kdtree](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L686) | compute horizontal interpolation from source mesh and kdtree |
| subroutine | [linop%] [interp_grid](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L899) | compute horizontal grid interpolation |
| subroutine | [linop%] [interp_check_mask](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L1043) | check mask boundaries for interpolations |
| subroutine | [linop%] [interp_missing](https://github.com/benjaminmenetrier/bump/tree/master/src/type_linop.F90#L1110) | deal with missing interpolation points |
