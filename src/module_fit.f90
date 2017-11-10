!----------------------------------------------------------------------
! Module: module_fit.f90
!> Purpose: fit routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module module_fit

use omp_lib
use tools_const, only: gc99
use tools_display, only: msgerror,msgwarning
use tools_kinds, only: kind_real
use tools_fit, only: fast_fit,ver_smooth
use tools_minim, only: minim
use tools_missing, only: msr,isnotmsr
use type_curve, only: curvetype,curve_pack,curve_unpack
use type_geom, only: geomtype
use type_hdata, only: hdatatype
use type_min, only: mintype
use type_mpl, only: mpl,mpl_recv,mpl_send,mpl_bcast
use type_nam, only: namtype

implicit none

integer,parameter :: nsc = 50

interface compute_fit
  module procedure compute_fit
  module procedure compute_fit_multi
end interface

private
public :: compute_fit

contains

!----------------------------------------------------------------------
! Subroutine: compute_fit
!> Purpose: compute a semi-positive definite fit of a raw function
!----------------------------------------------------------------------
subroutine compute_fit(hdata,curve)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata
type(curvetype),intent(inout) :: curve              !< Curve

! Local variables
integer :: jl0,offset,isc
real(kind_real) :: rawv(hdata%geom%nl0)
real(kind_real) :: alpha,alpha_opt,mse,mse_opt
real(kind_real) :: fit_rh(hdata%geom%nl0),fit_rv(hdata%geom%nl0),fit(hdata%nam%nc,hdata%geom%nl0,hdata%geom%nl0)
type(mintype) :: mindata

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Check
if (trim(nam%fit_type)=='none') call msgerror('cannot compute fit if fit_type = none')

! Initialization
call msr(curve%fit_rh)
call msr(curve%fit_rv)
call msr(curve%fit)

! Fast fit
do jl0=1,geom%nl0  
   ! Horizontal fast fit
   call fast_fit(nam%nc,1,geom%disth,curve%raw(:,jl0,jl0),curve%fit_rh(jl0))

   ! Vertical fast fit
   rawv = curve%raw(1,:,jl0)
   call fast_fit(geom%nl0,jl0,geom%distv(:,jl0),rawv,curve%fit_rv(jl0))
end do
if (nam%lhomh) curve%fit_rh = sum(curve%fit_rh)/float(geom%nl0)
if (nam%lhomv) curve%fit_rv = sum(curve%fit_rv)/float(geom%nl0)

! Scaling optimization (brute-force)
mse_opt = huge(1.0)
alpha_opt = 1.0
do isc=1,nsc
   ! Scaling factor
   alpha = 0.5+float(isc-1)/float(nsc-1)*(2.0-0.5)

   ! Scaled radii
   fit_rh = alpha*curve%fit_rh
   fit_rv = alpha*curve%fit_rv

   ! Fit
   call define_fit(nam,geom,fit_rh,fit_rv,fit)

   ! MSE
   mse = sum((fit-curve%raw)**2,mask=isnotmsr(curve%raw))
   if (mse<mse_opt) then
      mse_opt = mse
      alpha_opt = alpha
   end if
end do
curve%fit_rh = alpha_opt*curve%fit_rh
curve%fit_rv = alpha_opt*curve%fit_rv
write(mpl%unit,'(a7,a,f6.1,a)') '','Scaling optimization, cost function decrease:',abs(mse_opt-mse)/mse*100.0,'%'

select case (trim(nam%fit_type))
case ('nelder_mead','compass_search','praxis')
   ! Allocation
   mindata%nam => nam
   mindata%geom => geom
   mindata%nx = 0
   if (nam%lhomh) then
      mindata%nx = mindata%nx+1
   else
      mindata%nx = mindata%nx+geom%nl0
   end if
   if (nam%lhomv) then
      mindata%nx = mindata%nx+1
   else
      mindata%nx = mindata%nx+geom%nl0
   end if
   mindata%ny = nam%nc*geom%nl0**2
   allocate(mindata%x(mindata%nx))
   allocate(mindata%guess(mindata%nx))
   allocate(mindata%binf(mindata%nx))
   allocate(mindata%bsup(mindata%nx))
   allocate(mindata%obs(mindata%ny))

   ! Fill mindata
   offset = 0
   if (nam%lhomh) then
      mindata%guess(offset+1) = curve%fit_rh(1)
      offset = offset+1
   else
      mindata%guess(offset+1:offset+geom%nl0) = curve%fit_rh
      offset = offset+geom%nl0
   end if
   if (nam%lhomv) then
      mindata%guess(offset+1) = curve%fit_rv(1)
      offset = offset+1
   else
      mindata%guess(offset+1:offset+geom%nl0) = curve%fit_rv
      offset = offset+geom%nl0
   end if
   mindata%binf = 0.75*mindata%guess
   mindata%bsup = 1.25*mindata%guess
   mindata%obs = pack(curve%raw,mask=.true.)

   ! Compute fit
   call minim(mindata,func)

   ! Copy parameters
   offset = 0
   if (nam%lhomh) then
      curve%fit_rh = mindata%x(offset+1)
      offset = offset+1
   else
      curve%fit_rh = mindata%x(offset+1:offset+geom%nl0)
      offset = offset+geom%nl0
   end if
   if (nam%lhomv) then
      curve%fit_rv = mindata%x(offset+1)
      offset = offset+1
   else
      curve%fit_rv = mindata%x(offset+1:offset+geom%nl0)
      offset = offset+geom%nl0
   end if

   ! Dummy call to avoid warnings
   call dummy(mindata)
