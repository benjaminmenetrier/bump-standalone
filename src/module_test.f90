!----------------------------------------------------------------------
! Module: module_test.f90
!> Purpose: test NICAS
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module module_test

use model_interface, only: model_write
use module_apply_convol, only: convol
use module_apply_interp, only: interp,interp_ad
use module_apply_localization, only: apply_localization
use module_apply_nicas, only: apply_nicas,apply_nicas_sqrt,apply_nicas_sqrt_ad,apply_nicas_from_sqrt
use omp_lib
use tools_const, only: deg2rad,rad2deg,sphere_dist
use tools_display, only: msgerror
use tools_kinds,only: kind_real
use tools_missing, only: msi,msr,isnotmsi,isnotmsr
use type_bpar, only: bpartype
use type_com, only: com_ext,com_red
use type_ctree, only: find_nearest_neighbors
use type_geom, only: geomtype,fld_com_gl,fld_com_lg
use type_mpl, only: mpl
use type_nam, only: namtype
use type_ndata, only: ndatatype,ndataloctype
use type_randgen, only: rng,rand_real
use type_timer, only: timertype,timer_start,timer_end

implicit none

real(kind_real),parameter :: tol = 1.0e-3 !< Positive-definiteness test tolerance
integer,parameter :: nitermax = 50        !< Nunmber of iterations for the positive-definiteness test

private
public :: test_adjoints,test_pos_def,test_mpi,test_dirac,test_perf,test_dirac_localization

contains

!----------------------------------------------------------------------
! Subroutine: test_adjoints
!> Purpose: test adjoints accuracy
!----------------------------------------------------------------------
subroutine test_adjoints(ndata)

implicit none

! Passed variables
type(ndatatype),intent(in) :: ndata !< Sampling data

! Local variables
real(kind_real) :: sum1,sum2
real(kind_real) :: alpha(ndata%ns),alpha_save(ndata%ns)
real(kind_real) :: alpha1(ndata%ns),alpha1_save(ndata%ns)
real(kind_real) :: alpha2(ndata%ns),alpha2_save(ndata%ns)
real(kind_real) :: fld(ndata%geom%nc0,ndata%geom%nl0),fld_save(ndata%geom%nc0,ndata%geom%nl0)
real(kind_real) :: fld1(ndata%geom%nc0,ndata%geom%nl0),fld1_save(ndata%geom%nc0,ndata%geom%nl0)
real(kind_real) :: fld2(ndata%geom%nc0,ndata%geom%nl0),fld2_save(ndata%geom%nc0,ndata%geom%nl0)

! Associate
associate(nam=>ndata%nam,geom=>ndata%geom)

! Initialization
call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,alpha_save)
call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,fld_save)

! Adjoint test
call interp(ndata,alpha_save,fld)
call interp_ad(ndata,fld_save,alpha)

! Print result
sum1 = sum(alpha*alpha_save)
sum2 = sum(fld*fld_save)
write(mpl%unit,'(a7,a,e15.8,a,e15.8,a,e15.8)') '','Interpolation adjoint test: ', &
 & sum1,' / ',sum2,' / ',2.0*abs(sum1-sum2)/abs(sum1+sum2)

! Initialization
call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,alpha1_save)
call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,alpha2_save)
alpha1 = alpha1_save
alpha2 = alpha2_save

! Adjoint test
call convol(ndata,alpha1)
call convol(ndata,alpha2)

! Print result
sum1 = sum(alpha1*alpha2_save)
sum2 = sum(alpha2*alpha1_save)
write(mpl%unit,'(a7,a,e15.8,a,e15.8,a,e15.8)') '','Convolution adjoint test:   ', &
 & sum1,' / ',sum2,' / ',2.0*abs(sum1-sum2)/abs(sum1+sum2)

! Initialization
call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,fld1_save)
call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,fld2_save)
fld1 = fld1_save
fld2 = fld2_save

! Adjoint test
if (nam%lsqrt) then
   call apply_nicas_from_sqrt(ndata,fld1)
   call apply_nicas_from_sqrt(ndata,fld2)
else
   call apply_nicas(ndata,fld1)
   call apply_nicas(ndata,fld2)
end if

! Print result
sum1 = sum(fld1*fld2_save)
sum2 = sum(fld2*fld1_save)
write(mpl%unit,'(a7,a,e15.8,a,e15.8,a,e15.8)') '','NICAS adjoint test:         ', &
 & sum1,' / ',sum2,' / ',2.0*abs(sum1-sum2)/abs(sum1+sum2)

