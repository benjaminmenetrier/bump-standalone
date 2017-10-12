!----------------------------------------------------------------------
! Module: module_apply_bens.f90
!> Purpose: apply Bens matrix
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module module_apply_bens

use model_interface, only: model_read
use module_apply_nicas, only: apply_nicas
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msr
use type_ens, only: enstype
use type_mpl, only: mpl
use type_ndata, only: ndataloctype

implicit none

private
public :: apply_bens

contains

!----------------------------------------------------------------------
! Subroutine: apply_bens
!> Purpose: apply 4D matrix
!----------------------------------------------------------------------
subroutine apply_bens(ndataloc,ens,fld)

implicit none

! Passed variables
type(ndataloctype),intent(in) :: ndataloc(:) !< Sampling data
type(enstype),intent(in) :: ens
real(kind_real),intent(inout) :: fld(ndataloc(1)%geom%nc0a,ndataloc(1)%geom%nl0,ndataloc(1)%nam%nv,ndataloc(1)%nam%nts)  !< Field

! Local variable
integer :: isub,ie,its,iv
real(kind_real) :: fld_out(ndataloc(1)%geom%nc0a,ndataloc(1)%geom%nl0,ndataloc(1)%nam%nv,ndataloc(1)%nam%nts)
real(kind_real),allocatable :: fld_uni(:,:)

! Associate
associate(nam=>ndataloc(1)%nam,geom=>ndataloc(1)%geom)

select case (nam%strategy)
case ('common')
   ! Allocation
   allocate(fld_uni(geom%nc0a,geom%nl0))
  
   ! Initialization
   fld_out = 0.0

   do isub=1,ens%nsub
      do ie=1,ens%ne/ens%nsub
         ! Sum product over variables and timeslots
         fld_uni = 0.0
         do its=1,nam%nts
            do iv=1,nam%nv
               fld_uni = fld_uni+fld(:,:,iv,its)*ens%pert(:,:,iv,its,ie,isub)
            end do
         end do

         ! Apply common localization
         call apply_nicas(ndataloc(nam%nb+1),fld_uni)

         ! Add contribution to final vector
         do its=1,nam%nts
            do iv=1,nam%nv
               fld_out(:,:,iv,its) = fld_out(:,:,iv,its)+fld_uni*ens%pert(:,:,iv,its,ie,isub)
            end do
         end do
      end do
   end do

   ! Normalize
   fld = fld_out/float(ens%ne-1)
case ('specific_univariate')
   call msgerror('not implemented yet in apply_bens')
case ('specific_multivariate')
   call msgerror('not implemented yet in apply_bens')
case ('common_weighted')
   call msgerror('not implemented yet in apply_bens')
end select

! End associate
end associate

end subroutine apply_bens

end module module_apply_bens
