!----------------------------------------------------------------------
! Module: type_avg
!> Purpose: averaged statistics derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module type_avg

use tools_kinds, only: kind_real
use tools_missing, only: msr
use type_hdata, only: hdatatype
implicit none

! Averaged statistics derived type
type avgtype
   integer :: ne                                !< Ensemble size
   integer :: nsub                              !< Sub-ensembles number
   real(kind_real),allocatable :: m11(:,:,:)               !< Covariance average
   real(kind_real),allocatable :: m11m11(:,:,:,:,:)        !< Product of covariances average
   real(kind_real),allocatable :: m2m2(:,:,:,:,:)          !< Product of variances average
   real(kind_real),allocatable :: m22(:,:,:,:)             !< Fourth-order centered moment average
   real(kind_real),allocatable :: cor(:,:,:)               !< Correlation average
   real(kind_real),allocatable :: m11asysq(:,:,:)          !< Squared asymptotic covariance average
   real(kind_real),allocatable :: m2m2asy(:,:,:)           !< Product of asymptotic variances average
   real(kind_real),allocatable :: m22asy(:,:,:)            !< Asymptotic fourth-order centered moment average
   real(kind_real),allocatable :: m11sq(:,:,:)             !< Squared covariance average for several ensemble sizes
   real(kind_real),allocatable :: m11sta(:,:,:)            !< Ensemble covariance/static covariance product
   real(kind_real),allocatable :: stasq(:,:,:)             !< Squared static covariance
   real(kind_real),allocatable :: m11lrm11(:,:,:)          !< LR covariance/HR covariance product average
   real(kind_real),allocatable :: m11lrm11asy(:,:,:)       !< LR covariance/HR asymptotic covariance product average
end type avgtype

private
public :: avgtype
public :: avg_alloc,avg_dealloc

contains

!----------------------------------------------------------------------
! Subroutine: avg_alloc
!> Purpose: averaged statistics object allocation
!----------------------------------------------------------------------
subroutine avg_alloc(hdata,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata
type(avgtype),intent(inout) :: avg !< Averaged statistics

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Allocation
allocate(avg%m11(nam%nc,geom%nl0,geom%nl0))
allocate(avg%m11m11(nam%nc,geom%nl0,geom%nl0,avg%nsub,avg%nsub))
allocate(avg%m2m2(nam%nc,geom%nl0,geom%nl0,avg%nsub,avg%nsub))
allocate(avg%m22(nam%nc,geom%nl0,geom%nl0,avg%nsub))
allocate(avg%cor(nam%nc,geom%nl0,geom%nl0))
allocate(avg%m11asysq(nam%nc,geom%nl0,geom%nl0))
allocate(avg%m2m2asy(nam%nc,geom%nl0,geom%nl0))
allocate(avg%m22asy(nam%nc,geom%nl0,geom%nl0))
allocate(avg%m11sq(nam%nc,geom%nl0,geom%nl0))
select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   allocate(avg%m11sta(nam%nc,geom%nl0,geom%nl0))
   allocate(avg%stasq(nam%nc,geom%nl0,geom%nl0))
case ('dual-ens')
   allocate(avg%m11lrm11(nam%nc,geom%nl0,geom%nl0))
   allocate(avg%m11lrm11asy(nam%nc,geom%nl0,geom%nl0))
end select

! Initialization
call msr(avg%m11)
call msr(avg%m11m11)
call msr(avg%m2m2)
call msr(avg%m22)
call msr(avg%cor)
call msr(avg%m11asysq)
call msr(avg%m2m2asy)
call msr(avg%m22asy)
call msr(avg%m11sq)
select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   call msr(avg%m11sta)
   call msr(avg%stasq)
case ('dual-ens')
   call msr(avg%m11lrm11)
   call msr(avg%m11lrm11asy)
end select

! End associate
end associate

end subroutine avg_alloc

!----------------------------------------------------------------------
! Subroutine: avg_dealloc
!> Purpose: averaged statistics object deallocation
!----------------------------------------------------------------------
subroutine avg_dealloc(hdata,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata
type(avgtype),intent(inout) :: avg !< Averaged statistics

! Associate
associate(nam=>hdata%nam)

! Allocation
deallocate(avg%m11)
deallocate(avg%m11m11)
deallocate(avg%m2m2)
deallocate(avg%m22)
deallocate(avg%cor)
deallocate(avg%m11asysq)
deallocate(avg%m2m2asy)
deallocate(avg%m22asy)
deallocate(avg%m11sq)
select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   deallocate(avg%m11sta)
   deallocate(avg%stasq)
case ('dual-ens')
   deallocate(avg%m11lrm11)
   deallocate(avg%m11lrm11asy)
end select

! End associate
end associate

end subroutine avg_dealloc

end module type_avg
