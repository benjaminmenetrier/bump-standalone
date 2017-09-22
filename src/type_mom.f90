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
   character(len=1024),allocatable :: input(:)   !< Ensemble file prefix
   character(len=1024),allocatable :: varname(:) !< Variables to read
   integer,allocatable :: time(:)                !< Time of the variables to read
   real(kind_real),allocatable :: m1b(:,:,:,:)              !< Base means
   real(kind_real),allocatable :: m2b(:,:,:,:,:,:)              !< Base variances
   real(kind_real),allocatable :: m2(:,:,:,:,:,:)             !< Variances
   real(kind_real),allocatable :: m2full(:,:,:,:)            !< Full variances
   real(kind_real),allocatable :: m11(:,:,:,:,:,:)            !< Covariances
   real(kind_real),allocatable :: m22(:,:,:,:,:,:)            !< Fourth-order centered moment
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
deallocate(mom%input)
deallocate(mom%varname)
deallocate(mom%time)
deallocate(mom%m1b)
deallocate(mom%m2b)
deallocate(mom%m2)
if (nam%full_var) deallocate(mom%m2full)
deallocate(mom%m11)
if (.not.nam%gau_approx) deallocate(mom%m22)

! End associate
end associate

end subroutine mom_dealloc

end module type_mom
