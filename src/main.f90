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

use, intrinsic :: iso_fortran_env, only : output_unit
use mpi
use type_hnb, only: hnb_type

implicit none

! Local variables
integer :: len,info,info_loc,myproc,narg
character(len=mpi_max_error_string) :: message
character(len=1024) :: arg1,prefix
type(hnb_type) :: hnb

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
      write(output_unit,'(a)') 'Error: no argument provided'
      call flush(output_unit)
      call print_usage
   end if
   call mpi_finalize(info)
   stop
else
   call get_command_argument(1,arg1)
   if (trim(arg1)=='online') then
      if (narg==1) then
         if (myproc==0) then
            write(output_unit,'(a)') 'Error: prefix required for online test from file'
            call flush(output_unit)
            call print_usage
         end if
         call mpi_finalize(info)
         stop
      else
         call get_command_argument(2,prefix)
      end if
      if (narg>2) then
         if (myproc==0) then
            write(output_unit,'(a)') 'Warning: two arguments only required for online test from file'
            call flush(output_unit)
            call print_usage
         end if
      end if
   else
      if (narg>1) then
         if (myproc==0) then
            write(output_unit,'(a)') 'Warning: one arguments only required for offline run'
            call flush(output_unit)
            call print_usage
         end if
      end if
   end if
end if

! Note to users
if (myproc==0) then
   write(output_unit,'(a)') 'To check the listing: tail -f hdiag_nicas.out.0000'
   call flush(output_unit)
end if

if (trim(arg1)=='online') then
   ! Online setup from file
   call hnb%setup_online_from_file(mpi_comm_world,prefix)
else
   ! Offline setup
   call hnb%setup_offline(mpi_comm_world,arg1)
end if

! Finalize MPI
call mpi_finalize(info)
stop

end program main

!----------------------------------------------------------------------
! Subroutine: print_usage
!> Purpose: print hdiag_nicas call options
!----------------------------------------------------------------------
subroutine print_usage

use, intrinsic :: iso_fortran_env, only : output_unit

implicit none

write(output_unit,'(a)') 'Usage: ./hdiag_nicas namelist (offline run)'
write(output_unit,'(a)') '       ./hdiag_nicas online prefix (online test from file)'
call flush(output_unit)

end subroutine print_usage