! End associate
end associate

end subroutine test_adjoints

!----------------------------------------------------------------------
! Subroutine: test_pos_def
!> Purpose: test positive_definiteness
!----------------------------------------------------------------------
subroutine test_pos_def(ndata)

implicit none

! Passed variables
type(ndatatype),intent(in) :: ndata !< Sampling data

! Local variables
integer :: iter
real(kind_real) :: norm,egvmax,egvmax_prev,egvmin,egvmin_prev
real(kind_real) :: fld(ndata%geom%nc0,ndata%geom%nl0),fld_prev(ndata%geom%nc0,ndata%geom%nl0)

! Associate
associate(nam=>ndata%nam,geom=>ndata%geom)

! Power method to find the largest eigenvalue
call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,fld_prev)
norm = sum(fld_prev**2)
fld_prev = fld_prev/norm
egvmax_prev = huge(1.0)
iter = 1
do while (iter<=nitermax)
   ! Copy vector
   fld = fld_prev

   ! Apply C
   if (nam%lsqrt) then
      call apply_nicas_from_sqrt(ndata,fld)
   else
      call apply_nicas(ndata,fld)
   end if

   ! Compute Rayleigh quotient
   egvmax = sum(fld*fld_prev)/sum(fld_prev*fld_prev)

   ! Renormalize the vector
   norm = sum(fld**2)
   fld = fld/norm

   ! Exit test
   if (abs(egvmax-egvmax_prev)<tol) exit

   ! Update
   iter = iter+1
   fld_prev = fld
   egvmax_prev = egvmax
end do

! Power method to find the smallest eigenvalue
call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,fld_prev)
norm = sum(fld_prev**2)
egvmin_prev = huge(1.0)
fld_prev = fld_prev/norm
egvmin_prev = huge(1.0)
iter = 1
do while (iter<=nitermax)
   ! Copy vector
   fld = fld_prev

   ! Apply C
   if (nam%lsqrt) then
      call apply_nicas_from_sqrt(ndata,fld)
   else
      call apply_nicas(ndata,fld)
   end if
   fld = fld-egvmax*fld_prev

   ! Compute Rayleigh quotient
   egvmin = sum(fld*fld_prev)/sum(fld_prev*fld_prev)

   ! Renormalize the vector
   norm = sum(fld**2)
   fld = fld/norm

   ! Exit test
   if (egvmax+egvmin<-tol*egvmax) then
      write(mpl%unit,'(a7,a)') '','NICAS is not positive definite'
      exit
   end if

   ! Update
   iter = iter+1
   fld_prev = fld
   egvmin_prev = egvmin
end do

! Non conclusive test
if (iter==nitermax+1) write(mpl%unit,'(a7,a,e15.8,a,i4,a,e15.8)') '','NICAS seems to be positive definite: difference ', &
 & egvmax+egvmin,' after ',nitermax,' iterations for a tolerance ',tol

! End associate
end associate

end subroutine test_pos_def

!----------------------------------------------------------------------
! Subroutine: test_mpi
!> Purpose: test global/local equivalence
!----------------------------------------------------------------------
subroutine test_mpi(ndata,ndataloc)

implicit none

! Passed variables
type(ndatatype),intent(in) :: ndata       !< Sampling data
type(ndataloctype),intent(in) :: ndataloc !< Sampling data, local

! Local variables
real(kind_real),allocatable :: fld(:,:),fldloc(:,:)

! Associate
associate(nam=>ndata%nam,geom=>ndata%geom)

if (mpl%nproc>0) then
   ! Allocation
   if (mpl%main) then
      ! Allocation
      allocate(fld(geom%nc0,geom%nl0))
      allocate(fldloc(geom%nc0,geom%nl0))
   
      ! Initialization
      call rand_real(rng,0.0_kind_real,1.0_kind_real,.false.,fld)
      fldloc = fld
   end if
   
   ! Global to local
   call fld_com_gl(geom,fldloc)
   
   if (nam%lsqrt) then
      ! Global
      if (mpl%main) call apply_nicas_from_sqrt(ndata,fld)
   
      ! Local
      call apply_nicas_from_sqrt(nam,geom,ndataloc,fldloc)
   else
      ! Global
      if (mpl%main) call apply_nicas(ndata,fld)
   
      ! Local
      call apply_nicas(nam,geom,ndataloc,fldloc)
   end if
   
   ! Local to global
   call fld_com_lg(geom,fldloc)
   
   ! Print difference
   if (mpl%main) write(mpl%unit,'(a7,a,e15.8,a,e15.8,a,e15.8)') '','RMSE for single-proc and multi-procs executions: ', &
    & sqrt(sum(fld**2)/float(geom%nc0*geom%nl0)),' / ',sqrt(sum(fldloc**2)/float(geom%nc0*geom%nl0)), &
    & ' / ',sqrt(sum((fld-fldloc)**2)/float(geom%nc0*geom%nl0))
