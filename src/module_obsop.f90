!----------------------------------------------------------------------
! Module: module_obsop.f90
!> Purpose: compute observation operator interpolation
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module module_obsop

use module_namelist, only: nam
use omp_lib
use tools_display, only: msgerror
use tools_interp, only: interp_horiz
use tools_kinds, only: kind_real
use tools_missing, only: msi
use tools_qsort, only: qsort
use type_com, only: comtype,com_setup,com_ext,com_red
use type_ctree, only: ctreetype,create_ctree,find_nearest_neighbors,delete_ctree
use type_linop, only: linoptype,linop_alloc,linop_reorder,apply_linop,apply_linop_ad
use type_mesh, only: meshtype,create_mesh,mesh_dealloc
use type_mpl, only: mpl,mpl_allreduce_sum
use type_ndata, only: ndatatype
use type_randgen, only: randgentype,rand_real

implicit none

! Conversion derived type (private to module_mpi)
type convtype
   integer,allocatable :: ic0_to_ic0b(:)
end type

private
public :: compute_obsop

contains

!----------------------------------------------------------------------
! Subroutine: compute_obsop
!> Purpose: compute observation operator interpolation
!----------------------------------------------------------------------
subroutine compute_obsop(nc0,nl0,rng,lon,lat,mask,ic0_to_iproc,ic0_to_ic0a)

implicit none

! Passed variables
integer,intent(in) :: nc0
integer,intent(in) :: nl0
type(randgentype),intent(in) :: rng
real(kind_real),intent(in) :: lon(nc0)
real(kind_real),intent(in) :: lat(nc0)
logical,intent(in) :: mask(nc0,nl0)
integer,intent(in) :: ic0_to_iproc(nc0)
integer,intent(in) :: ic0_to_ic0a(nc0)

! Local variables
integer :: nobs,iobs,jobs,iobsa,iproc,nobsa,i_s,ic0,ic0b,i,jproc,ic0a
integer :: iproc_to_nobsa(nam%nproc),iproc_to_nc0a(nam%nproc),ic0_to_ic0b(nc0)
integer,allocatable :: mask_ctree(:),order(:),iop(:),srcproc(:,:),srcic0(:,:)
integer,allocatable :: iobs_to_iproc(:),iobs_to_iobsa(:)
real(kind_real) :: diff,diffloc,sum1,sum2,sum1loc,sum2loc
real(kind_real) :: fld(nc0,nl0),fld_save(nc0,nl0)
real(kind_real),allocatable :: lonobs(:),latobs(:),list(:)
real(kind_real),allocatable :: fldloc(:,:),fldloc_save(:,:)
real(kind_real),allocatable :: yobs(:,:),yobs_save(:,:),yobsloc(:,:),yobsloc_save(:,:)
logical :: lcheck_nc0b(nc0)
logical,allocatable :: maskobs(:)
type(comtype) :: comobs(nam%nproc)
type(convtype) :: conv(nam%nproc)
type(ctreetype) :: ctree
type(meshtype) :: mesh
type(linoptype) :: interp,interploc(nam%nproc)

! Define number of observations
nobs = int(1.0e-2*float(nc0))

! Allocation
allocate(lonobs(nobs))
allocate(latobs(nobs))
allocate(maskobs(nobs))
allocate(iobs_to_iproc(nobs))
allocate(iobs_to_iobsa(nobs))
allocate(list(nobs))
allocate(order(nobs))
allocate(iop(nobs))
allocate(srcproc(3,nobs))
allocate(srcic0(3,nobs))

! Generate random observation network
call rand_real(rng,-180.0_kind_real,180.0_kind_real,.true.,lonobs) 
call rand_real(rng,-90.0_kind_real,90.0_kind_real,.true.,latobs) 
maskobs = .true.

! Create mesh
call create_mesh(rng,nc0,lon,lat,.false.,mesh)

! Compute cover tree
allocate(mask_ctree(mesh%nnr))
mask_ctree = 1
ctree = create_ctree(mesh%nnr,dble(lon(mesh%order)),dble(lat(mesh%order)),mask_ctree)
deallocate(mask_ctree)

