!----------------------------------------------------------------------
! Module: type_curve
!> Purpose: curve derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module type_curve

use model_interface, only: model_write
use module_diag_tools, only: diag_write,diag_filter,diag_interpolation
use module_namelist, only: namncwrite
use netcdf
use tools_const, only: egvmat
use tools_display, only: vunitchar,msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msvalr,msr,isnotmsr,isallnotmsr
use tools_nc, only: ncerr,ncfloat
use type_hdata, only: hdatatype
implicit none

! Curve derived type
type curvetype
   character(len=1024) :: cname        !< Curve name
   real(kind_real),allocatable :: raw(:,:,:)        !< Raw curve
   real(kind_real),allocatable :: raw_spec(:,:,:)   !< Raw curve spectrum
   real(kind_real),allocatable :: raw_coef_ens(:) !< Raw ensemble coefficient
   real(kind_real) :: raw_coef_sta                !< Raw static coefficient
   real(kind_real),allocatable :: fit_wgt(:,:,:)    !< Fit weight
   real(kind_real),allocatable :: fit(:,:,:)        !< Fit
   real(kind_real),allocatable :: fit_spec(:,:,:)   !< Fit spectrum
   real(kind_real),allocatable :: fit_coef_ens(:) !< Fit ensemble coefficient
   real(kind_real),allocatable :: fit_rh(:)        !< Fit support radius
   real(kind_real),allocatable :: fit_rv(:)        !< Fit support radius
end type curvetype

private
public :: curvetype
public :: curve_alloc,curve_dealloc,curve_normalization,curve_write,curve_write_all,curve_write_local

contains

!----------------------------------------------------------------------
! Subroutine: curve_alloc
!> Purpose: curve object allocation
!----------------------------------------------------------------------
subroutine curve_alloc(hdata,cname,curve)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata    !< Sampling data
character(len=*),intent(in) :: cname   !< Curve name
type(curvetype),intent(inout) :: curve !< Curve

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Set name
curve%cname = cname

! Allocation
allocate(curve%raw(nam%nc,geom%nl0,geom%nl0))
if (nam%spectrum) allocate(curve%raw_spec(nam%nc,geom%nl0,geom%nl0))
allocate(curve%raw_coef_ens(geom%nl0))

! Initialization
call msr(curve%raw)
if (nam%spectrum) call msr(curve%raw_spec)
call msr(curve%raw_coef_ens)

if (trim(nam%fit_type)/='none') then
   ! Allocation
   allocate(curve%fit_wgt(nam%nc,geom%nl0,geom%nl0))
   allocate(curve%fit(nam%nc,geom%nl0,geom%nl0))
   if (nam%spectrum) allocate(curve%fit_spec(nam%nc,geom%nl0,geom%nl0))
   allocate(curve%fit_coef_ens(geom%nl0))
   allocate(curve%fit_rh(geom%nl0))
   allocate(curve%fit_rv(geom%nl0))

   ! Initialization
   curve%fit_wgt = 1.0
   call msr(curve%fit)
   if (nam%spectrum) call msr(curve%fit_spec)
   call msr(curve%fit_coef_ens)
   call msr(curve%fit_rh)
   call msr(curve%fit_rv)
end if

! End ssociate
end associate

end subroutine curve_alloc

!----------------------------------------------------------------------
! Subroutine: curve_dealloc
!> Purpose: curve object deallocation
!----------------------------------------------------------------------
subroutine curve_dealloc(hdata,curve)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata    !< Sampling data
type(curvetype),intent(inout) :: curve !< Curve

! Associate
associate(nam=>hdata%nam)

! Deallocation
deallocate(curve%raw)
if (nam%spectrum) deallocate(curve%raw_spec)
deallocate(curve%raw_coef_ens)
if (trim(nam%fit_type)/='none') then
   deallocate(curve%fit_wgt)
   deallocate(curve%fit)
   if (nam%spectrum) deallocate(curve%fit_spec)
   deallocate(curve%fit_coef_ens)
   deallocate(curve%fit_rh)
   deallocate(curve%fit_rv)
end if

! End associate
end associate

end subroutine curve_dealloc

!----------------------------------------------------------------------
! Subroutine: curve_normalization
!> Purpose: compute localization normalization
!----------------------------------------------------------------------
subroutine curve_normalization(hdata,curve)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata    !< Sampling data
type(curvetype),intent(inout) :: curve !< Curve

