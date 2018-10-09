# Module type_mesh

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mesh%] [create](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L67) | create mesh |
| subroutine | [mesh%] [dealloc](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L138) | deallocate mesh |
| function | [mesh%] [copy](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L167) | copy mesh |
| subroutine | [mesh%] [trans](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L226) | transform to cartesian coordinates |
| subroutine | [mesh%] [trlist](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L248) | compute triangle list, arc list |
| subroutine | [mesh%] [bnodes](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L300) | find boundary nodes |
| subroutine | [mesh%] [barcs](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L320) | find boundary arcs |
| subroutine | [mesh%] [check](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L398) | check whether the mesh is made of counter-clockwise triangles |
| subroutine | [mesh%] [inside](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L461) | find whether a point is inside the mesh |
| subroutine | [mesh%] [barycentric](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L492) | compute barycentric coordinates |
| subroutine | [mesh%] [addnode](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L521) | add node to a mesh |
| subroutine | [mesh%] [polygon](https://github.com/benjaminmenetrier/bump/tree/master/src/type_mesh.F90#L604) | compute polygon area |
