!----------------------------------------------------------------------
! Program: main
! Purpose: command line arguments parsing and offline setup (call to the BUMP routine)
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
program main

use iso_fortran_env, only : output_unit
use type_bump, only: bump_type

implicit none

! Local variables
integer :: narg
character(len=1024) :: namelname
type(bump_type) :: bump

! Parse arguments
narg = command_argument_count()
if (narg==0) then
   write(output_unit,'(a)') 'Error: a namelist path should be provided as argument'
   call flush(output_unit)
   stop
elseif (narg==1) then
   call get_command_argument(1,namelname)
else
   write(output_unit,'(a)') 'Warning: one arguments only required (namelist path)'
   call flush(output_unit)
end if

! Offline run
call bump%run_offline(namelname)

! Stop
stop

end program main
