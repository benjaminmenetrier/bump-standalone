!----------------------------------------------------------------------
! Module: module_average.f90
!> Purpose: average routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code ic1 distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module module_average

use omp_lib
use tools_const, only: taverage,add,divide
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msr,isnotmsr,isallnotmsr,isanynotmsr
use tools_qsort, only: qsort
use type_avg, only: avgtype,avg_alloc
use type_mom, only: momtype
use type_mpl, only: mpl
use type_hdata, only: hdatatype
implicit none

interface compute_avg
  module procedure compute_avg_global
  module procedure compute_avg_local
end interface
interface compute_avg_asy
  module procedure compute_avg_asy
  module procedure compute_avg_asy_local
end interface
interface compute_bwavg
  module procedure compute_bwavg
  module procedure compute_bwavg_local
end interface

private
public :: compute_avg,compute_avg_lr,compute_avg_asy,compute_bwavg

contains

!----------------------------------------------------------------------
! Subroutine: compute_avg_single
!> Purpose: compute averaged statistics via spatial-angular erogodicity assumption
!----------------------------------------------------------------------
subroutine compute_avg_single(hdata,ib,mom,ic2,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
integer,intent(in) :: ib            !< Block index
type(momtype),intent(in) :: mom     !< Moments
integer,intent(in) :: ic2       !< Local index
type(avgtype),intent(inout) :: avg  !< Averaged statistics

! Local variables
integer :: il0,jl0,ic,isub,jsub,ic1,nc1max,jc1
real(kind_real) :: m2m2
real(kind_real),allocatable :: list_m11(:),list_m11m11(:,:,:),list_m2m2(:,:,:),list_m22(:,:),list_cor(:)
logical :: valid

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Copy ensemble size
avg%ne = mom%ne
avg%nsub = mom%nsub

! Allocation
call avg_alloc(hdata,ib,avg)

! Average
do jl0=1,geom%nl0
   do il0=1,bpar%nl0(ib)
      ! Allocation
      if (ic2>0) then
         nc1max = count(hdata%local_mask(:,ic2,min(bpar%il0min(jl0,ib)+il0,geom%nl0i)))
      else
         nc1max = nam%nc1
      end if
      allocate(list_m11(nc1max))
      allocate(list_m11m11(nc1max,mom%nsub,mom%nsub))
      allocate(list_m2m2(nc1max,mom%nsub,mom%nsub))
      allocate(list_m22(nc1max,mom%nsub))
      allocate(list_cor(nc1max))

      do ic=1,bpar%icmax(ib)
         ! Fill lists
         jc1 = 0
         do ic1=1,nam%nc1
            ! Check validity
            valid = hdata%ic1il0_log(ic1,jl0).and.hdata%ic1icil0_log(ic1,ic,bpar%il0min(jl0,ib)+il0)
            if (ic2>0) valid = valid.and.hdata%local_mask(ic1,ic2,min(bpar%il0min(jl0,ib)+il0,geom%nl0i))

            if (valid) then
               ! Update
               jc1 = jc1+1

               ! Averages for diagnostics
               list_m11(jc1) = sum(mom%m11(ic1,ic,il0,jl0,:))/float(avg%nsub)
               do jsub=1,avg%nsub
                  do isub=1,avg%nsub
                     list_m11m11(jc1,isub,jsub) = mom%m11(ic1,ic,il0,jl0,jsub)*mom%m11(ic1,ic,il0,jl0,isub)
                     list_m2m2(jc1,isub,jsub) = mom%m2_1(ic1,ic,il0,jl0,jsub)*mom%m2_2(ic1,ic,il0,jl0,isub)
                  end do
                  if (.not.nam%gau_approx) list_m22(jc1,jsub) = mom%m22(ic1,ic,il0,jl0,jsub)
               end do

               ! Correlation
               m2m2 = sum(mom%m2_1(ic1,ic,il0,jl0,:))*sum(mom%m2_2(ic1,ic,il0,jl0,:))/float(mom%nsub**2)
               if (m2m2>0.0) then
                  list_cor(jc1) = list_m11(jc1)/sqrt(m2m2)
               else
                  call msr(list_cor(jc1))
               end if
            end if
         end do

         ! Average
         avg%m11(ic,il0,jl0) = taverage(jc1,list_m11(1:jc1))
         do jsub=1,avg%nsub
            do isub=1,avg%nsub
               avg%m11m11(ic,il0,jl0,isub,jsub) = taverage(jc1,list_m11m11(1:jc1,isub,jsub))
               avg%m2m2(ic,il0,jl0,isub,jsub) = taverage(jc1,list_m2m2(1:jc1,isub,jsub))
            end do
            if (.not.nam%gau_approx) avg%m22(ic,il0,jl0,jsub) = taverage(jc1,list_m22(1:jc1,jsub))
         end do
         avg%cor(ic,il0,jl0) = taverage(jc1,list_cor(1:jc1))
      end do

      ! Release memory
      deallocate(list_m11)
      deallocate(list_m11m11)
      deallocate(list_m2m2)
      deallocate(list_m22)
      deallocate(list_cor) 
   end do
end do

! End associate
end associate

end subroutine compute_avg_single

!----------------------------------------------------------------------
! Subroutine: compute_avg_global
!> Purpose: compute averaged statistics via spatial-angular erogodicity assumption, global
!----------------------------------------------------------------------
subroutine compute_avg_global(hdata,ib,mom,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
integer,intent(in) :: ib            !< Block index
type(momtype),intent(in) :: mom     !< Moments
type(avgtype),intent(inout) :: avg  !< Averaged statistics

! Loop over points
call compute_avg_single(hdata,ib,mom,0,avg)

end subroutine compute_avg_global

!----------------------------------------------------------------------
! Subroutine: compute_avg_local
!> Purpose: compute averaged statistics via spatial-angular erogodicity assumption, local
!----------------------------------------------------------------------
subroutine compute_avg_local(hdata,ib,mom,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata            !< Sampling data
integer,intent(in) :: ib                       !< Block index
type(momtype),intent(in) :: mom                !< Moments
type(avgtype),intent(inout) :: avg(hdata%nc2)  !< Averaged statistics

! Local variables
integer :: ic2

! Loop over points
!$omp parallel do private(ic2)
do ic2=1,hdata%nc2
   call compute_avg_single(hdata,ib,mom,ic2,avg(ic2))
end do
!$omp end parallel do

end subroutine compute_avg_local

!----------------------------------------------------------------------
! Subroutine: compute_avg_lr
!> Purpose: compute averaged statistics via spatial-angular erogodicity assumption, for LR covariance/HR covariance and LR covariance/HR asymptotic covariance products
!----------------------------------------------------------------------
subroutine compute_avg_lr(hdata,ib,mom,mom_lr,avg,avg_lr)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata   !< Sampling data
integer,intent(in) :: ib              !< Block index
type(momtype),intent(in) :: mom       !< Moments
type(momtype),intent(in) :: mom_lr    !< Low-resolution moments
type(avgtype),intent(inout) :: avg    !< Averaged statistics
type(avgtype),intent(inout) :: avg_lr !< Low-resolution averaged statistics

! Local variables
integer :: il0,jl0,ic

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Average
do jl0=1,geom%nl0
   do il0=1,bpar%nl0(ib)
      do ic=1,bpar%icmax(ib)
         ! LR covariance/HR covariance product average
         avg_lr%m11lrm11(ic,il0,jl0) = sum(sum(mom_lr%m11(:,ic,il0,jl0,:),dim=2) &
                                     & *sum(mom%m11(:,ic,il0,jl0,:),dim=2)*hdata%swgt(:,ic,bpar%il0min(jl0,ib)+il0,jl0), &
                                     & mask=hdata%ic1il0_log(:,jl0).and.hdata%ic1icil0_log(:,ic,bpar%il0min(jl0,ib)+il0)) &
                                     & /float(avg%nsub*avg_lr%nsub)

         ! LR covariance/HR asymptotic covariance product average
         avg_lr%m11lrm11asy(ic,il0,jl0) = avg_lr%m11lrm11(ic,il0,jl0)
      end do
   end do
end do

! End associate
end associate

end subroutine compute_avg_lr

!----------------------------------------------------------------------
! Subroutine: compute_avg_asy
!> Purpose: compute averaged asymptotic statistics
!----------------------------------------------------------------------
subroutine compute_avg_asy(hdata,ib,ne,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
integer,intent(in) :: ib            !< Block index
integer,intent(in) :: ne            !< Ensemble sizes
type(avgtype),intent(inout) :: avg  !< Averaged statistics

! Local variables
integer :: n,il0,jl0,ic,isub,jsub
real(kind_real) :: P1,P3,P4,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17
real(kind_real),allocatable :: m11asysq(:,:),m2m2asy(:,:),m22asy(:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Ensemble size-dependent coefficients
n = ne
P1 = 1.0/float(n)
P3 = 1.0/float(n*(n-1))
P4 = 1.0/float(n-1)
P14 = float(n**2-2*n+2)/float(n*(n-1))
P16 = float(n)/float(n-1)

! Ensemble/sub-ensemble size-dependent coefficients
n = avg%ne/avg%nsub
P7 = float((n-1)*(n**2-3*n+1))/float(n*(n-2)*(n-3))
P8 = float(n-1)/float(n*(n-2)*(n-3))
P9 = -float(n)/float((n-2)*(n-3))
P10 = -float((n-1)*(2*n-3))/float(n*(n-2)*(n-3))
P11 = float(n*(n**2-2*n+3))/float((n-1)*(n-2)*(n-3))
P12 = float(n*(n-1))/float((n-2)*(n+1))
P13 = -float(n-1)/float((n-2)*(n+1))
P15 = float((n-1)**2)/float(n*(n-3))
P17 = float((n-1)**2)/float((n-2)*(n+1))

! Asymptotic statistics
do jl0=1,geom%nl0
   do il0=1,bpar%nl0(ib)
      do ic=1,bpar%icmax(ib)
         ! Allocation
         allocate(m11asysq(avg%nsub,avg%nsub))
         allocate(m2m2asy(avg%nsub,avg%nsub))
         allocate(m22asy(avg%nsub))

         ! Asymptotic statistics
         do isub=1,avg%nsub
            do jsub=1,avg%nsub
               if (isub==jsub) then
                  ! Diagonal terms
                  if (nam%gau_approx) then
                     ! Gaussian approximation
                     m11asysq(jsub,isub) = P17*avg%m11m11(ic,il0,jl0,jsub,isub)+P13*avg%m2m2(ic,il0,jl0,jsub,isub)
                     m2m2asy(jsub,isub) = 2.0*P13*avg%m11m11(ic,il0,jl0,jsub,isub)+P12*avg%m2m2(ic,il0,jl0,jsub,isub)
                  else
                     ! General case
                     m11asysq(jsub,isub) = P15*avg%m11m11(ic,il0,jl0,jsub,isub)+P8*avg%m2m2(ic,il0,jl0,jsub,isub) &
                                         & +P9*avg%m22(ic,il0,jl0,isub)
                     m2m2asy(jsub,isub) = 2.0*P8*avg%m11m11(ic,il0,jl0,jsub,isub)+P7*avg%m2m2(ic,il0,jl0,jsub,isub) &
                                        & +P9*avg%m22(ic,il0,jl0,isub)
                     m22asy(isub) = P10*(2.0*avg%m11m11(ic,il0,jl0,jsub,isub)+avg%m2m2(ic,il0,jl0,jsub,isub)) &
                                  & +P11*avg%m22(ic,il0,jl0,isub)
                  end if
               else
                  ! Off-diagonal terms
                  m11asysq(jsub,isub) = avg%m11m11(ic,il0,jl0,jsub,isub)
                  m2m2asy(jsub,isub) = avg%m2m2(ic,il0,jl0,jsub,isub)
               end if
            end do
         end do

         ! Sum
         avg%m11asysq(ic,il0,jl0) = sum(m11asysq)/float(avg%nsub**2)
         avg%m2m2asy(ic,il0,jl0) = sum(m2m2asy)/float(avg%nsub**2)
         if (.not.nam%gau_approx) avg%m22asy(ic,il0,jl0) = sum(m22asy)/float(avg%nsub)

         ! Check positivity
         if (.not.(avg%m11asysq(ic,il0,jl0)>0.0)) call msr(avg%m11asysq(ic,il0,jl0))
         if (.not.(avg%m2m2asy(ic,il0,jl0)>0.0)) call msr(avg%m2m2asy(ic,il0,jl0))
         if (.not.nam%gau_approx) then
            if (.not.(avg%m22asy(ic,il0,jl0)>0.0)) call msr(avg%m22asy(ic,il0,jl0))
         end if

         ! Squared covariance average for several ensemble sizes
         if (nam%gau_approx) then
            ! Gaussian approximation
            if (isnotmsr(avg%m11asysq(ic,il0,jl0)).and.isnotmsr(avg%m2m2asy(ic,il0,jl0))) & 
          & avg%m11sq(ic,il0,jl0) = P16*avg%m11asysq(ic,il0,jl0)+P4*avg%m2m2asy(ic,il0,jl0)
         else
            ! General case
            if (isnotmsr(avg%m22asy(ic,il0,jl0)).and.isnotmsr(avg%m11asysq(ic,il0,jl0)) &
          & .and.isnotmsr(avg%m2m2asy(ic,il0,jl0))) & 
          & avg%m11sq(ic,il0,jl0) = P1*avg%m22asy(ic,il0,jl0)+P14*avg%m11asysq(ic,il0,jl0) &
                                  & +P3*avg%m2m2asy(ic,il0,jl0)
         end if

         ! Check value
         if (.not.isnotmsr(avg%m11sq(ic,il0,jl0))) then
            if (avg%m11sq(ic,il0,jl0)<avg%m11asysq(ic,il0,jl0)) call msr(avg%m11sq(ic,il0,jl0))
            if (avg%m11sq(ic,il0,jl0)<avg%m11(ic,il0,jl0)**2) call msr(avg%m11sq(ic,il0,jl0))
         end if

         ! Allocation
         deallocate(m11asysq)
         deallocate(m2m2asy)
         deallocate(m22asy)
      end do
   end do
end do

! End associate
end associate

end subroutine compute_avg_asy

!----------------------------------------------------------------------
! Subroutine: compute_avg_asy_local
!> Purpose: compute averaged asymptotic statistics, local
!----------------------------------------------------------------------
subroutine compute_avg_asy_local(hdata,ib,ne,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
integer,intent(in) :: ib            !< Block index
integer,intent(in) :: ne            !< Ensemble sizes
type(avgtype),intent(inout) :: avg(hdata%nc2)  !< Averaged statistics

! Local variables
integer :: ic2

! Loop over points
!$omp parallel do private(ic2)
do ic2=1,hdata%nc2
   call compute_avg_asy(hdata,ib,ne,avg(ic2))
end do
!$omp end parallel do

end subroutine compute_avg_asy_local

!----------------------------------------------------------------------
! Subroutine: compute_bwavg
!> Purpose: compute block-averaged statistics
!----------------------------------------------------------------------
subroutine compute_bwavg(hdata,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata                !< Sampling data
type(avgtype),intent(inout) :: avg(hdata%bpar%nb+1) !< Averaged statistics

! Local variables
integer :: ib,il0,jl0,ic
real(kind_real),allocatable :: cor(:,:,:),m11asysq(:,:,:),m11sq(:,:,:)
real(kind_real),allocatable :: m11sta(:,:,:),stasq(:,:,:)
real(kind_real),allocatable :: m11lrm11(:,:,:),m11lrm11asy(:,:,:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Copy ensemble size
avg(bpar%nb+1)%ne = avg(1)%ne
avg(bpar%nb+1)%nsub = avg(1)%nsub

! Allocation
call avg_alloc(hdata,bpar%nb+1,avg(bpar%nb+1))

! Allocation
allocate(cor(nam%nc,geom%nl0,geom%nl0))
allocate(m11asysq(nam%nc,geom%nl0,geom%nl0))
allocate(m11sq(nam%nc,geom%nl0,geom%nl0))
select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   allocate(m11sta(nam%nc,geom%nl0,geom%nl0))
   allocate(stasq(nam%nc,geom%nl0,geom%nl0))
case ('dual-ens')
   allocate(m11lrm11(nam%nc,geom%nl0,geom%nl0))
   allocate(m11lrm11asy(nam%nc,geom%nl0,geom%nl0))
end select

! Initialization
avg(bpar%nb+1)%cor = 0.0
cor = 0.0
avg(bpar%nb+1)%m11asysq = 0.0
m11asysq = 0.0
avg(bpar%nb+1)%m11sq = 0.0
m11sq = 0.0
select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   avg(bpar%nb+1)%m11sta = 0.0
   m11sta = 0.0
   avg(bpar%nb+1)%stasq = 0.0
   stasq = 0.0
case ('dual-ens')
   avg(bpar%nb+1)%m11lrm11 = 0.0
   m11lrm11 = 0.0
   avg(bpar%nb+1)%m11lrm11asy = 0.0
   m11lrm11asy = 0.0
end select

! Block averages
do ib=1,bpar%nb
   if (bpar%avg_block(ib)) then
      do jl0=1,geom%nl0
         do il0=1,geom%nl0
            do ic=1,nam%nc
               call add(avg(ib)%cor(ic,il0,jl0),avg(bpar%nb+1)%cor(ic,il0,jl0),cor(ic,il0,jl0))
               call add(avg(ib)%m11asysq(ic,il0,jl0),avg(bpar%nb+1)%m11asysq(ic,il0,jl0),m11asysq(ic,il0,jl0), &
             & hdata%bwgtsq(ic,il0,jl0,ib))
               call add(avg(ib)%m11sq(ic,il0,jl0),avg(bpar%nb+1)%m11sq(ic,il0,jl0),m11sq(ic,il0,jl0), &
             & hdata%bwgtsq(ic,il0,jl0,ib))
               select case (trim(nam%method))
               case ('hyb-avg','hyb-rnd')
                  call add(avg(ib)%m11sta(ic,il0,jl0),avg(bpar%nb+1)%m11sta(ic,il0,jl0),m11sta(ic,il0,jl0), &
                & hdata%bwgtsq(ic,il0,jl0,ib))
                  call add(avg(ib)%stasq(ic,il0,jl0),avg(bpar%nb+1)%stasq(ic,il0,jl0),stasq(ic,il0,jl0), &
                & hdata%bwgtsq(ic,il0,jl0,ib))
               case ('dual-ens')
                  call add(avg(ib)%m11lrm11(ic,il0,jl0),avg(bpar%nb+1)%m11lrm11(ic,il0,jl0),m11lrm11(ic,il0,jl0), &
                & hdata%bwgtsq(ic,il0,jl0,ib))
                  call add(avg(ib)%m11lrm11asy(ic,il0,jl0),avg(bpar%nb+1)%m11lrm11asy(ic,il0,jl0),m11lrm11asy(ic,il0,jl0), &
                & hdata%bwgtsq(ic,il0,jl0,ib))
               end select
            end do
         end do
      end do
   end if
end do

! Normalization
do jl0=1,geom%nl0
   do il0=1,geom%nl0
      do ic=1,nam%nc
         call divide(avg(bpar%nb+1)%cor(ic,il0,jl0),cor(ic,il0,jl0))
         call divide(avg(bpar%nb+1)%m11asysq(ic,il0,jl0),m11asysq(ic,il0,jl0))
         call divide(avg(bpar%nb+1)%m11sq(ic,il0,jl0),m11sq(ic,il0,jl0))
         select case (trim(nam%method))
         case ('hyb-avg','hyb-rnd')
            call divide(avg(bpar%nb+1)%m11sta(ic,il0,jl0),m11sta(ic,il0,jl0))
            call divide(avg(bpar%nb+1)%stasq(ic,il0,jl0),stasq(ic,il0,jl0))
         case ('dual-ens')
            call divide(avg(bpar%nb+1)%m11lrm11(ic,il0,jl0),m11lrm11(ic,il0,jl0))
            call divide(avg(bpar%nb+1)%m11lrm11asy(ic,il0,jl0),m11lrm11asy(ic,il0,jl0))
         end select
      end do
   end do
end do

! End associate
end associate

end subroutine compute_bwavg

!----------------------------------------------------------------------
! Subroutine: compute_bwavg_local
!> Purpose: compute block-averaged statistics, local
!----------------------------------------------------------------------
subroutine compute_bwavg_local(hdata,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata                !< Sampling data
type(avgtype),intent(inout) :: avg(hdata%nc2,hdata%bpar%nb+1) !< Averaged statistics

! Local variables
integer :: ic2

! Loop over points
!$omp parallel do private(ic2)
do ic2=1,hdata%nc2
   call compute_bwavg(hdata,avg(ic2,:))
end do 
!$omp end parallel do

end subroutine compute_bwavg_local

end module module_average
