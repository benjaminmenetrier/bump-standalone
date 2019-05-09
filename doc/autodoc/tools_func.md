# Module tools_func

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [lonlatmod](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L32) | set latitude between -pi/2 and pi/2 and longitude between -pi and pi |
| subroutine | [sphere_dist](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L62) | compute the great-circle distance between two points |
| subroutine | [reduce_arc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L82) | reduce arc to a given distance |
| subroutine | [lonlat2xyz](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L119) | convert longitude/latitude to cartesian coordinates |
| subroutine | [xyz2lonlat](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L147) | convert longitude/latitude to cartesian coordinates |
| subroutine | [vector_product](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L176) | compute normalized vector product |
| subroutine | [vector_triple_product](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L203) | compute vector triple product |
| subroutine | [add](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L230) | check if value missing and add if not missing |
| subroutine | [divide](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L260) | check if value missing and divide if not missing |
| subroutine | [fit_diag](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L282) | compute diagnostic fit function |
| subroutine | [fit_diag_dble](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L416) | compute diagnostic fit function |
| function | [gc99](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L565) | Gaspari and Cohn (1999) function, with the support radius as a parameter |
| subroutine | [fit_lct](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L598) | LCT fit |
| subroutine | [lct_d2h](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L670) | from D (Daley tensor) to H (local correlation tensor) |
| subroutine | [lct_h2r](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L712) | from H (local correlation tensor) to support radii |
| subroutine | [lct_r2d](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L763) | from support radius to Daley tensor diagonal element |
| subroutine | [check_cond](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L780) | check tensor conditioning |
| function | [matern](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L821) | compute the normalized diffusion function from eq. (55) of Mirouze and Weaver (2013), for the 3d case (d = 3) |
| subroutine | [cholesky](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L864) | compute cholesky decomposition |
| subroutine | [syminv](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L916) | compute inverse of a symmetric matrix |
| subroutine | [histogram](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/tools_func.F90#L968) | compute bins and histogram from a list of values |
