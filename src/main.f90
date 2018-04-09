!----------------------------------------------------------------------
! Program: main
!> Purpose: initialization, drivers, finalization
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
program main

use mpi
use type_hnb, only: hnb_type

implicit none

! Local variables
integer :: len,info,info_loc
character(len=mpi_max_error_string) :: message
type(hnb_type) :: hnb

! Initialize MPI
call mpi_init(info)
if (info/=mpi_success) then
   call mpi_error_string(info,message,len,info_loc)
   write(*,'(a)') trim(message)
   call mpi_finalize(info)
   if (info/=mpi_success) then
      call mpi_error_string(info,message,len,info_loc)
      write(*,'(a)') trim(message)
   end if
end if

! Offline setup
call hnb%setup_offline(mpi_comm_world)

! Finalize MPI
call mpi_finalize(info)
if (info/=mpi_success) then
   call mpi_error_string(info,message,len,info_loc)
    write(*,'(a)') trim(message)
end if

end program main
