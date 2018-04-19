!----------------------------------------------------------------------
! Module: type_hnb
!> Purpose: HDIAG NICAS bundle derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module type_hnb

use netcdf
use model_offline, only: model_coord,load_ensemble
use model_online, only: model_online_coord,model_online_from_file,model_online_to_file
use tools_const, only: req,deg2rad
use tools_display, only: listing_setup,msgerror
use tools_kinds,only: kind_real
use tools_nc, only: ncfloat,ncerr
use type_bpar, only: bpar_type
use type_cmat, only: cmat_type
use type_geom, only: geom_type
use type_lct, only: lct_type
use type_mpl, only: mpl
use type_nam, only: nam_type
use type_nicas, only: nicas_type
use type_obsop, only: obsop_type
use type_rng, only: rng
use type_timer, only: timer_type

implicit none

! HDIAG NICAS bundle derived type
type hnb_type
  type(nam_type) :: nam
  type(geom_type) :: geom
  type(bpar_type) :: bpar
  type(cmat_type) :: cmat
  type(nicas_type) :: nicas
  type(lct_type) :: lct
  type(obsop_type) :: obsop
  real(kind_real),allocatable :: ens1(:,:,:,:,:)
  real(kind_real),allocatable :: rh0(:,:,:,:)
  real(kind_real),allocatable :: rv0(:,:,:,:)
contains
   procedure :: setup_offline => hnb_setup_offline
   procedure :: setup_online => hnb_setup_online
   procedure :: setup_online_from_file => hnb_setup_online_from_file
   procedure :: setup_online_generic => hnb_setup_online_generic
   procedure :: setup_generic => hnb_setup_generic
   procedure :: apply_nicas => hnb_apply_nicas
end type hnb_type

logical,parameter :: write_online = .false. !< Write online data for tests

private
public :: hnb_type

contains

!----------------------------------------------------------------------
! Subroutine: hnb_setup_offline
!> Purpose: HDIAG NICAS bundle offline setup
!----------------------------------------------------------------------
subroutine hnb_setup_offline(hnb,mpi_comm,namelname)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb     !< HDIAG NICAS bundle
integer,intent(in) :: mpi_comm           !< MPI communicator
character(len=*),intent(in) :: namelname !< Namelist name

! Local variables
type(timer_type) :: timer

! Initialize MPL
call mpl%init(mpi_comm)

! Initialize timer
if (mpl%main) call timer%start

! Initialize, read and broadcast namelist
call hnb%nam%init
call hnb%nam%read(namelname)
call hnb%nam%bcast

! Setup display
call listing_setup(hnb%nam%colorlog,hnb%nam%logpres)

! Header
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- You are running hdiag_nicas -----------------------------------'
write(mpl%unit,'(a)') '--- Author: Benjamin Menetrier ------------------------------------'
write(mpl%unit,'(a)') '--- Copyright © 2017 METEO-FRANCE ---------------------------------'
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
call flush(mpl%unit)

! Check namelist
call hnb%nam%check

! Parallel setup
write(mpl%unit,'(a,i4,a,i4,a)') '--- Parallelization with ',mpl%nproc,' MPI tasks and ',mpl%nthread,' OpenMP threads'
call flush(mpl%unit)

! Initialize random number generator
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize random number generator'
call flush(mpl%unit)
call rng%create(hnb%nam)

! Initialize geometry
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize geometry'
call flush(mpl%unit)
call model_coord(hnb%nam,hnb%geom)
call hnb%geom%init(hnb%nam)

if (hnb%nam%load_ensemble) then
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Load ensemble'
   call flush(mpl%unit)

   ! Allocation
   allocate(hnb%ens1(hnb%geom%nc0a,hnb%geom%nl0,hnb%nam%nv,hnb%nam%nts,hnb%nam%ens1_ne))

   ! Load ensemble
   call load_ensemble(hnb%nam,hnb%geom,hnb%ens1)
end if

if (hnb%nam%new_obsop) then
   ! Generate observations locations
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Generate observations locations'
   call flush(mpl%unit)
   call hnb%obsop%generate(hnb%nam,hnb%geom)
end if

! Generic setup
call hnb%setup_generic

! Execution stats
if (mpl%main) then
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Execution stats'
   call timer%display
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
else
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Done ----------------------------------------------------------'
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
end if
call flush(mpl%unit)

! Close listings
close(unit=mpl%unit)

end subroutine hnb_setup_offline

