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
use type_mpl, only: mpl
use type_nam, only: nam_type
use type_nicas, only: nicas_type
use type_obsop, only: obsop_type
use type_rng, only: rng

implicit none

! HDIAG NICAS bundle derived type
type hnb_type
  type(nam_type) :: nam
  type(geom_type) :: geom
  type(bpar_type) :: bpar
  type(cmat_type) :: cmat
  type(nicas_type) :: nicas
  type(obsop_type) :: obsop
  real(kind_real),allocatable :: ens1(:,:,:,:,:)
contains
   procedure :: setup_offline => hnb_setup_offline
   procedure :: setup_online => hnb_setup_online
   procedure :: setup_generic => hnb_setup_generic
   procedure :: apply_nicas => hnb_apply_nicas
   procedure :: delete => hnb_delete
end type hnb_type

private
public :: hnb_type

contains

!----------------------------------------------------------------------
! Subroutine: hnb_setup_offline
!> Purpose: HDIAG NICAS bundle offline setup
!----------------------------------------------------------------------
subroutine hnb_setup_offline(hnb)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb !< HDIAG NICAS bundle

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

! Initialize geometry
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize geometry'
call model_coord(hnb%nam,hnb%geom)

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

! Close listings
if ((mpl%main.and..not.hnb%nam%colorlog).or..not.mpl%main) close(unit=mpl%unit)

end subroutine hnb_setup_offline

!----------------------------------------------------------------------
! Subroutine: hnb_setup_online
!> Purpose: HDIAG NICAS bundle online setup
!----------------------------------------------------------------------
subroutine hnb_setup_online(hnb,nc0a,nl0,nv,nts,ens1_ne,lon,lat,area,vunit,lmask)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb !< HDIAG NICAS bundle
integer,intent(in) :: nc0a
integer,intent(in) :: nl0
integer,intent(in) :: nv
integer,intent(in) :: nts
integer,intent(in) :: ens1_ne
real(kind_real), intent(in) :: lon(nc0a)
real(kind_real), intent(in) :: lat(nc0a)
real(kind_real), intent(in) :: area(nc0a)
real(kind_real), intent(in) :: vunit(nl0)
logical,intent(in) :: lmask(nc0a,nl0)

! Local variables
integer :: il,iv

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

! Initialize geometry
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize geometry'
call model_online_coord(hnb%geom,lon,lat,area,vunit,lmask)

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

! Initialize random number generator
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize random number generator'
call rng%create(hnb%nam)

! Initialize block parameters
call hnb%bpar%alloc(hnb%nam,hnb%geom)

! Compute grid mesh
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Compute grid mesh'
call hnb%geom%compute_grid_mesh(hnb%nam)

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
   call run_lct(hnb%nam,hnb%geom,hnb%bpar,hnb%ens1)
else
   call run_lct(hnb%nam,hnb%geom,hnb%bpar)
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

!----------------------------------------------------------------------
! Subroutine: hnb_delete
!> Purpose: HDIAG NICAS bundle destructor
!----------------------------------------------------------------------
subroutine hnb_delete(hnb)

implicit none

! Passed variables
class(hnb_type),intent(inout) :: hnb !< HDIAG NICAS bundle

! Deallocate
! TODO

end subroutine hnb_delete

end module type_hnb
