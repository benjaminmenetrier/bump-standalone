# Module type_fckit_mpi_comm

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| function | [fckit_mpi_comm%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L89) | initialize fckit MPI communicator |
| subroutine | [fckit_mpi_comm%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L115) | finalize fckit MPI communicator |
| subroutine | [fckit_mpi_comm%] [rank](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L141) | get MPI rank |
| subroutine | [fckit_mpi_comm%] [size](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L166) | get MPI size |
| subroutine | [fckit_mpi_comm%] [check](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L191) | check MPI error |
| subroutine | [fckit_mpi_comm%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L221) | abort |
| subroutine | [fckit_mpi_comm%] [barrier](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L244) | MPI barrier |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L266) | broadcast integer |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L290) | broadcast 1d integer array |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L314) | broadcast 2d integer array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L338) | broadcast real |
| subroutine | [fckit_mpi_comm%] [broadcast_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L362) | broadcast 1d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L386) | broadcast 2d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L410) | broadcast 3d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L434) | broadcast 4d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_5d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L458) | broadcast 5d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_6d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L482) | broadcast 6d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L506) | broadcast logical |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L530) | broadcast 1d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L554) | broadcast 2d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L578) | broadcast 3d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_string_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L602) | broadcast string |
| subroutine | [fckit_mpi_comm%] [receive_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L626) | receive integer |
| subroutine | [fckit_mpi_comm%] [receive_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L652) | receive 1d integer array |
| subroutine | [fckit_mpi_comm%] [receive_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L678) | receive real |
| subroutine | [fckit_mpi_comm%] [receive_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L704) | receive 1d real array |
| subroutine | [fckit_mpi_comm%] [receive_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L730) | receive 1d logical array |
| subroutine | [fckit_mpi_comm%] [send_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L756) | send integer |
| subroutine | [fckit_mpi_comm%] [send_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L781) | send 1d integer array |
| subroutine | [fckit_mpi_comm%] [send_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L806) | send real |
| subroutine | [fckit_mpi_comm%] [send_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L831) | send 1d real array |
| subroutine | [fckit_mpi_comm%] [send_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L856) | send 1d logical array |
| subroutine | [fckit_mpi_comm%] [allgather_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L881) | allgather for a integer |
| subroutine | [fckit_mpi_comm%] [allgather_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L909) | allgather for a real |
| subroutine | [fckit_mpi_comm%] [allgather_logical_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L937) | allgather for a logical |
| subroutine | [fckit_mpi_comm%] [alltoallv_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L965) | alltoallv for a real array |
| subroutine | [fckit_mpi_comm%] [allreduce_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L993) | allreduce for an integer |
| subroutine | [fckit_mpi_comm%] [allreduce_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1018) | allreduce for a real number |
| subroutine | [fckit_mpi_comm%] [allreduce_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1043) | allreduce for a real array, 1d |
| subroutine | [fckit_mpi_sum](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1068) | get MPI sum index |
| subroutine | [fckit_mpi_min](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1082) | get MPI min index |
| subroutine | [fckit_mpi_max](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1096) | get MPI max index |
| subroutine | [fckit_mpi_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1110) | get MPI real index |
