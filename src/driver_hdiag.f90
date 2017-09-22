!----------------------------------------------------------------------
! Module: driver_hdiag
!> Purpose: hybrid_diag driver
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module driver_hdiag

use model_interface, only: model_write
use module_average, only: compute_avg,compute_avg_lr,compute_avg_asy,compute_bwavg
use module_diag_tools, only: diag_write,diag_filter,diag_interpolation
use module_displacement, only: compute_displacement
use module_dualens, only: compute_dualens
use module_fit, only: compute_fit
use module_hybridization, only: compute_hybridization
use module_localization, only: compute_localization
use module_moments, only: compute_moments
use module_namelist, only: namtype,namncwrite
use module_sampling, only: setup_sampling
use netcdf
use tools_const, only: eigen_init,reqkm
use tools_display, only: vunitchar,prog_init,prog_print,msgerror,msgwarning,aqua,aqua,peach,peach,purple,purple,black
use tools_kinds, only: kind_real
use tools_missing, only: msvali,msvalr,isnotmsi,isanynotmsr,msr
use tools_nc, only: ncerr,ncfloat
use type_avg, only: avgtype,avg_dealloc
use type_bdata, only: bdatatype
use type_curve, only: curvetype,curve_alloc,curve_dealloc,curve_write
use type_displ, only: displtype,displ_alloc,displ_dealloc
use type_geom, only: geomtype
use type_hdata, only: hdatatype
use type_mom, only: momtype,mom_dealloc
use type_mpl, only: mpl

implicit none

private
public :: hdiag

contains

!----------------------------------------------------------------------
! Subroutine: hdiag
!> Purpose: hybrid_diag
!----------------------------------------------------------------------
subroutine hdiag(nam,geom,bdata)

implicit none

! Passed variables
type(namtype),target,intent(inout) :: nam !< Namelist variables
type(geomtype),target,intent(in) :: geom    !< Sampling data
type(bdatatype),intent(inout) :: bdata(nam%nvp) !< B data

! Local variables
integer :: iv,il0,jl0,ic,ic2,ildw,ic0,iter,progint
integer :: ncid,nv_id,one_id,nc_id,nl0_1_id,nl0_2_id,na_id,two_id,displ_niter_id
integer :: disth_id,vunit_id,larc_id,rhflt_id
real(kind_real),allocatable :: fld(:,:),fld_nc2(:,:)
logical,allocatable :: done(:)
character(len=2) :: iterchar
character(len=3) :: levchar,icchar
character(len=7) :: lonchar,latchar
character(len=1024) :: filename
character(len=1024),allocatable :: varname(:),varind(:)
character(len=1024) :: subr = 'driver_hdiag'
type(avgtype) :: avg,avg_rnd,avg_lr
type(avgtype),allocatable :: avg_nc2(:)
type(curvetype),allocatable :: cor(:),cor_sta(:),cor_lr(:)
type(curvetype),allocatable :: cor_nc2(:,:),loc_nc2(:,:)
type(curvetype),allocatable :: loc(:),loc_hyb(:),loc_lr(:),loc_deh(:),loc_deh_lr(:)
type(displtype) :: displ
type(hdatatype) :: hdata
type(momtype) :: mom,mom_rnd,mom_lr

! Set namelist
hdata%nam => nam

! Set geometry
hdata%geom => geom

if (nam%spectrum) then
   ! Initialize eigendecomposition
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Initialize eigendecomposition'

   call eigen_init(nam%nc)
end if

! Setup sampling
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a,i5,a)') '--- Setup sampling (nc1 = ',nam%nc1,')'

call setup_sampling(hdata)

! Compute sample moments
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Compute sample moments'

! Compute ensemble 1 sample moments
write(mpl%unit,'(a7,a,i4,a)') '','Ensemble 1:'
if (nam%cross_diag.or.nam%displ_diag) then
   call compute_moments('cross',hdata,mom)
else
   call compute_moments('ens1',hdata,mom)
end if

if (trim(nam%method)=='hyb-rnd') then
   ! Compute randomized sample moments
   write(mpl%unit,'(a7,a,i4,a)') '','Ensemble 2 (randomized):'
   call compute_moments('ens2',hdata,mom_rnd)
elseif (trim(nam%method)=='dual-ens') then
   ! Compute low-resolution sample moments
   write(mpl%unit,'(a7,a,i4,a)') '','Ensemble 2 (low-resolution):'
   call compute_moments('ens2',hdata,mom_lr)
end if

! Setup display
allocate(varname(nam%nvp))
allocate(varind(nam%nvp))
do iv=1,nam%nv
   varname(iv) = nam%ens1_varname(iv)
   write(varind(iv),'(i2.2)') iv
