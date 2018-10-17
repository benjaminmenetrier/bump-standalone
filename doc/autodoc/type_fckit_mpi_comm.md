# Module type_fckit_mpi_comm

| Type | Name | Purpose |
| :--: | :--: | :---------- |
| function | [fckit_mpi_comm%] [init](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L89) | initialize fckit MPI communicator |
| subroutine | [fckit_mpi_comm%] [final](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L127) | finalize fckit MPI communicator |
| subroutine | [fckit_mpi_comm%] [rank](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L153) | get MPI rank |
| subroutine | [fckit_mpi_comm%] [size](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L178) | get MPI size |
| subroutine | [fckit_mpi_comm%] [check](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L203) | check MPI error |
| subroutine | [fckit_mpi_comm%] [abort](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L233) | abort |
| subroutine | [fckit_mpi_comm%] [barrier](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L256) | MPI barrier |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L278) | broadcast integer |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L302) | broadcast 1d integer array |
| subroutine | [fckit_mpi_comm%] [broadcast_integer_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L326) | broadcast 2d integer array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L350) | broadcast real |
| subroutine | [fckit_mpi_comm%] [broadcast_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L374) | broadcast 1d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L398) | broadcast 2d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L422) | broadcast 3d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_4d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L446) | broadcast 4d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_5d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L470) | broadcast 5d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_real_6d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L494) | broadcast 6d real array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L518) | broadcast logical |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L542) | broadcast 1d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_2d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L566) | broadcast 2d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_logical_3d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L590) | broadcast 3d logical array |
| subroutine | [fckit_mpi_comm%] [broadcast_string_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L614) | broadcast string |
| subroutine | [fckit_mpi_comm%] [receive_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L638) | receive integer |
| subroutine | [fckit_mpi_comm%] [receive_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L664) | receive 1d integer array |
| subroutine | [fckit_mpi_comm%] [receive_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L690) | receive real |
| subroutine | [fckit_mpi_comm%] [receive_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L716) | receive 1d real array |
| subroutine | [fckit_mpi_comm%] [receive_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L742) | receive 1d logical array |
| subroutine | [fckit_mpi_comm%] [send_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L768) | send integer |
| subroutine | [fckit_mpi_comm%] [send_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L793) | send 1d integer array |
| subroutine | [fckit_mpi_comm%] [send_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L818) | send real |
| subroutine | [fckit_mpi_comm%] [send_integer_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L843) | send 1d real array |
| subroutine | [fckit_mpi_comm%] [send_logical_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L868) | send 1d logical array |
| subroutine | [fckit_mpi_comm%] [allgather_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L893) | allgather for a integer |
| subroutine | [fckit_mpi_comm%] [allgather_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L921) | allgather for a real |
| subroutine | [fckit_mpi_comm%] [allgather_logical_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L949) | allgather for a logical |
| subroutine | [fckit_mpi_comm%] [alltoallv_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L977) | alltoallv for a real array |
| subroutine | [fckit_mpi_comm%] [allreduce_integer_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1005) | allreduce for an integer |
| subroutine | [fckit_mpi_comm%] [allreduce_real_0d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1030) | allreduce for a real number |
| subroutine | [fckit_mpi_comm%] [allreduce_real_1d](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1055) | allreduce for a real array, 1d |
| subroutine | [fckit_mpi_sum](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1080) | get MPI sum index |
| subroutine | [fckit_mpi_min](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1094) | get MPI min index |
| subroutine | [fckit_mpi_max](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1108) | get MPI max index |
| subroutine | [fckit_mpi_real](https://github.com/benjaminmenetrier/bump/tree/master/src/type_fckit_mpi_comm.F90#L1122) | get MPI real index |
