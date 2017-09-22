!----------------------------------------------------------------------
! Module: type_displ
!> Purpose: displacement data derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module type_displ

use netcdf
use tools_const, only: rad2deg
use tools_kinds, only: kind_real
use tools_missing, only: msi,msr
use tools_nc, only: ncfloat,ncerr
use type_hdata, only: hdatatype
implicit none

! Displacement data derived type
type displtype
   real(kind_real),allocatable :: lon(:,:)           !< Mesh longitude
   real(kind_real),allocatable :: lat(:,:)           !< Mesh latitude
   real(kind_real),allocatable :: dlon_raw(:,:,:)    !< Longitude displacement, raw
   real(kind_real),allocatable :: dlat_raw(:,:,:)    !< Latitude displacement, raw
   real(kind_real),allocatable :: dist_raw(:,:,:)    !< Displacement distance, raw
   real(kind_real),allocatable :: valid_raw(:,:,:)   !< Displacement validity, raw
   integer :: niter                                  !< Number of stored iterations
   real(kind_real),allocatable :: dlon_flt(:,:,:,:)  !< Longitude displacement, filtered
   real(kind_real),allocatable :: dlat_flt(:,:,:,:)  !< Latitude displacement, filtered
   real(kind_real),allocatable :: dist_flt(:,:,:,:)  !< Displacement distance, filtered
   real(kind_real),allocatable :: valid_flt(:,:,:,:) !< Displacement validity, filtered
   real(kind_real),allocatable :: rhflt(:,:,:)        !< Displacement filtering support radius
end type displtype

private
public :: displtype
public :: displ_alloc,displ_dealloc

contains

!----------------------------------------------------------------------
! Subroutine: displ_alloc
!> Purpose: displacement data allocation
!----------------------------------------------------------------------
subroutine displ_alloc(hdata,displ)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
type(displtype),intent(inout) :: displ !< Displacement data

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Number of stored iterations
if (nam%displ_explicit) then
   displ%niter = max(nam%displ_niter,1)
else
   displ%niter = 1
end if

! Allocation
allocate(displ%lon(nam%nc1,geom%nl0))
allocate(displ%lat(nam%nc1,geom%nl0))
allocate(displ%dlon_raw(nam%nc1,geom%nl0,nam%nvp))
allocate(displ%dlat_raw(nam%nc1,geom%nl0,nam%nvp))
allocate(displ%dist_raw(nam%nc1,geom%nl0,nam%nvp))
allocate(displ%valid_raw(nam%nc1,geom%nl0,nam%nvp))
allocate(displ%dlon_flt(nam%nc1,displ%niter,geom%nl0,nam%nvp))
allocate(displ%dlat_flt(nam%nc1,displ%niter,geom%nl0,nam%nvp))
allocate(displ%dist_flt(nam%nc1,displ%niter,geom%nl0,nam%nvp))
allocate(displ%valid_flt(nam%nc1,displ%niter,geom%nl0,nam%nvp))
allocate(displ%rhflt(displ%niter,geom%nl0,nam%nvp))

! Initialization
call msr(displ%lon)
call msr(displ%lat)
call msr(displ%dlon_raw)
call msr(displ%dlat_raw)
call msr(displ%dist_raw)
call msr(displ%valid_raw)
call msr(displ%dlon_flt)
call msr(displ%dlat_flt)
call msr(displ%dist_flt)
call msr(displ%valid_flt)
call msr(displ%rhflt)

! End associate
end associate

end subroutine displ_alloc

!----------------------------------------------------------------------
! Subroutine: displ_dealloc
!> Purpose: displacement data deallocation
!----------------------------------------------------------------------
subroutine displ_dealloc(displ)

implicit none

! Passed variables
type(displtype),intent(inout) :: displ !< Displacement data

! Deallocation
deallocate(displ%lon)
deallocate(displ%lat)
deallocate(displ%dlon_raw)
deallocate(displ%dlat_raw)
deallocate(displ%dist_raw)
deallocate(displ%valid_raw)
deallocate(displ%dlon_flt)
deallocate(displ%dlat_flt)
deallocate(displ%dist_flt)
deallocate(displ%valid_flt)
deallocate(displ%rhflt)

end subroutine displ_dealloc

end module type_displ
