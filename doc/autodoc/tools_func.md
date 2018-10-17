# Module tools_func

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [lonlatmod](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L32) | set latitude between -pi/2 and pi/2 and longitude between -pi and pi |
| subroutine | [sphere_dist](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L62) | compute the great-circle distance between two points |
| subroutine | [reduce_arc](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L89) | reduce arc to a given distance |
| subroutine | [vector_product](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L126) | compute normalized vector product |
| subroutine | [vector_triple_product](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L153) | compute vector triple product |
| subroutine | [add](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L180) | check if value missing and add if not missing |
| subroutine | [divide](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L209) | check if value missing and divide if not missing |
| subroutine | [fit_diag](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L230) | compute diagnostic fit function |
| subroutine | [fit_diag_dble](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L364) | compute diagnostic fit function |
| function | [gc99](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L513) | Gaspari and Cohn (1999) function, with the support radius as a parameter |
| subroutine | [fit_lct](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L543) | LCT fit |
| subroutine | [lct_d2h](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L615) | inversion from D (Daley tensor) to H (local correlation tensor) |
| subroutine | [check_cond](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L656) | check tensor conditioning |
| function | [matern](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L697) | compute the normalized diffusion function from eq. (55) of Mirouze and Weaver (2013), for the 3d case (d = 3) |
| subroutine | [cholesky](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L739) | compute cholesky decomposition |
| subroutine | [syminv](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_func.F90#L787) | compute inverse of a symmetric matrix |