end do
if (nam%nv>1) then
   varname(nam%nv+1) = 'common'
   varind(nam%nv+1) = 'common'
end if

! Compute global statistics
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Compute statistics'

! Compute global statistics
call compute_avg(hdata,mom,0,avg)

! Compute global asymptotic statistics
call compute_avg_asy(hdata,nam%ne,avg)

if (nam%local_diag) then
   ! Allocation
   allocate(avg_nc2(hdata%nc2))
   allocate(done(hdata%nc2))

   write(mpl%unit,'(a7,a)',advance='no') '','Compute local statistics:'
   call prog_init(progint,done)
   !$omp parallel do private(ic2)
   do ic2=1,hdata%nc2
      ! Compute local statistics
      call compute_avg(hdata,mom,ic2,avg_nc2(ic2))

      ! Compute local asymptotic statistics
      call compute_avg_asy(hdata,nam%ne,avg_nc2(ic2))
      done(ic2) = .true.
      call prog_print(progint,done)
   end do
   !$omp end parallel do
   write(mpl%unit,'(a)') '100%'
end if

if (trim(nam%method)=='hyb-avg') then
   ! Static covariance = ensemble covariance
   avg%m11sta(:,:,:,1:nam%nvp) = avg%m11*avg%m11
   avg%stasq(:,:,:,1:nam%nvp) = avg%m11**2
elseif (trim(nam%method)=='hyb-rnd') then
   ! Compute randomized averaged statistics
   call compute_avg(hdata,mom_rnd,0,avg_rnd)

   ! Static covariance = randomized covariance
   avg%m11sta(:,:,:,1:nam%nv) = avg%m11*avg_rnd%m11
   avg%stasq(:,:,:,1:nam%nv) = avg_rnd%m11**2
elseif (trim(nam%method)=='dual-ens') then
   ! Compute low-resolution averaged statistics
   call compute_avg(hdata,mom_lr,0,avg_lr)
   call compute_avg_asy(hdata,nam%ens2_ne,avg_lr)

   ! LR covariance/HR covariance product average
   call compute_avg_lr(hdata,mom,mom_lr,avg,avg_lr)
end if

! Define block weights (inverse variances product)
do iv=1,nam%nv
   do jl0=1,geom%nl0
      do il0=1,geom%nl0
         do ic=1,nam%nc
            if (avg%m2m2asy(1,il0,il0,iv)>0.0) then
               hdata%bwgtsq(ic,il0,jl0,iv) = 1.0/avg%m2m2asy(ic,il0,jl0,iv)
            else
               hdata%bwgtsq(ic,il0,jl0,iv) = 0.0
            end if
         end do
      end do
   end do
end do

if (nam%nv>1) then
   ! Compute global block averages
   call compute_bwavg(hdata,avg)
   if (trim(nam%method)=='hyb-rnd') then
      call compute_bwavg(hdata,avg_rnd)
   elseif (trim(nam%method)=='dual-ens') then
      call compute_bwavg(hdata,avg_lr)
   end if

   if (nam%local_diag) then
      ! Compute local block averages
      !$omp parallel do private(ic2)
      do ic2=1,hdata%nc2
         call compute_bwavg(hdata,avg_nc2(ic2))
      end do
      !$omp end parallel do
   end if
end if

