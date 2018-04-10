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

use driver_hdiag, only: run_hdiag
use driver_lct, only: run_lct
use driver_nicas, only: run_nicas
use driver_obsgen, only: run_obsgen
use driver_obsop, only: run_obsop
use model_interface, only: model_coord,model_online_coord,load_ensemble
use tools_display, only: listing_setup
use tools_kinds,only: kind_real
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
contains
   procedure :: setup_offline => hnb_setup_offline
   procedure :: setup_online => hnb_setup_online
   procedure :: setup_generic => hnb_setup_generic
   procedure :: apply_nicas => hnb_apply_nicas
end type hnb_type

private
public :: hnb_type

contains

!----------------------------------------------------------------------
! Subroutine: hnb_setup_offline
!> Purpose: HDIAG NICAS bundle offline setup
!----------------------------------------------------------------------
subroutine hnb_setup_offline(hnb,mpi_comm)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb !< HDIAG NICAS bundle
integer,intent(in) :: mpi_comm       !< MPI communicator

! Local variables
type(timer_type) :: timer

! Initialize MPL
call mpl%init(mpi_comm)

! Initialize timer
if (mpl%main) call timer%start

! Read namelist
call hnb%nam%read

! Setup display
call listing_setup(hnb%nam%colorlog,hnb%nam%logpres)

! Header
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- You are running hdiag_nicas -----------------------------------'
write(mpl%unit,'(a)') '--- Author: Benjamin Menetrier ------------------------------------'
write(mpl%unit,'(a)') '--- Copyright © 2017 METEO-FRANCE ---------------------------------'
write(mpl%unit,'(a)') '-------------------------------------------------------------------'

! Check namelist
call hnb%nam%check

! Parallel setup
write(mpl%unit,'(a,i4,a,i4,a)') '--- Parallelization with ',mpl%nproc,' MPI tasks and ',mpl%nthread,' OpenMP threads'

! Initialize random number generator
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize random number generator'
call rng%create(hnb%nam)

! Initialize geometry
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize geometry'
call model_coord(hnb%nam,hnb%geom)

! Compute grid mesh
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Compute grid mesh'
call hnb%geom%compute_grid_mesh(hnb%nam)

! Load ensemble
if (hnb%nam%load_ensemble) then
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Load ensemble'

   ! Allocation
   allocate(hnb%ens1(hnb%geom%nc0a,hnb%geom%nl0,hnb%nam%nv,hnb%nam%nts,hnb%nam%ens1_ne))

   ! Load ensemble
   call load_ensemble(hnb%nam,hnb%geom,hnb%ens1)
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

! Close listings
if ((mpl%main.and..not.hnb%nam%colorlog).or..not.mpl%main) close(unit=mpl%unit)

end subroutine hnb_setup_offline

!----------------------------------------------------------------------
! Subroutine: hnb_setup_online
!> Purpose: HDIAG NICAS bundle online setup
!----------------------------------------------------------------------
subroutine hnb_setup_online(hnb,nc0a,nl0,nv,nts,ens1_ne,lon,lat,area,vunit,lmask,mpi_comm)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb      !< HDIAG NICAS bundle
integer,intent(in) :: nc0a                !< Halo A size
integer,intent(in) :: nl0                 !< Number of levels in subset Sl0
integer,intent(in) :: nv                  !< Number of variables
integer,intent(in) :: nts                 !< Number of time slots
integer,intent(in) :: ens1_ne             !< Ensemble 1 size
real(kind_real), intent(in) :: lon(nc0a)  !< Longitude
real(kind_real), intent(in) :: lat(nc0a)  !< Latitude
real(kind_real), intent(in) :: area(nc0a) !< Area
real(kind_real), intent(in) :: vunit(nl0) !< Vertical unit
logical,intent(in) :: lmask(nc0a,nl0)     !< Mask
integer,intent(in) :: mpi_comm            !< MPI communicator

! Local variables
integer :: il,iv

! Initialize MPL
call mpl%init(mpi_comm)

! Copy sizes
hnb%geom%nc0a = nc0a
hnb%geom%nl0 = nl0
hnb%geom%nlev = nl0
hnb%nam%nl = nl0
hnb%nam%nv = nv
hnb%nam%nts = nts
hnb%nam%timeslot = 0
hnb%nam%ens1_ne = ens1_ne

! Force other namelist variables
hnb%nam%datadir = '.'
hnb%nam%model = 'online'
hnb%nam%colorlog = .false.
hnb%nam%ens1_ne_offset = 0
hnb%nam%ens1_nsub = 1
do iv=1,hnb%nam%nv
   write(hnb%nam%varname(iv),'(a,i2.2)') 'var_',iv
   hnb%nam%addvar2d(iv) = ''
end do
do il=1,hnb%nam%nl
   hnb%nam%levs(il) = il
end do

! Setup display
call listing_setup(hnb%nam%colorlog,hnb%nam%logpres)

! Check namelist parameters
call hnb%nam%check

! Write parallel setup
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i3,a,i2,a)') '--- Parallelization with ',mpl%nproc,' MPI tasks and ',mpl%nthread,' OpenMP threads'

! Initialize random number generator
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize random number generator'
call rng%create(hnb%nam)

! Initialize geometry
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize geometry'
call model_online_coord(hnb%geom,lon,lat,area,vunit,lmask)

! Compute grid mesh
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Compute grid mesh'
call hnb%geom%compute_grid_mesh(hnb%nam)

! Generic setup
call hnb%setup_generic

! Close listings
if ((mpl%main.and..not.hnb%nam%colorlog).or..not.mpl%main) close(unit=mpl%unit)

end subroutine hnb_setup_online

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
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Call HDIAG driver'
if (hnb%nam%load_ensemble) then
   call run_hdiag(hnb%nam,hnb%geom,hnb%bpar,hnb%cmat,hnb%ens1)
else
   call run_hdiag(hnb%nam,hnb%geom,hnb%bpar,hnb%cmat)
end if

! Call NICAS driver
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Call NICAS driver'
if (hnb%nam%load_ensemble) then
   call run_nicas(hnb%nam,hnb%geom,hnb%bpar,hnb%cmat,hnb%nicas,hnb%ens1)
else
   call run_nicas(hnb%nam,hnb%geom,hnb%bpar,hnb%cmat,hnb%nicas)
end if

! Call LCT driver
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Call LCT driver'
if (hnb%nam%load_ensemble) then
   call run_lct(hnb%nam,hnb%geom,hnb%bpar,hnb%lct,hnb%ens1)
else
   call run_lct(hnb%nam,hnb%geom,hnb%bpar,hnb%lct)
end if

! Call observation operator driver
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i5,a)') '--- Call observation operator driver'
call run_obsgen(hnb%nam,hnb%geom,hnb%obsop)
call run_obsop(hnb%nam,hnb%geom,hnb%obsop)

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