! Local variables
integer :: il0,jl0,ic

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Get diagonal values
do il0=1,geom%nl0
   if (isnotmsr(curve%raw(1,il0,il0))) curve%raw_coef_ens(il0) = curve%raw(1,il0,il0)
   if (trim(nam%fit_type)/='none') then
      if (isnotmsr(curve%fit(1,il0,il0))) curve%fit_coef_ens(il0) = curve%fit(1,il0,il0)
   end if
end do

! Normalize
if (nam%norm_loc) then
   do jl0=1,geom%nl0
      do il0=1,geom%nl0
         do ic=1,nam%nc
            if (isnotmsr(curve%raw_coef_ens(il0)).and.isnotmsr(curve%raw_coef_ens(jl0)) &
          & .and.isnotmsr(curve%raw(ic,il0,jl0))) &
          & curve%raw(ic,il0,jl0) = curve%raw(ic,il0,jl0) &
          & /sqrt(curve%raw_coef_ens(il0)*curve%raw_coef_ens(jl0))
            if (trim(nam%fit_type)/='none') then
               if (isnotmsr(curve%fit_coef_ens(il0)).and.isnotmsr(curve%fit_coef_ens(jl0)) &
             & .and.isnotmsr(curve%fit(ic,il0,jl0))) &
             & curve%fit(ic,il0,jl0) = curve%fit(ic,il0,jl0) &
             & /sqrt(curve%fit_coef_ens(il0)*curve%fit_coef_ens(ic))
            end if
         end do
      end do
   end do
end if

! End associate
end associate

end subroutine curve_normalization

!----------------------------------------------------------------------
! Subroutine: curve_spectra
!> Purpose: compute curve components spectra
!----------------------------------------------------------------------
subroutine curve_spectra(hdata,curve)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata    !< Sampling data
type(curvetype),intent(inout) :: curve !< Curve

! Local variables
integer :: il0,jl0

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

do jl0=1,geom%nl0
   do il0=1,geom%nl0
      if (isallnotmsr(curve%raw(:,il0,jl0))) curve%raw_spec(:,il0,jl0) = matmul(egvmat,curve%raw(:,il0,jl0))
      if (trim(nam%fit_type)/='none') then
         if (isallnotmsr(curve%fit(:,il0,jl0))) curve%fit_spec(:,il0,jl0) = matmul(egvmat,curve%fit(:,il0,jl0))
      end if
   end do
end do

! End associate
end associate

end subroutine curve_spectra

!----------------------------------------------------------------------
! Subroutine: curve_write
!> Purpose: write a curve
!----------------------------------------------------------------------
subroutine curve_write(hdata,ncid,curve)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata    !< Sampling data
integer,intent(in) :: ncid                  !< File ID
type(curvetype),intent(inout) :: curve  !< Curve

! Local variables
integer :: one_id,nc_id,nl0_1_id,nl0_2_id
integer :: raw_id,raw_coef_ens_id,raw_spec_id,raw_coef_sta_id
integer :: fit_id,fit_coef_ens_id,fit_rh_id,fit_rv_id,fit_spec_id
character(len=1024) :: subr = 'curve_write'

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Compute spectra
if (nam%spectrum) call curve_spectra(hdata,curve)

! Get dimensions ID
call ncerr(subr,nf90_inq_dimid(ncid,'one',one_id))
call ncerr(subr,nf90_inq_dimid(ncid,'nc',nc_id))
call ncerr(subr,nf90_inq_dimid(ncid,'nl0_1',nl0_1_id))
call ncerr(subr,nf90_inq_dimid(ncid,'nl0_2',nl0_2_id))

! Define variables
call ncerr(subr,nf90_redef(ncid))

! Raw curve
call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_raw',ncfloat,(/nc_id,nl0_1_id,nl0_2_id/),raw_id))
call ncerr(subr,nf90_put_att(ncid,raw_id,'_FillValue',msvalr))
! Raw curve ensemble coefficient
call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_raw_coef_ens',ncfloat,(/nl0_1_id/),raw_coef_ens_id))
call ncerr(subr,nf90_put_att(ncid,raw_coef_ens_id,'_FillValue',msvalr))
if (nam%spectrum) then
   ! Raw curve eigenspectrum
   call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_raw_spec',ncfloat,(/nc_id,nl0_1_id,nl0_2_id/),raw_spec_id))
   call ncerr(subr,nf90_put_att(ncid,raw_spec_id,'_FillValue',msvalr))