else
   write(mpl%unit,'(a7,a)') '','Only one proc used, no test'
end if

! End associate
end associate

end subroutine test_mpi

!----------------------------------------------------------------------
! Subroutine: test_dirac
!> Purpose: apply NICAS to diracs
!----------------------------------------------------------------------
subroutine test_dirac(nam,geom,blockname,ndataloc)

implicit none

! Passed variables
type(namtype),intent(in) :: nam !< Namelist variables
type(geomtype),intent(in) :: geom    !< Geometry
character(len=*),intent(in) :: blockname !< Block name
type(ndataloctype),intent(in) :: ndataloc !< Sampling data, local

! Local variables
integer :: il0,il0dir(nam%ndir),ic0dir(nam%ndir),idir
real(kind_real) :: dum(1)
real(kind_real),allocatable :: fld(:,:)

if (mpl%main) then
   ! Allocation
   allocate(fld(geom%nc0,geom%nl0))

   ! Generate diracs field
   fld = 0.0
   do idir=1,nam%ndir
      ! Find level index
      do il0=1,geom%nl0
          if (nam%levs(il0)==nam%levdir(idir)) il0dir(idir) = il0
      end do

      ! Find nearest neighbor
      call find_nearest_neighbors(geom%ctree(min(il0dir(idir),geom%nl0i)),dble(nam%londir(idir)*deg2rad), &
    & dble(nam%latdir(idir)*deg2rad),1,ic0dir(idir:idir),dum)

      ! Dirac value
      fld(ic0dir(idir),il0dir(idir)) = 1.0
   end do
end if

! Global to local
call fld_com_gl(geom,fld)

! Apply NICAS method
if (nam%lsqrt) then
   call apply_nicas_from_sqrt(nam,geom,ndataloc,fld)
else
   call apply_nicas(nam,geom,ndataloc,fld)
end if

! Local to global
call fld_com_lg(geom,fld)

