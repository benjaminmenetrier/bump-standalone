# Module tools_func

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [lonlatmod](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L31) | set latitude between -pi/2 and pi/2 and longitude between -pi and pi |
| subroutine | [sphere_dist](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L61) | compute the great-circle distance between two points |
| subroutine | [reduce_arc](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L83) | reduce arc to a given distance |
| subroutine | [vector_product](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L120) | compute normalized vector product |
| subroutine | [vector_triple_product](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L147) | compute vector triple product |
| subroutine | [add](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L174) | check if value missing and add if not missing |
| subroutine | [divide](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L204) | check if value missing and divide if not missing |
| subroutine | [fit_diag](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L226) | compute diagnostic fit function |
| subroutine | [fit_diag_dble](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L360) | compute diagnostic fit function |
| function | [gc99](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L509) | Gaspari and Cohn (1999) function, with the support radius as a parameter |
| subroutine | [fit_lct](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L542) | LCT fit |
| subroutine | [lct_d2h](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L614) | inversion from D (Daley tensor) to H (local correlation tensor) |
| subroutine | [lct_h2r](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L656) | inversion from H (local correlation tensor) to support radii |
| subroutine | [lct_r2d](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L707) | conversion from support radius to Daley tensor diagonal element |
| subroutine | [check_cond](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L724) | check tensor conditioning |
| function | [matern](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L765) | compute the normalized diffusion function from eq. (55) of Mirouze and Weaver (2013), for the 3d case (d = 3) |
| subroutine | [cholesky](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L808) | compute cholesky decomposition |
| subroutine | [syminv](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L860) | compute inverse of a symmetric matrix |
