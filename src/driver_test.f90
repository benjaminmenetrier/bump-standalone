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
use module_test, only: test_dirac,test_dirac_localization,test_perf
use type_geom, only: geomtype
use type_mpl, only: mpl
use type_ndata, only: ndataloctype

implicit none

private
public :: run_test

contains

!----------------------------------------------------------------------
! Subroutine: run_test
!> Purpose: test NICAS method
!----------------------------------------------------------------------
subroutine run_test(nam,geom,ndataloc)

implicit none

! Passed variables
type(namtype),target,intent(in) :: nam !< Namelist variables
type(geomtype),target,intent(in) :: geom    !< Sampling data
type(ndataloctype),intent(inout) :: ndataloc(:) !< Sampling data,local

! Local variables
integer :: ib

! Set namelist and geometry
do ib=1,nam%nb+1
   ndataloc(ib)%nam => nam
   ndataloc(ib)%geom => geom
end do

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
   write(mpl%unit,'(a)') '--- Apply localization to diracs'
   call test_dirac_localization(ndataloc)
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

end subroutine run_test

end module driver_test
