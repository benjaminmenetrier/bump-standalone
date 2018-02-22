!----------------------------------------------------------------------
! Module: hdiag_fit_lct.f90
!> Purpose: LCT fit routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module hdiag_fit_lct

use omp_lib
use tools_const, only: lonlatmod
use tools_diffusion, only: matern
use tools_display, only: msgerror,msgwarning,prog_init,prog_print
use tools_kinds, only: kind_real
use tools_minim, only: minim
use tools_missing, only: msr,isnotmsr
use type_hdata, only: hdatatype
use type_lct, only: lcttype
use type_mdata, only: mdatatype
use type_mpl, only: mpl

implicit none

real(kind_real),parameter :: Hmin = 1.0e-12 !< Minimum tensor diagonal value
real(kind_real),parameter :: Hscale = 10.0  !< Typical factor between LCT scales
integer,parameter :: M = 0                  !< Number of implicit itteration for the Matern function (Gaussian function if M = 0)

private
public :: compute_fit_lct

contains

!----------------------------------------------------------------------
! Subroutine: compute_fit_lct
!> Purpose: compute a semi-positive definite fit of a raw function
!----------------------------------------------------------------------
subroutine compute_fit_lct(hdata,ib,lct)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata                           !< HDIAG data
integer,intent(in) :: ib                                      !< Block index
type(lcttype),intent(inout) :: lct(hdata%nc1a,hdata%geom%nl0) !< LCT

! Local variables
integer :: il0,jl0r,jl0,ic1a,ic1,jc3,iscales,offset,progint
real(kind_real) :: distsq,Hh(hdata%nam%nc3),Hv(hdata%bpar%nl0r(ib)),Hhbar,Hvbar
real(kind_real),allocatable :: dx(:,:),dy(:,:),dz(:)
logical,allocatable :: dmask(:,:),done(:)
type(lcttype) :: lct_guess,lct_norm,lct_binf,lct_bsup
type(mdatatype) :: mdata

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Allocation
allocate(dx(nam%nc3,bpar%nl0r(ib)))
allocate(dy(nam%nc3,bpar%nl0r(ib)))
allocate(dz(bpar%nl0r(ib)))
allocate(dmask(nam%nc3,bpar%nl0r(ib)))
allocate(done(hdata%nc1a))

