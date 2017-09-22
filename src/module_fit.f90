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

use module_namelist, only: namtype
use omp_lib
use tools_const, only: gc99
use tools_display, only: msgerror,msgwarning
use tools_kinds, only: kind_real
use tools_fit, only: fast_fit,ver_smooth
use tools_minim, only: minim
use tools_missing, only: msr,isnotmsr
use type_curve, only: curvetype
use type_geom, only: geomtype
use type_min, only: mintype
implicit none

real(kind_real),parameter :: epsilon = 1.0e-6 !< Small parameter to compute the Jacobian

private
public :: compute_fit

contains

!----------------------------------------------------------------------
! Subroutine: compute_fit
!> Purpose: compute a semi-positive definite fit of a raw function
!----------------------------------------------------------------------
subroutine compute_fit(nam,geom,curve,norm)

implicit none

! Passed variables
type(namtype),pointer,intent(in) :: nam
type(geomtype),pointer,intent(in) :: geom
type(curvetype),intent(inout) :: curve(nam%nvp)              !< Curve
real(kind_real),intent(in),optional :: norm            !< Normalization

! Local variables
integer :: iv,il0,jl0,info,offset
real(kind_real) :: distv(geom%nl0,geom%nl0),raw(geom%nl0)
type(mintype) :: mindata

! Check
if (trim(nam%fit_type)=='none') call msgerror('cannot compute fit if fit_type = none')

! Vertical distance
do jl0=1,geom%nl0
   do il0=1,geom%nl0
      distv(il0,jl0) = abs(geom%vunit(jl0)-geom%vunit(il0))
   end do
end do

! Allocation
mindata%nam => nam
mindata%geom => geom
mindata%lnorm = present(norm)
if (mindata%lnorm) then
   mindata%nx = 0
else
   mindata%nx = geom%nl0
end if
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
allocate(mindata%guess(mindata%nx))
allocate(mindata%binf(mindata%nx))
allocate(mindata%bsup(mindata%nx))
allocate(mindata%obs(mindata%ny))
allocate(mindata%wgt(mindata%ny))

! Fill mindata
mindata%binf = 0.0
mindata%wgt = 1.0

