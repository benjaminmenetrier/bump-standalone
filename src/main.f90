!----------------------------------------------------------------------
! Program: main
!> Purpose: initialization, drivers, finalization
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
program main

use, intrinsic :: iso_fortran_env, only : output_unit
use mpi
use type_bump, only: bump_type

implicit none

! Local variables
integer :: len,info,info_loc,myproc,narg
character(len=mpi_max_error_string) :: message
character(len=1024) :: arg
type(bump_type) :: bump

! Initialize MPI
call mpi_init(info)
if (info/=mpi_success) then
   call mpi_error_string(info,message,len,info_loc)
   write(output_unit,'(a)') trim(message)
   call mpi_finalize(info)
   stop
end if
call mpi_comm_rank(mpi_comm_world,myproc,info)

! Parse arguments
narg = command_argument_count()
if (narg==0) then
   if (myproc==0) then
      write(output_unit,'(a)') 'Error: a namelist path should be provided as argument'
      call flush(output_unit)
   end if
   call mpi_finalize(info)
   stop
elseif (narg==1) then
   call get_command_argument(1,arg)
else
   if (myproc==0) then
      write(output_unit,'(a)') 'Warning: one arguments only required (namelist path)'
      call flush(output_unit)
   end if
end if

! Offline setup
call bump%setup_offline(mpi_comm_world,arg)

! Finalize MPI
call mpi_finalize(info)
stop

end program main
