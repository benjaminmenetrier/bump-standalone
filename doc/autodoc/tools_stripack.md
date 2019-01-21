# Module tools_stripack

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| subroutine | [addnod](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L27) | add a node to a triangulation |
| function | [areas](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L296) | compute the area of a spherical triangle on the unit sphere |
| subroutine | [bdyadd](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L441) | add a boundary node to a triangulation |
| subroutine | [bnodes](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L583) | return the boundary nodes of a triangulation |
| subroutine | [circum](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L719) | return the circumcenter of a spherical triangle |
| subroutine | [covsph](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L806) | connect an exterior node to boundary nodes, covering the sphere |
| subroutine | [det](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L918) | compute 3D determinant |
| subroutine | [crlist](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L955) | return triangle circumcenters and other information |
| subroutine | [insert](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L1595) | insert K as a neighbor of N1 |
| function | [inside](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L1654) | determine if a point is inside a polygonal region |
| subroutine | [intadd](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2017) | add an interior node to a triangulation |
| subroutine | [intrsc](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2119) | find the intersection of two great circles |
| subroutine | [jrand](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2227) | return a random integer between 1 and N |
| subroutine | [left](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2293) | determin whether a node is to the left of a plane through the origin |
| subroutine | [lstptr](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2356) | return the index of NB in the adjacency list |
| function | [nbcnt](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2437) | return the number of neighbors of a node |
| function | [nearnd](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2513) | return the nearest node to a given point |
| subroutine | [scoord](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2837) | convert from Cartesian to spherical coordinates |
| subroutine | [swap](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L2902) | replace the diagonal arc of a quadrilateral with the other diagonal |
| subroutine | [swptst](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L3019) | decide whether to replace a diagonal arc by the other |
| subroutine | [trans](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L3119) | transform spherical coordinates to Cartesian coordinates |
| subroutine | [trfind](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L3205) | locate a point relative to a triangulation |
| subroutine | [trlist](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L3719) | convert a triangulation data structure to a triangle list |
| subroutine | [trmesh](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_stripack.F90#L4019) | create a Delaunay triangulation on the unit sphere |