end select

! Smooth vertically
call ver_smooth(geom%nl0,geom%vunit,nam%rvflt,curve%fit_rh)
call ver_smooth(geom%nl0,geom%vunit,nam%rvflt,curve%fit_rv)

! Rebuild fit
call define_fit(nam,geom,curve%fit_rh,curve%fit_rv,curve%fit)

! End associate
end associate

end subroutine compute_fit

!----------------------------------------------------------------------
! Subroutine: compute_fit_multi
!> Purpose: compute a semi-positive definite fit of a raw function, multiple curves
!----------------------------------------------------------------------
subroutine compute_fit_multi(hdata,curve)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata
type(curvetype),intent(inout) :: curve(hdata%nc2)              !< Curve

! Local variables
integer :: ic2,npack
integer :: iproc,ic2_s(mpl%nproc),ic2_e(mpl%nproc),nc2_loc(mpl%nproc),ic2_loc
real(kind_real),allocatable :: rbuf(:),sbuf(:)

! MPI splitting
do iproc=1,mpl%nproc
   ic2_s(iproc) = (iproc-1)*(hdata%nc2/mpl%nproc+1)+1
   ic2_e(iproc) = min(iproc*(hdata%nc2/mpl%nproc+1),hdata%nc2)
   nc2_loc(iproc) = ic2_e(iproc)-ic2_s(iproc)+1
end do

! Loop over points
do ic2_loc=1,nc2_loc(mpl%myproc)
   ic2 = ic2_s(mpl%myproc)+ic2_loc-1
   call compute_fit(hdata,curve(ic2))
end do

! Allocation
npack = curve(ic2_s(mpl%myproc))%npack
allocate(rbuf(hdata%nc2*npack))

! Communication
if (mpl%main) then 
   do iproc=1,mpl%nproc
      if (iproc==mpl%ioproc) then
         ! Format data
         do ic2_loc=1,nc2_loc(iproc)
            ic2 = ic2_s(iproc)+ic2_loc-1
            call curve_pack(hdata,curve(ic2),rbuf((ic2-1)*npack+1:ic2*npack))
         end do
      else
         ! Receive data on ioproc
         call mpl_recv(nc2_loc(iproc)*npack, &
       & rbuf((ic2_s(iproc)-1)*npack+1:ic2_e(iproc)*npack),iproc,mpl%tag)
      end if
   end do
else
   ! Allocation
   allocate(sbuf(nc2_loc(mpl%myproc)*npack))

   ! Format data
   do ic2_loc=1,nc2_loc(mpl%myproc)
      ic2 = ic2_s(mpl%myproc)+ic2_loc-1
      call curve_pack(hdata,curve(ic2),sbuf((ic2_loc-1)*npack+1:ic2_loc*npack))
   end do

   ! Send data to ioproc
   call mpl_send(nc2_loc(mpl%myproc)*npack,sbuf,mpl%ioproc,mpl%tag)

   ! Release memory
   deallocate(sbuf)
end if
mpl%tag = mpl%tag+1

! Broadcast data
call mpl_bcast(rbuf,mpl%ioproc)

! Format data
do ic2=1,hdata%nc2
   call curve_unpack(hdata,curve(ic2),rbuf((ic2-1)*npack+1:ic2*npack))
end do

end subroutine compute_fit_multi

!----------------------------------------------------------------------
! Subroutine: define_fit
!> Purpose: define the fit
!----------------------------------------------------------------------
subroutine define_fit(nam,geom,Dh,Dv,fit)

implicit none

! Passed variables
type(namtype),intent(in) :: nam
type(geomtype),intent(in) :: geom
real(kind_real),intent(in) :: Dh(geom%nl0)
real(kind_real),intent(in) :: Dv(geom%nl0)
real(kind_real),intent(out) :: fit(nam%nc,geom%nl0,geom%nl0)

! Local variables
integer :: il0,jl0,kl0,ic,kc,ip,jp,np,np_new
integer,allocatable :: plist(:,:),plist_new(:,:)
real(kind_real) :: Dhsq,Dvsq,distnorm,disttest
real(kind_real),allocatable :: dist(:,:)
logical :: add_to_front

! Initialization
fit = 0.0

