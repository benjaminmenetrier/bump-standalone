!----------------------------------------------------------------------
! Module: fckit_log_module
! Purpose: fckit log emulator for standalone execution
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
module fckit_log_module

implicit none

type fckit_log_type
contains
   procedure :: info => fckit_log_info
   procedure :: test => fckit_log_test
end type fckit_log_type

type(fckit_log_type) :: fckit_log

private
public :: fckit_log

contains

!----------------------------------------------------------------------
! Subroutine: fckit_log_info
! Purpose: info log emulator
!----------------------------------------------------------------------
subroutine fckit_log_info(flog,msg,newl,flush)

implicit none

! Passed variables
class(fckit_log_type),intent(in) :: flog
character(len=*),intent(in) :: msg
logical,intent(in),optional :: newl
logical,intent(in),optional :: flush

end subroutine fckit_log_info

!----------------------------------------------------------------------
! Subroutine: fckit_log_test
! Purpose: test log emulator
!----------------------------------------------------------------------
subroutine fckit_log_test(flog,msg,newl,flush)

implicit none

! Passed variables
class(fckit_log_type),intent(in) :: flog
character(len=*),intent(in) :: msg
logical,intent(in),optional :: newl
logical,intent(in),optional :: flush

end subroutine fckit_log_test

end module fckit_log_module
