!----------------------------------------------------------------------
! Module: fckit_configuration_module
! Purpose: fckit configuration emulator for standalone execution
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
module fckit_configuration_module

use iso_c_binding
use tools_kinds,only: kind_real

implicit none

type fckit_configuration
contains
  procedure :: has
  procedure :: get_logical_or_die
  procedure :: get_integer_or_die
  procedure :: get_real_or_die
  procedure :: get_string_or_die
  procedure :: get_array_logical_or_die
  procedure :: get_array_integer_or_die
  procedure :: get_array_real_or_die
  procedure :: get_array_string_or_die
  generic :: get_or_die => get_logical_or_die,get_integer_or_die,get_real_or_die,get_string_or_die, &
                         & get_array_logical_or_die,get_array_integer_or_die,get_array_real_or_die,get_array_string_or_die
end type fckit_configuration

private
public :: fckit_configuration

contains

!----------------------------------------------------------------------
! Function: has
! Purpose: dummy function
!----------------------------------------------------------------------
function has(conf,name) result(value)

implicit none

! Passed variable
class(fckit_configuration),intent(inout) :: conf ! Configuration
character(len=*),intent(in) :: name              ! Key name

! Result
logical :: value                     ! Results

value = .false.

end function has

!----------------------------------------------------------------------
! Function: get_logical_or_die
! Purpose: dummy subroutine
!----------------------------------------------------------------------
subroutine get_logical_or_die(conf,name,value)

implicit none

! Passed variables
class(fckit_configuration),intent(inout) :: conf ! Configuration
character(len=*),intent(in) :: name              ! Key name
logical,intent(out) :: value                     ! Value

end subroutine get_logical_or_die

!----------------------------------------------------------------------
! Function: get_integer_or_die
! Purpose: dummy subroutine
!----------------------------------------------------------------------
subroutine get_integer_or_die(conf,name,value)

implicit none

! Passed variables
class(fckit_configuration),intent(inout) :: conf ! Configuration
character(len=*),intent(in) :: name              ! Key name
integer,intent(out) :: value                     ! Value

end subroutine get_integer_or_die

!----------------------------------------------------------------------
! Function: get_real_or_die
! Purpose: dummy subroutine
!----------------------------------------------------------------------
subroutine get_real_or_die(conf,name,value)

implicit none

! Passed variables
class(fckit_configuration),intent(inout) :: conf ! Configuration
character(len=*),intent(in) :: name              ! Key name
real(kind_real),intent(out) :: value          ! Value

end subroutine get_real_or_die

!----------------------------------------------------------------------
! Function: get_string_or_die
! Purpose: dummy subroutine
!----------------------------------------------------------------------
subroutine get_string_or_die(conf,name,value)

implicit none

! Passed variables
class(fckit_configuration),intent(inout) :: conf ! Configuration
character(len=*),intent(in) :: name              ! Key name
character(len=*),intent(out) :: value            ! Value

end subroutine get_string_or_die

!----------------------------------------------------------------------
! Function: get_array_logical_or_die
! Purpose: dummy subroutine
!----------------------------------------------------------------------
subroutine get_array_logical_or_die(conf,name,value)

implicit none

! Passed variables
class(fckit_configuration),intent(inout) :: conf ! Configuration
character(len=*),intent(in) :: name              ! Key name
logical,allocatable,intent(out) :: value(:)      ! Value

end subroutine get_array_logical_or_die

!----------------------------------------------------------------------
! Function: get_array_integer_or_die
! Purpose: dummy subroutine
!----------------------------------------------------------------------
subroutine get_array_integer_or_die(conf,name,value)

implicit none

! Passed variables
class(fckit_configuration),intent(inout) :: conf ! Configuration
character(len=*),intent(in) :: name              ! Key name
integer,allocatable,intent(out) :: value(:)      ! Value

end subroutine get_array_integer_or_die

!----------------------------------------------------------------------
! Function: get_array_real_or_die
! Purpose: dummy subroutine
!----------------------------------------------------------------------
subroutine get_array_real_or_die(conf,name,value)

implicit none

! Passed variables
class(fckit_configuration),intent(inout) :: conf    ! Configuration
character(len=*),intent(in) :: name                 ! Key name
real(kind_real),allocatable,intent(out) :: value(:) ! Value

end subroutine get_array_real_or_die

!----------------------------------------------------------------------
! Function: get_array_string_or_die
! Purpose: dummy subroutine
!----------------------------------------------------------------------
subroutine get_array_string_or_die(conf,name,length,value)

implicit none

! Passed variables
class(fckit_configuration),intent(inout) :: conf          ! Configuration
character(len=*),intent(in) :: name                       ! Key name
integer(c_size_t),intent(in) :: length                    ! Length
character(len=length),allocatable,intent(out) :: value(:) ! Value

end subroutine get_array_string_or_die

end module fckit_configuration_module