! Loop over levels
do il0=1,geom%nl0
   write(mpl%unit,'(a13,a,i3,a)',advance='no') '','Level ',nam%levs(il0),':'

   ! Loop over points
   call prog_init(progint,done)
   do ic1a=1,hdata%nc1a
      ic1 = hdata%c1a_to_c1(ic1a)

      ! Prepare vectors
      do jl0r=1,bpar%nl0r(ib)
         jl0 = bpar%l0rl0b_to_l0(jl0r,il0,ib)
         do jc3=1,nam%nc3
            dmask(jc3,jl0r) = hdata%c1l0_log(ic1,il0).and.hdata%c1c3l0_log(ic1,jc3,jl0)
            if (dmask(jc3,jl0r)) then
               dx(jc3,jl0r) = geom%lon(hdata%c1c3_to_c0(ic1,jc3))-geom%lon(hdata%c1c3_to_c0(ic1,1))
               dy(jc3,jl0r) = geom%lat(hdata%c1c3_to_c0(ic1,jc3))-geom%lat(hdata%c1c3_to_c0(ic1,1))
               call lonlatmod(dx(jc3,jl0r),dy(jc3,jl0r))
               dx(jc3,jl0r) = dx(jc3,jl0r)/cos(geom%lat(hdata%c1c3_to_c0(ic1,1)))
            end if
         end do
         dz(jl0r) = float(nam%levs(jl0)-nam%levs(il0))
      end do

      ! Approximate homogeneous horizontal length-scale
      call msr(Hh)
      do jl0r=1,bpar%nl0r(ib)
         if (.not.(abs(dz(jl0r))>0.0)) then
            do jc3=1,nam%nc3
               if (dmask(jc3,jl0r)) then
                  distsq = dx(jc3,jl0r)**2+dy(jc3,jl0r)**2
                  if ((lct(ic1a,il0)%raw(jc3,jl0r)>0.0).and.(distsq>0.0)) Hh(jc3) = -2.0*log(lct(ic1a,il0)%raw(jc3,jl0r))/distsq
               end if
            end do
         end if
      end do
      if (count(isnotmsr(Hh))>0) then
         Hhbar = sum(Hh,mask=isnotmsr(Hh))/float(count(isnotmsr(Hh)))
      else
         return
      end if
      if (lct(ic1a,il0)%nscales>1) Hhbar = Hhbar*Hscale

      ! Approximate homogeneous vertical length-scale
      call msr(Hv)
      jc3 = 1
      do jl0r=1,bpar%nl0r(ib)
         distsq = dz(jl0r)**2
         if ((lct(ic1a,il0)%raw(jc3,jl0r)>0.0).and.(distsq>0.0)) Hv(jl0r) = -2.0*log(lct(ic1a,il0)%raw(jc3,jl0r))/distsq
      end do
      if (bpar%nl0r(ib)>0) then
         Hvbar = 1.0
      else
         if (count(isnotmsr(Hv))>0) then
            Hvbar = sum(Hv,mask=isnotmsr(Hv))/float(count(isnotmsr(Hv)))
         else
           return
         end if
      end if
      if (lct(ic1a,il0)%nscales>1) Hvbar = Hvbar*Hscale

      ! Allocation
      mdata%nx = sum(lct(ic1a,il0)%ncomp)+lct(ic1a,il0)%nscales
      mdata%ny = nam%nc3*bpar%nl0r(ib)
      allocate(mdata%x(mdata%nx))
      allocate(mdata%guess(mdata%nx))
      allocate(mdata%norm(mdata%nx))
      allocate(mdata%binf(mdata%nx))
      allocate(mdata%bsup(mdata%nx))
      allocate(mdata%obs(mdata%ny))
      allocate(mdata%dx(nam%nc3,bpar%nl0r(ib)))
      allocate(mdata%dy(nam%nc3,bpar%nl0r(ib)))
      allocate(mdata%dz(bpar%nl0r(ib)))
      allocate(mdata%dmask(nam%nc3,bpar%nl0r(ib)))
      allocate(mdata%ncomp(lct(ic1a,il0)%nscales))
      call lct_guess%alloc(hdata)
      call lct_norm%alloc(hdata)
      call lct_binf%alloc(hdata)
      call lct_bsup%alloc(hdata)

      ! Define norm and bounds
      offset = 0
      do iscales=1,lct(ic1a,il0)%nscales
         lct_guess%H(offset+1:offset+3) = (/Hhbar,Hhbar,Hvbar/)/Hscale**(iscales-1)
         lct_norm%H(offset+1:offset+3) = (/Hhbar,Hhbar,Hvbar/)/Hscale**(iscales-1)
         lct_binf%H(offset+1:offset+3) = (/1.0/sqrt(Hscale),1.0/sqrt(Hscale),1.0/sqrt(Hscale)/) &
                                       & *lct_guess%H(1:3)/Hscale**(iscales-1)
         lct_bsup%H(offset+1:offset+3) = (/sqrt(Hscale),sqrt(Hscale),sqrt(Hscale)/)*lct_guess%H(1:3)/Hscale**(iscales-1)
         offset = offset+3
         if (lct(ic1a,il0)%ncomp(iscales)==4) then
            lct_guess%H(offset+1) = 0.0
            lct_norm%H(offset+1) = 1.0
            lct_binf%H(offset+1) = -1.0
            lct_bsup%H(offset+1) = 1.0
            offset = offset+1
         end if
         lct_guess%coef(iscales) = 1.0/float(lct(ic1a,il0)%nscales)
         lct_norm%coef(iscales) = 1.0/float(lct(ic1a,il0)%nscales)
         lct_binf%coef(iscales) = 0.0
         lct_bsup%coef(iscales) = 1.0
      end do

      ! Fill mdata
      mdata%guess(1:sum(lct(ic1a,il0)%ncomp)) = lct_guess%H
      mdata%norm(1:sum(lct(ic1a,il0)%ncomp)) = lct_norm%H
      mdata%binf(1:sum(lct(ic1a,il0)%ncomp)) = lct_binf%H
      mdata%bsup(1:sum(lct(ic1a,il0)%ncomp)) = lct_bsup%H
      mdata%guess(sum(lct(ic1a,il0)%ncomp)+1:sum(lct(ic1a,il0)%ncomp)+lct(ic1a,il0)%nscales) = lct_guess%coef
      mdata%norm(sum(lct(ic1a,il0)%ncomp)+1:sum(lct(ic1a,il0)%ncomp)+lct(ic1a,il0)%nscales) = lct_norm%coef
      mdata%binf(sum(lct(ic1a,il0)%ncomp)+1:sum(lct(ic1a,il0)%ncomp)+lct(ic1a,il0)%nscales) = lct_binf%coef
      mdata%bsup(sum(lct(ic1a,il0)%ncomp)+1:sum(lct(ic1a,il0)%ncomp)+lct(ic1a,il0)%nscales) = lct_bsup%coef
      mdata%obs = pack(lct(ic1a,il0)%raw,.true.)
      mdata%fit_type = trim(nam%fit_type)
      mdata%nc3 = nam%nc3
      mdata%nl0 = bpar%nl0r(ib)
      mdata%dx = dx
      mdata%dy = dy
      mdata%dz = dz
      mdata%dmask = dmask
      mdata%nscales = lct(ic1a,il0)%nscales
      mdata%ncomp = lct(ic1a,il0)%ncomp

      ! Compute fit
      call minim(mdata,cost_fit_lct,.false.)

      ! Copy parameters
      lct(ic1a,il0)%H = mdata%x(1:sum(lct(ic1a,il0)%ncomp))
      lct(ic1a,il0)%coef = mdata%x(sum(lct(ic1a,il0)%ncomp)+1:sum(lct(ic1a,il0)%ncomp)+lct(ic1a,il0)%nscales)

      ! Dummy call to avoid warnings
      call dummy(mdata)

      ! Fixed positive value for the 2D case
      if (bpar%nl0r(ib)==1) then
         offset = 0
         do iscales=1,lct(ic1a,il0)%nscales
            lct(ic1a,il0)%H(offset+3) = 1.0
            offset = offset+lct(ic1a,il0)%ncomp(iscales)
         end do
      end if

      ! Check positive-definiteness
      do iscales=1,lct(ic1a,il0)%nscales
         offset = 0
         lct(ic1a,il0)%H(offset+1) = max(Hmin,lct(ic1a,il0)%H(offset+1))
         lct(ic1a,il0)%H(offset+2) = max(Hmin,lct(ic1a,il0)%H(offset+2))
         lct(ic1a,il0)%H(offset+3) = max(Hmin,lct(ic1a,il0)%H(offset+3))
         if (lct(ic1a,il0)%ncomp(iscales)==4) lct(ic1a,il0)%H(offset+4) = max(-1.0_kind_real,min(lct(ic1a,il0)%H(offset+4), &
                                                                        & 1.0_kind_real))
         if (lct(ic1a,il0)%coef(iscales)<0.0) lct(ic1a,il0)%coef(iscales) = 0.0
         offset = offset+lct(ic1a,il0)%ncomp(iscales)
      end do
      if (lct(ic1a,il0)%nscales==1) then
         lct(ic1a,il0)%coef(1) = 1.0
      else
         lct(ic1a,il0)%coef(lct(ic1a,il0)%nscales) = 1.0-sum(lct(ic1a,il0)%coef(1:lct(ic1a,il0)%nscales-1))
      end if

      ! Rebuild fit
      call define_fit_lct(nam%nc3,bpar%nl0r(ib),dx,dy,dz,dmask,lct(ic1a,il0)%nscales,lct(ic1a,il0)%ncomp,lct(ic1a,il0)%H, &
    & lct(ic1a,il0)%coef,lct(ic1a,il0)%fit)

      ! Print progression
      done(ic1a) = .true.
      call prog_print(progint,done)

      ! Release memory
      deallocate(mdata%x)
      deallocate(mdata%guess)
      deallocate(mdata%norm)
      deallocate(mdata%binf)
      deallocate(mdata%bsup)
      deallocate(mdata%obs)
      deallocate(mdata%dx)
      deallocate(mdata%dy)
      deallocate(mdata%dz)
      deallocate(mdata%dmask)
      deallocate(mdata%ncomp)
      call lct_guess%dealloc
      call lct_norm%dealloc
      call lct_binf%dealloc
      call lct_bsup%dealloc
   end do
   write(mpl%unit,'(a)') '100%'