!----------------------------------------------------------------------
! Subroutine: hnb_setup_online
!> Purpose: HDIAG NICAS bundle online setup
!----------------------------------------------------------------------
subroutine hnb_setup_online(hnb,mpi_comm,nga,nl0,nv,nts,lon,lat,area,vunit,lmask,ens1,rh0,rv0,lonobs,latobs)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb                   !< HDIAG NICAS bundle
integer,intent(in) :: mpi_comm                         !< MPI communicator
integer,intent(in) :: nga                              !< Halo A size
integer,intent(in) :: nl0                              !< Number of levels in subset Sl0
integer,intent(in) :: nv                               !< Number of variables
integer,intent(in) :: nts                              !< Number of time slots
real(kind_real),intent(in) :: lon(nga)                 !< Longitude
real(kind_real),intent(in) :: lat(nga)                 !< Latitude
real(kind_real),intent(in) :: area(nga)                !< Area
real(kind_real),intent(in) :: vunit(nl0)               !< Vertical unit
logical,intent(in) :: lmask(nga,nl0)                   !< Mask
real(kind_real),intent(in),optional :: ens1(:,:,:,:,:) !< Ensemble 1
real(kind_real),intent(in),optional :: rh0(:,:,:,:)    !< Horizontal support radius for covariance
real(kind_real),intent(in),optional :: rv0(:,:,:,:)    !< Vertical support radius for covariance
real(kind_real),intent(in),optional :: lonobs(:)       !< Observations longitudes
real(kind_real),intent(in),optional :: latobs(:)       !< Observations latitudes

! Initialize MPL
call mpl%init(mpi_comm)

! Check consistency
if ((present(rh0).and.(.not.present(rv0))).or.((.not.present(rh0)).and.present(rv0))) &
 & call msgerror('rh0 and rv0 should be present together')
if ((present(lonobs).and.(.not.present(latobs))).or.((.not.present(lonobs)).and.present(latobs))) &
 & call msgerror('lonobs and latobs should be present together')

! Check sizes consistency
if (present(ens1)) then
   if (size(ens1,1)/=nga) call msgerror('wrong size(1) for ens1')
   if (size(ens1,2)/=nl0) call msgerror('wrong size(2) for ens1')
   if (size(ens1,3)/=nv) call msgerror('wrong size(3) for ens1')
   if (size(ens1,4)/=nts) call msgerror('wrong size(4) for ens1')
end if
if (present(rh0).and.present(rv0)) then
   if (size(rh0,1)/=nga) call msgerror('wrong size(1) for rh0')
   if (size(rh0,2)/=nl0) call msgerror('wrong size(2) for rh0')
   if (size(rh0,3)/=nv) call msgerror('wrong size(3) for rh0')
   if (size(rh0,4)/=nts) call msgerror('wrong size(4) for rh0')
   if (size(rv0,1)/=nga) call msgerror('wrong size(1) for rv0')
   if (size(rv0,2)/=nl0) call msgerror('wrong size(2) for rv0')
   if (size(rv0,3)/=nv) call msgerror('wrong size(3) for rv0')
   if (size(rv0,4)/=nts) call msgerror('wrong size(4) for rv0')
end if
if (present(lonobs).and.present(latobs)) then
   if (size(lonobs,1)/=size(latobs,1)) call msgerror('lonobs and latobs should have the same size')
end if

if (write_online) then
   ! Write online setup data to file (for tests)
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Write online setup data to file (for tests)'
   call flush(mpl%unit)
   if (present(ens1)) then
      call model_online_to_file(hnb%nam%prefix,nga,nl0,nv,nts,lon,lat,area,vunit,lmask,ens1=ens1)
   elseif (present(rh0).and.present(rv0)) then
      call model_online_to_file(hnb%nam%prefix,nga,nl0,nv,nts,lon,lat,area,vunit,lmask,rh0=rh0,rv0=rv0)
   elseif (present(lonobs).and.present(latobs)) then
      call model_online_to_file(hnb%nam%prefix,nga,nl0,nv,nts,lon,lat,area,vunit,lmask,lonobs=lonobs,latobs=latobs)
   else
      call model_online_to_file(hnb%nam%prefix,nga,nl0,nv,nts,lon,lat,area,vunit,lmask)
   end if
end if

! Generic online setup
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Generic online setup'
call flush(mpl%unit)
if (present(ens1)) then
   call hnb%setup_online_generic(nga,nl0,nv,nts,lon,lat,area,vunit,lmask,ens1=ens1)
elseif (present(rh0).and.present(rv0)) then
   call hnb%setup_online_generic(nga,nl0,nv,nts,lon,lat,area,vunit,lmask,rh0=rh0,rv0=rv0)
else
   call hnb%setup_online_generic(nga,nl0,nv,nts,lon,lat,area,vunit,lmask,lonobs=lonobs,latobs=latobs)
end if

end subroutine hnb_setup_online

