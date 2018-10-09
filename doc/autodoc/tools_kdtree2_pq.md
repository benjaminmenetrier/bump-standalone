# Module tools_kdtree2_pq

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| function | [pq_create](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2_pq.F90#L81) | create a priority queue from ALREADY allocated array pointers for storage |
| subroutine | [heapify](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2_pq.F90#L109) | take a heap rooted at 'i' and force it to be in the heap canonical form |
| subroutine | [pq_max](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2_pq.F90#L186) | return the priority and its payload of the maximum priority element on the queue, which should be the first one, if it is in heapified form |
| function | [pq_maxpri](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2_pq.F90#L202) | unknown |
| subroutine | [pq_extract_max](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2_pq.F90#L217) | return the priority and payload of maximum priority element, and remove it from the queue |
| function | [pq_insert](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2_pq.F90#L247) | insert a new element and return the new maximum priority, which may or may not be the same as the old maximum priority |
| function | [pq_replace_max](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2_pq.F90#L294) | replace the extant maximum priority element in the PQ with (dis,sdis,idx) |
| subroutine | [pq_delete](https://github.com/benjaminmenetrier/bump/tree/master/src/tools_kdtree2_pq.F90#L368) | delete item with index 'i' |