end do

! End associate
end associate

end subroutine compute_fit_lct

!----------------------------------------------------------------------
! Subroutine: define_fit_lct
!> Purpose: define the LCT fit
!----------------------------------------------------------------------
subroutine define_fit_lct(nc,nl0,dx,dy,dz,dmask,nscales,ncomp,H,coef,fit)

implicit none

! Passed variables
integer,intent(in) :: nc                    !< Number of classes
integer,intent(in) :: nl0                   !< Number of levels
real(kind_real),intent(in) :: dx(nc,nl0)    !< Zonal separation
real(kind_real),intent(in) :: dy(nc,nl0)    !< Meridian separation
real(kind_real),intent(in) :: dz(nl0)       !< Vertical separation
logical,intent(in) :: dmask(nc,nl0)         !< Mask
integer,intent(in) :: nscales               !< Number of LCT scales
integer,intent(in) :: ncomp(nscales)        !< Number of LCT components
real(kind_real),intent(in) :: H(sum(ncomp)) !< LCT components
real(kind_real),intent(in) :: coef(nscales) !< LCT coefficients
real(kind_real),intent(out) :: fit(nc,nl0)  !< Fit

! Local variables
integer :: jl0,jc3,iscales,offset
real(kind_real) :: H11,H22,H33,Hc12,rsq