!----------------------------------------------------------------------
! Subroutine: hnb_setup_online_from_file
!> Purpose: HDIAG NICAS bundle online setup from file (for tests)
!----------------------------------------------------------------------
subroutine hnb_setup_online_from_file(hnb,mpi_comm,prefix)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb  !< HDIAG NICAS bundle
integer,intent(in) :: mpi_comm        !< MPI communicator
character(len=*),intent(in) :: prefix !< Prefix

! Local variables
integer :: nga,nl0,nv,nts
real(kind_real),allocatable :: lon(:),lat(:),area(:),vunit(:),ens1(:,:,:,:,:),rh0(:,:,:,:),rv0(:,:,:,:),lonobs(:),latobs(:)
logical,allocatable :: lmask(:,:)

! Initialize MPL
call mpl%init(mpi_comm)

! Load online data from file
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Load online data from file'
call flush(mpl%unit)
call model_online_from_file(prefix,nga,nl0,nv,nts,lon,lat,area,vunit,lmask,ens1,rh0,rv0,lonobs,latobs)

! Initialize and set parameters
call hnb%nam%init
call hnb%nam%setup_online(prefix)

! Generic online setup
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Generic online setup'
call flush(mpl%unit)
if (allocated(ens1)) then
   call hnb%setup_online_generic(nga,nl0,nv,nts,lon,lat,area,vunit,lmask,ens1=ens1)
elseif (allocated(rh0).and.allocated(rv0)) then
   call hnb%setup_online_generic(nga,nl0,nv,nts,lon,lat,area,vunit,lmask,rh0=rh0,rv0=rv0)
elseif (allocated(lonobs).and.allocated(latobs)) then
   call hnb%setup_online_generic(nga,nl0,nv,nts,lon,lat,area,vunit,lmask,lonobs=lonobs,latobs=latobs)
else
   call hnb%setup_online_generic(nga,nl0,nv,nts,lon,lat,area,vunit,lmask)
end if

end subroutine hnb_setup_online_from_file

!----------------------------------------------------------------------
! Subroutine: hnb_setup_online_generic
!> Purpose: HDIAG NICAS bundle online setup, generic part
!----------------------------------------------------------------------
subroutine hnb_setup_online_generic(hnb,nga,nl0,nv,nts,lon,lat,area,vunit,lmask,ens1,rh0,rv0,lonobs,latobs)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb                   !< HDIAG NICAS bundle
integer,intent(in) :: nga                              !< Halo A size
integer,intent(in) :: nl0                              !< Number of levels in subset Sl0
integer,intent(in) :: nv                               !< Number of variables
integer,intent(in) :: nts                              !< Number of time slots
real(kind_real),intent(in) :: lon(nga)                 !< Longitude
real(kind_real),intent(in) :: lat(nga)                 !< Latitude
real(kind_real),intent(in) :: area(nga)                !< Area
real(kind_real),intent(in) :: vunit(nl0)               !< Vertical unit
logical,intent(in) :: lmask(nga,nl0)                   !< Mask
real(kind_real),intent(in),optional :: ens1(:,:,:,:,:) !< Ensemble 1
real(kind_real),intent(in),optional :: rh0(:,:,:,:)    !< Horizontal support radius for covariance
real(kind_real),intent(in),optional :: rv0(:,:,:,:)    !< Vertical support radius for covariance
real(kind_real),intent(in),optional :: lonobs(:)       !< Observations longitudes
real(kind_real),intent(in),optional :: latobs(:)       !< Observations latitudes

! Local variables
integer :: il,il0,iv,its,ie

! Copy geometry variables
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Copy geometry variables'
call flush(mpl%unit)
hnb%geom%nga = nga
hnb%geom%nl0 = nl0
hnb%geom%nlev = nl0

! Setup namelist variables
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Setup namelist variables'
call flush(mpl%unit)
hnb%nam%datadir = '.'
hnb%nam%model = 'online'
hnb%nam%colorlog = .false.
hnb%nam%load_ensemble = present(ens1)
hnb%nam%nl = nl0
do il=1,hnb%nam%nl
   hnb%nam%levs(il) = il
end do
hnb%nam%nv = nv
do iv=1,hnb%nam%nv
   write(hnb%nam%varname(iv),'(a,i2.2)') 'var_',iv
   hnb%nam%addvar2d(iv) = ''
end do
hnb%nam%nts = nts
hnb%nam%timeslot = 0
if (present(ens1)) then
   hnb%nam%ens1_ne = size(ens1,5)
else
   hnb%nam%ens1_ne = 4
end if
hnb%nam%ens1_ne_offset = 0
hnb%nam%ens1_nsub = 1

! Setup display
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Setup display'
call flush(mpl%unit)
call listing_setup(hnb%nam%colorlog,hnb%nam%logpres)