do iv=1,nam%nvp
   ! Initialization
   call msr(curve(iv)%fit_coef_ens)
   call msr(curve(iv)%fit_rh)
   call msr(curve(iv)%fit_rv)
   call msr(curve(iv)%fit)

   ! Fast fit
   do jl0=1,geom%nl0
      if (isnotmsr(curve(iv)%raw(1,jl0,jl0))) then
         ! Diagonal values
         curve(iv)%fit_coef_ens(jl0) = curve(iv)%raw(1,jl0,jl0)

         ! Horizontal fast fit
         call fast_fit(nam%nc,1,nam%disth,curve(iv)%raw(:,jl0,jl0)/curve(iv)%raw(1,jl0,jl0),curve(iv)%fit_rh(jl0))

         ! Vertical fast fit
         do il0=1,geom%nl0
            if (isnotmsr(curve(iv)%raw(1,il0,il0))) raw(il0) = curve(iv)%raw(1,il0,jl0) &
          & /sqrt(curve(iv)%raw(1,jl0,jl0)*curve(iv)%raw(1,il0,il0))
         end do
         call fast_fit(geom%nl0,jl0,distv(:,jl0),raw,curve(iv)%fit_rv(jl0))
      else
         call msgerror('missing zero separation value')
      end if
   end do
   if (nam%lhomh) curve(iv)%fit_rh = sum(curve(iv)%fit_rh)/float(geom%nl0)
   if (nam%lhomv) curve(iv)%fit_rv = sum(curve(iv)%fit_rv)/float(geom%nl0)

   if (trim(nam%fit_type)=='full') then
      ! Iterative fit
      offset = 0
      if (.not.mindata%lnorm) then
         mindata%guess(offset+1:offset+geom%nl0) = curve(iv)%fit_coef_ens
         offset = offset+geom%nl0
      end if
      if (nam%lhomh) then
         mindata%guess(offset+1) = curve(iv)%fit_rh(1)
         offset = offset+1
      else
         mindata%guess(offset+1:offset+geom%nl0) = curve(iv)%fit_rh
         offset = offset+geom%nl0
      end if
      if (nam%lhomv) then
         mindata%guess(offset+1) = curve(iv)%fit_rv(1)
         offset = offset+1
      else
         mindata%guess(offset+1:offset+geom%nl0) = curve(iv)%fit_rv
         offset = offset+geom%nl0
      end if
      mindata%bsup = 3.0*mindata%guess
      mindata%obs = pack(curve(iv)%raw,mask=.true.)
      info = minim(mindata,func,jacobian)
      offset = 0
      if (mindata%lnorm) then
         curve(iv)%fit_coef_ens = norm
      else
         curve(iv)%fit_coef_ens = mindata%x(offset+1:offset+geom%nl0)
         offset = offset+geom%nl0
      end if
      if (nam%lhomh) then
         curve(iv)%fit_rh = mindata%x(offset+1)
         offset = offset+1
      else
         curve(iv)%fit_rh = mindata%x(offset+1:offset+geom%nl0)
         offset = offset+geom%nl0
      end if
      if (nam%lhomv) then
         curve(iv)%fit_rv = mindata%x(offset+1)
         offset = offset+1
      else
         curve(iv)%fit_rv = mindata%x(offset+1:offset+geom%nl0)
         offset = offset+geom%nl0
      end if

      ! Dummy call to avoid warnings
      call dummy(mindata)
   end if

   ! Smooth vertically
   call ver_smooth(geom%nl0,geom%vunit,nam%rvflt,curve(iv)%fit_coef_ens)
   call ver_smooth(geom%nl0,geom%vunit,nam%rvflt,curve(iv)%fit_rh)
   call ver_smooth(geom%nl0,geom%vunit,nam%rvflt,curve(iv)%fit_rv)

   ! Rebuild fit
   call define_fit(nam,geom,curve(iv)%fit_coef_ens,curve(iv)%fit_rh,curve(iv)%fit_rv,curve(iv)%fit)
end do

end subroutine compute_fit

!----------------------------------------------------------------------
! Subroutine: define_fit
!> Purpose: define the fit
!----------------------------------------------------------------------
subroutine define_fit(nam,geom,coef,Dh,Dv,fit)

implicit none

! Passed variables
type(namtype),intent(in) :: nam
type(geomtype),intent(in) :: geom
real(kind_real),intent(in) :: coef(geom%nl0)
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
            do kl0=max(jl0-1,1),min(jl0+1,geom%nl0)
               Dhsq = 0.5*(Dh(il0)**2+Dh(kl0)**2)              
               Dvsq = 0.5*(Dv(il0)**2+Dv(kl0)**2)
               distnorm = 0.0
               if (Dhsq>0.0) distnorm = distnorm+(nam%disth(kc)-nam%disth(ic))**2/Dhsq
               if (Dvsq>0.0) distnorm = distnorm+(geom%vunit(jl0)-geom%vunit(kl0))**2/Dvsq
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
         if (distnorm<1.0) fit(ic,il0,jl0) = sqrt(coef(jl0)*coef(il0))*gc99(distnorm)
      end do
   end do

   ! Release memory
   deallocate(plist)
   deallocate(plist_new)
   deallocate(dist)
end do

end subroutine define_fit

!----------------------------------------------------------------------
! Subroutine: compute_fit_jacobian
!> Purpose: compute the fit jacobian
!----------------------------------------------------------------------
subroutine compute_fit_jacobian(nam,geom,coef,Dh,Dv,Jfit)

implicit none

! Passed variables
type(namtype),intent(in) :: nam
type(geomtype),intent(in) :: geom
real(kind_real),intent(in) :: coef(geom%nl0)
real(kind_real),intent(in) :: Dh(geom%nl0)
real(kind_real),intent(in) :: Dv(geom%nl0)
real(kind_real),intent(out) :: Jfit(nam%nc,geom%nl0,geom%nl0,3*geom%nl0)

