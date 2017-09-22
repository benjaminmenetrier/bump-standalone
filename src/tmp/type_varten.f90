!----------------------------------------------------------------------
! Module: type_varten
!> Purpose: variance and tensor data derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module type_varten

use tools_kinds, only: kind_real
use tools_missing, only: msi,msr
use type_hdata, only: hdatatype
implicit none

! Variance and tensor data derived type
type vartentype
   real(kind_real),allocatable :: varasysq(:,:)       !< Squared asymptotic variance average
   real(kind_real),allocatable :: var_raw(:,:,:)      !< Variance, raw
   real(kind_real),allocatable :: var_flt(:,:,:)      !< Variance, filtered
   integer,allocatable :: nn_ic0(:,:,:)               !< Nearest neighbors to compute gradient
   real(kind_real),allocatable :: grad_dlon(:,:,:)    !< Gradient computation matrix for longitude
   real(kind_real),allocatable :: grad_dlat(:,:,:)    !< Gradient computation matrix for latitude
   real(kind_real),allocatable :: Hlon_raw(:,:,:)     !< Tensor longitude component, raw
   real(kind_real),allocatable :: Hlat_raw(:,:,:)     !< Tensor latitude component, raw
   real(kind_real),allocatable :: Hlonlat_raw(:,:,:)  !< Tensor cross component, raw
   real(kind_real),allocatable :: Lb_raw(:,:,:)       !< Tensor length-scale, raw
   real(kind_real),allocatable :: Hlon_flt(:,:,:)     !< Tensor longitude component, filtered
   real(kind_real),allocatable :: Hlat_flt(:,:,:)     !< Tensor latitude component, filtered
   real(kind_real),allocatable :: Hlonlat_flt(:,:,:)  !< Tensor cross component, filtered
   real(kind_real),allocatable :: Lb_flt(:,:,:)       !< Tensor length-scale, filtered
end type vartentype

private
public :: vartentype,varten_alloc,varten_dealloc

contains

!----------------------------------------------------------------------
! Subroutine: varten_alloc
!> Purpose: variance and tensor object allocation
!----------------------------------------------------------------------
subroutine varten_alloc(hdata,varten)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata      !< Sampling data
type(vartentype),intent(inout) :: varten !< Variance and tensor data

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Allocation
allocate(varten%varasysq(geom%nl0,nam%nv))
allocate(varten%var_raw(nam%nc1,geom%nl0,nam%nv))
allocate(varten%var_flt(nam%nc1,geom%nl0,nam%nv))
allocate(varten%nn_ic0(nam%varten_ngrad+1,nam%nc1,geom%nl0i))
allocate(varten%grad_dlon(nam%varten_ngrad,nam%nc1,geom%nl0i))
allocate(varten%grad_dlat(nam%varten_ngrad,nam%nc1,geom%nl0i))
allocate(varten%Hlon_raw(nam%nc1,geom%nl0,nam%nv))
allocate(varten%Hlat_raw(nam%nc1,geom%nl0,nam%nv))
allocate(varten%Hlonlat_raw(nam%nc1,geom%nl0,nam%nv))
allocate(varten%Lb_raw(nam%nc1,geom%nl0,nam%nv))
allocate(varten%Hlon_flt(nam%nc1,geom%nl0,nam%nv))
allocate(varten%Hlat_flt(nam%nc1,geom%nl0,nam%nv))
allocate(varten%Hlonlat_flt(nam%nc1,geom%nl0,nam%nv))
allocate(varten%Lb_flt(nam%nc1,geom%nl0,nam%nv))

! Initialization
call msr(varten%varasysq)
call msr(varten%var_raw)
call msr(varten%var_flt)
call msi(varten%nn_ic0)
call msr(varten%grad_dlon)
call msr(varten%grad_dlat)
call msr(varten%Hlon_raw)
call msr(varten%Hlat_raw)
call msr(varten%Hlonlat_raw)
call msr(varten%Lb_raw)
call msr(varten%Hlon_flt)
call msr(varten%Hlat_flt)
call msr(varten%Hlonlat_flt)
call msr(varten%Lb_flt)

! End associate
end associate

end subroutine varten_alloc

!----------------------------------------------------------------------
! Subroutine: varten_dealloc
!> Purpose: variance and tensor object deallocation
!----------------------------------------------------------------------
subroutine varten_dealloc(varten)

implicit none

! Passed variables
type(vartentype),intent(inout) :: varten !< Variance and tensor data

! Release memory
deallocate(varten%varasysq)
deallocate(varten%var_raw)
deallocate(varten%var_flt)
deallocate(varten%Hlon_raw)
deallocate(varten%Hlat_raw)
deallocate(varten%Hlonlat_raw)
deallocate(varten%Lb_raw)
deallocate(varten%Hlon_flt)
deallocate(varten%Hlat_flt)
deallocate(varten%Hlonlat_flt)
deallocate(varten%Lb_flt)

end subroutine varten_dealloc

end module type_varten
