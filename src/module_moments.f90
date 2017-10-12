!----------------------------------------------------------------------
! Module: module_moments.f90
!> Purpose: moments routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code ic1 distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module module_moments

use omp_lib
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msr,isnotmsr
use type_ens, only: enstype,load_field
use type_mom, only: momtype
use type_mpl, only: mpl
use type_hdata, only: hdatatype
implicit none

logical,parameter :: momtest = .false. !< Test recursive formulas

private
public :: compute_moments

contains

!----------------------------------------------------------------------
! Subroutine: compute_moments
!> Purpose: compute centered moments (iterative formulae)
!----------------------------------------------------------------------
subroutine compute_moments(hdata,ens,ib,mom)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
type(enstype),intent(in) :: ens
integer,intent(in) :: ib
type(momtype),intent(inout) :: mom     !< Moments

! Local variables
integer :: ie,ic0,jc0,il0,jl0,isub,ic,ic1
real(kind_real) :: fac1,fac2,fac3,fac4,fac5,fac6
real(kind_real),allocatable :: fld_1(:,:),fld_2(:,:)
real(kind_real),allocatable :: m21(:,:,:,:),m12(:,:,:,:)
real(kind_real),allocatable :: m22test(:,:,:,:),m21test(:,:,:,:),m12test(:,:,:,:)
real(kind_real),allocatable :: m11test(:,:,:,:),m2test(:,:,:,:),m2btest(:,:,:,:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Allocation
mom%ne = ens%ne
mom%nsub = ens%nsub
allocate(mom%m1_1(geom%nc0,geom%nl0,mom%nsub))
allocate(mom%m2_1(nam%nc1,nam%nc,geom%nl0,geom%nl0,mom%nsub))
allocate(mom%m1_2(geom%nc0,geom%nl0,mom%nsub))
allocate(mom%m2_2(nam%nc1,nam%nc,geom%nl0,geom%nl0,mom%nsub))
if (nam%full_var) allocate(mom%m2full(geom%nc0,geom%nl0,mom%nsub))
allocate(mom%m11(nam%nc1,nam%nc,geom%nl0,geom%nl0,mom%nsub))
if (.not.nam%gau_approx) then
   allocate(m21(nam%nc1,nam%nc,geom%nl0,geom%nl0))
   allocate(m12(nam%nc1,nam%nc,geom%nl0,geom%nl0))
   allocate(mom%m22(nam%nc1,nam%nc,geom%nl0,geom%nl0,mom%nsub))
end if
if (momtest) then
   allocate(m2btest(nam%nc1,nam%nc,geom%nl0,geom%nl0))
   allocate(m2test(nam%nc1,nam%nc,geom%nl0,geom%nl0))
   allocate(m11test(nam%nc1,nam%nc,geom%nl0,geom%nl0))
   if (.not.nam%gau_approx) then
      allocate(m21test(nam%nc1,nam%nc,geom%nl0,geom%nl0))
      allocate(m12test(nam%nc1,nam%nc,geom%nl0,geom%nl0))
      allocate(m22test(nam%nc1,nam%nc,geom%nl0,geom%nl0))
   end if
end if

! Initialization
mom%m1_1 = 0.0
mom%m2_1 = 0.0
mom%m1_2 = 0.0
mom%m2_2 = 0.0
if (nam%full_var) mom%m2full = 0.0
mom%m11 = 0.0
if (.not.nam%gau_approx) mom%m22 = 0.0

! Loop on sub-ensembles
do isub=1,ens%nsub
   if (ens%nsub==1) then
      write(mpl%unit,'(a10,a)',advance='no') '','Full ensemble, member:'
   else
      write(mpl%unit,'(a10,a,i4,a)',advance='no') '','Sub-ensemble ',isub,', member:'
   end if

   ! Initialization
   if (.not.nam%gau_approx) then
      m21 = 0.0
      m12 = 0.0
   end if

   ! Compute centered moments iteratively
   do ie=1,ens%ne/ens%nsub
      write(mpl%unit,'(i4)',advance='no') ens%ne_offset+ie

      ! Computation factors
      fac1 = 2.0/float(ie)
      fac2 = 1.0/float(ie**2)
      fac3 = float((ie-1)*(ie**2-3*ie+3))/float(ie**3)
      fac4 = 1.0/float(ie)
      fac5 = float((ie-1)*(ie-2))/float(ie**2)
      fac6 = float(ie-1)/float(ie)

      ! Load fields
      call load_field(nam,geom,ens,nam%ib_to_iv(ib),nam%ib_to_its(ib),ie,isub,.false.,fld_1)
      call load_field(nam,geom,ens,nam%ib_to_jv(ib),nam%ib_to_jts(ib),ie,isub,.false.,fld_2)

      ! Remove means
      fld_1 = fld_1 - mom%m1_1(:,:,isub)
      fld_2 = fld_2 - mom%m1_2(:,:,isub)

      ! Update high-order moments
      if (ie>1) then
         do jl0=1,geom%nl0
            do il0=1,geom%nl0
               do ic=1,nam%nc
                  !$omp parallel do private(ic1,ic0,jc0)
                  do ic1=1,nam%nc1
                     if (hdata%ic1il0_log(ic1,jl0).and.hdata%ic1icil0_log(ic1,ic,il0)) then
                        ! Indices
                        ic0 = hdata%ic1icil0_to_ic0(ic1,ic,il0)
                        jc0 = hdata%ic1_to_ic0(ic1)

                        if (.not.nam%gau_approx) then
                           ! Fourth-order moment
                           mom%m22(ic1,ic,il0,jl0,isub) = mom%m22(ic1,ic,il0,jl0,isub) &
                            & -fac1*(m21(ic1,ic,il0,jl0)*fld_2(ic0,il0)+m12(ic1,ic,il0,jl0)*fld_1(jc0,jl0)) &
                            & +fac2*(4.0*mom%m11(ic1,ic,il0,jl0,isub)*fld_1(jc0,jl0)*fld_2(ic0,il0) &
                            & +mom%m2_1(ic1,ic,il0,jl0,isub)*fld_2(ic0,il0)**2 & 
                            & +mom%m2_2(ic1,ic,il0,jl0,isub)*fld_1(jc0,jl0)**2) &
                            & +fac3*fld_1(jc0,jl0)**2*fld_2(ic0,il0)**2

                           ! Third-order moments
                           m21(ic1,ic,il0,jl0) = m21(ic1,ic,il0,jl0) &
                            & -fac4*(2.0*mom%m11(ic1,ic,il0,jl0,isub)*fld_1(jc0,jl0) &
                            & +mom%m2_1(ic1,ic,il0,jl0,isub)*fld_2(ic0,il0)) &
                            & +fac5*fld_1(jc0,jl0)**2*fld_2(ic0,il0)

                           m12(ic1,ic,il0,jl0) = m12(ic1,ic,il0,jl0) &
                            & -fac4*(2.0*mom%m11(ic1,ic,il0,jl0,isub)*fld_2(ic0,il0) &
                            & +mom%m2_2(ic1,ic,il0,jl0,isub)*fld_1(jc0,jl0)) &
                            & +fac5*fld_2(ic0,il0)**2*fld_1(jc0,jl0)
                        end if

                        ! Covariance
                        mom%m11(ic1,ic,il0,jl0,isub) = mom%m11(ic1,ic,il0,jl0,isub) &
                                                        & +fac6*fld_1(jc0,jl0)*fld_2(ic0,il0)

                        ! Variances
                        mom%m2_1(ic1,ic,il0,jl0,isub) = mom%m2_1(ic1,ic,il0,jl0,isub)+fac6*fld_1(jc0,jl0)**2
                        mom%m2_2(ic1,ic,il0,jl0,isub) = mom%m2_2(ic1,ic,il0,jl0,isub)+fac6*fld_2(ic0,il0)**2
                     end if
                  end do
                  !$omp end parallel do
               end do
            end do
         end do

         ! Full variance
         if (nam%full_var) then
            do il0=1,geom%nl0
               !$omp parallel do private(ic0)
               do ic0=1,geom%nc0
                  if (geom%mask(ic0,il0)) then
                     mom%m2full(ic0,il0,isub) = mom%m2full(ic0,il0,isub)+fac6*fld_1(ic0,il0)**2
                  end if
               end do
               !$omp end parallel do
            end do
         end if
      end if

      ! Update means
      do il0=1,geom%nl0
      !$omp parallel do private(ic0)
         do ic0=1,geom%nc0
            if (geom%mask(ic0,il0)) then
               mom%m1_1(ic0,il0,isub) = mom%m1_1(ic0,il0,isub)+fac4*fld_1(ic0,il0)
               mom%m1_2(ic0,il0,isub) = mom%m1_2(ic0,il0,isub)+fac4*fld_2(ic0,il0)
            end if
         end do
         !$omp end parallel do
      end do

      ! Release memory
      deallocate(fld_1)
      deallocate(fld_2)
   end do
   write(mpl%unit,'(a)') ''

   if (momtest) then
      ! Test recursive formulas
      write(mpl%unit,'(a10,a)',advance='no') '','Test recursive formulas, member:'

      ! Initialization
      if (.not.nam%gau_approx) then
         m22test = 0.0
         m21test = 0.0
         m12test = 0.0
      end if
      m11test = 0.0
      m2test = 0.0
      m2btest = 0.0

      do ie=1,ens%ne/ens%nsub
         write(mpl%unit,'(i4)',advance='no') ens%ne_offset+ie

         ! Load fields
         call load_field(nam,geom,ens,nam%ib_to_iv(ib),nam%ib_to_its(ib),ie,isub,.false.,fld_1)
         call load_field(nam,geom,ens,nam%ib_to_jv(ib),nam%ib_to_jts(ib),ie,isub,.false.,fld_2)

         ! Remove means
         fld_1 = fld_1 - mom%m1_1(:,:,isub)
         fld_2 = fld_2 - mom%m1_2(:,:,isub)

         do jl0=1,geom%nl0
            do il0=1,geom%nl0
               do ic=1,nam%nc
                  !$omp parallel do private(ic1,ic0,jc0)
                  do ic1=1,nam%nc1
                     if (hdata%ic1il0_log(ic1,jl0).and.hdata%ic1icil0_log(ic1,ic,il0)) then
                        ! Indices
                        ic0 = hdata%ic1icil0_to_ic0(ic1,ic,il0)
                        jc0 = hdata%ic1_to_ic0(ic1)

                        ! Update moments
                        if (.not.nam%gau_approx) then
                           m22test(ic1,ic,il0,jl0) = m22test(ic1,ic,il0,jl0)+fld_1(jc0,jl0)**2*fld_2(ic0,il0)**2
                           m21test(ic1,ic,il0,jl0) = m21test(ic1,ic,il0,jl0)+fld_1(jc0,jl0)**2*fld_2(ic0,il0)
                           m12test(ic1,ic,il0,jl0) = m12test(ic1,ic,il0,jl0)+fld_1(jc0,jl0)*fld_2(ic0,il0)**2
                        end if
                        m11test(ic1,ic,il0,jl0) = m11test(ic1,ic,il0,jl0)+fld_1(jc0,jl0)*fld_2(ic0,il0)
                        m2test(ic1,ic,il0,jl0) = m2test(ic1,ic,il0,jl0)+fld_2(ic0,il0)**2
                        m2btest(ic1,ic,il0,jl0) = m2btest(ic1,ic,il0,jl0)+fld_1(jc0,jl0)**2
                     end if
                  end do
                  !$omp end parallel do
               end do
            end do
         end do

         ! Release memory
         deallocate(fld_1)
         deallocate(fld_2)
      end do
      write(mpl%unit,'(a)') ''

      ! Test
      write(mpl%unit,'(a10,a)') '','Max and avg. relative RMS error between recursive and non-recursive formulas:'
      if (.not.nam%gau_approx) then
         write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m22: ',maxval(100.0*abs(mom%m22(:,:,:,:,isub)-m22test)/abs(m22test), &
       & mask=abs(m22test)>0.0),' % / ',sum(100.0*abs(mom%m22(:,:,:,:,isub)-m22test)/abs(m22test), &
       & mask=abs(m22test)>0.0)/float(count(abs(m22test)>0.0)),' %'
         write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m21: ',maxval(100.0*abs(m21-m21test)/abs(m21test), &
       & mask=abs(m21test)>0.0),' % / ',sum(100.0*abs(m21-m21test)/abs(m21test), &
       & mask=abs(m21test)>0.0)/float(count(abs(m21test)>0.0)),' %'
         write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m12: ',maxval(100.0*abs(m12-m12test)/abs(m12test), &
       & mask=abs(m12test)>0.0),' % / ',sum(100.0*abs(m12-m12test)/abs(m12test), &
       & mask=abs(m12test)>0.0)/float(count(abs(m12test)>0.0)),' %'
      end if
      write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m11: ',maxval(100.0*abs(mom%m11(:,:,:,:,isub)-m11test)/abs(m11test), &
    & mask=abs(m11test)>0.0),' % / ',sum(100.0*abs(mom%m11(:,:,:,:,isub)-m11test)/abs(m11test), &
    & mask=abs(m11test)>0.0)/float(count(abs(m11test)>0.0)),' %'
      write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m2_1: ',maxval(100.0*abs(mom%m2_1(:,:,:,:,isub)-m2btest)/abs(m2btest), &
    & mask=abs(m2btest)>0.0),' % / ',sum(100.0*abs(mom%m2_1(:,:,:,:,isub)-m2btest)/abs(m2btest), &
    & mask=abs(m2btest)>0.0)/float(count(abs(m2btest)>0.0)),' %'
      write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m2_2: ',maxval(100.0*abs(mom%m2_2(:,:,:,:,isub)-m2test)/abs(m2test), &
    & mask=abs(m2test)>0.0),' % / ',sum(100.0*abs(mom%m2_2(:,:,:,:,isub)-m2test)/abs(m2test), &
    & mask=abs(m2test)>0.0)/float(count(abs(m2test)>0.0)),' %'
   end if

   ! Normalize
   mom%m2_1(:,:,:,:,isub) = mom%m2_1(:,:,:,:,isub)/float(ens%ne/ens%nsub-1)
   mom%m2_2(:,:,:,:,isub) = mom%m2_2(:,:,:,:,isub)/float(ens%ne/ens%nsub-1)
   mom%m11(:,:,:,:,isub) = mom%m11(:,:,:,:,isub)/float(ens%ne/ens%nsub-1)
   if (nam%full_var) mom%m2full(:,:,isub) = mom%m2full(:,:,isub)/float(ens%ne/ens%nsub-1)
   if (.not.nam%gau_approx) mom%m22(:,:,:,:,isub) = mom%m22(:,:,:,:,isub)/float(ens%ne/ens%nsub)
end do

! Release memory
if (.not.nam%gau_approx) then
   deallocate(m21)
   deallocate(m12)
end if

! End associate
end associate

end subroutine compute_moments

end module module_moments
