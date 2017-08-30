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
use module_namelist, only: nam,namread,namcheck
use module_driver, only: nicas_driver
use tools_display, only: listing_setup
use type_mpl, only: mpl,mpl_start,mpl_end
use type_ndata, only: ndatatype,ndataloctype
use type_timer, only: timertype,timer_start,timer_display

implicit none

! Local variables
type(ndatatype) :: ndata
type(ndataloctype) :: ndataloc
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

call namread

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

call namcheck

!----------------------------------------------------------------------
! Parallel setup
!----------------------------------------------------------------------

write(mpl%unit,'(a,i2,a,i2,a)') '--- Parallelization with ',mpl%nproc,' MPI tasks and ',mpl%nthread,' OpenMP threads'

!----------------------------------------------------------------------
! Initialize coordinates
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i5,a)') '--- Initialize coordinates'

! Get coordinates
call model_coord(ndata)

!----------------------------------------------------------------------
! Call NICAS driver
!----------------------------------------------------------------------

write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i5,a)') '--- Call NICAS driver'

call nicas_driver(ndata,ndataloc)

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
