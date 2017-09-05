!----------------------------------------------------------------------
! Program: nicas
!> Purpose: compute NICAS correlation model parameters
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
program nicas

use model_interface, only: model_coord
use module_namelist, only: namtype,namread,namcheck
use module_driver, only: nicas_driver,obsop_driver
use tools_display, only: listing_setup
use type_geom, only: geomtype
use type_mpl, only: mpl,mpl_start,mpl_end
use type_ndata, only: ndataloctype
use type_odata, only: odataloctype
use type_randgen, only: rng,create_randgen
use type_timer, only: timertype,timer_start,timer_display

implicit none

! Local variables
type(geomtype),target :: geom
type(namtype) :: nam
type(ndataloctype) :: ndataloc
type(odataloctype) :: odataloc
type(timertype) :: timer

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

call listing_setup(nam%colorlog)

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

if (.true.) then
   !----------------------------------------------------------------------
   ! Call NICAS driver
   !----------------------------------------------------------------------

   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a,i5,a)') '--- Call NICAS driver'

   call nicas_driver(nam,geom,ndataloc)
else
   !----------------------------------------------------------------------
   ! Call observation operator driver
   !----------------------------------------------------------------------

   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a,i5,a)') '--- Call observation operator driver'

   call obsop_driver(nam,geom,odataloc)   
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

end program nicas
