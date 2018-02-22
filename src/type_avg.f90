!----------------------------------------------------------------------
! Module: type_avg
!> Purpose: averaged statistics derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module type_avg

use tools_kinds, only: kind_real
use tools_missing, only: msr
use type_hdata, only: hdatatype
use type_mpl, only: mpl
implicit none

! Averaged statistics derived type
type avgtype
   integer :: ne                                     !< Ensemble size
   integer :: nsub                                   !< Sub-ensembles number
   integer :: npack                                  !< Pack format size
   real(kind_real),allocatable :: nc1a(:,:,:)        !< Number of points in subset Sc1 on halo A
   real(kind_real),allocatable :: m11(:,:,:)         !< Covariance average
   real(kind_real),allocatable :: m11m11(:,:,:,:,:)  !< Product of covariances average
   real(kind_real),allocatable :: m2m2(:,:,:,:,:)    !< Product of variances average
   real(kind_real),allocatable :: m22(:,:,:,:)       !< Fourth-order centered moment average
   real(kind_real),allocatable :: cor(:,:,:)         !< Correlation average
   real(kind_real),allocatable :: m11asysq(:,:,:)    !< Squared asymptotic covariance average
   real(kind_real),allocatable :: m2m2asy(:,:,:)     !< Product of asymptotic variances average
   real(kind_real),allocatable :: m22asy(:,:,:)      !< Asymptotic fourth-order centered moment average
   real(kind_real),allocatable :: m11sq(:,:,:)       !< Squared covariance average for several ensemble sizes
   real(kind_real),allocatable :: m11sta(:,:,:)      !< Ensemble covariance/static covariance product
   real(kind_real),allocatable :: stasq(:,:,:)       !< Squared static covariance
   real(kind_real),allocatable :: m11lrm11(:,:,:)    !< LR covariance/HR covariance product average
   real(kind_real),allocatable :: m11lrm11asy(:,:,:) !< LR covariance/HR asymptotic covariance product average
contains
   procedure :: alloc => avg_alloc
   procedure :: dealloc => avg_dealloc
   procedure :: copy => avg_copy
   procedure :: pack => avg_pack
   procedure :: unpack => avg_unpack
end type avgtype

private
public :: avgtype

contains

!----------------------------------------------------------------------
! Subroutine: avg_alloc
!> Purpose: averaged statistics object allocation
!----------------------------------------------------------------------
subroutine avg_alloc(avg,hdata,ib)

implicit none

