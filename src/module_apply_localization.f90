!----------------------------------------------------------------------
! Module: module_apply_localization.f90
!> Purpose: apply 4D localization
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module module_apply_localization

use module_apply_nicas, only: apply_nicas
use module_namelist, only: namtype
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msr
use type_geom, only: geomtype
use type_mpl, only: mpl
use type_ndata, only: ndataloctype

implicit none

private
public :: apply_localization

contains

!----------------------------------------------------------------------
! Subroutine: apply_localization
!> Purpose: apply 4D localization
!----------------------------------------------------------------------
subroutine apply_localization(nam,geom,ndataloc,fld)

implicit none

! Passed variables
type(namtype),target,intent(in) :: nam !< Namelist variables
type(geomtype),target,intent(in) :: geom    !< Sampling data
type(ndataloctype),intent(inout) :: ndataloc(nam%nb+1) !< Sampling
real(kind_real),intent(inout) :: fld(geom%nc0a,geom%nl0,nam%nv,nam%nts)  !< Field

! Local variable
integer :: ib,its,iv
real(kind_real),allocatable :: fld_uni(:,:)

! Set namelist and geometry
do ib=1,nam%nb+1
   ndataloc(ib)%nam => nam
   ndataloc(ib)%geom => geom
end do

select case (nam%strategy)
case ('common')
   ! Allocation
   allocate(fld_uni(geom%nc0a,geom%nl0))

   ! Sum product over variables and timeslots
   fld_uni = 0.0
   do its=1,nam%nts
      do iv=1,nam%nv
         fld_uni = fld_uni+fld(:,:,iv,its)
      end do
   end do

   ! Apply common localization
   call apply_nicas(ndataloc(nam%nb+1),fld_uni)

   ! Add contribution to final vector
   do its=1,nam%nts
      do iv=1,nam%nv
         fld(:,:,iv,its) = fld_uni
      end do
   end do
case ('specific_univariate')
   call msgerror('not implemented yet in apply_localization')
case ('specific_multivariate')
   call msgerror('not implemented yet in apply_localization')
case ('common_weighted')
   call msgerror('not implemented yet in apply_localization')
end select

end subroutine apply_localization

end module module_apply_localization
