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

use model_interface, only: model_read
use omp_lib
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msr,isnotmsr
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
subroutine compute_moments(ensname,hdata,mom)

implicit none

! Passed variables
character(len=*),intent(in) :: ensname !< Ensemble name
type(hdatatype),intent(inout) :: hdata !< Sampling data
type(momtype),intent(inout) :: mom     !< Moments

! Local variables
integer :: ie,ic0,jc0,iv,il0,jl0,isub,ic,ic1
real(kind_real) :: fac1,fac2,fac3,fac4,fac5,fac6
real(kind_real) :: fldb(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: fld(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: m1(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv)
real(kind_real),allocatable :: m21(:,:,:,:,:),m12(:,:,:,:,:)
real(kind_real),allocatable :: m22test(:,:,:,:,:),m21test(:,:,:,:,:),m12test(:,:,:,:,:)
real(kind_real),allocatable :: m11test(:,:,:,:,:),m2test(:,:,:,:,:),m2btest(:,:,:,:,:)
type(momtype) :: mom_cross

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Copy ensemble parameters
if (trim(ensname)=='ens1') then
   mom%ne = nam%ens1_ne
   mom%ne_offset = nam%ens1_ne_offset
   mom%nsub = nam%ens1_nsub
elseif (trim(ensname)=='ens2') then
   mom%ne = nam%ens2_ne
   mom%ne_offset = nam%ens2_ne_offset
   mom%nsub = nam%ens2_nsub
elseif (trim(ensname)=='cross') then
   mom%ne = nam%ens1_ne
   mom%ne_offset = nam%ens1_ne_offset
   mom%nsub = nam%ens1_nsub
   mom_cross%ne = nam%ens2_ne
   mom_cross%ne_offset = nam%ens2_ne_offset
   mom_cross%nsub = nam%ens2_nsub
else
   call msgerror('wrong ensemble name')
end if

! Allocation
allocate(mom%input(nam%nv))
allocate(mom%varname(nam%nv))
allocate(mom%time(nam%nv))
allocate(mom%m1b(geom%nc0,geom%nl0,nam%nv,mom%nsub))
allocate(mom%m2b(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv,mom%nsub))
allocate(mom%m2(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv,mom%nsub))
if (nam%full_var) allocate(mom%m2full(geom%nc0,geom%nl0,nam%nv,mom%nsub))
allocate(mom%m11(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv,mom%nsub))
if (.not.nam%gau_approx) then
   allocate(m21(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv))
   allocate(m12(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv))
   allocate(mom%m22(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv,mom%nsub))
end if
if (momtest) then
   allocate(m2btest(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv))
   allocate(m2test(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv))
   allocate(m11test(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv))
   if (.not.nam%gau_approx) then
      allocate(m21test(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv))
      allocate(m12test(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv))
      allocate(m22test(nam%nc1,nam%nc,geom%nl0,geom%nl0,nam%nv))
   end if
end if

! Copy members parameters
if (trim(ensname)=='ens1') then
   mom%input = nam%ens1_input(1:nam%nv)
   mom%varname = nam%ens1_varname(1:nam%nv)
   mom%time = nam%ens1_time(1:nam%nv)
elseif (trim(ensname)=='ens2') then
   mom%input = nam%ens2_input(1:nam%nv)
   mom%varname = nam%ens2_varname(1:nam%nv)
   mom%time = nam%ens2_time(1:nam%nv)
elseif (trim(ensname)=='cross') then
   mom%input = nam%ens1_input(1:nam%nv)
   mom%varname = nam%ens1_varname(1:nam%nv)
   mom%time = nam%ens1_time(1:nam%nv)
   mom_cross%input = nam%ens2_input(1:nam%nv)
   mom_cross%varname = nam%ens2_varname(1:nam%nv)
   mom_cross%time = nam%ens2_time(1:nam%nv)
else
   call msgerror('wrong ensemble name')
end if

! Initialization
mom%m1b = 0.0
mom%m2b = 0.0
mom%m2 = 0.0
if (nam%full_var) mom%m2full = 0.0
mom%m11 = 0.0
if (.not.nam%gau_approx) mom%m22 = 0.0

! Loop on sub-ensembles
do isub=1,mom%nsub
   if (mom%nsub==1) then
      write(mpl%unit,'(a10,a)',advance='no') '','Full ensemble, member:'
   else
      write(mpl%unit,'(a10,a,i4,a)',advance='no') '','Sub-ensemble ',isub,', member:'
   end if

   ! Initialization
   if (.not.nam%gau_approx) then
      m21 = 0.0
      m12 = 0.0
   end if
   m1 = 0.0

   ! Compute centered moments iteratively
   do ie=1,mom%ne/mom%nsub
      write(mpl%unit,'(i4)',advance='no') mom%ne_offset+ie

      ! Computation factors
      fac1 = 2.0/float(ie)
      fac2 = 1.0/float(ie**2)
      fac3 = float((ie-1)*(ie**2-3*ie+3))/float(ie**3)
      fac4 = 1.0/float(ie)
      fac5 = float((ie-1)*(ie-2))/float(ie**2)
      fac6 = float(ie-1)/float(ie)

      ! Load field(s) and subtract mean(s)
      call model_read(nam,mom,ie,isub,geom,fldb)
      fldb = fldb - mom%m1b(:,:,:,isub)
      if (trim(ensname)=='cross') then
         ! Load another field
         call model_read(nam,mom_cross,ie,isub,geom,fld)
         fld = fld - m1
      else
         ! Copy initial field
         fld = fldb
      end if

      ! Update high-order moments
      if (ie>1) then
         do iv=1,nam%nv
            do jl0=1,geom%nl0
               do il0=1,geom%nl0
                  do ic=1,nam%nc
                     !$omp parallel do private(ic1,ic0,jc0)
                     do ic1=1,nam%nc1
                        if (hdata%ic1il0_log(ic1,jl0).and.hdata%ic1icil0iv_log(ic1,ic,il0,iv)) then
                           ! Indices
                           ic0 = hdata%ic1icil0iv_to_ic0(ic1,ic,il0,iv)
                           jc0 = hdata%ic1_to_ic0(ic1)

                           if (.not.nam%gau_approx) then
                              ! Fourth-order moment
                              mom%m22(ic1,ic,il0,jl0,iv,isub) = mom%m22(ic1,ic,il0,jl0,iv,isub) &
                               & -fac1*(m21(ic1,ic,il0,jl0,iv)*fld(ic0,il0,iv)+m12(ic1,ic,il0,jl0,iv)*fldb(jc0,jl0,iv)) &
                               & +fac2*(4.0*mom%m11(ic1,ic,il0,jl0,iv,isub)*fldb(jc0,jl0,iv)*fld(ic0,il0,iv) &
                               & +mom%m2b(ic1,ic,il0,jl0,iv,isub)*fld(ic0,il0,iv)**2 & 
                               & +mom%m2(ic1,ic,il0,jl0,iv,isub)*fldb(jc0,jl0,iv)**2) &
                               & +fac3*fldb(jc0,jl0,iv)**2*fld(ic0,il0,iv)**2

                              ! Third-order moments
                              m21(ic1,ic,il0,jl0,iv) = m21(ic1,ic,il0,jl0,iv) &
                               & -fac4*(2.0*mom%m11(ic1,ic,il0,jl0,iv,isub)*fldb(jc0,jl0,iv) &
                               & +mom%m2b(ic1,ic,il0,jl0,iv,isub)*fld(ic0,il0,iv)) &
                               & +fac5*fldb(jc0,jl0,iv)**2*fld(ic0,il0,iv)

                              m12(ic1,ic,il0,jl0,iv) = m12(ic1,ic,il0,jl0,iv) &
                               & -fac4*(2.0*mom%m11(ic1,ic,il0,jl0,iv,isub)*fld(ic0,il0,iv) &
                               & +mom%m2(ic1,ic,il0,jl0,iv,isub)*fldb(jc0,jl0,iv)) &
                               & +fac5*fld(ic0,il0,iv)**2*fldb(jc0,jl0,iv)
                           end if

                           ! Covariance
                           mom%m11(ic1,ic,il0,jl0,iv,isub) = mom%m11(ic1,ic,il0,jl0,iv,isub) &
                                                           & +fac6*fldb(jc0,jl0,iv)*fld(ic0,il0,iv)

                           ! Variances
                           mom%m2(ic1,ic,il0,jl0,iv,isub) = mom%m2(ic1,ic,il0,jl0,iv,isub)+fac6*fld(ic0,il0,iv)**2
                           mom%m2b(ic1,ic,il0,jl0,iv,isub) = mom%m2b(ic1,ic,il0,jl0,iv,isub)+fac6*fldb(jc0,jl0,iv)**2
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
                        mom%m2full(ic0,il0,iv,isub) = mom%m2full(ic0,il0,iv,isub)+fac6*fldb(ic0,il0,iv)**2
                     end if
                  end do
                  !$omp end parallel do
               end do
            end if
         end do
      end if

      ! Update means
      do iv=1,nam%nv
         do il0=1,geom%nl0
            !$omp parallel do private(ic0)
            do ic0=1,geom%nc0
               if (geom%mask(ic0,il0)) then
                  mom%m1b(ic0,il0,iv,isub) = mom%m1b(ic0,il0,iv,isub)+fac4*fldb(ic0,il0,iv)
                  m1(ic0,il0,iv) = m1(ic0,il0,iv)+fac4*fld(ic0,il0,iv)
               end if
            end do
            !$omp end parallel do
         end do
      end do
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

      do ie=1,mom%ne/mom%nsub
         write(mpl%unit,'(i4)',advance='no') mom%ne_offset+ie

         ! Load field(s) and subtract mean(s)
         call model_read(nam,mom,ie,isub,geom,fldb)
         fldb = fldb - mom%m1b(:,:,:,isub)
         if (trim(ensname)=='cross') then
            ! Load another field
            call model_read(nam,mom_cross,ie,isub,geom,fld)
            fld = fld - m1
         else
            ! Copy initial field
            fld = fldb
         end if

         do iv=1,nam%nv
            do jl0=1,geom%nl0
               do il0=1,geom%nl0
                  do ic=1,nam%nc
                     !$omp parallel do private(ic1,ic0,jc0)
                     do ic1=1,nam%nc1
                        if (hdata%ic1il0_log(ic1,jl0).and.hdata%ic1icil0iv_log(ic1,ic,il0,iv)) then
                           ! Indices
                           ic0 = hdata%ic1icil0iv_to_ic0(ic1,ic,il0,iv)
                           jc0 = hdata%ic1_to_ic0(ic1)

                           ! Update moments
                           if (.not.nam%gau_approx) then
                              m22test(ic1,ic,il0,jl0,iv) = m22test(ic1,ic,il0,jl0,iv)+fldb(jc0,jl0,iv)**2*fld(ic0,il0,iv)**2
                              m21test(ic1,ic,il0,jl0,iv) = m21test(ic1,ic,il0,jl0,iv)+fldb(jc0,jl0,iv)**2*fld(ic0,il0,iv)
                              m12test(ic1,ic,il0,jl0,iv) = m12test(ic1,ic,il0,jl0,iv)+fldb(jc0,jl0,iv)*fld(ic0,il0,iv)**2
                           end if
                           m11test(ic1,ic,il0,jl0,iv) = m11test(ic1,ic,il0,jl0,iv)+fldb(jc0,jl0,iv)*fld(ic0,il0,iv)
                           m2test(ic1,ic,il0,jl0,iv) = m2test(ic1,ic,il0,jl0,iv)+fld(ic0,il0,iv)**2
                           m2btest(ic1,ic,il0,jl0,iv) = m2btest(ic1,ic,il0,jl0,iv)+fldb(jc0,jl0,iv)**2
                        end if
                     end do
                     !$omp end parallel do
                  end do
               end do
            end do
         end do
      end do
      write(mpl%unit,'(a)') ''

      ! Test
      write(mpl%unit,'(a10,a)') '','Max and avg. relative RMS error between recursive and non-recursive formulas:'
      if (.not.nam%gau_approx) then
         write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m22: ',maxval(100.0*abs(mom%m22(:,:,:,:,:,isub)-m22test)/abs(m22test), &
       & mask=abs(m22test)>0.0),' % / ',sum(100.0*abs(mom%m22(:,:,:,:,:,isub)-m22test)/abs(m22test), &
       & mask=abs(m22test)>0.0)/float(count(abs(m22test)>0.0)),' %'
         write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m21: ',maxval(100.0*abs(m21-m21test)/abs(m21test), &
       & mask=abs(m21test)>0.0),' % / ',sum(100.0*abs(m21-m21test)/abs(m21test), &
       & mask=abs(m21test)>0.0)/float(count(abs(m21test)>0.0)),' %'
         write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m12: ',maxval(100.0*abs(m12-m12test)/abs(m12test), &
       & mask=abs(m12test)>0.0),' % / ',sum(100.0*abs(m12-m12test)/abs(m12test), &
       & mask=abs(m12test)>0.0)/float(count(abs(m12test)>0.0)),' %'
      end if
      write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m11: ',maxval(100.0*abs(mom%m11(:,:,:,:,:,isub)-m11test)/abs(m11test), &
    & mask=abs(m11test)>0.0),' % / ',sum(100.0*abs(mom%m11(:,:,:,:,:,isub)-m11test)/abs(m11test), &
    & mask=abs(m11test)>0.0)/float(count(abs(m11test)>0.0)),' %'
      write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m2: ',maxval(100.0*abs(mom%m2(:,:,:,:,:,isub)-m2test)/abs(m2test), &
    & mask=abs(m2test)>0.0),' % / ',sum(100.0*abs(mom%m2(:,:,:,:,:,isub)-m2test)/abs(m2test), &
    & mask=abs(m2test)>0.0)/float(count(abs(m2test)>0.0)),' %'
      write(mpl%unit,'(a13,a,f9.3,a,f9.3,a)') '','m2b: ',maxval(100.0*abs(mom%m2b(:,:,:,:,:,isub)-m2btest)/abs(m2btest), &
    & mask=abs(m2btest)>0.0),' % / ',sum(100.0*abs(mom%m2b(:,:,:,:,:,isub)-m2btest)/abs(m2btest), &
    & mask=abs(m2btest)>0.0)/float(count(abs(m2btest)>0.0)),' %'
   end if

   ! Normalize
   mom%m2b(:,:,:,:,:,isub) = mom%m2b(:,:,:,:,:,isub)/float(mom%ne/mom%nsub-1)
   mom%m2(:,:,:,:,:,isub) = mom%m2(:,:,:,:,:,isub)/float(mom%ne/mom%nsub-1)
   mom%m11(:,:,:,:,:,isub) = mom%m11(:,:,:,:,:,isub)/float(mom%ne/mom%nsub-1)
   if (nam%full_var) mom%m2full(:,:,:,isub) = mom%m2full(:,:,:,isub)/float(mom%ne/mom%nsub-1)
   if (.not.nam%gau_approx) mom%m22(:,:,:,:,:,isub) = mom%m22(:,:,:,:,:,isub)/float(mom%ne/mom%nsub)
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