! Passed variables
class(avgtype),intent(inout) :: avg !< Averaged statistics
type(hdatatype),intent(in) :: hdata !< HDIAG data
integer,intent(in) :: ib            !< Block index

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Allocation
if (.not.allocated(avg%nc1a)) then
   allocate(avg%nc1a(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   allocate(avg%m11(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   allocate(avg%m11m11(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0,avg%nsub,avg%nsub))
   allocate(avg%m2m2(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0,avg%nsub,avg%nsub))
   if (.not.nam%gau_approx) allocate(avg%m22(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0,avg%nsub))
   allocate(avg%cor(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   allocate(avg%m11asysq(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   allocate(avg%m2m2asy(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   if (.not.nam%gau_approx) allocate(avg%m22asy(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   allocate(avg%m11sq(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   select case (trim(nam%method))
   case ('hyb-avg','hyb-rnd')
      allocate(avg%m11sta(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
      allocate(avg%stasq(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   case ('dual-ens')
      allocate(avg%m11lrm11(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
      allocate(avg%m11lrm11asy(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
   end select
end if

! Initialization
avg%npack = (3+2*avg%nsub**2)*bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0
if (.not.nam%gau_approx) avg%npack = avg%npack+avg%nsub*bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0
call msr(avg%nc1a)
call msr(avg%m11)
call msr(avg%m11m11)
call msr(avg%m2m2)
if (.not.nam%gau_approx) call msr(avg%m22)
call msr(avg%cor)
call msr(avg%m11asysq)
call msr(avg%m2m2asy)
if (.not.nam%gau_approx) call msr(avg%m22asy)
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
subroutine avg_dealloc(avg)

implicit none

! Passed variables
class(avgtype),intent(inout) :: avg !< Averaged statistics

! Allocation
if (allocated(avg%nc1a)) deallocate(avg%nc1a)
if (allocated(avg%m11)) deallocate(avg%m11)
if (allocated(avg%m11m11)) deallocate(avg%m11m11)
if (allocated(avg%m2m2)) deallocate(avg%m2m2)
if (allocated(avg%cor)) deallocate(avg%cor)
if (allocated(avg%m11asysq)) deallocate(avg%m11asysq)
if (allocated(avg%m2m2asy)) deallocate(avg%m2m2asy)
if (allocated(avg%m11sq)) deallocate(avg%m11sq)
if (allocated(avg%m11sta)) deallocate(avg%m11sta)
if (allocated(avg%stasq)) deallocate(avg%stasq)
if (allocated(avg%m11lrm11)) deallocate(avg%m11lrm11)
if (allocated(avg%m11lrm11asy)) deallocate(avg%m11lrm11asy)

end subroutine avg_dealloc

!----------------------------------------------------------------------
! Subroutine: avg_copy
!> Purpose: averaged statistics object copy
!----------------------------------------------------------------------
type(avgtype) function avg_copy(avg,hdata,ib)

implicit none

! Passed variables
class(avgtype),intent(in) :: avg    !< Averaged statistics, input
type(hdatatype),intent(in) :: hdata !< HDIAG data
integer,intent(in) :: ib            !< Block index

! Associate
associate(nam=>hdata%nam)

! Initialization
avg_copy%ne = avg%ne
avg_copy%nsub = avg%nsub

! Allocation
call avg_copy%alloc(hdata,ib)

! Copy
avg_copy%npack = avg%npack
avg_copy%nc1a = avg%nc1a
avg_copy%m11 = avg%m11
avg_copy%m11m11 = avg%m11m11
avg_copy%m2m2 = avg%m2m2
if (.not.nam%gau_approx) avg_copy%m22 = avg%m22
avg_copy%cor = avg%cor
avg_copy%m11asysq = avg%m11asysq
avg_copy%m2m2asy = avg%m2m2asy
if (.not.nam%gau_approx) avg_copy%m22asy = avg%m22asy
avg_copy%m11sq = avg%m11sq
select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   avg_copy%m11sta = avg%m11sta
   avg_copy%stasq = avg%stasq
case ('dual-ens')
   avg_copy%m11lrm11 = avg%m11lrm11
   avg_copy%m11lrm11asy = avg%m11lrm11asy
end select

! End associate
end associate

end function avg_copy

!----------------------------------------------------------------------
! Subroutine: avg_pack
!> Purpose: averaged statistics object packing
!----------------------------------------------------------------------
subroutine avg_pack(avg,hdata,ib,buf)

implicit none

! Passed variables
class(avgtype),intent(in) :: avg              !< Averaged statistics
type(hdatatype),intent(in) :: hdata           !< HDIAG data
integer,intent(in) :: ib                      !< Block index
real(kind_real),intent(out) :: buf(avg%npack) !< Buffer

! Local variables
integer :: offset

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Pack
offset = 0
buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0) = pack(avg%nc1a,.true.)
offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0
buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0) = pack(avg%m11,.true.)
offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0
buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub**2) = pack(avg%m11m11,.true.)
offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub**2
buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub**2) = pack(avg%m2m2,.true.)
offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub**2
if (.not.nam%gau_approx) then
   buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub) = pack(avg%m22,.true.)
   offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub
end if
buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0) = pack(avg%cor,.true.)

! End associate
end associate

end subroutine avg_pack

!----------------------------------------------------------------------
! Subroutine: avg_unpack
!> Purpose: averaged statistics object unpacking
!----------------------------------------------------------------------
subroutine avg_unpack(avg,hdata,ib,buf)

implicit none

! Passed variables
class(avgtype),intent(inout) :: avg          !< Averaged statistics
type(hdatatype),intent(in) :: hdata          !< HDIAG data
integer,intent(in) :: ib                     !< Block index
real(kind_real),intent(in) :: buf(avg%npack) !< Buffer

! Local variables
integer :: offset
logical,allocatable :: mask_0(:,:,:),mask_1(:,:,:,:),mask_2(:,:,:,:,:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Allocation
allocate(mask_0(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0))
if (.not.nam%gau_approx) allocate(mask_1(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0,avg%nsub))
allocate(mask_2(bpar%nc3(ib),bpar%nl0r(ib),geom%nl0,avg%nsub,avg%nsub))
mask_0 = .true.
if (.not.nam%gau_approx) mask_1 = .true.
mask_2 = .true.

! Unpack
offset = 0
avg%nc1a = unpack(buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0),mask_0,avg%m11)
offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0
avg%m11 = unpack(buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0),mask_0,avg%m11)
offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0
avg%m11m11 = unpack(buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub**2),mask_2,avg%m11m11)
offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub**2
avg%m2m2 = unpack(buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub**2),mask_2,avg%m2m2)
offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub**2
if (.not.nam%gau_approx) then
   avg%m22 = unpack(buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub),mask_1,avg%m22)
   offset = offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0*avg%nsub
end if
avg%cor = unpack(buf(offset+1:offset+bpar%nc3(ib)*bpar%nl0r(ib)*geom%nl0),mask_0,avg%cor)

! End associate
end associate

end subroutine avg_unpack

end module type_avg
