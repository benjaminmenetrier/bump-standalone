# Module type_mesh

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mesh%] [alloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L73) | allocation |
| subroutine | [mesh%] [init](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L102) | intialization |
| subroutine | [mesh%] [dealloc](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L156) | release memory |
| subroutine | [mesh%] [copy](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L191) | copy |
| subroutine | [mesh%] [store](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L240) | store mesh cartesian coordinates |
| subroutine | [mesh%] [trlist](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L272) | compute triangle list, arc list |
| subroutine | [mesh%] [bnodes](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L331) | find boundary nodes |
| subroutine | [mesh%] [find_bdist](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L402) | find shortest distance to boundary arcs |
| subroutine | [mesh%] [check](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L459) | check whether the mesh is made of counter-clockwise triangles |
| subroutine | [mesh%] [inside](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L613) | find whether a point is inside the mesh |
| subroutine | [mesh%] [barycentric](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L645) | compute barycentric coordinates |
| subroutine | [mesh%] [addnode](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L675) | add node to a mesh |
| subroutine | [mesh%] [polygon](https://github.com/benjaminmenetrier/bump-standalone/tree/master/src/type_mesh.F90#L770) | compute polygon area |