! Compute interpolation
interp%prefix = 'o'
write(mpl%unit,'(a7,a)') '','Single level:'
call interp_horiz(mesh,ctree,nc0,any(mask,dim=2),nobs,lonobs,latobs,maskobs,interp)

! Reorder interpolation
call linop_reorder(interp)

! Find grid points origin
iop = 0
call msi(srcproc)
call msi(srcic0) 
do i_s=1,interp%n_s
   ic0 = interp%col(i_s)
   iproc = ic0_to_iproc(ic0)
   iobs = interp%row(i_s)
   iop(iobs) = iop(iobs)+1
   srcproc(iop(iobs),iobs) = iproc
   srcic0(iop(iobs),iobs) = ic0
end do

! Generate observation distribution on processors
if (.false.) then
   ! Random repartition
   call rand_real(rng,0.0_kind_real,1.0_kind_real,.true.,list)
   call qsort(nobs,list,order)
   nobsa = nobs/nam%nproc
   if (nobsa*nam%nproc<nobs) nobsa = nobsa+1 
   iproc = 1
   iobsa = 1
   do iobs=1,nobs
      jobs = order(iobs)
      iobs_to_iproc(jobs) = iproc
      iobsa = iobsa+1
      if (iobsa>nobsa) then
         iproc = iproc+1
         iobsa = 1
      end if
   end do
else
   ! Source grid-based repartition
   do iobs=1,nobs
      ! Set observation proc
      if (srcproc(2,iobs)==srcproc(3,iobs)) then
         ! Set to second point proc
         iobs_to_iproc(iobs) = srcproc(2,iobs)
      else
         ! Set to first point proc
         iobs_to_iproc(iobs) = srcproc(1,iobs)
      end if
   end do
end if

! Local observations
iproc_to_nobsa = 0
do iobs=1,nobs
   ! Concerned proc
   iproc = iobs_to_iproc(iobs)

   ! Number of observations per proc
   iproc_to_nobsa(iproc) = iproc_to_nobsa(iproc)+1

   ! Observations local index
   iobs_to_iobsa(iobs) = iproc_to_nobsa(iproc)
end do

! Count number of local interpolation operations
do i_s=1,interp%n_s
   iobs = interp%row(i_s)
   iproc = iobs_to_iproc(iobs)
   interploc(iproc)%n_s = interploc(iproc)%n_s+1
end do

do iproc=1,nam%nproc
   ! Count halo points
   lcheck_nc0b = .false.
   do ic0=1,nc0
      jproc = ic0_to_iproc(ic0)
      if (iproc==jproc) lcheck_nc0b(ic0) = .true.
   end do
   do iobs=1,nobs
      jproc = iobs_to_iproc(iobs)
      if (iproc==jproc) then
         do i=1,iop(iobs)
            ic0 = srcic0(i,iobs)
            lcheck_nc0b(ic0) = .true.
         end do
      end if
   end do

   ! Communication
   comobs(iproc)%prefix = 'comobs'
   comobs(iproc)%nred = count(ic0_to_iproc==iproc)
   comobs(iproc)%next = count(lcheck_nc0b)

   ! Allocation
   allocate(comobs(iproc)%iext_to_iproc(comobs(iproc)%next))
   allocate(comobs(iproc)%iext_to_ired(comobs(iproc)%next))
   allocate(comobs(iproc)%ired_to_iext(comobs(iproc)%nred))

   ! Define halo origin
   call msi(ic0_to_ic0b)
   ic0b = 0
   do ic0=1,nc0
      if (lcheck_nc0b(ic0)) then
         ic0b = ic0b+1
         comobs(iproc)%iext_to_iproc(ic0b) = ic0_to_iproc(ic0)
         ic0a = ic0_to_ic0a(ic0)
         comobs(iproc)%iext_to_ired(ic0b) = ic0a
         jproc = ic0_to_iproc(ic0)
         if (iproc==jproc) comobs(iproc)%ired_to_iext(ic0a) = ic0b
         ic0_to_ic0b(ic0) = ic0b
      end if
   end do

   ! Split interpolation data
   interploc(iproc)%prefix = 'o'
   interploc(iproc)%n_src = comobs(iproc)%next
   interploc(iproc)%n_dst = iproc_to_nobsa(iproc)
   call linop_alloc(interploc(iproc))
   interploc(iproc)%n_s = 0
   do i_s=1,interp%n_s
      iobs = interp%row(i_s)
      jproc = iobs_to_iproc(iobs)
      if (iproc==jproc) then
         interploc(iproc)%n_s = interploc(iproc)%n_s+1
         interploc(iproc)%row(interploc(iproc)%n_s) = iobs_to_iobsa(iobs)
         interploc(iproc)%col(interploc(iproc)%n_s) = ic0_to_ic0b(interp%col(i_s))
         interploc(iproc)%S(interploc(iproc)%n_s) = interp%S(i_s)
      end if
   end do
