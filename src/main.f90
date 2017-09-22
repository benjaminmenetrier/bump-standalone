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

use driver_hdiag, only: hdiag
use driver_nicas, only: nicas
use driver_obsop, only: obsop
use model_interface, only: model_coord
use module_namelist, only: namtype,namread,namcheck
use tools_display, only: listing_setup,msgerror
use type_bdata, only: bdatatype,bdata_alloc,bdata_read,bdata_write
use type_geom, only: geomtype,compute_grid_mesh
use type_mpl, only: mpl,mpl_start,mpl_end
use type_ndata, only: ndataloctype
use type_odata, only: odataloctype
use type_randgen, only: rng,create_randgen
use type_timer, only: timertype,timer_start,timer_display

implicit none

! Local variables
integer :: iv
character(len=6) :: ivchar
type(geomtype),target :: geom
type(namtype),target :: nam
type(bdatatype),allocatable :: bdata(:)
type(ndataloctype),allocatable :: ndataloc(:)
type(odataloctype) :: odataloc
type(timertype) :: timer

logical :: univariate=.true.

!----------------------------------------------------------------------
! Initialize MPL
!----------------------------------------------------------------------

call mpl_start

!----------------------------------------------------------------------
! Initialize timer
!----------------------------------------------------------------------

call timer_start(timer)

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
write(mpl%unit,'(a)') '--- You are running nicas -----------------------------------------'
write(mpl%unit,'(a)') '--- Author: Benjamin Menetrier ------------------------------------'
write(mpl%unit,'(a)') '--- Copyright © 2017 METEO-FRANCE------------------ ---------------'
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
write(mpl%unit,'(a,i5,a)') '--- Initialize random number generator'
   
rng = create_randgen(nam)

!----------------------------------------------------------------------
! Initialize coordinates
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i5,a)') '--- Initialize coordinates'

call model_coord(nam,geom)

!----------------------------------------------------------------------
! Compute grid mesh
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i5,a)') '--- Compute grid mesh'

! Compute grid mesh
call compute_grid_mesh(nam,geom)

! Allocate B data
allocate(bdata(nam%nvp))
do iv=1,nam%nvp
   bdata(iv)%nam => nam
   bdata(iv)%geom => geom
   if (iv<=nam%nv) then
      write(ivchar,'(i2.2)') iv
   else
      ivchar = 'common'
   end if
   bdata(iv)%cname = 'bdata_'//trim(ivchar)
   call bdata_alloc(bdata(iv))
end do

if (nam%new_hdiag) then
   !----------------------------------------------------------------------
   ! Call hybrid_diag driver
   !----------------------------------------------------------------------

   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a,i5,a)') '--- Call hybrid_diag driver'

   call hdiag(nam,geom,bdata)

   !----------------------------------------------------------------------
   ! Write B data
   !----------------------------------------------------------------------

   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a,i5,a)') '--- Write B data'

   do iv=1,nam%nvp
      call bdata_write(bdata(iv))
   end do
else
   !----------------------------------------------------------------------
   ! Call hybrid_diag driver
   !----------------------------------------------------------------------

   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a,i5,a)') '--- Read B data'

   do iv=1,nam%nvp
      call bdata_read(bdata(iv))
   end do
end if

!----------------------------------------------------------------------
! Call NICAS driver
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i5,a)',advance='no') '--- Call NICAS driver '

if (univariate) then ! TODO: nam%univariate
   allocate(ndataloc(1))
   write(mpl%unit,'(a)') 'for common diagnostic'
   call nicas(nam,geom,bdata(nam%nvp),ndataloc(1))
else
   allocate(ndataloc(nam%nv))
   write(mpl%unit,'(a)') 'for all variables'
   do iv=1,nam%nv
      call nicas(nam,geom,bdata(iv),ndataloc(iv))
   end do
end if

if (.false.) then
   !----------------------------------------------------------------------
   ! Call observation operator driver
   !----------------------------------------------------------------------

   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a,i5,a)') '--- Call observation operator driver'

   call obsop(nam,geom,odataloc)   
end if

!----------------------------------------------------------------------
! Execution stats
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Execution stats'

call timer_display(timer)

write(mpl%unit,'(a)') '-------------------------------------------------------------------'

!----------------------------------------------------------------------
! Close listing files
!----------------------------------------------------------------------

if ((mpl%main.and..not.nam%colorlog).or..not.mpl%main) close(unit=mpl%unit)

!----------------------------------------------------------------------
! Finalize MPL
!----------------------------------------------------------------------

call mpl_end

end program main
