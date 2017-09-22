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
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msr,isnotmsr,isallnotmsr,isanynotmsr
use tools_qsort, only: qsort
use type_avg, only: avgtype,avg_alloc
use type_mom, only: momtype
use type_hdata, only: hdatatype
implicit none

real(kind_real),parameter :: qtrim = 0.05  !< Fraction for which upper and lower quantiles are removed in trimmed averages
integer,parameter :: ntrim = 1  !< Minimum number of remaining points for the trimmed average

private
public :: compute_avg,compute_avg_lr,compute_avg_asy,compute_bwavg

contains

!----------------------------------------------------------------------
! Subroutine: compute_avg
!> Purpose: compute averaged statistics via spatial-angular erogodicity assumption
!----------------------------------------------------------------------
subroutine compute_avg(hdata,mom,ic2_loc,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
type(momtype),intent(in) :: mom     !< Moments
integer,intent(in) :: ic2_loc       !< Local index
type(avgtype),intent(inout) :: avg  !< Averaged statistics

! Local variables
integer :: iv,il0,jl0,ic,isub,jsub,ic1,nc1_eff,jc1
real(kind_real) :: m2m2
real(kind_real),allocatable :: list_m11(:),list_m11m11(:,:,:),list_m2m2(:,:,:),list_m22(:,:),list_cor(:)
logical :: smask(hdata%nam%nc1)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Copy ensemble size
avg%ne = mom%ne
avg%nsub = mom%nsub

! Allocation
call avg_alloc(hdata,avg)

! TODO: MPI split

! Average
do iv=1,nam%nv
   do jl0=1,geom%nl0
      do il0=1,geom%nl0
         do ic=1,nam%nc
            ! Averaging domain
            nc1_eff = 0
            do ic1=1,nam%nc1
               if (ic2_loc>0) then
                  ! Local average
                  jc1 = hdata%nn_nc1_index(ic1,ic2_loc,min(il0,geom%nl0i))
                  smask(jc1) = (ic1==1).or.(hdata%nn_nc1_dist(ic1,ic2_loc,min(il0,geom%nl0i)) &
                             & <min(nam%local_rad,hdata%bdist(ic2_loc)))

               else
                  ! Global average
                  jc1 = ic1
                  smask(jc1) = .true.
               end if
               smask(jc1) = smask(jc1).and.hdata%ic1il0_log(jc1,jl0).and.hdata%ic1icil0iv_log(jc1,ic,il0,iv)
            end do
            nc1_eff = count(smask)

            ! Allocation of private arrays
            allocate(list_m11(nc1_eff))
            allocate(list_m11m11(nc1_eff,mom%nsub,mom%nsub))
            allocate(list_m2m2(nc1_eff,mom%nsub,mom%nsub))
            allocate(list_m22(nc1_eff,mom%nsub))
            allocate(list_cor(nc1_eff))

            ! Fill lists
            jc1 = 0
            do ic1=1,nam%nc1
               if (smask(ic1)) then
                  ! Update
                  jc1 = jc1+1

                  ! Averages for diagnostics
                  list_m11(jc1) = sum(mom%m11(ic1,ic,il0,jl0,iv,:))/float(avg%nsub)
                  do jsub=1,avg%nsub
                     do isub=1,avg%nsub
                        list_m11m11(jc1,isub,jsub) = mom%m11(ic1,ic,il0,jl0,iv,jsub)*mom%m11(ic1,ic,il0,jl0,iv,isub)
                        list_m2m2(jc1,isub,jsub) = mom%m2b(ic1,ic,il0,jl0,iv,jsub)*mom%m2(ic1,ic,il0,jl0,iv,isub)
                     end do
                     if (.not.nam%gau_approx) list_m22(jc1,jsub) = mom%m22(ic1,ic,il0,jl0,iv,jsub)
                  end do

                  ! Correlation
                  m2m2 = sum(mom%m2b(ic1,ic,il0,jl0,iv,:))*sum(mom%m2(ic1,ic,il0,jl0,iv,:))/float(mom%nsub**2)
                  if (m2m2>0.0) then
                     list_cor(jc1) = list_m11(jc1)/sqrt(m2m2)
                  else
                     if (ic==1) then
                        list_cor(jc1) = 1.0
                     else
                        list_cor(jc1) = 0.0
                     end if
                  end if
               end if
            end do

            ! Average
            avg%m11(ic,il0,jl0,iv) = taverage(nc1_eff,list_m11)
            do jsub=1,avg%nsub
               do isub=1,avg%nsub
                  avg%m11m11(ic,il0,jl0,iv,isub,jsub) = taverage(nc1_eff,list_m11m11)
                  avg%m2m2(ic,il0,jl0,iv,isub,jsub) = taverage(nc1_eff,list_m2m2)
               end do
               if (.not.nam%gau_approx) avg%m22(ic,il0,jl0,iv,jsub) = taverage(nc1_eff,list_m22)
            end do
            avg%cor(ic,il0,jl0,iv) = taverage(nc1_eff,list_cor)

            ! Release memory
            deallocate(list_m11)
            deallocate(list_m11m11)
            deallocate(list_m2m2)
            deallocate(list_m22)
            deallocate(list_cor) 
         end do
      end do
   end do
end do

! End associate
end associate

end subroutine compute_avg

!----------------------------------------------------------------------
! Function: taverage
!> Purpose: compute the trimmed average
!----------------------------------------------------------------------
real(kind_real) function taverage(n,list)

implicit none

! Passed variables
integer,intent(in) :: n        !< Number of values
real(kind_real),intent(in) :: list(n)     !< List values

! Local variable
integer :: nrm
integer :: order(n)
real(kind_real) :: list_copy(n)

! Copy list
list_copy = list

! Compute the number of values to remove
nrm = floor(n*qtrim)

if (n-2*nrm>=ntrim) then
   ! Order array
   call qsort(n,list_copy,order)

   ! Compute trimmed average
   taverage = sum(list_copy(1+nrm:n-nrm))/float(n-2*nrm)
else
   ! Missing value
   call msr(taverage)
end if

end function taverage

!----------------------------------------------------------------------
! Subroutine: compute_avg_lr
!> Purpose: compute averaged statistics via spatial-angular erogodicity assumption, for LR covariance/HR covariance and LR covariance/HR asymptotic covariance products
!----------------------------------------------------------------------
subroutine compute_avg_lr(hdata,mom,mom_lr,avg,avg_lr)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata   !< Sampling data
type(momtype),intent(in) :: mom       !< Moments
type(momtype),intent(in) :: mom_lr    !< Low-resolution moments
type(avgtype),intent(inout) :: avg    !< Averaged statistics
type(avgtype),intent(inout) :: avg_lr !< Low-resolution averaged statistics

! Local variables
integer :: iv,il0,jl0,ic

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Average
do iv=1,nam%nv
   do jl0=1,geom%nl0
      do il0=1,geom%nl0
         !$omp parallel do private(ic)
         do ic=1,nam%nc
            ! LR covariance/HR covariance product average
            avg_lr%m11lrm11(ic,il0,jl0,iv) = sum(sum(mom_lr%m11(:,ic,il0,jl0,iv,:),dim=2) &
                                           & *sum(mom%m11(:,ic,il0,jl0,iv,:),dim=2)*hdata%swgt(:,ic,il0,jl0,iv), &
                                           & mask=hdata%ic1il0_log(:,jl0).and.hdata%ic1icil0iv_log(:,ic,il0,iv)) &
                                           & /float(avg%nsub*avg_lr%nsub)

            ! LR covariance/HR asymptotic covariance product average
            avg_lr%m11lrm11asy(ic,il0,jl0,iv) = avg_lr%m11lrm11(ic,il0,jl0,iv)
         end do
         !$omp end parallel do
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
subroutine compute_avg_asy(hdata,ne,avg)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
integer,intent(in) :: ne            !< Ensemble sizes
type(avgtype),intent(inout) :: avg  !< Averaged statistics

! Local variables
integer :: n,iv,il0,jl0,ic,isub,jsub
real(kind_real) :: P1,P3,P4,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17
real(kind_real),allocatable :: m11asysq(:,:),m2m2asy(:,:),m22asy(:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

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
do iv=1,nam%nv
   do jl0=1,geom%nl0
      do il0=1,geom%nl0
         !$omp parallel do private(ic,isub,jsub,m11asysq,m2m2asy,m22asy)
         do ic=1,nam%nc
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
                        m11asysq(jsub,isub) = P17*avg%m11m11(ic,il0,jl0,iv,jsub,isub)+P13*avg%m2m2(ic,il0,jl0,iv,jsub,isub)
                        m2m2asy(jsub,isub) = 2.0*P13*avg%m11m11(ic,il0,jl0,iv,jsub,isub)+P12*avg%m2m2(ic,il0,jl0,iv,jsub,isub)
                     else
                        ! General case
                        m11asysq(jsub,isub) = P15*avg%m11m11(ic,il0,jl0,iv,jsub,isub)+P8*avg%m2m2(ic,il0,jl0,iv,jsub,isub) &
                                            & +P9*avg%m22(ic,il0,jl0,iv,isub)
                        m2m2asy(jsub,isub) = 2.0*P8*avg%m11m11(ic,il0,jl0,iv,jsub,isub)+P7*avg%m2m2(ic,il0,jl0,iv,jsub,isub) &
                                           & +P9*avg%m22(ic,il0,jl0,iv,isub)
                        m22asy(isub) = P10*(2.0*avg%m11m11(ic,il0,jl0,iv,jsub,isub)+avg%m2m2(ic,il0,jl0,iv,jsub,isub)) &
                                     & +P11*avg%m22(ic,il0,jl0,iv,isub)
                     end if
                  else
                     ! Off-diagonal terms
                     m11asysq(jsub,isub) = avg%m11m11(ic,il0,jl0,iv,jsub,isub)
                     m2m2asy(jsub,isub) = avg%m2m2(ic,il0,jl0,iv,jsub,isub)
                  end if
               end do
            end do
   
            ! Sum
            avg%m11asysq(ic,il0,jl0,iv) = sum(m11asysq)/float(avg%nsub**2)
            avg%m2m2asy(ic,il0,jl0,iv) = sum(m2m2asy)/float(avg%nsub**2)
            if (.not.nam%gau_approx) avg%m22asy(ic,il0,jl0,iv) = sum(m22asy)/float(avg%nsub)
   
            ! Check positivity
            if (avg%m11asysq(ic,il0,jl0,iv)<0.0) call msr(avg%m11asysq(ic,il0,jl0,iv))
            if (avg%m2m2asy(ic,il0,jl0,iv)<0.0) call msr(avg%m2m2asy(ic,il0,jl0,iv))
            if (.not.nam%gau_approx) then
               if (avg%m22asy(ic,il0,jl0,iv)<0.0) call msr(avg%m22asy(ic,il0,jl0,iv))
            end if
   
            ! Squared covariance average for several ensemble sizes
            if (nam%gau_approx) then
               ! Gaussian approximation
               if (isnotmsr(avg%m11asysq(ic,il0,jl0,iv)).and.isnotmsr(avg%m2m2asy(ic,il0,jl0,iv))) & 
             & avg%m11sq(ic,il0,jl0,iv) = P16*avg%m11asysq(ic,il0,jl0,iv)+P4*avg%m2m2asy(ic,il0,jl0,iv)
            else
               ! General case
               if (isnotmsr(avg%m22asy(ic,il0,jl0,iv)).and.isnotmsr(avg%m11asysq(ic,il0,jl0,iv)) &
             & .and.isnotmsr(avg%m2m2asy(ic,il0,jl0,iv))) & 
             & avg%m11sq(ic,il0,jl0,iv) = P1*avg%m22asy(ic,il0,jl0,iv)+P14*avg%m11asysq(ic,il0,jl0,iv) &
                                          & +P3*avg%m2m2asy(ic,il0,jl0,iv)
            end if

            ! Check value
            if (.not.isnotmsr(avg%m11sq(ic,il0,jl0,iv))) then
               if (avg%m11sq(ic,il0,jl0,iv)<avg%m11asysq(ic,il0,jl0,iv)) call msr(avg%m11sq(ic,il0,jl0,iv))
               if (avg%m11sq(ic,il0,jl0,iv)<avg%m11(ic,il0,jl0,iv)**2) call msr(avg%m11sq(ic,il0,jl0,iv))
            end if
   
            ! Allocation
            deallocate(m11asysq)
            deallocate(m2m2asy)
            deallocate(m22asy)
         end do
         !$omp end parallel do
      end do
   end do
end do

! End associate
end associate

end subroutine compute_avg_asy

!----------------------------------------------------------------------
! Subroutine: compute_bwavg
!> Purpose: compute block-averaged statistics
!----------------------------------------------------------------------
subroutine compute_bwavg(hdata,avg)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata !< Sampling data
type(avgtype),intent(inout) :: avg     !< Averaged statistics

! Local variables
integer :: il0,jl0,ic

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Block averages
do jl0=1,geom%nl0
   do il0=1,geom%nl0
      do ic=1,nam%nc
         avg%cor(ic,il0,jl0,nam%nv+1) = sum(avg%cor(ic,il0,jl0,1:nam%nv),mask=isnotmsr(avg%cor(ic,il0,jl0,:))) &
                                      & /count(isnotmsr(avg%cor(ic,il0,jl0,:)))
         if (isanynotmsr(avg%m11asysq(ic,il0,jl0,1:nam%nv))) & 
       & avg%m11asysq(ic,il0,jl0,nam%nv+1) = sum(hdata%bwgtsq(ic,il0,jl0,:)*avg%m11asysq(ic,il0,jl0,1:nam%nv), &
                                           & mask=isnotmsr(avg%m11asysq(ic,il0,jl0,1:nam%nv)))
         if (isanynotmsr(avg%m11sq(ic,il0,jl0,1:nam%nv))) & 
       & avg%m11sq(ic,il0,jl0,nam%nv+1) = sum(hdata%bwgtsq(ic,il0,jl0,:)*avg%m11sq(ic,il0,jl0,1:nam%nv), &
                                        & mask=isnotmsr(avg%m11sq(ic,il0,jl0,1:nam%nv)))
         select case (trim(nam%method))
         case ('hyb-avg','hyb-rnd')
            avg%m11sta(ic,il0,jl0,nam%nv+1) = sum(hdata%bwgtsq(ic,il0,jl0,:)*avg%m11sta(ic,il0,jl0,1:nam%nv))
            avg%stasq(ic,il0,jl0,nam%nv+1) = sum(hdata%bwgtsq(ic,il0,jl0,:)*avg%stasq(ic,il0,jl0,1:nam%nv))
         case ('dual-ens')
            avg%m11lrm11(ic,il0,jl0,nam%nv+1) = sum(hdata%bwgtsq(ic,il0,jl0,:)*avg%m11lrm11(ic,il0,jl0,1:nam%nv))
            if (isanynotmsr(avg%m11lrm11asy(ic,il0,jl0,1:nam%nv))) & 
          & avg%m11lrm11asy(ic,il0,jl0,nam%nv+1) = sum(hdata%bwgtsq(ic,il0,jl0,:) &
                                                 & *avg%m11lrm11asy(ic,il0,jl0,1:nam%nv), &
                                                 & mask=isnotmsr(avg%m11lrm11asy(ic,il0,jl0,1:nam%nv)))
         end select
      end do
   end do
end do

! End associate
end associate

end subroutine compute_bwavg

end module module_average