end do

! Communications setup
call com_setup(comobs)

! Print results
write(mpl%unit,'(a7,a,i8)') '','Number of observations: ',nobs
write(mpl%unit,'(a7,a)') '','Number of observations per MPI task:'
do iproc=1,nam%nproc
   write(mpl%unit,'(a10,a,i3,a,i8)') '','Task ',iproc,': ',count(iobs_to_iproc==iproc)
end do
write(mpl%unit,'(a7,a,f5.1,a)') '','Observation repartition imbalance: ', &
 & 100.0*float(maxval(iproc_to_nobsa)-minval(iproc_to_nobsa))/(float(sum(iproc_to_nobsa))/float(nam%nproc)),' %'
write(mpl%unit,'(a7,a)') '','Number of grid points, halo size and number of received values per MPI task:'
do iproc=1,nam%nproc
   write(mpl%unit,'(a10,a,i3,a,i8,a,i8,a,i8)') '','Task ',iproc,': ', &
 & comobs(iproc)%nred,' / ',comobs(iproc)%next,' / ',comobs(iproc)%nhalo
end do


! Allocation
do iproc=1,nam%nproc
   iproc_to_nc0a(iproc) = count(ic0_to_iproc==iproc)
end do
allocate(yobs(nobs,nl0))
allocate(yobsloc(iproc_to_nobsa(mpl%myproc),nl0))
allocate(yobs_save(nobs,nl0))
allocate(yobsloc_save(iproc_to_nobsa(mpl%myproc),nl0))
allocate(fldloc(iproc_to_nc0a(mpl%myproc),nl0))
allocate(fldloc_save(iproc_to_nc0a(mpl%myproc),nl0))

! Test difference between single-proc and multi-procs executions

! Generate random field
call rand_real(rng,0.0_kind_real,1.0_kind_real,.true.,fld)

! Global to local
do ic0=1,nc0
   iproc = ic0_to_iproc(ic0)
   if (iproc==mpl%myproc) fldloc(ic0_to_ic0a(ic0),:) = fld(ic0,:)
end do

! Global and local observation operators
call obsop_global(interp,fld,yobs)
call obsop_local(comobs(mpl%myproc),interploc(mpl%myproc),fldloc,yobsloc)

! Compute local differences and gather results
diffloc = 0.0
do iobs=1,nobs
   iproc = iobs_to_iproc(iobs)
   iobsa = iobs_to_iobsa(iobs)
   if (iproc==mpl%myproc) diffloc = diffloc+sum((yobs(iobs,:)-yobsloc(iobsa,:))**2)
end do
call mpl_allreduce_sum(diffloc,diff)

! Print difference
if (mpl%main) write(mpl%unit,'(a7,a,e14.8)') '','RMSE between single-proc and multi-procs executions: ', &
 & sqrt(diff/float(nobs*nl0))

! Test interpolation adjoint, global

! Generate random fields
call rand_real(rng,0.0_kind_real,1.0_kind_real,.true.,fld_save)
call rand_real(rng,0.0_kind_real,1.0_kind_real,.true.,yobs_save)

! Apply direct and adjoint obsservation operators
call obsop_global(interp,fld_save,yobs)
call obsop_ad_global(interp,yobs_save,fld)