do jl0=1,geom%nl0
   ! Allocation
   allocate(plist(nam%nc*geom%nl0,2))
   allocate(plist_new(nam%nc*geom%nl0,2))
   allocate(dist(nam%nc,geom%nl0))

   ! Initialize the front
   np = 1
   plist(1,1) = 1
   plist(1,2) = jl0
   dist = 1.0
   dist(1,jl0) = 0.0

   do while (np>0)
      ! Propagate the front
      np_new = 0

      do ip=1,np
         ! Indices of the central point
         ic = plist(ip,1)
         il0 = plist(ip,2)

         ! Loop over neighbors
         do kc=max(ic-1,1),min(ic+1,nam%nc)
            do kl0=max(il0-1,1),min(il0+1,geom%nl0)
               if (isnotmsr(Dh(il0)).and.isnotmsr(Dh(kl0))) then
                  Dhsq = 0.5*(Dh(il0)**2+Dh(kl0)**2)              
               else
                  Dhsq = 0.0
               end if
               if (isnotmsr(Dv(il0)).and.isnotmsr(Dv(kl0))) then
                  Dvsq = 0.5*(Dv(il0)**2+Dv(kl0)**2)
               else
                  Dvsq = 0.0
               end if
               distnorm = 0.0
               if (Dhsq>0.0) then
                  distnorm = distnorm+(geom%disth(kc)-geom%disth(ic))**2/Dhsq
               else
                  distnorm = huge(1.0)
               end if 
               if (Dvsq>0.0) then
                  distnorm = distnorm+geom%distv(kl0,il0)**2/Dvsq
               elseif (kl0/=il0) then
                  distnorm = huge(1.0)
               end if
               distnorm = sqrt(distnorm)
               disttest = dist(ic,il0)+distnorm
               if (disttest<1.0) then
                  ! Point is inside the support
                  if (disttest<dist(kc,kl0)) then
                     ! Update distance
                     dist(kc,kl0) = disttest

                     ! Check if the point should be added to the front (avoid duplicates)
                     add_to_front = .true.
                     do jp=1,np_new
                        if ((plist_new(jp,1)==kc).and.(plist_new(jp,1)==kl0)) then
                           add_to_front = .false.
                           exit
                        end if
                     end do

                     if (add_to_front) then
                        ! Add point to the front
                        np_new = np_new+1
                        plist_new(np_new,1) = kc
                        plist_new(np_new,2) = kl0
                     end if
                  end if
               end if
            end do
         end do
      end do

      ! Copy new front
      np = np_new
      plist(1:np,:) = plist_new(1:np,:)
   end do

   do il0=1,geom%nl0
      do ic=1,nam%nc
         ! Gaspari-Cohn (1999) function
         distnorm = dist(ic,il0)
         if (distnorm<1.0) fit(ic,il0,jl0) = gc99(distnorm)
      end do
   end do

   ! Release memory
   deallocate(plist)
   deallocate(plist_new)
   deallocate(dist)
end do

end subroutine define_fit

!----------------------------------------------------------------------
! Function: func
!> Purpose: fit function cost
!----------------------------------------------------------------------
subroutine func(mindata,x,f)

implicit none

! Passed variables
type(mintype),intent(in) :: mindata !< Minimization data
real(kind_real),intent(inout) :: x(mindata%nx)            !< Control vector
real(kind_real),intent(out) :: f

! Local variables
integer :: offset,ix
real(kind_real) :: fit_rh(mindata%geom%nl0),fit_rv(mindata%geom%nl0)
real(kind_real) :: fit(mindata%nam%nc,mindata%geom%nl0,mindata%geom%nl0)
real(kind_real) :: fit_pack(mindata%ny),xx

! Associate
associate(nam=>mindata%nam,geom=>mindata%geom)

! Renormalize
x = x*mindata%guess

! Get data
offset = 0
if (nam%lhomh) then
   fit_rh = x(offset+1)
   offset = offset+1
else
   fit_rh = x(offset+1:offset+geom%nl0)
   offset = offset+geom%nl0
end if
if (nam%lhomv) then
   fit_rv = x(offset+1)
   offset = offset+1
else
   fit_rv = x(offset+1:offset+geom%nl0)
   offset = offset+geom%nl0
end if

! Compute function
call define_fit(nam,geom,fit_rh,fit_rv,fit)

! Pack
fit_pack = pack(fit,mask=.true.)

! Cost
f = sum((mindata%obs-fit_pack)**2,mask=isnotmsr(mindata%obs))

! Bound penalty
do ix=1,mindata%nx
   xx = (x(ix)-mindata%binf(ix))/(mindata%bsup(ix)-mindata%binf(ix))
   if (xx<0.0) then
      f = f+mindata%f_guess*xx**2
   elseif (xx>1.0) then
      f = f+mindata%f_guess*(xx-1.0)**2 
   end if
end do

! Reset
do ix=1,mindata%nx
   if (abs(mindata%guess(ix))>0.0) then
      x(ix) = x(ix)/mindata%guess(ix)
   else
      x(ix) = 1.0
   end if
end do

! End associate
end associate

end subroutine func

!----------------------------------------------------------------------
! Subroutine: dummy
!> Purpose: dummy subroutine to avoid warnings
!----------------------------------------------------------------------
subroutine dummy(mindata)

implicit none

! Passed variables
type(mintype),intent(in) :: mindata

! Local variables
real(kind_real) :: x(mindata%nx)
real(kind_real) :: f

if (.false.) call func(mindata,x,f)

end subroutine

end module module_fit
