!----------------------------------------------------------------------
! Module: type_mom
!> Purpose: moments derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module type_mom

use tools_kinds, only: kind_real
use type_hdata, only: hdatatype
implicit none

! Moments derived type
type momtype
   integer :: ne                                 !< Ensemble size
   integer :: ne_offset                          !< Ensemble index offset
   integer :: nsub                               !< Number of sub-ensembles
   character(len=1024) :: filename  !< File name
   character(len=1024) :: varname_1 !< Variable name 1
   character(len=1024) :: varname_2 !< Variable name 2
   integer :: timeslot_1           !< Time slot 1
   integer :: timeslot_2           !< Time slot 2
   real(kind_real),allocatable :: m1_1(:,:,:)              !< Mean
   real(kind_real),allocatable :: m2_1(:,:,:,:,:)          !< Variance
   real(kind_real),allocatable :: m1_2(:,:,:)              !< Mean
   real(kind_real),allocatable :: m2_2(:,:,:,:,:)          !< Variance
   real(kind_real),allocatable :: m2full(:,:,:)            !< Full variance
   real(kind_real),allocatable :: m11(:,:,:,:,:)            !< Covariance
   real(kind_real),allocatable :: m22(:,:,:,:,:)            !< Fourth-order centered moment
end type momtype

private
public :: momtype
public :: mom_dealloc

contains

!----------------------------------------------------------------------
! Subroutine: mom_dealloc
!> Purpose: moments object deallocation
!----------------------------------------------------------------------
subroutine mom_dealloc(hdata,mom)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
type(momtype),intent(inout) :: mom !< Moments

! Associate
associate(nam=>hdata%nam)

! Release memory
deallocate(mom%m1_1)
deallocate(mom%m2_1)
deallocate(mom%m1_2)
deallocate(mom%m2_2)
if (nam%full_var) deallocate(mom%m2full)
deallocate(mom%m11)
if (.not.nam%gau_approx) deallocate(mom%m22)

! End associate
end associate

end subroutine mom_dealloc

end module type_mom
