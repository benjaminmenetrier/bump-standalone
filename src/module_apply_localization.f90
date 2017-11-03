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
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msr
use type_bpar, only: bpartype
use type_geom, only: geomtype
use type_mpl, only: mpl
use type_nam, only: namtype
use type_ndata, only: ndataloctype

implicit none

private
public :: apply_localization

contains

!----------------------------------------------------------------------
! Subroutine: apply_localization
!> Purpose: apply 4D localization
!----------------------------------------------------------------------
subroutine apply_localization(nam,geom,bpar,ndataloc,fld)

implicit none

! Passed variables
type(namtype),target,intent(in) :: nam !< Namelist variables
type(geomtype),target,intent(in) :: geom    !< Sampling data
type(bpartype),target,intent(in) :: bpar    !< Sampling data
type(ndataloctype),intent(in) :: ndataloc(bpar%nb+1) !< Sampling
real(kind_real),intent(inout) :: fld(geom%nc0a,geom%nl0,nam%nv,nam%nts)  !< Field

! Local variable
integer :: ib,its,iv,jv
real(kind_real),allocatable :: fld_3d(:,:),fld_4d(:,:,:),fld_4d_tmp(:,:,:),wgt(:,:),wgt_diag(:)

select case (nam%strategy)
case ('common')
   ! Allocation
   allocate(fld_3d(geom%nc0a,geom%nl0))

   ! Sum product over variables and timeslots
   fld_3d = 0.0
   do its=1,nam%nts
      do iv=1,nam%nv
         fld_3d = fld_3d+fld(:,:,iv,its)
      end do
   end do

   ! Apply common ensemble coefficient square-root
   fld_3d = fld_3d*sqrt(ndataloc(bpar%nb+1)%coef_ens)

   ! Apply common localization
   call apply_nicas(nam,geom,ndataloc(bpar%nb+1),fld_3d)

   ! Apply common ensemble coefficient square-root
   fld_3d = fld_3d*sqrt(ndataloc(bpar%nb+1)%coef_ens)

   ! Build final vector
   do its=1,nam%nts
      do iv=1,nam%nv
         fld(:,:,iv,its) = fld_3d
      end do
   end do
case ('specific_univariate')
   ! Allocation
   allocate(fld_4d(geom%nc0a,geom%nl0,nam%nv))

   ! Sum product over timeslots
   fld_4d = 0.0
   do its=1,nam%nts
      fld_4d = fld_4d+fld(:,:,:,its)
   end do

   do ib=1,bpar%nb
      if (bpar%nicas_block(ib)) then
         ! Variable index
         iv = bpar%ib_to_iv(ib)

         ! Apply common ensemble coefficient square-root
         fld_4d(:,:,iv) = fld_4d(:,:,iv)*sqrt(ndataloc(ib)%coef_ens)

         ! Apply specific localization (same for all timeslots)
         call apply_nicas(nam,geom,ndataloc(ib),fld_4d(:,:,iv))

         ! Apply common ensemble coefficient square-root
         fld_4d(:,:,iv) = fld_4d(:,:,iv)*sqrt(ndataloc(ib)%coef_ens)
      end if
   end do

   ! Build final vector
   do its=1,nam%nts
      fld(:,:,:,its) = fld_4d
   end do
case ('specific_multivariate')
   call msgerror('not implemented yet in apply_localization')
case ('common_weighted')
   ! Allocation
   allocate(fld_4d(geom%nc0a,geom%nl0,nam%nv))
   allocate(fld_4d_tmp(geom%nc0a,geom%nl0,nam%nv))
   allocate(wgt(nam%nv,nam%nv))
   allocate(wgt_diag(nam%nv))

   ! Sum product over timeslots
   fld_4d = 0.0
   do its=1,nam%nts
      fld_4d = fld_4d+fld(:,:,:,its)
   end do

   do iv=1,nam%nv
      ! Apply common ensemble coefficient square-root
      fld_4d(:,:,iv) = fld_4d(:,:,iv)*sqrt(ndataloc(bpar%nb+1)%coef_ens)

      ! Apply common localization
      call apply_nicas(nam,geom,ndataloc(bpar%nb+1),fld_4d(:,:,iv))

      ! Apply common ensemble coefficient square-root
      fld_4d(:,:,iv) = fld_4d(:,:,iv)*sqrt(ndataloc(bpar%nb+1)%coef_ens)
   end do

   ! Prepare weights
   do ib=1,bpar%nb
      if (bpar%diag_block(ib)) then
         ! Variable indices
         iv = bpar%ib_to_iv(ib)
         jv = bpar%ib_to_jv(ib)
         wgt(iv,jv) = ndataloc(ib)%wgt
         if (iv==jv) wgt_diag(iv) = wgt(iv,iv)
      end if
   end do
   do iv=1,nam%nv
      do jv=1,nam%nv
         wgt(iv,jv) = wgt(iv,jv)/sqrt(wgt_diag(iv)*wgt_diag(jv))
      end do
   end do

   ! Apply weights
   fld_4d_tmp = fld_4d
   fld_4d = 0.0
   do iv=1,nam%nv
      do jv=1,nam%nv
         fld_4d(:,:,iv) = fld_4d(:,:,iv)+wgt(iv,jv)*fld_4d_tmp(:,:,jv)
      end do
   end do

   ! Build final vector
   do its=1,nam%nts
      fld(:,:,:,its) = fld_4d
   end do
end select

end subroutine apply_localization

end module module_apply_localization
