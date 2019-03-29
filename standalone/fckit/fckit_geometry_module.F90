!----------------------------------------------------------------------
! Module: fckit_geometry_module
! Purpose: fckit geometry emulator for standalone execution
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
module fckit_geometry_module

use tools_const, only: deg2rad,rad2deg
use tools_kinds, only: kind_real

implicit none

private
public :: sphere_distance,sphere_lonlat2xyz,sphere_xyz2lonlat

contains

!----------------------------------------------------------------------
! Function: sphere_distance
! Purpose: unit sphere distance
!----------------------------------------------------------------------
function sphere_distance(lon_i,lat_i,lon_f,lat_f) result(dist)

implicit none

! Result
real(kind_real) :: dist

! Passed variables
real(kind_real),intent(in) :: lon_i ! Initial point longitude (degrees)
real(kind_real),intent(in) :: lat_i ! Initial point latitude (degrees)
real(kind_real),intent(in) :: lon_f ! Final point longitude (degrees)
real(kind_real),intent(in) :: lat_f ! Final point longilatitudetude (degrees)

! Great-circle distance using Vincenty formula on the unit sphere
dist = atan2(sqrt((cos(lat_f*deg2rad)*sin(lon_f*deg2rad-lon_i*deg2rad))**2 &
     & +(cos(lat_i*deg2rad)*sin(lat_f*deg2rad)-sin(lat_i*deg2rad)*cos(lat_f*deg2rad)*cos(lon_f*deg2rad-lon_i*deg2rad))**2), &
     & sin(lat_i*deg2rad)*sin(lat_f*deg2rad)+cos(lat_i*deg2rad)*cos(lat_f*deg2rad)*cos(lon_f*deg2rad-lon_i*deg2rad))

end function sphere_distance

!----------------------------------------------------------------------
! Subroutine: sphere_lonlat2xyz
! Purpose: convert longitude/latitude to cartesian coordinates
!----------------------------------------------------------------------
subroutine sphere_lonlat2xyz(lon,lat,x,y,z)

implicit none

! Passed variables
real(kind_real),intent(in) :: lon ! Longitude (degrees)
real(kind_real),intent(in) :: lat ! Latitude (degrees)
real(kind_real),intent(out) :: x  ! X coordinate
real(kind_real),intent(out) :: y  ! Y coordinate
real(kind_real),intent(out) :: z  ! Z coordinate

! Local variables
real(kind_real) :: coslat

! Latitude cosine
coslat = cos(lat*deg2rad)

! X coordinate
x = cos(lat*deg2rad)*cos(lon*deg2rad)

! Y coordinate
y = cos(lat*deg2rad)*sin(lon*deg2rad)

! Z coordinate
z = sin(lat*deg2rad)

end subroutine sphere_lonlat2xyz

!----------------------------------------------------------------------
! Subroutine: sphere_xyz2lonlat
! Purpose: convert cartesian coordinates to longitude/latitude
!----------------------------------------------------------------------
subroutine sphere_xyz2lonlat(x,y,z,lon,lat)

implicit none

! Passed variables
real(kind_real),intent(in) :: x    ! X coordinate
real(kind_real),intent(in) :: y    ! Y coordinate
real(kind_real),intent(in) :: z    ! Z coordinate
real(kind_real),intent(out) :: lon ! Longitude (degrees)
real(kind_real),intent(out) :: lat ! Latitude (degrees)

! Local variables
real(kind_real) :: r

! Radius
r = sqrt(x**2+y**2+z**2)

! Longitude
if ((abs(x)>0.0).or.(abs(y)>0.0)) then
   lon = atan2(y,x)*rad2deg
else
   lon = 0.0
end if

! Latitude
if (r>0.0) then
   lat = asin(z/r)*rad2deg
else
   lat = 0.0
end if

end subroutine sphere_xyz2lonlat

end module fckit_geometry_module
