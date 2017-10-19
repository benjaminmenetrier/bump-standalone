!----------------------------------------------------------------------
! Module: driver_obsop
!> Purpose: observation operator driver
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module driver_obsop

use module_mpi_obsop, only: compute_mpi_obsop
use module_namelist, only: namtype
use module_parameters_obsop, only: compute_parameters_obsop
use module_test_obsop, only: test_adjoint_obsop,test_mpi_obsop,test_mpi_obsop_ad
use tools_const, only: eigen_init,pi
use tools_display, only: msgerror
use type_ctree, only: ctreetype,create_ctree,find_nearest_neighbors,delete_ctree
use type_geom, only: geomtype
use type_mpl, only: mpl
use type_odata, only: odatatype,odataloctype

implicit none

private
public :: run_obsop

contains

!----------------------------------------------------------------------
! Subroutine: run_obsop
!> Purpose: observation operator
!----------------------------------------------------------------------
subroutine run_obsop(nam,geom,odataloc)

implicit none

! Passed variables
type(namtype),target,intent(in) :: nam !< Namelist variables
type(geomtype),target,intent(inout) :: geom    !< Sampling data
type(odataloctype),intent(inout) :: odataloc !< Sampling data

! Local variables
type(odatatype) :: odata

! Set namelist
odata%nam => nam
odataloc%nam => nam

! Set geometry
odata%geom => geom
odataloc%geom => geom

!if (nam%new_param) then
   ! Compute observation operator parameters
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute observation operator parameters'
   call compute_parameters_obsop(odata)

!   if (mpl%main) then
!      ! Write observation operator parameters
!      write(mpl%unit,'(a)') '-------------------------------------------------------------------'
!      write(mpl%unit,'(a)') '--- Write observation operator parameters'
!      call odata_write_param(odata)
!   end if
!else
!   ! Read observation operator parameters
!   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
!   write(mpl%unit,'(a)') '--- Read observation operator parameters'
!   call odata_read_param(odata)
!end if
call flush(mpl%unit)

!if (nam%new_mpi) then
   ! Compute observation operator MPI distribution
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute observation operator MPI distribution'
   call compute_mpi_obsop(odata,odataloc)

!   if (mpl%main) then
!      ! Write observation operator MPI distribution
!      write(mpl%unit,'(a)') '-------------------------------------------------------------------'
!      write(mpl%unit,'(a)') '--- Write observation operator MPI distribution'
!      call odata_write_mpi(odataloc_arr)
!   end if
!else
!   ! Read observation operator MPI distribution
!   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
!   write(mpl%unit,'(a)') '--- Read observation operator MPI distribution'
!   call odata_read_mpi(odataloc)
!end if
call flush(mpl%unit)

if (nam%check_adjoints) then
   ! Test adjoints
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Test observation operator adjoint'
   call test_adjoint_obsop(odata)
   call flush(mpl%unit)
end if

if (nam%check_mpi.and.(mpl%nproc>0)) then
   ! Test single/multi-procs equivalence
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Test observation operator single/multi-procs equivalence'
   call test_mpi_obsop(odata,odataloc)
   call test_mpi_obsop_ad(odata,odataloc)
   call flush(mpl%unit)
end if

end subroutine run_obsop

end module driver_obsop