! Local variables
integer :: il0,offset
real(kind_real) :: delta
real(kind_real) :: coefp(geom%nl0),coefm(geom%nl0)
real(kind_real) :: Dhp(geom%nl0),Dhm(geom%nl0)
real(kind_real) :: Dvp(geom%nl0),Dvm(geom%nl0)
real(kind_real) :: fitp(nam%nc,geom%nl0,geom%nl0),fitm(nam%nc,geom%nl0,geom%nl0)

! Differenciation on coef
do il0=1,geom%nl0
   do offset=1,3
      coefp = coef
      coefm = coef
      Dhp = Dh
      Dhm = Dh
      Dvp = Dv
      Dvm = Dv
      select case (offset)
      case(1)
         delta = epsilon*coef(il0)
         coefp(il0) = coef(il0)+delta
         coefm(il0) = coef(il0)-delta
      case(2)
         delta = epsilon*Dh(il0)
         Dhp(il0) = Dh(il0)+delta
         Dhm(il0) = Dh(il0)-delta
      case(3)
         delta = epsilon*Dv(il0)
         Dvp(il0) = Dv(il0)+delta
         Dvm(il0) = Dv(il0)-delta
      case default
         delta = 1.0
      end select
      call define_fit(nam,geom,coefp,Dhp,Dvp,fitp)
      call define_fit(nam,geom,coefm,Dhm,Dvm,fitm)
      Jfit(:,:,:,(offset-1)*geom%nl0+il0) = (fitp-fitm)/(2.0*delta)
   end do
end do

end subroutine compute_fit_jacobian

!----------------------------------------------------------------------
! Function: func
!> Purpose: fit function
!----------------------------------------------------------------------
subroutine func(mindata,x,f)

implicit none

! Passed variables
type(mintype),intent(in) :: mindata !< Minimization data
real(kind_real),intent(in) :: x(mindata%nx)            !< Control vector
real(kind_real),intent(out) :: f(mindata%ny)

! Local variables
integer :: offset
real(kind_real) :: coef(mindata%geom%nl0),fit_rh(mindata%geom%nl0),fit_rv(mindata%geom%nl0)
real(kind_real) :: fit(mindata%nam%nc,mindata%geom%nl0,mindata%geom%nl0)

! Associate
associate(nam=>mindata%nam,geom=>mindata%geom)

! Get data
offset = 0
if (mindata%lnorm) then
   coef = 1.0
else
   coef = x(offset+1:offset+geom%nl0)
   offset = offset+geom%nl0
end if
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
call define_fit(nam,geom,coef,fit_rh,fit_rv,fit)

! Pack
f = pack(fit,mask=.true.)

! End associate
end associate

end subroutine func

!----------------------------------------------------------------------
! Function: jacobian
!> Purpose: fit jacobian
!----------------------------------------------------------------------
subroutine jacobian(mindata,x,jac)

implicit none

! Passed variables
type(mintype),intent(in) :: mindata !< Minimization data
real(kind_real),intent(in) :: x(mindata%nx)            !< Control vector
real(kind_real),intent(out) :: jac(mindata%ny,mindata%nx)

! Local variables
integer :: offset,ix
real(kind_real) :: coef(mindata%geom%nl0),fit_rh(mindata%geom%nl0),fit_rv(mindata%geom%nl0)
real(kind_real) :: J(mindata%nam%nc,mindata%geom%nl0,mindata%geom%nl0,3*mindata%geom%nl0)

! Associate
associate(nam=>mindata%nam,geom=>mindata%geom)

! Get data
offset = 0
if (mindata%lnorm) then
   coef = 1.0
else
   coef = x(offset+1:offset+geom%nl0)
   offset = offset+geom%nl0
end if
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
call compute_fit_jacobian(nam,geom,coef,fit_rh,fit_rv,J)

! Pack
do ix=1,mindata%nx
   jac(:,ix) = pack(J(:,:,:,ix),mask=.true.)
end do

! End associate
end associate

end subroutine jacobian

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
real(kind_real) :: f(mindata%ny)
real(kind_real) :: jac(mindata%ny,mindata%nx)

if (.false.) then
   call func(mindata,x,f)
   call jacobian(mindata,x,jac)
end if

end subroutine

end module module_fit
