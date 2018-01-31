!----------------------------------------------------------------------
! Program: main
!> Purpose: initialization, drivers, finalization
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
program main

use driver_hdiag, only: run_hdiag
use driver_lct, only: run_lct
use driver_nicas, only: run_nicas
use driver_obsgen, only: run_obsgen
use driver_obsop, only: run_obsop
use model_interface, only: model_coord,load_ensemble
use tools_display, only: listing_setup,msgerror
use tools_kinds,only: kind_real
use type_bdata, only: bdatatype
use type_bpar, only: bpartype,bpar_alloc
use type_geom, only: geomtype,compute_grid_mesh
use type_mpl, only: mpl,mpl_start,mpl_end
use type_nam, only: namtype,namread,namcheck
use type_ndata, only: ndatatype
use type_odata, only: odatatype
use type_randgen, only: create_randgen
use type_timer, only: timertype,timer_start,timer_display

implicit none

! Local variables
real(kind_real),allocatable :: ens1(:,:,:,:,:)
type(geomtype),target :: geom
type(namtype),target :: nam
type(bpartype) :: bpar
type(bdatatype),allocatable :: bdata(:)
type(ndatatype),allocatable :: ndata(:)
type(odatatype) :: odata
type(timertype) :: timer

!----------------------------------------------------------------------
! Initialize MPL
!----------------------------------------------------------------------

call mpl_start

!----------------------------------------------------------------------
! Initialize timer
!----------------------------------------------------------------------

if (mpl%main) call timer_start(timer)

!----------------------------------------------------------------------
! Read namelist
!----------------------------------------------------------------------

call namread(nam)

!----------------------------------------------------------------------
! Setup display
!----------------------------------------------------------------------

call listing_setup(nam%colorlog,nam%logpres)

!----------------------------------------------------------------------
! Header
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- You are running hdiag_nicas -----------------------------------'
write(mpl%unit,'(a)') '--- Author: Benjamin Menetrier ------------------------------------'
write(mpl%unit,'(a)') '--- Copyright © 2017 METEO-FRANCE ---------------------------------'
write(mpl%unit,'(a)') '-------------------------------------------------------------------'

!----------------------------------------------------------------------
! Check namelist
!----------------------------------------------------------------------

call namcheck(nam)

!----------------------------------------------------------------------
! Parallel setup
!----------------------------------------------------------------------

write(mpl%unit,'(a,i2,a,i2,a)') '--- Parallelization with ',mpl%nproc,' MPI tasks and ',mpl%nthread,' OpenMP threads'

!----------------------------------------------------------------------
! Initialize random number generator
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize random number generator'

call create_randgen(nam)

!----------------------------------------------------------------------
! Initialize geometry
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Initialize geometry'

call model_coord(nam,geom)

!----------------------------------------------------------------------
! Initialize block parameters
!----------------------------------------------------------------------

call bpar_alloc(nam,geom,bpar)

!----------------------------------------------------------------------
! Compute grid mesh
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Compute grid mesh'

! Compute grid mesh
call compute_grid_mesh(nam,geom)

!----------------------------------------------------------------------
! Load ensemble
!----------------------------------------------------------------------

if (nam%load_ensemble) then
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Load ensemble'

   call load_ensemble(nam,geom,ens1)
end if

!----------------------------------------------------------------------
! Call hybrid_diag driver
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Call hybrid_diag driver'

if (nam%load_ensemble) then
   call run_hdiag(nam,geom,bpar,bdata,ens1)
else
   call run_hdiag(nam,geom,bpar,bdata)
end if

!----------------------------------------------------------------------
! Call NICAS driver
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Call NICAS driver'

if (nam%load_ensemble) then
   call run_nicas(nam,geom,bpar,bdata,ndata,ens1)
else
   call run_nicas(nam,geom,bpar,bdata,ndata)
end if

!----------------------------------------------------------------------
! Call LCT driver
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Call LCT driver'

if (nam%load_ensemble) then
   call run_lct(nam,geom,bpar,ens1)
else
   call run_lct(nam,geom,bpar)
end if

!----------------------------------------------------------------------
! Call observation operator driver
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i5,a)') '--- Call observation operator driver'

call run_obsgen(nam,geom,odata)
call run_obsop(nam,geom,odata)

!----------------------------------------------------------------------
! Execution stats
!----------------------------------------------------------------------

if (mpl%main) then
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Execution stats'

   call timer_display(timer)

   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
else
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Done ----------------------------------------------------------'
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
end if

!----------------------------------------------------------------------
! Close listing files
!----------------------------------------------------------------------

if ((mpl%main.and..not.nam%colorlog).or..not.mpl%main) close(unit=mpl%unit)

!----------------------------------------------------------------------
! Finalize MPL
!----------------------------------------------------------------------

call mpl_end

end program main
