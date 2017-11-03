!----------------------------------------------------------------------
! Module: type_min
!> Purpose: minimization data derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module type_min

use tools_kinds, only: kind_real
use type_geom, only: geomtype
use type_nam, only: namtype

implicit none

! Minimization data derived type
type mintype
   ! Namelist
   type(namtype),pointer :: nam                    !< Namelist

   ! Geometry
   type(geomtype),pointer :: geom                  !< Geometry

   ! Generic data
   integer :: nx
   integer :: ny
   real(kind_real),allocatable :: x(:)           !< Control vector
   real(kind_real),allocatable :: guess(:)           !< Control vector
   real(kind_real),allocatable :: binf(:)        !< Control vector lower bound
   real(kind_real),allocatable :: bsup(:)        !< Control vector lower bound
   real(kind_real),allocatable :: obs(:)           !< Control vector
   real(kind_real),allocatable :: wgt(:)         !< Weight

   ! Specific data
   logical :: lnorm
end type mintype

private
public :: mintype

end module type_min
