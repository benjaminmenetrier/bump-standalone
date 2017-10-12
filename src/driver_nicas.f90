!----------------------------------------------------------------------
! Module: driver_nicas
!> Purpose: nicas driver
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module driver_nicas

use module_mpi, only: compute_mpi
use module_namelist, only: namtype
use module_normalization, only: compute_normalization
use module_parameters, only: compute_parameters
use module_test, only: test_adjoints,test_pos_def,test_mpi
use tools_const, only: eigen_init,pi
use tools_display, only: msgerror
use type_bdata, only: bdatatype
use type_ctree, only: ctreetype,create_ctree,find_nearest_neighbors,delete_ctree
use type_geom, only: geomtype
use type_mpl, only: mpl
use type_ndata, only: ndatatype,ndataloctype,ndata_read_param,ndata_read_mpi, &
  & ndata_write_param,ndata_write_mpi,ndata_write_mpi_summary

implicit none

private
public :: nicas

contains

!----------------------------------------------------------------------
! Subroutine: nicas
!> Purpose: NICAS
!----------------------------------------------------------------------
subroutine nicas(nam,geom,bdata,ndataloc)

implicit none

! Passed variables
type(namtype),target,intent(in) :: nam !< Namelist variables
type(geomtype),target,intent(inout) :: geom    !< Sampling data
type(bdatatype),intent(in) :: bdata !< B data
type(ndataloctype),intent(inout) :: ndataloc !< Sampling data,local

! Local variables
type(ndatatype) :: ndata

! Set namelist and geometry
ndata%nam => nam
ndata%geom => geom

if (nam%new_param) then
   ! Compute NICAS parameters
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute NICAS parameters'
   call compute_parameters(bdata,ndata)

   ! Compute NICAS normalization
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute NICAS normalization'
   call compute_normalization(ndata)

   if (mpl%main) then
      ! Write NICAS parameters
      write(mpl%unit,'(a)') '-------------------------------------------------------------------'
      write(mpl%unit,'(a)') '--- Write NICAS parameters'
      call ndata_write_param(ndata)
   end if
else
   ! Read NICAS parameters
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Read NICAS parameters'
   call ndata_read_param(ndata)
end if
call flush(mpl%unit)

if (nam%new_mpi) then
   ! Compute NICAS MPI distribution
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute NICAS MPI distribution'
   call compute_mpi(ndata,ndataloc)

   ! Write NICAS MPI distribution
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Write NICAS MPI distribution'
   call ndata_write_mpi(ndataloc)

   if (mpl%main.and.(nam%nproc>1)) then
      ! Write NICAS MPI summary
      write(mpl%unit,'(a)') '-------------------------------------------------------------------'
      write(mpl%unit,'(a)') '--- Write NICAS MPI summary'
      call ndata_write_mpi_summary(ndata)
   end if
else
   ! Read NICAS MPI distribution
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Read NICAS MPI distribution'
   call ndata_read_mpi(ndataloc)
end if
call flush(mpl%unit)

if (nam%check_adjoints) then
   ! Test adjoints
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Test NICAS adjoints'
   if (mpl%main) call test_adjoints(ndata)
   call flush(mpl%unit)
end if

if (nam%check_pos_def) then
   ! Test NICAS positive definiteness
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Test NICAS positive definiteness'
   if (mpl%main) call test_pos_def(ndata)
   call flush(mpl%unit)
end if

if (nam%check_mpi.and.(nam%nproc>0)) then
   ! Test single/multi-procs equivalence
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Test NICAS single/multi-procs equivalence'
   call test_mpi(ndata,ndataloc)
   call flush(mpl%unit)
end if

end subroutine nicas

end module driver_nicas