! Copy correlation
allocate(cor(nam%nvp))
if (nam%local_diag) allocate(cor_nc2(nam%nvp,hdata%nc2))
do iv=1,nam%nvp
   ! Allocation
   call curve_alloc(hdata,trim(varind(iv))//'_cor',cor(iv))

   ! Copy
   cor(iv)%raw = avg%cor(:,:,:,iv)
   do il0=1,geom%nl0
      if (iv<=nam%nv) cor(iv)%raw_coef_ens(il0) = avg%m11(1,il0,il0,iv)
   end do
   if (nam%local_diag) then
      do ic2=1,hdata%nc2
         ! Allocation
         call curve_alloc(hdata,trim(varind(iv))//'_cor_nc2',cor_nc2(iv,ic2))

         ! Copy
         cor_nc2(iv,ic2)%raw = avg_nc2(ic2)%cor(:,:,:,iv)
         do il0=1,geom%nl0
            if (iv<=nam%nv) cor_nc2(iv,ic2)%raw_coef_ens(il0) = avg_nc2(ic2)%m11(1,il0,il0,iv)
         end do
      end do
   end if
end do

if (trim(nam%fit_type)/='none') then
   ! Compute correlation fit
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute correlation fit'

   ! Compute global fit
   if (nam%cross_diag.or.nam%displ_diag) then
      call compute_fit(hdata%nam,hdata%geom,cor)
   else
      call compute_fit(hdata%nam,hdata%geom,cor,norm=1.0_kind_real)
   end if

   if (nam%local_diag) then
      ! Compute local fit
      write(mpl%unit,'(a7,a)',advance='no') '','Compute local fit:'
      call prog_init(progint,done)
      !$omp parallel do private(ic2)
      do ic2=1,hdata%nc2
         if (nam%cross_diag.or.nam%displ_diag) then
            call compute_fit(hdata%nam,hdata%geom,cor_nc2(:,ic2))
         else
            call compute_fit(hdata%nam,hdata%geom,cor_nc2(:,ic2),norm=1.0_kind_real)
         end if
         done(ic2) = .true.
         call prog_print(progint,done)
      end do
      !$omp end parallel do
      write(mpl%unit,'(a)') '100%'
   end if

   ! Print results
   do iv=1,nam%nvp
      write(mpl%unit,'(a7,a,a)') '','Variable: ',trim(varname(iv))
      do il0=1,geom%nl0
         ! Check variables to print
         write(mpl%unit,'(a10,a,i3,a,f8.2,a,f8.2,a)') '','Level: ',nam%levs(il0), &
       & ' ~>  cor. support radii: '//trim(aqua),cor(iv)%fit_rh(il0)*reqkm,trim(black)//' km  / ' &
       & //trim(aqua),cor(iv)%fit_rv(il0),trim(black)//' '//trim(vunitchar)
      end do
   end do
end if

select case (trim(nam%method))
case ('loc','hyb-avg','hyb-rnd','dual-ens')
   ! Compute localization diagnostic and fit
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute localization diagnostic and fit'

   ! Allocation
   allocate(loc(nam%nvp))
   do iv=1,nam%nvp
      call curve_alloc(hdata,trim(varind(iv))//'_loc',loc(iv))
   end do
   if (nam%local_diag) then
      allocate(loc_nc2(nam%nvp,hdata%nc2))
      do iv=1,nam%nvp
         do ic2=1,hdata%nc2
            call curve_alloc(hdata,trim(varind(iv))//'_loc_nc2',loc_nc2(iv,ic2))
         end do
      end do
   end if

   ! Compute localization
   call compute_localization(hdata,avg,loc)
   if (nam%local_diag) then
      !$omp parallel do private(ic2)
      do ic2=1,hdata%nc2
         call compute_localization(hdata,avg_nc2(ic2),loc_nc2(:,ic2))
      end do
      !$omp end parallel do
   end if

   ! Print results
   if (nam%fit_type/='none') then
      do iv=1,nam%nvp
         write(mpl%unit,'(a7,a,a)') '','Variable: ',trim(varname(iv))
         do il0=1,geom%nl0
            write(mpl%unit,'(a10,a,i3,a4,a21,a,f8.2,a,f8.2,a)') '','Level: ',nam%levs(il0),' ~> ','loc. support radii: ', &
          & trim(aqua),loc(iv)%fit_rh(il0)*reqkm,trim(black)//' km  / ' &
          & //trim(aqua),loc(iv)%fit_rv(il0),trim(black)//' '//trim(vunitchar)
            write(mpl%unit,'(a45,a,f8.2,a)') 'raw norm.: ',trim(peach),loc(iv)%raw_coef_ens(il0),trim(black)
            write(mpl%unit,'(a45,a,f8.2,a)') 'fit norm.: ',trim(peach),loc(iv)%fit_coef_ens(il0),trim(black)
         end do
      end do
   end if
end select

select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   ! Compute static covariance fit
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute static covariance fit'

   ! Allocation
   allocate(cor_sta(nam%nvp))
   do iv=1,nam%nvp
      call curve_alloc(hdata,trim(varind(iv))//'_cor_sta',cor_sta(iv))
   end do
   allocate(loc_hyb(nam%nvp))
   do iv=1,nam%nvp
      call curve_alloc(hdata,trim(varind(iv))//'_loc_hyb',loc_hyb(iv))
   end do

   ! Compute static covariance fit
   do iv=1,nam%nvp
      if (trim(nam%method)=='hyb-avg') then
         cor_sta(iv)%raw = avg%cor(:,:,:,iv)
         do il0=1,geom%nl0
            if (iv<=nam%nv) cor_sta(iv)%raw_coef_ens(il0) = avg%m11(1,il0,il0,iv)
         end do
      end if
      if (trim(nam%method)=='hyb-rnd') then
         cor_sta(iv)%raw = avg_rnd%cor(:,:,:,iv)
         do il0=1,geom%nl0
            if (iv<=nam%nv) cor_sta(iv)%raw_coef_ens(il0) = avg_rnd%m11(1,il0,il0,iv)
         end do
      end if
   end do

   if (trim(nam%fit_type)/='none') then
      ! Compute fit
      if (nam%cross_diag.or.nam%displ_diag) then
         call compute_fit(hdata%nam,hdata%geom,cor_sta)
      else
        call compute_fit(hdata%nam,hdata%geom,cor_sta,norm=1.0_kind_real)
      end if

      ! Print results
      do iv=1,nam%nvp
         write(mpl%unit,'(a7,a,a)') '','Variable: ',trim(varname(iv))
         do il0=1,geom%nl0
            write(mpl%unit,'(a10,a,i3,a,f8.2,a,f8.2,a)') '','Level: ',nam%levs(il0),' ~> static support radii: '// &
          & trim(aqua),cor_sta(iv)%fit_rh(il0)*reqkm,trim(black)//' km  / ' &
          & //trim(aqua),cor_sta(iv)%fit_rv(il0),trim(black)//' '//trim(vunitchar)
         end do
      end do
   end if

   ! Compute static hybridization diagnostic and fit
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute static hybridization diagnostic and fit'

   ! Compute static hybridization
   call compute_hybridization(hdata,avg,loc_hyb)

   ! Print results
   if (nam%fit_type/='none') then
      do iv=1,nam%nvp
         write(mpl%unit,'(a7,a,a)') '','Variable: ',trim(varname(iv))
         do il0=1,geom%nl0
            write(mpl%unit,'(a10,a,i3,a4,a21,a,f8.2,a,f8.2,a)') '','Level: ',nam%levs(il0),' ~> ','loc. support radii: ', &
          & trim(aqua),loc_hyb(iv)%fit_rh(il0)*reqkm,trim(black)//' km  / ' &
          & //trim(aqua),loc_hyb(iv)%fit_rv(il0),trim(black)//' '//trim(vunitchar)
            write(mpl%unit,'(a45,a,f8.2,a)') '','raw ensemble coeff.: ',trim(peach),loc_hyb(iv)%raw_coef_ens(il0),trim(black)
            write(mpl%unit,'(a45,a,f8.2,a)') '','fit ensemble coeff.: ',trim(peach),loc_hyb(iv)%fit_coef_ens(il0),trim(black)
         end do
         write(mpl%unit,'(a10,a,f8.2,a)') '','Raw static coeff.: ',trim(purple),loc_hyb(iv)%raw_coef_sta,trim(black)
      end do
   end if
end select

if (trim(nam%method)=='dual-ens') then
   ! Compute low-resolution correlation fit
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute low-resolution correlation fit'

   ! Allocation
   allocate(cor_lr(nam%nvp))
   do iv=1,nam%nvp
      call curve_alloc(hdata,trim(varind(iv))//'_cor_lr',cor_lr(iv))
   end do
   allocate(loc_lr(nam%nvp))
   allocate(loc_deh(nam%nvp))
   allocate(loc_deh_lr(nam%nvp))
   do iv=1,nam%nvp
      call curve_alloc(hdata,trim(varind(iv))//'_loc_lr',loc_lr(iv))
      call curve_alloc(hdata,trim(varind(iv))//'_loc_deh',loc_deh(iv))
      call curve_alloc(hdata,trim(varind(iv))//'_loc_deh_lr',loc_deh_lr(iv))
   end do

   ! Compute low-resolution correlation fit
   do iv=1,nam%nvp
      cor_lr(iv)%raw = avg_lr%cor(:,:,:,iv)
      do il0=1,geom%nl0
         cor_lr(iv)%raw_coef_ens(il0) = avg_lr%m11(1,il0,il0,iv)
      end do
   end do

   if (trim(nam%fit_type)/='none') then
      ! Compute fit
      if (nam%cross_diag.or.nam%displ_diag) then
         call compute_fit(hdata%nam,hdata%geom,cor_lr)
      else
         call compute_fit(hdata%nam,hdata%geom,cor_lr,norm=1.0_kind_real)
      end if

      ! Print results
      do iv=1,nam%nvp
         write(mpl%unit,'(a7,a,a)') '','Variable: ',trim(varname(iv))
         do il0=1,geom%nl0
            write(mpl%unit,'(a10,a,i3,a,f8.2,a,f8.2,a)') '','Level: ',nam%levs(il0),' ~> correlation: '//trim(aqua), &
          & cor_lr(iv)%fit_rh(il0)*reqkm,trim(black)//' km  / ' &
          & //trim(aqua),cor_lr(iv)%fit_rv(il0),trim(black)//' '//trim(vunitchar)
         end do
      end do
   end if

   ! Compute low-resolution localization diagnostic and fit
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute low-resolution localization diagnostic and fit'

   ! Compute low-resolution localization
   call compute_localization(hdata,avg_lr,loc_lr)

   ! Print results
   if (nam%fit_type/='none') then
      do iv=1,nam%nvp
         write(mpl%unit,'(a7,a,a)') '','Variable: ',trim(varname(iv))
         do il0=1,geom%nl0
            write(mpl%unit,'(a10,a,i3,a4,a21,a,f8.2,a,f8.2,a)') '','Level: ',nam%levs(il0),' ~> ','loc. support radii: ', &
          & trim(aqua),loc_lr(iv)%fit_rh(il0)*reqkm,trim(black)//' km  / ' &
          & //trim(aqua),loc_lr(iv)%fit_rv(il0),trim(black)//' '//trim(vunitchar)
            write(mpl%unit,'(a45,a,f8.2,a)') '','raw norm.: ',trim(peach),loc_lr(iv)%raw_coef_ens(il0),trim(black)
            write(mpl%unit,'(a45,a,f8.2,a)') '','fit norm.: ',trim(peach),loc_lr(iv)%fit_coef_ens(il0),trim(black)
         end do
      end do
   end if

   ! Compute dual-ensemble hybridization diagnostic and fit
   write(mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(mpl%unit,'(a)') '--- Compute dual-ensemble hybridization diagnostic and fit'

   ! Compute dual-ensemble hybridization
   call compute_dualens(hdata,avg,avg_lr,loc_deh,loc_deh_lr)

   ! Print results
   if (nam%fit_type/='none') then
      do iv=1,nam%nvp
         write(mpl%unit,'(a7,a,a)') '','Variable: ',trim(varname(iv))
         do il0=1,geom%nl0
            write(mpl%unit,'(a10,a,i3,a4,a21,a,f8.2,a,f8.2,a)') '','Level: ',nam%levs(il0),' ~> ','loc. support radii (HR): ', &
          & trim(aqua),loc_deh(iv)%fit_rh(il0)*reqkm,trim(black)//' km  / ' &
          & //trim(aqua),loc_deh(iv)%fit_rv(il0),trim(black)//' '//trim(vunitchar)
            write(mpl%unit,'(a45,a,f8.2,a,f8.2,a)') '','loc. support radii (LR): ', &
          & trim(aqua),loc_deh_lr(iv)%fit_rh(il0)*reqkm,trim(black)//' km  / ' &
          & //trim(aqua),loc_deh_lr(iv)%fit_rv(il0),trim(black)//' '//trim(vunitchar)
            write(mpl%unit,'(a45,a,f8.2,a)') '','raw coeff. (HR): ',trim(peach),loc_deh(iv)%raw_coef_ens(il0),trim(black)
            write(mpl%unit,'(a45,a,f8.2,a)') '','fit coeff. (HR): ',trim(peach),loc_deh(iv)%fit_coef_ens(il0),trim(black)
            write(mpl%unit,'(a45,a,f8.2,a)') '','raw coeff. (LR): ',trim(purple),loc_deh_lr(iv)%raw_coef_ens(il0),trim(black)
            write(mpl%unit,'(a45,a,f8.2,a)') '','fit coeff. (LR): ',trim(purple),loc_deh_lr(iv)%fit_coef_ens(il0),trim(black)
         end do
      end do
   end if
end if

! Copy diagnostics into B data
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Copy diagnostics into B data'

! Allocation
if (nam%local_diag) allocate(fld_nc2(hdata%nc2,geom%nl0))

select case (trim(nam%method))
case ('cor')
   if (nam%local_diag) then
! TODO
   else
! TODO
   end if
case ('loc')

   do iv=1,nam%nvp
      if (nam%local_diag) then
         do ic2=1,hdata%nc2
            fld_nc2(ic2,:) = loc_nc2(iv,ic2)%fit_coef_ens
         end do
         if (trim(nam%flt_type)/='none') call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
         call diag_interpolation(hdata,fld_nc2,bdata(iv)%coef_ens)
         do ic2=1,hdata%nc2
            fld_nc2(ic2,:) = loc_nc2(iv,ic2)%fit_rh
         end do
         if (trim(nam%flt_type)/='none') call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
         call diag_interpolation(hdata,fld_nc2,bdata(iv)%rh0)
         do ic2=1,hdata%nc2
            fld_nc2(ic2,:) = loc_nc2(iv,ic2)%fit_rv
         end do
         if (trim(nam%flt_type)/='none') call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
         call diag_interpolation(hdata,fld_nc2,bdata(iv)%rv0)
      else
         do il0=1,geom%nl0
            bdata(iv)%coef_ens(:,il0) = loc(iv)%fit_coef_ens(il0)
            bdata(iv)%rh0(:,il0) = loc(iv)%fit_rh(il0)
            bdata(iv)%rv0(:,il0) = loc(iv)%fit_rv(il0)
         end do
      end if
      bdata(iv)%coef_sta = 0.0
   end do
case default
! TODO
end select

! Write data
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Write data'

if (nam%displ_diag) then
   ! TODO routine in type_displ
   ! Write displacement diagnostics
   filename = trim(nam%prefix)//'_displ_diag.nc'
   call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
   call namncwrite(nam,ncid)
   call ncerr(subr,nf90_def_dim(ncid,'nv',nam%nvp,nv_id))
   call ncerr(subr,nf90_def_dim(ncid,'nl0',geom%nl0,nl0_1_id))
   if (nam%displ_explicit) then
      call ncerr(subr,nf90_def_dim(ncid,'na',3*hdata%nc2-6,na_id))
      call ncerr(subr,nf90_def_dim(ncid,'two',2,two_id))
   end if
   call ncerr(subr,nf90_def_dim(ncid,'displ_niter',displ%niter,displ_niter_id))
   call ncerr(subr,nf90_def_var(ncid,'vunit',ncfloat,(/nl0_1_id/),vunit_id))
   if (nam%displ_explicit) then
      call ncerr(subr,nf90_def_var(ncid,'larc',nf90_int,(/two_id,na_id/),larc_id))
      call ncerr(subr,nf90_put_att(ncid,larc_id,'_FillValue',msvali))
   end if
   call ncerr(subr,nf90_def_var(ncid,'rhflt',ncfloat,(/displ_niter_id,nl0_1_id,nv_id/),rhflt_id))
   call ncerr(subr,nf90_put_att(ncid,rhflt_id,'_FillValue',msvalr))
   call ncerr(subr,nf90_enddef(ncid))
   call ncerr(subr,nf90_put_var(ncid,vunit_id,geom%vunit))
   if (nam%displ_explicit) call ncerr(subr,nf90_put_var(ncid,larc_id,hdata%larc))
   call ncerr(subr,nf90_put_var(ncid,rhflt_id,displ%rhflt))
   call ncerr(subr,nf90_close(ncid))
   if (nam%displ_explicit) then
      call diag_write(filename,'lon',hdata,displ%lon)
      call diag_write(filename,'lat',hdata,displ%lat)
      call diag_write(filename,'bdist',hdata,hdata%bdist)
   end if
   do iv=1,nam%nvp
      if (nam%displ_explicit) then
         call diag_write(filename,trim(varind(iv))//'_dlon_raw',hdata,displ%dlon_raw(:,:,iv))
         call diag_write(filename,trim(varind(iv))//'_dlat_raw',hdata,displ%dlat_raw(:,:,iv))
         call diag_write(filename,trim(varind(iv))//'_dist_raw',hdata,displ%dist_raw(:,:,iv))
         call diag_write(filename,trim(varind(iv))//'_valid_raw',hdata,displ%valid_raw(:,:,iv))
         do iter=1,displ%niter
            write(iterchar,'(i2.2)') iter
            call diag_write(filename,trim(varind(iv))//'_dlon_flt_'//iterchar,hdata,displ%dlon_flt(:,iter,:,iv))
            call diag_write(filename,trim(varind(iv))//'_dlat_flt_'//iterchar,hdata,displ%dlat_flt(:,iter,:,iv))
            call diag_write(filename,trim(varind(iv))//'_dist_flt_'//iterchar,hdata,displ%dist_flt(:,iter,:,iv))
            call diag_write(filename,trim(varind(iv))//'_valid_flt_'//iterchar,hdata,displ%valid_flt(:,iter,:,iv))
         end do
      else
         call diag_interpolation(hdata,displ%dlon_flt(:,1,:,iv),fld)
         call model_write(nam,geom,filename,trim(varind(iv))//'_dlon_flt',fld)
         call diag_interpolation(hdata,displ%dlat_flt(:,1,:,iv),fld)
         call model_write(nam,geom,filename,trim(varind(iv))//'_dlat_flt',fld)
         call diag_interpolation(hdata,displ%dist_flt(:,1,:,iv),fld)
         call model_write(nam,geom,filename,trim(varind(iv))//'_dist_flt',fld)
         call diag_interpolation(hdata,displ%valid_flt(:,1,:,iv),fld)
         call model_write(nam,geom,filename,trim(varind(iv))//'_valid_flt',fld)
      end if
   end do
end if

if (nam%full_var) then
   ! Write full variances
   filename = trim(nam%prefix)//'_full_var.nc'
   do iv=1,nam%nv
      call model_write(nam,geom,filename,trim(varind(iv))//'_'//trim(varname(iv)),sum(mom%m2full(:,:,iv,:),dim=3)/float(mom%nsub))
   end do
end if

! Write global diagnostics
filename = trim(nam%prefix)//'_diag.nc'
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
call curve_write(hdata,ncid,cor,.true.)
select case (trim(nam%method))
case ('loc','hyb-avg','hyb-rnd','dual-ens')
   call curve_write(hdata,ncid,loc,.true.)
end select
select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   call curve_write(hdata,ncid,cor_sta,.false.)
   call curve_write(hdata,ncid,loc_hyb,.true.)
end select
if (trim(nam%method)=='dual-ens') then
   call curve_write(hdata,ncid,cor_lr,.true.)
   call curve_write(hdata,ncid,loc_lr,.true.)
   call curve_write(hdata,ncid,loc_deh,.true.)
   call curve_write(hdata,ncid,loc_deh_lr,.true.)
end if
call ncerr(subr,nf90_close(ncid))

if (nam%local_diag) then
   ! Allocation
   allocate(fld(geom%nc0,geom%nl0))

   ! Write support radii fields
   if (trim(nam%fit_type)/='none') then
      ! Open file
      filename = trim(nam%prefix)//'_local_diag_cor.nc'
      call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
      call namncwrite(nam,ncid)
      call ncerr(subr,nf90_close(ncid))

      do iv=1,nam%nvp
         call msr(fld_nc2)
         do ic2=1,hdata%nc2
            fld_nc2(ic2,:) = cor_nc2(iv,ic2)%fit_rh
         end do
         call diag_interpolation(hdata,fld_nc2,fld)
         call model_write(nam,geom,filename,trim(varind(iv))//'_fit_rh',fld)
         if (trim(nam%flt_type)/='none') then
            call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
            call diag_interpolation(hdata,fld_nc2,fld)
            call model_write(nam,geom,filename,trim(varind(iv))//'_fit_rh_flt',fld)
         end if
         call msr(fld_nc2)
         do ic2=1,hdata%nc2
            fld_nc2(ic2,:) = cor_nc2(iv,ic2)%fit_rv
         end do
         call diag_interpolation(hdata,fld_nc2,fld)
         call model_write(nam,geom,filename,trim(varind(iv))//'_fit_rv',fld)
         if (trim(nam%flt_type)/='none') then
            call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
            call diag_interpolation(hdata,fld_nc2,fld)
            call model_write(nam,geom,filename,trim(varind(iv))//'_fit_rv_flt',fld)
         end if
      end do

      select case (trim(nam%method))
      case ('loc','hyb-avg','hyb-rnd','dual-ens')
         ! Open file
         filename = trim(nam%prefix)//'_local_diag_loc.nc'
         call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
         call namncwrite(nam,ncid)
         call ncerr(subr,nf90_close(ncid))

         do iv=1,nam%nvp
            call msr(fld_nc2)
            do ic2=1,hdata%nc2
               fld_nc2(ic2,:) = loc_nc2(iv,ic2)%fit_rh
            end do
            call diag_filter(hdata,'median',nam%diag_rhflt,fld_nc2)
            call diag_interpolation(hdata,fld_nc2,fld)
            call model_write(nam,geom,filename,trim(varind(iv))//'_fit_rh',fld)
            if (trim(nam%flt_type)/='none') then
               call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
               call diag_interpolation(hdata,fld_nc2,fld)
               call model_write(nam,geom,filename,trim(varind(iv))//'_fit_rh_flt',fld)
            end if
            call msr(fld_nc2)
            do ic2=1,hdata%nc2
               fld_nc2(ic2,:) = loc_nc2(iv,ic2)%fit_rv
            end do
            call diag_filter(hdata,'median',nam%diag_rhflt,fld_nc2)
            call diag_interpolation(hdata,fld_nc2,fld)
            call model_write(nam,geom,filename,trim(varind(iv))//'_fit_rv',fld)
            if (trim(nam%flt_type)/='none') then
               call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
               call diag_interpolation(hdata,fld_nc2,fld)
               call model_write(nam,geom,filename,trim(varind(iv))//'_fit_rv_flt',fld)
            end if
         end do
      end select
   end if

   if (nam%nldwh>0) then
      ! Write local diagnostic fields
      filename = trim(nam%prefix)//'_local_diag_ldwh.nc'
      call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
      call namncwrite(nam,ncid)
      call ncerr(subr,nf90_close(ncid))

      ! Write mask
      fld = 0.0
      do il0=1,geom%nl0
         do ic0=1,geom%nc0
            if (geom%mask(ic0,il0)) fld(ic0,il0) = 1.0
         end do
      end do
      call model_write(nam,geom,filename,'mask',fld)

      do ildw=1,nam%nldwh
         ! Level and class
         il0 = nam%il_ldwh(ildw)
         ic = nam%ic_ldwh(ildw)
         write(levchar,'(i3.3)') nam%levs(il0)
         write(icchar,'(i3.3)') ic

         ! Write correlation field
         do iv=1,nam%nvp
            call msr(fld_nc2)
            do ic2=1,hdata%nc2
               fld_nc2(ic2,1) = cor_nc2(iv,ic2)%raw(ic,il0,il0)
            end do
            call diag_interpolation(hdata,il0,fld_nc2(:,1),fld(:,1))
            call model_write(nam,geom,filename,trim(varind(iv))//'_cor_'//levchar//'_'//icchar,fld)
         end do
   
         select case (trim(nam%method))
         case ('loc','hyb-avg','hyb-rnd','dual-ens')
            ! Write localization field
            do iv=1,nam%nvp
               call msr(fld_nc2)
               do ic2=1,hdata%nc2
                  fld_nc2(ic2,1) = loc_nc2(iv,ic2)%raw(ic,il0,il0)
               end do
               call diag_interpolation(hdata,il0,fld_nc2(:,1),fld(:,1))
               call model_write(nam,geom,filename,trim(varind(iv))//'_loc'//'_'//levchar//'_'//icchar,fld)
            end do
         end select
      end do
   end if

   ! Write local diagnostic profiles
   do ildw=1,nam%nldwv
      if (isnotmsi(hdata%nn_ldwv_index(ildw))) then
         ! Write data
         write(lonchar,'(f7.2)') nam%lon_ldwv(ildw)
         write(latchar,'(f7.2)') nam%lat_ldwv(ildw)

         filename = trim(nam%prefix)//'_diag_'//trim(adjustl(lonchar))//'-'//trim(adjustl(latchar))//'.nc'
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
         call curve_write(hdata,ncid,cor_nc2(:,hdata%nn_ldwv_index(ildw)),.true.)
         select case (trim(nam%method))
         case ('loc','hyb-avg','hyb-rnd','dual-ens')
            call curve_write(hdata,ncid,loc_nc2(:,hdata%nn_ldwv_index(ildw)),.true.)
         end select
         call ncerr(subr,nf90_close(ncid))
      else
         call msgwarning('missing local profile')
      end if
   end do
end if

! Release memory
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Release memory'

if (nam%local_diag) then
   deallocate(fld_nc2)
   deallocate(fld)
end if

if (trim(nam%method)=='dual-ens') then
   do iv=1,nam%nvp
      call curve_dealloc(hdata,loc_deh_lr(iv))
      call curve_dealloc(hdata,loc_deh(iv))
      call curve_dealloc(hdata,loc_lr(iv))
   end do
   deallocate(loc_deh_lr)
   deallocate(loc_deh)
   deallocate(loc_lr)

   do iv=1,nam%nvp
      call curve_dealloc(hdata,cor_lr(iv))
   end do
   deallocate(cor_lr)
   call avg_dealloc(hdata,avg_lr)
   call mom_dealloc(hdata,mom_lr)
end if

if (trim(nam%method)=='hyb-rnd') then
   call avg_dealloc(hdata,avg_rnd)
   call mom_dealloc(hdata,mom_rnd)
end if

select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   do iv=1,nam%nvp
      call curve_dealloc(hdata,loc_hyb(iv))
   end do
   deallocate(loc_hyb)
   do iv=1,nam%nvp
      call curve_dealloc(hdata,cor_sta(iv))
   end do
   deallocate(cor_sta)
end select

select case (trim(nam%method))
case ('loc','hyb-avg','hyb-rnd','dual-ens')
   if (nam%local_diag) then
      do iv=1,nam%nvp
         do ic2=1,hdata%nc2
            call curve_dealloc(hdata,loc_nc2(iv,ic2))
         end do
      end do
      deallocate(loc_nc2)
   end if
    do iv=1,nam%nvp
      call curve_dealloc(hdata,loc(iv))
   end do
   deallocate(loc)
end select

if (nam%local_diag) then
   do iv=1,nam%nvp
      do ic2=1,hdata%nc2
         call curve_dealloc(hdata,cor_nc2(iv,ic2))
      end do
   end do
   deallocate(cor_nc2)
end if
do iv=1,nam%nvp
   call curve_dealloc(hdata,cor(iv))
end do
deallocate(cor)
if (nam%local_diag) then
   deallocate(done)
   do ic2=1,hdata%nc2
      call avg_dealloc(hdata,avg_nc2(ic2))
   end do
   deallocate(avg_nc2)
end if
call avg_dealloc(hdata,avg)
call mom_dealloc(hdata,mom)
if (nam%displ_diag) call displ_dealloc(displ)

deallocate(varind)
deallocate(varname)

end subroutine hdiag

end module driver_hdiag