! Compute adjoint test
sum1 = sum(fld*fld_save)
sum2 = sum(yobs*yobs_save)
write(mpl%unit,'(a7,a,e14.8,a,e14.8,a,e14.8)') '','Observation operator adjoint test, global: ', &
 & sum1,' / ',sum2,' / ',2.0*abs(sum1-sum2)/abs(sum1+sum2)

! Test interpolation adjoint, local

! Generate random fields
call rand_real(rng,0.0_kind_real,1.0_kind_real,.true.,fld_save)
call rand_real(rng,0.0_kind_real,1.0_kind_real,.true.,yobs_save)

! Global to local
do ic0=1,nc0
   iproc = ic0_to_iproc(ic0)
   if (iproc==mpl%myproc) fldloc_save(ic0_to_ic0a(ic0),:) = fld_save(ic0,:)
end do
do iobs=1,nobs
   iproc = iobs_to_iproc(iobs)
   if (iproc==mpl%myproc) yobsloc_save(iobs_to_iobsa(iobs),:) = yobs_save(iobs,:)
end do

! Apply direct and adjoint obsservation operators
call obsop_local(comobs(mpl%myproc),interploc(mpl%myproc),fldloc_save,yobsloc)
call obsop_ad_local(comobs(mpl%myproc),interploc(mpl%myproc),yobsloc_save,fldloc)

! Compute adjoint test
sum1loc = 0.0
sum2loc = 0.0
do ic0=1,nc0
   iproc = ic0_to_iproc(ic0)
   ic0a = ic0_to_ic0a(ic0)
   if (iproc==mpl%myproc) sum1loc = sum1loc+sum(fldloc(ic0a,:)*fldloc_save(ic0a,:))
end do
do iobs=1,nobs
   iproc = iobs_to_iproc(iobs)
   iobsa = iobs_to_iobsa(iobs)
   if (iproc==mpl%myproc) sum2loc = sum2loc+sum(yobsloc(iobsa,:)*yobsloc_save(iobsa,:))
end do
call mpl_allreduce_sum(sum1loc,sum1)
call mpl_allreduce_sum(sum2loc,sum2)
write(mpl%unit,'(a7,a,e14.8,a,e14.8,a,e14.8)') '','Observation operator adjoint test, local:  ', &
 & sum1,' / ',sum2,' / ',2.0*abs(sum1-sum2)/abs(sum1+sum2)

end subroutine compute_obsop

!----------------------------------------------------------------------
! Subroutine: obsop_global
!> Purpose: observation operator interpolation, global
!----------------------------------------------------------------------
subroutine obsop_global(interp,fld,obs)

implicit none

! Passed variables
type(linoptype),intent(in) :: interp !< Interpolation data
real(kind_real),intent(in) :: fld(:,:) !< Field
real(kind_real),intent(out) :: obs(:,:)  !< Observations columns

! Local variables
integer :: nl0,il0

! Check dimensions
if (size(fld,1)/=interp%n_src) call msgerror('inconsistent dimension for field in obsop_global')
if (size(obs,1)/=interp%n_dst) call msgerror('inconsistent dimension for obs in obsop_global')

! Number of levels
if (size(fld,2)/=size(obs,2)) call msgerror('field and observations with different numbers of levels in obsop_global')
nl0 = size(fld,2)

! Horizontal interpolation
!$omp parallel do private(il0)
do il0=1,nl0
   call apply_linop(interp,fld(:,il0),obs(:,il0))
end do
!$omp end parallel do

end subroutine obsop_global

!----------------------------------------------------------------------
! Subroutine: obsop_local
!> Purpose: observation operator interpolation, local
!----------------------------------------------------------------------
subroutine obsop_local(com,interp,fld,obs)

implicit none

! Passed variables
type(comtype),intent(in) :: com !< Communication data
type(linoptype),intent(in) :: interp !< Interpolation data
real(kind_real),intent(in) :: fld(:,:) !< Field
real(kind_real),intent(out) :: obs(:,:)  !< Observations columns

