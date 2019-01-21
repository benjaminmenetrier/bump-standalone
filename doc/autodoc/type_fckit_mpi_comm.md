# Module type_fckit_mpi_comm

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| function | [fckit_mpi_comm%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L95) | initialize fckit MPI communicator |
| subroutine | [fckit_mpi_comm%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L133) | finalize fckit MPI communicator |
| subroutine | [fckit_mpi_comm%] [rank](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L159) | get MPI rank |
| subroutine | [fckit_mpi_comm%] [size](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L184) | get MPI size |
| subroutine | [fckit_mpi_comm%] [check](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L209) | check MPI error |
| subroutine | [fckit_mpi_comm%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L239) | abort |
| subroutine | [fckit_mpi_comm%] [barrier](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L262) | MPI barrier |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L284) | broadcast integer |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L308) | broadcast 1d integer array |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L332) | broadcast 2d integer array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L356) | broadcast real |
| subroutine | [fckit_mpi_comm%] [broadcast_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L380) | broadcast 1d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L404) | broadcast 2d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L428) | broadcast 3d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L452) | broadcast 4d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_5d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L476) | broadcast 5d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_6d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L500) | broadcast 6d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L524) | broadcast logical |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L548) | broadcast 1d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L572) | broadcast 2d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L596) | broadcast 3d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_string_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L620) | broadcast string |
| subroutine | [fckit_mpi_comm%] [receive_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L644) | receive integer |
| subroutine | [fckit_mpi_comm%] [receive_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L670) | receive 1d integer array |
| subroutine | [fckit_mpi_comm%] [receive_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L696) | receive real |
| subroutine | [fckit_mpi_comm%] [receive_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L722) | receive 1d real array |
| subroutine | [fckit_mpi_comm%] [receive_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L748) | receive 1d logical array |
| subroutine | [fckit_mpi_comm%] [send_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L774) | send integer |
| subroutine | [fckit_mpi_comm%] [send_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L799) | send 1d integer array |
| subroutine | [fckit_mpi_comm%] [send_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L824) | send real |
| subroutine | [fckit_mpi_comm%] [send_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L849) | send 1d real array |
| subroutine | [fckit_mpi_comm%] [send_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L874) | send 1d logical array |
| subroutine | [fckit_mpi_comm%] [allgather_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L899) | allgather for a integer |
| subroutine | [fckit_mpi_comm%] [allgather_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L927) | allgather for a real |
| subroutine | [fckit_mpi_comm%] [allgather_logical_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L955) | allgather for a logical |
| subroutine | [fckit_mpi_comm%] [allgatherv_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L983) | allgatherv for a integer array, 1d |
| subroutine | [fckit_mpi_comm%] [allgatherv_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1010) | allgatherv for a real array, 1d |
| subroutine | [fckit_mpi_comm%] [allgatherv_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1037) | allgatherv for a logical array, 1d |
| subroutine | [fckit_mpi_comm%] [alltoallv_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1064) | alltoallv for a real array |
| subroutine | [fckit_mpi_comm%] [allreduce_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1092) | allreduce for an integer |
| subroutine | [fckit_mpi_comm%] [allreduce_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1117) | allreduce for a integer array, 1d |
| subroutine | [fckit_mpi_comm%] [allreduce_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1142) | allreduce for a real number |
| subroutine | [fckit_mpi_comm%] [allreduce_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1167) | allreduce for a real array, 1d |
| subroutine | [fckit_mpi_sum](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1192) | get MPI sum index |
| subroutine | [fckit_mpi_min](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1206) | get MPI min index |
| subroutine | [fckit_mpi_max](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1220) | get MPI max index |
| subroutine | [fckit_mpi_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1234) | get MPI real index |
