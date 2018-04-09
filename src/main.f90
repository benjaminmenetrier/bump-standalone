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

use type_hnb, only: hnb_type
use type_mpl, only: mpl,mpl_start,mpl_end
use type_timer, only: timer_type

implicit none

! Local variables
type(hnb_type) :: hnb
type(timer_type) :: timer

! Initialize MPL
call mpl_start()

! Initialize timer
if (mpl%main) call timer%start

! Read namelist
call hnb%nam%read

! Offline setup
call hnb%setup_offline

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

! Delete HDIAG NICAS bundle
call hnb%delete

! Finalize MPL
call mpl_end()

end program main
