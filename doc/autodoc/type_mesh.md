# Module type_mesh

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mesh%] [alloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L73) | allocation |
| subroutine | [mesh%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L102) | intialization |
| subroutine | [mesh%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L156) | release memory |
| function | [mesh%] [copy](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L191) | copy |
| subroutine | [mesh%] [trans](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L238) | transform to cartesian coordinates |
| subroutine | [mesh%] [trlist](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L265) | compute triangle list, arc list |
| subroutine | [mesh%] [bnodes](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L324) | find boundary nodes |
| subroutine | [mesh%] [find_bdist](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L387) | find shortest distance to boundary arcs |
| subroutine | [mesh%] [check](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L445) | check whether the mesh is made of counter-clockwise triangles |
| subroutine | [mesh%] [inside](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L600) | find whether a point is inside the mesh |
| subroutine | [mesh%] [barycentric](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L632) | compute barycentric coordinates |
| subroutine | [mesh%] [addnode](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L662) | add node to a mesh |
| subroutine | [mesh%] [polygon](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L757) | compute polygon area |
