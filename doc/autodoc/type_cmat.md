# Module type_cmat

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [cmat%] [alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L58) | C matrix allocation |
| subroutine | [cmat%] [alloc_blk](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L87) | allocation |
| subroutine | [cmat%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L115) | release memory |
| function | [cmat%] [copy](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L142) | copy |
| subroutine | [cmat%] [read](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L198) | read |
| subroutine | [cmat%] [write](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L291) | write |
| subroutine | [cmat%] [from_hdiag](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L367) | import HDIAG into C matrix |
| subroutine | [cmat%] [from_lct](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L574) | import LCT into C matrix |
| subroutine | [cmat%] [from_nam](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L649) | import radii into C matrix |
| subroutine | [cmat%] [from_bump](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L712) | import C matrix from BUMP |
| subroutine | [cmat%] [setup_sampling](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_cmat.F90#L809) | setup C matrix sampling |