end if
if (isnotmsr(curve%raw_coef_sta)) then
   ! Raw curve static coefficient
   call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_raw_coef_sta',ncfloat,(/one_id/),raw_coef_sta_id))
   call ncerr(subr,nf90_put_att(ncid,raw_coef_sta_id,'_FillValue',msvalr))
end if
if (trim(nam%fit_type)/='none') then
   ! Fitted curve
   call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_fit',ncfloat,(/nc_id,nl0_1_id,nl0_2_id/),fit_id))
   call ncerr(subr,nf90_put_att(ncid,fit_id,'_FillValue',msvalr))
   ! Fitted curve support radius
   call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_fit_rh',ncfloat,(/nl0_1_id/),fit_rh_id))
   call ncerr(subr,nf90_put_att(ncid,fit_rh_id,'_FillValue',msvalr))
   ! Fitted curve support radius
   call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_fit_rv',ncfloat,(/nl0_1_id/),fit_rv_id))
   call ncerr(subr,nf90_put_att(ncid,fit_rv_id,'_FillValue',msvalr))
   ! Fitted curve ensemble coefficient
   call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_fit_coef_ens',ncfloat,(/nl0_1_id/),fit_coef_ens_id))
   call ncerr(subr,nf90_put_att(ncid,fit_coef_ens_id,'_FillValue',msvalr))
   if (nam%spectrum) then
      ! Fitted curve eigenspectrum
      call ncerr(subr,nf90_def_var(ncid,trim(curve%cname)//'_fit_spec',ncfloat,(/nc_id,nl0_1_id,nl0_2_id/),fit_spec_id))
      call ncerr(subr,nf90_put_att(ncid,fit_spec_id,'_FillValue',msvalr))
   end if
end if
call ncerr(subr,nf90_enddef(ncid))

! Write variables

! Raw curve
call ncerr(subr,nf90_put_var(ncid,raw_id,curve%raw))
! Raw curve ensemble coefficient
call ncerr(subr,nf90_put_var(ncid,raw_coef_ens_id,curve%raw_coef_ens))
if (nam%spectrum) then
   ! Raw curve eigenspectrum
   call ncerr(subr,nf90_put_var(ncid,raw_spec_id,curve%raw_spec))
end if
! Raw curve static coefficient
if (isnotmsr(curve%raw_coef_sta)) call ncerr(subr,nf90_put_var(ncid,raw_coef_sta_id,curve%raw_coef_sta))
if (trim(nam%fit_type)/='none') then
   ! Fitted curve
   call ncerr(subr,nf90_put_var(ncid,fit_id,curve%fit))
   ! Fitted curve ensemble coefficient
   call ncerr(subr,nf90_put_var(ncid,fit_coef_ens_id,curve%fit_coef_ens))
   ! Fitted curve support radius
   call ncerr(subr,nf90_put_var(ncid,fit_rh_id,curve%fit_rh))
   ! Fitted curve support radius
   call ncerr(subr,nf90_put_var(ncid,fit_rv_id,curve%fit_rv))
   if (nam%spectrum) then
      ! Fitted curve eigenspectrum
      call ncerr(subr,nf90_put_var(ncid,fit_spec_id,curve%fit_spec))
   end if
end if

! End associate
end associate

end subroutine curve_write

!----------------------------------------------------------------------
! Subroutine: curve_write_all
!> Purpose: write all curves
!----------------------------------------------------------------------
subroutine curve_write_all(hdata,filename,cor_1,cor_2,loc_1,loc_2,loc_3,loc_4)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
character(len=*),intent(in) :: filename
type(curvetype),intent(inout) :: cor_1(hdata%nam%nb+1) !< 
type(curvetype),intent(inout) :: cor_2(hdata%nam%nb+1) !< 
type(curvetype),intent(inout) :: loc_1(hdata%nam%nb+1) !< 
type(curvetype),intent(inout) :: loc_2(hdata%nam%nb+1) !< 
type(curvetype),intent(inout) :: loc_3(hdata%nam%nb+1) !< 
type(curvetype),intent(inout) :: loc_4(hdata%nam%nb+1) !< 

! Local variables
integer :: ncid,one_id,nc_id,nl0_1_id,nl0_2_id,disth_id,vunit_id
integer :: ib
character(len=1024) :: subr = 'curve_write_all'

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

call system('rm -f '//trim(nam%datadir)//'/'//trim(filename))
call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
call namncwrite(nam,ncid)
call ncerr(subr,nf90_put_att(ncid,nf90_global,'vunitchar',trim(vunitchar)))
call ncerr(subr,nf90_def_dim(ncid,'one',1,one_id))
call ncerr(subr,nf90_def_dim(ncid,'nc',nam%nc,nc_id))
call ncerr(subr,nf90_def_dim(ncid,'nl0_1',geom%nl0,nl0_1_id))
call ncerr(subr,nf90_def_dim(ncid,'nl0_2',geom%nl0,nl0_2_id))
call ncerr(subr,nf90_def_var(ncid,'disth',ncfloat,(/nc_id/),disth_id))
call ncerr(subr,nf90_def_var(ncid,'vunit',ncfloat,(/nl0_1_id/),vunit_id))
call ncerr(subr,nf90_enddef(ncid))
call ncerr(subr,nf90_put_var(ncid,disth_id,nam%disth(1:nam%nc)))
call ncerr(subr,nf90_put_var(ncid,vunit_id,geom%vunit))
do ib=1,nam%nb+1
   if (nam%diag_block(ib)) then
      call curve_write(hdata,ncid,cor_1(ib))
      select case (trim(nam%method))
      case ('hyb-avg','hyb-rnd','dual-ens')
         call curve_write(hdata,ncid,cor_2(ib))
      end select
      select case (trim(nam%method))
      case ('loc','hyb-avg','hyb-rnd','dual-ens')
         call curve_write(hdata,ncid,loc_1(ib))
      end select
      select case (trim(nam%method))
      case ('hyb-avg','hyb-rnd','dual-ens')
         call curve_write(hdata,ncid,loc_2(ib))
      end select
      if (trim(nam%method)=='dual-ens') then
         call curve_write(hdata,ncid,loc_3(ib))
         call curve_write(hdata,ncid,loc_4(ib))
      end if
   end if
end do
call ncerr(subr,nf90_close(ncid))

! End associate
end associate

end subroutine curve_write_all

!----------------------------------------------------------------------
! Subroutine: curve_write_local
!> Purpose: write all curves
!----------------------------------------------------------------------
subroutine curve_write_local(hdata,filename,curve_nc2)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
character(len=*),intent(in) :: filename !<
type(curvetype),intent(in) :: curve_nc2(hdata%nam%nb+1,hdata%nc2) !< 

! Local variables
integer :: ncid
integer :: ib,ic2
real(kind_real) :: fld_nc2(hdata%nc2,hdata%geom%nl0),fld(hdata%geom%nc0,hdata%geom%nl0)
character(len=1024) :: subr = 'curve_write_all'

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
call namncwrite(nam,ncid)
call ncerr(subr,nf90_close(ncid))
do ib=1,nam%nb+1
   if (nam%fit_block(ib)) then
      call msr(fld_nc2)
      do ic2=1,hdata%nc2
         fld_nc2(ic2,:) = curve_nc2(ib,ic2)%fit_rh
      end do
      call diag_interpolation(hdata,fld_nc2,fld)
      call model_write(nam,geom,filename,trim(nam%blockname(ib))//'_fit_rh',fld)
      if (trim(nam%flt_type)/='none') then
         call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
         call diag_interpolation(hdata,fld_nc2,fld)
         call model_write(nam,geom,filename,trim(nam%blockname(ib))//'_fit_rh_flt',fld)
      end if
      call msr(fld_nc2)
      do ic2=1,hdata%nc2
         fld_nc2(ic2,:) = curve_nc2(ib,ic2)%fit_rv
      end do
      call diag_interpolation(hdata,fld_nc2,fld)
      call model_write(nam,geom,filename,trim(nam%blockname(ib))//'_fit_rv',fld)
      if (trim(nam%flt_type)/='none') then
         call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
         call diag_interpolation(hdata,fld_nc2,fld)
         call model_write(nam,geom,filename,trim(nam%blockname(ib))//'_fit_rv_flt',fld)
      end if
   end if
end do

! End associate
end associate

end subroutine curve_write_local

end module type_curve