! Check namelist parameters
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Check namelist parameters'
call flush(mpl%unit)
call hnb%nam%check

! Write parallel setup
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i3,a,i2,a)') '--- Parallelization with ',mpl%nproc,' MPI tasks and ',mpl%nthread,' OpenMP threads'
call flush(mpl%unit)

! Initialize random number generator
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize random number generator'
call flush(mpl%unit)
call rng%create(hnb%nam)

! Initialize geometry
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize geometry'
call flush(mpl%unit)
call model_online_coord(hnb%geom,lon,lat,area,vunit,lmask)
call hnb%geom%init(hnb%nam)

if (present(ens1)) then
   ! Initialize ensemble
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Initialize ensemble'
   call flush(mpl%unit)
   allocate(hnb%ens1(hnb%geom%nc0a,hnb%geom%nl0,hnb%nam%nv,hnb%nam%nts,hnb%nam%ens1_ne))
   !$omp parallel do schedule(static) private(ie,its,iv,il0)
   do ie=1,hnb%nam%ens1_ne
      do its=1,hnb%nam%nts
         do iv=1,hnb%nam%nv
            do il0=1,hnb%geom%nl0
               hnb%ens1(:,il0,iv,its,ie) = ens1(hnb%geom%c0a_to_ga,il0,iv,its,ie)
            end do
         end do
      end do
   end do
   !$omp end parallel do
end if

if (present(rh0).and.present(rv0)) then
   ! Initialize C matrix from support radii
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Initialize C matrix from support radii'
   call flush(mpl%unit)
   call hnb%cmat%from_radii(hnb%nam,hnb%geom,hnb%bpar,rh0,rv0)
end if

if (present(lonobs).and.present(latobs)) then
   ! Initialize observations locations
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Initialize observations locations'
   call flush(mpl%unit)
   hnb%obsop%nobs = size(lonobs)
   allocate(hnb%obsop%lonobs(hnb%obsop%nobs))
   allocate(hnb%obsop%latobs(hnb%obsop%nobs))
   hnb%obsop%lonobs = lonobs
   hnb%obsop%latobs = latobs
end if

! Generic setup
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Generic setup'
call flush(mpl%unit)
call hnb%setup_generic

! Close listings
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Close listings'
call flush(mpl%unit)
close(unit=mpl%unit)

end subroutine hnb_setup_online_generic

!----------------------------------------------------------------------
! Subroutine: hnb_setup_generic
!> Purpose: HDIAG NICAS bundle generic setup
!----------------------------------------------------------------------
subroutine hnb_setup_generic(hnb)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb !< HDIAG NICAS bundle

! Initialize block parameters
call hnb%bpar%alloc(hnb%nam,hnb%geom)

! Call HDIAG driver
if (hnb%nam%load_ensemble) then
   call hnb%cmat%run_hdiag(hnb%nam,hnb%geom,hnb%bpar,hnb%ens1)
else
   call hnb%cmat%run_hdiag(hnb%nam,hnb%geom,hnb%bpar)
end if

! Call NICAS driver
if (hnb%nam%load_ensemble) then
   call hnb%nicas%run_nicas(hnb%nam,hnb%geom,hnb%bpar,hnb%cmat,hnb%ens1)
else
   call hnb%nicas%run_nicas(hnb%nam,hnb%geom,hnb%bpar,hnb%cmat)
end if

! Call LCT driver
if (hnb%nam%load_ensemble) then
   call hnb%lct%run_lct(hnb%nam,hnb%geom,hnb%bpar,hnb%ens1)
else
   call hnb%lct%run_lct(hnb%nam,hnb%geom,hnb%bpar)
end if

! Call observation operator driver
call hnb%obsop%run_obsop(hnb%nam,hnb%geom)

end subroutine hnb_setup_generic

!----------------------------------------------------------------------
! Subroutine: hnb_apply_nicas
!> Purpose: HDIAG NICAS bundle, NICAS application
!----------------------------------------------------------------------
subroutine hnb_apply_nicas(hnb,fld)

implicit none

! Passed variables
class(hnb_type),intent(in) :: hnb                                                       !< HDIAG NICAS bundle
real(kind_real),intent(inout) :: fld(hnb%geom%nc0a,hnb%geom%nl0,hnb%nam%nv,hnb%nam%nts) !< Field

! Apply NICAS
if (hnb%nam%lsqrt) then
   call hnb%nicas%apply_from_sqrt(hnb%nam,hnb%geom,hnb%bpar,fld)
else
   call hnb%nicas%apply(hnb%nam,hnb%geom,hnb%bpar,fld)
end if

end subroutine hnb_apply_nicas

end module type_hnb