! Initialization
call msr(fit)

offset = 0
do iscales=1,nscales
   ! Force positive definiteness
   H11 = max(Hmin,H(offset+1))
   H22 = max(Hmin,H(offset+2))
   H33 = max(Hmin,H(offset+3))
   call msr(Hc12)
   if (ncomp(iscales)==4) Hc12 = max(-1.0_kind_real,min(H(offset+4),1.0_kind_real))

   ! Homogeneous anisotropic approximation
   do jl0=1,nl0
      do jc3=1,nc
         if (dmask(jc3,jl0)) then
            ! Initialization
            if (iscales==1) fit(jc3,jl0) = 0.0

            ! Squared distance
            rsq = H11*dx(jc3,jl0)**2+H22*dy(jc3,jl0)**2+H33*dz(jl0)**2
            if (ncomp(iscales)==4) rsq = rsq+2.0*sqrt(H11*H22)*Hc12*dx(jc3,jl0)*dy(jc3,jl0)

            if (M==0) then
               ! Gaussian function
               fit(jc3,jl0) = fit(jc3,jl0)+coef(iscales)*exp(-0.5*rsq)
            else
               ! Matern function
               fit(jc3,jl0) = fit(jc3,jl0)+coef(iscales)*matern(M,sqrt(rsq))
            end if
         end if
      end do
   end do

   ! Update offset
   offset = offset+ncomp(iscales)
end do

end subroutine define_fit_lct

!----------------------------------------------------------------------
! Function: cost_fit_lct
!> Purpose: LCT fit function cost
!----------------------------------------------------------------------
subroutine cost_fit_lct(mdata,x,f)

implicit none

! Passed variables
type(mdatatype),intent(in) :: mdata       !< Minimization data
real(kind_real),intent(in) :: x(mdata%nx) !< Control vector
real(kind_real),intent(out) :: f          !< Cost function value

! Local variables
integer :: ix,ncomptot
real(kind_real) :: fit(mdata%nc3,mdata%nl0)
real(kind_real) :: xtmp(mdata%nx),fit_pack(mdata%ny),xx

! Renormalize
xtmp = x*mdata%norm

! Compute function
ncomptot = sum(mdata%ncomp)
call define_fit_lct(mdata%nc3,mdata%nl0,mdata%dx,mdata%dy,mdata%dz,mdata%dmask,mdata%nscales,mdata%ncomp, &
 & xtmp(1:ncomptot),xtmp(ncomptot+1:ncomptot+mdata%nscales),fit)

! Pack
fit_pack = pack(fit,mask=.true.)

! Cost
f = sum((mdata%obs-fit_pack)**2,mask=isnotmsr(fit_pack))

! Bound penalty
do ix=1,mdata%nx
   xx = (xtmp(ix)-mdata%binf(ix))/(mdata%bsup(ix)-mdata%binf(ix))
   if (xx<0.0) then
      f = f+mdata%f_guess*xx**2
   elseif (xx>1.0) then
      f = f+mdata%f_guess*(xx-1.0)**2
   end if
end do

end subroutine cost_fit_lct

!----------------------------------------------------------------------
! Subroutine: dummy
!> Purpose: dummy subroutine to avoid warnings
!----------------------------------------------------------------------
subroutine dummy(mdata)

implicit none

! Passed variables
type(mdatatype),intent(in) :: mdata !< Minimization data

! Local variables
real(kind_real) :: x(mdata%nx)
real(kind_real) :: f

if (.false.) call cost_fit_lct(mdata,x,f)

end subroutine

end module hdiag_fit_lct
