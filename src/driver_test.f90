!----------------------------------------------------------------------
! Module: driver_test
!> Purpose: test driver
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module driver_test

use module_namelist, only: namtype
use module_test, only: test_dirac,test_dirac_bens,test_perf
use type_ens, only: enstype,ens_read
use type_geom, only: geomtype
use type_mpl, only: mpl
use type_ndata, only: ndataloctype

implicit none

private
public :: test

contains

!----------------------------------------------------------------------
! Subroutine: test
!> Purpose: test NICAS method
!----------------------------------------------------------------------
subroutine test(ndataloc)

implicit none

! Passed variables
type(ndataloctype),intent(in) :: ndataloc(:) !< Sampling data,local

! Local variables
integer :: ib
type(enstype) :: ens

! Associate
associate(nam=>ndataloc(1)%nam,geom=>ndataloc(1)%geom)

! Read ensemble
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Read ensemble'
call ens_read(nam,geom,'ens1',ens)

if (nam%check_dirac) then
   ! Apply NICAS to diracs
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Apply NICAS to diracs'
   do ib=1,nam%nb+1
      if (nam%nicas_block(ib)) call test_dirac(nam%blockname(ib),ndataloc(ib))
   end do
   call flush(mpl%unit)

   ! Apply NICAS to diracs
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Apply Bens to diracs'
   call test_dirac_bens(ndataloc,ens)
   call flush(mpl%unit)
end if

if (nam%check_perf) then
   ! Test NICAS performance
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Test NICAS performance'
   do ib=1,nam%nb+1
      if (nam%nicas_block(ib)) call test_perf(nam%blockname(ib),ndataloc(ib))
   end do
   call flush(mpl%unit)
end if

! End associate
end associate

end subroutine test

end module driver_test
