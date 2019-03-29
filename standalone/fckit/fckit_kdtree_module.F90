!----------------------------------------------------------------------
! Module: fckit_kdtree_module
! Purpose: fckit KDTree emulator for standalone execution
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
module fckit_kdtree_module

use fckit_geometry_module, only: sphere_lonlat2xyz
use tools_const, only: pi
use tools_kdtree2, only: kdtree2,kdtree2_result,kdtree2_create,kdtree2_destroy, &
& kdtree2_n_nearest,kdtree2_r_count
use tools_kinds, only: kind_real

implicit none

type kdtree
  type(kdtree2),pointer :: tp ! KDTree2 pointer
end type

private
public :: kdtree,kdtree_create,kdtree_destroy,kdtree_k_nearest_neighbors,kdtree_find_in_sphere

contains

!----------------------------------------------------------------------
! Subroutine: kdtree_create
! Purpose: create KDTree
!----------------------------------------------------------------------
function kdtree_create(n,lon,lat) result(kd)

implicit none

! Result
type(kdtree) :: kd                   ! KDTree

! Passed variables
integer,intent(in) :: n              ! Number of nodes
real(kind_real),intent(in) :: lon(n) ! Longitude (in degrees)
real(kind_real),intent(in) :: lat(n) ! Latitude (in degrees)

! Local variables
integer :: i
real(kind_real) :: input_data(3,n)

do i=1,n
   ! Transform to cartesian coordinates
   call sphere_lonlat2xyz(lon(i),lat(i),input_data(1,i),input_data(2,i),input_data(3,i))
end do

! Create KDTree
kd%tp => kdtree2_create(input_data,sort=.true.,rearrange=.true.)

end function kdtree_create

!----------------------------------------------------------------------
! Subroutine: kdtree_destroy
! Purpose: release memory of KDTree
!----------------------------------------------------------------------
subroutine kdtree_destroy(kd)

implicit none

! Passed variables
type(kdtree),intent(inout) :: kd ! KDTree

! Release memory
call kdtree2_destroy(kd%tp)

end subroutine kdtree_destroy

!----------------------------------------------------------------------
! Subroutine: kdtree_k_nearest_neighbors
! Purpose: find k nearest neighbors using a KDTree
!----------------------------------------------------------------------
subroutine kdtree_k_nearest_neighbors(kd,lon,lat,nn,nn_index)

implicit none

! Passed variables
class(kdtree),intent(in) :: kd      ! KDTree
real(kind_real),intent(in) :: lon   ! Point longitude (in degrees)
real(kind_real),intent(in) :: lat   ! Point latitude (in degrees)
integer,intent(in) :: nn            ! Number of nearest neighbors to find
integer,intent(out) :: nn_index(nn) ! Neareast neighbors index

! Local variables
integer :: i
real(kind_real) :: qv(3)
type(kdtree2_result) :: results(nn)

! Transform to cartesian coordinates
call sphere_lonlat2xyz(lon,lat,qv(1),qv(2),qv(3))

! Find nearest neighbors
call kdtree2_n_nearest(kd%tp,qv,nn,results)
do i=1,nn
   nn_index(i) = results(i)%idx
end do

end subroutine kdtree_k_nearest_neighbors

!----------------------------------------------------------------------
! Subroutine: kdtree_find_in_sphere
! Purpose: count nearest neighbors using a KDTree
!----------------------------------------------------------------------
subroutine kdtree_find_in_sphere(kd,lon,lat,sr,nn)

implicit none

! Passed variables
class(kdtree),intent(in) :: kd    ! KDTree
real(kind_real),intent(in) :: lon ! Point longitude (in degrees)
real(kind_real),intent(in) :: lat ! Point latitude (in degrees)
real(kind_real),intent(in) :: sr  ! Spherical radius (in radians)
integer,intent(out) :: nn         ! Number of nearest neighbors found

! Local variables
real(kind_real) :: qv(3),chordsq

! Transform to cartesian coordinates
call sphere_lonlat2xyz(lon,lat,qv(1),qv(2),qv(3))

! Convert radius on sphere to chord squared
chordsq = 4.0*sin(0.5*min(sr,pi))**2

! Count nearest neighbors
nn = kdtree2_r_count(kd%tp,qv,chordsq)

end subroutine kdtree_find_in_sphere

end module fckit_kdtree_module