! Local variables
integer :: nl0,il0
real(kind_real) :: sbuf(com%nexcl),rbuf(com%nhalo)
real(kind_real),allocatable :: slab(:),fld_ext(:,:)

! Check dimensions
if (size(fld,1)/=com%nred) call msgerror('inconsistent dimension for field in obsop_local')
if (com%next/=interp%n_src) call msgerror('inconsistent dimensions between com and interp in obsop_local')
if (size(obs,1)/=interp%n_dst) call msgerror('inconsistent dimension for obs in obsop_local')

! Number of levels
if (size(fld,2)/=size(obs,2)) call msgerror('field and observations with different numbers of levels in obsop_local')
nl0 = size(fld,2)

! Allocation
allocate(slab(com%nred))
allocate(fld_ext(com%next,nl0))

! Halo extension
do il0=1,nl0
   slab = fld(:,il0)
   call com_ext(com,slab)
   fld_ext(:,il0) = slab
end do

! Horizontal interpolation
!$omp parallel do private(il0)
do il0=1,nl0
   call apply_linop(interp,fld_ext(:,il0),obs(:,il0))
end do
!$omp end parallel do

end subroutine obsop_local

!----------------------------------------------------------------------
! Subroutine: obsop_ad_global
!> Purpose: observation operator interpolation adjoint, global
!----------------------------------------------------------------------
subroutine obsop_ad_global(interp,obs,fld)

implicit none

! Passed variables
type(linoptype),intent(in) :: interp !< Interpolation data
real(kind_real),intent(in) :: obs(:,:)  !< Observations columns
real(kind_real),intent(out) :: fld(:,:) !< Field

! Local variables
integer :: nl0,il0

! Check dimensions
if (size(fld,1)/=interp%n_src) call msgerror('inconsistent dimension for field in obsop_global')
if (size(obs,1)/=interp%n_dst) call msgerror('inconsistent dimension for obs in obsop_global')

! Number of levels
if (size(fld,2)/=size(obs,2)) call msgerror('field and observations with different numbers of levels in obsop_global')
nl0 = size(fld,2)

! Horizontal interpolation
!$omp parallel do private(il0)
do il0=1,nl0
   call apply_linop_ad(interp,obs(:,il0),fld(:,il0))
end do
!$omp end parallel do

end subroutine obsop_ad_global

!----------------------------------------------------------------------
! Subroutine: obsop_ad_local
!> Purpose: observation operator interpolation adjoint, local
!----------------------------------------------------------------------
subroutine obsop_ad_local(com,interp,obs,fld)

implicit none

! Passed variables
type(comtype),intent(in) :: com !< Communication data
type(linoptype),intent(in) :: interp !< Interpolation data
real(kind_real),intent(in) :: obs(:,:)  !< Observations columns
real(kind_real),intent(out) :: fld(:,:) !< Field

! Local variables
integer :: nl0,il0
real(kind_real) :: sbuf(com%nexcl),rbuf(com%nhalo)
real(kind_real),allocatable :: slab(:),fld_ext(:,:)

! Check dimensions
if (size(fld,1)/=com%nred) call msgerror('inconsistent dimension for field in obsop_local')
if (com%next/=interp%n_src) call msgerror('inconsistent dimensions between com and interp in obsop_local')
if (size(obs,1)/=interp%n_dst) call msgerror('inconsistent dimension for obs in obsop_local')

! Number of levels
if (size(fld,2)/=size(obs,2)) call msgerror('field and observations with different numbers of levels in obsop_local')
nl0 = size(fld,2)

! Allocation
allocate(slab(com%nred))
allocate(fld_ext(com%next,nl0))

! Horizontal interpolation
!$omp parallel do private(il0)
do il0=1,nl0
   call apply_linop_ad(interp,obs(:,il0),fld_ext(:,il0))
end do
!$omp end parallel do

! Halo reduction
do il0=1,nl0
   slab = fld_ext(:,il0)
   call com_red(com,slab)
   fld(:,il0) = slab
end do

end subroutine obsop_ad_local

end module module_obsop
