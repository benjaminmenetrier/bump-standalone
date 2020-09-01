# Module type_mesh

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [mesh_alloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L78) | allocation |
| subroutine | [mesh_init](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L108) | intialization |
| subroutine | [mesh_dealloc](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L219) | release memory |
| subroutine | [mesh_copy](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L256) | copy |
| subroutine | [mesh_store](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L315) | store mesh cartesian coordinates |
| subroutine | [mesh_trlist](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L347) | compute triangle list, arc list |
| subroutine | [mesh_bnodes](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L413) | find boundary nodes |
| subroutine | [mesh_find_bdist](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L496) | find shortest distance to boundary arcs |
| subroutine | [mesh_check](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L553) | check whether the mesh is made of counter-clockwise triangles |
| subroutine | [mesh_inside](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L624) | find whether a point is inside the mesh |
| subroutine | [mesh_barycentric](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L656) | compute barycentric coordinates |
| subroutine | [mesh_count_bnda](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L692) | count boundary arcs |
| subroutine | [mesh_get_bnda](https://github.com/JCSDA/saber/tree/develop/src/saber/bump/type_mesh.F90#L735) | get boundary arcs |