if (mpl%main) then
   ! Write field
   call model_write(nam,geom,trim(nam%prefix)//'_dirac.nc',trim(blockname)//'_dirac',fld)

   ! Print results
   do idir=1,nam%ndir
      write(mpl%unit,'(a10,f6.1,a,f6.1,a,f10.7)') '',nam%londir(idir),' / ',nam%latdir(idir),': ',fld(ic0dir(idir),il0dir(idir))
   end do
   write(mpl%unit,'(a7,a,f10.7,a,f10.7)') '','Min - max: ', &
 & minval(fld(:,il0dir),mask=geom%mask(:,il0dir)),' - ',maxval(fld(:,il0dir),mask=geom%mask(:,il0dir))
end if

end subroutine test_dirac

!----------------------------------------------------------------------
! Subroutine: test_perf
!> Purpose: test NICAS performance
!----------------------------------------------------------------------
subroutine test_perf(nam,geom,ndataloc)

implicit none

! Passed variables
type(namtype),intent(in) :: nam !< Namelist variables
type(geomtype),intent(in) :: geom    !< Geometry
type(ndataloctype),intent(in) :: ndataloc !< Sampling data

! Local variables
real(kind_real) :: fld(geom%nc0a,geom%nl0)
real(kind_real),allocatable :: alpha(:),alpha_tmp(:)
type(timertype) :: timer_interp_ad,timer_com_1,timer_convol,timer_com_2,timer_interp

! Allocation
allocate(alpha(ndataloc%nsb))

! Random initialization
call rand_real(rng,0.0_kind_real,1.0_kind_real,.true.,fld)

! Adjoint interpolation
call timer_start(timer_interp_ad)
call interp_ad(nam,geom,ndataloc,fld,alpha)
call timer_end(timer_interp_ad)

! Communication
call timer_start(timer_com_1)
if (nam%mpicom==1) then
   ! Allocation 
   allocate(alpha_tmp(ndataloc%nsb))

   ! Copy zone B
   alpha_tmp = alpha

   ! Reallocation
   deallocate(alpha)
   allocate(alpha(ndataloc%nsc))

   ! Initialize
   alpha = 0.0

   ! Copy zone B into zone C
   alpha(ndataloc%isb_to_isc) = alpha_tmp

   ! Release memory
   deallocate(alpha_tmp)
elseif (nam%mpicom==2) then
   ! Halo reduction from zone B to zone A
   call com_red(ndataloc%AB,alpha)

   ! Allocation 
   allocate(alpha_tmp(ndataloc%nsb))

   ! Copy zone A
   alpha_tmp = alpha

   ! Reallocation
   deallocate(alpha)
   allocate(alpha(ndataloc%nsc))

   ! Initialize
   alpha = 0.0

   ! Copy zone A into zone C
   alpha(ndataloc%isa_to_isc) = alpha_tmp

   ! Release memory
   deallocate(alpha_tmp)
end if
call timer_end(timer_com_1)

! Convolution
call timer_start(timer_convol)
call convol(ndataloc,alpha)
call timer_start(timer_convol)

call timer_start(timer_com_2)
! Halo reduction from zone C to zone A
call com_red(ndataloc%AC,alpha)

! Halo extension from zone A to zone B
call com_ext(ndataloc%AB,alpha)
call timer_end(timer_com_2)

! Interpolation
call timer_start(timer_interp)
call interp(nam,geom,ndataloc,alpha,fld)
call timer_end(timer_interp)

! Release memory
deallocate(alpha)

! Print results
write(mpl%unit,'(a10,a,f6.1,a)') '','Adjoint interpolation: ',timer_interp_ad%elapsed,' s'
write(mpl%unit,'(a10,a,f6.1,a)') '','Communication - 1    : ',timer_com_1%elapsed,' s'
write(mpl%unit,'(a10,a,f6.1,a)') '','Convolution          : ',timer_convol%elapsed,' s'
write(mpl%unit,'(a10,a,f6.1,a)') '','Communication - 2    : ',timer_com_2%elapsed,' s'
write(mpl%unit,'(a10,a,f6.1,a)') '','Interpolation        : ',timer_interp%elapsed,' s'

end subroutine test_perf

!----------------------------------------------------------------------
! Subroutine: test_dirac_localization
!> Purpose: apply localization to diracs
!----------------------------------------------------------------------
subroutine test_dirac_localization(nam,geom,bpar,ndataloc)

implicit none

! Passed variables
type(namtype),intent(in) :: nam !< Namelist variables
type(geomtype),intent(in) :: geom    !< Geometry
type(bpartype),intent(in) :: bpar    !< Block parameters
type(ndataloctype),intent(in) :: ndataloc(:) !< Sampling data, local

! Local variables
integer :: il0,il0dir(nam%ndir),ic0dir(nam%ndir),idir,iv,its
real(kind_real) :: dum(1)
real(kind_real),allocatable :: fld(:,:,:,:)
character(len=2) :: itschar

if (mpl%main) then
   ! Allocation
   allocate(fld(geom%nc0,geom%nl0,nam%nv,nam%nts))

   ! Generate diracs field
   fld = 0.0
   do idir=1,nam%ndir
      ! Find level index
      do il0=1,geom%nl0
          if (nam%levs(il0)==nam%levdir(idir)) il0dir(idir) = il0
      end do

      ! Find nearest neighbor
      call find_nearest_neighbors(geom%ctree(min(il0dir(idir),geom%nl0i)),dble(nam%londir(idir)*deg2rad), &
    & dble(nam%latdir(idir)*deg2rad),1,ic0dir(idir:idir),dum)

      ! Dirac value
      fld(ic0dir(idir),il0dir(idir),nam%ivdir(idir),nam%itsdir(idir)) = 1.0
   end do
end if

! Global to local
call fld_com_gl(nam,geom,fld)

! Apply localization
call apply_localization(nam,geom,bpar,ndataloc,fld)

! Local to global
call fld_com_lg(nam,geom,fld)

if (mpl%main) then
   ! Write field
   do its=1,nam%nts
      write(itschar,'(i2.2)') its
      do iv=1,nam%nv
         call model_write(nam,geom,trim(nam%prefix)//'_dirac.nc',trim(nam%varname(iv))//'_'//itschar,fld(:,:,iv,its))
      end do
   end do
end if

end subroutine test_dirac_localization

end module module_test
