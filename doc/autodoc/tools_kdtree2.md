# Module tools_kdtree2

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| function | [kdtree2_create](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L129) | create the actual tree structure, given an input array of data |
| subroutine | [build_tree](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L189) | build tree |
| function | [build_tree_for_range](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L204) | build tree |
| function | [select_on_coordinate_value](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L333) | move elts of ind around between l and u, so that all points <= than alpha (in c cooordinate) are first, and then all points > alpha are second |
| subroutine | [select_on_coordinate](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L391) | move elts of ind around between l and u, so that the kth element is >= those below, <= those above, in the coordinate c |
| subroutine | [spread_in_coordinate](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L424) | return lower bound in 'smin', and upper in 'smax', the spread in coordinate 'c', between l and u. |
| subroutine | [kdtree2_destroy](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L472) | deallocates all memory for the tree, except input data matrix |
| subroutine | [destroy_node](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L491) | destroy node |
| subroutine | [kdtree2_n_nearest](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L517) | find the 'nn' vectors in the tree nearest to 'qv' in euclidean norm |
| function | [kdtree2_r_count](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L557) | count the number of neighbors within square distance 'r2' |
| subroutine | [validate_query_storage](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L598) | make sure we have enough storage for n |
| function | [square_distance](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L613) | distance between iv[1:n] and qv[1:n] |
| function | [sdistance](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L629) | spherical distance between iv[1:n] and qv[1:n] |
| subroutine | [validate_query_storage](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L650) | innermost core routine of the kd-tree search |
| function | [dis2_from_bnd](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L727) | compute squared distance |
| subroutine | [process_terminal_node](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L748) | Look for actual near neighbors in 'node', and update the search results on the sr data structure |
| subroutine | [process_terminal_node_fixedball](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L846) | look for actual near neighbors in 'node', and update the search results on the sr data structure, i.e. save all within a fixed ball. |
| subroutine | [kdtree2_sort_results](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L930) | use after search to sort results(1:nfound) in order of increasing distance |
| subroutine | [heapsort_struct](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2.F90#L946) | sort a(1:n) in ascending order |
