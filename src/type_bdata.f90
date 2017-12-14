!----------------------------------------------------------------------
! Module: type_bdata
!> Purpose: sample data derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module type_bdata

use model_interface, only: model_write
use module_diag_tools, only: diag_filter,diag_interpolation
use netcdf
use tools_display, only: msgwarning,msgerror,prog_init,prog_print
use tools_kinds, only: kind_real
use tools_missing, only: msvalr,msr,isnotmsr,isallnotmsr,isanynotmsr
use tools_nc, only: ncerr,ncfloat
use type_ctree, only: find_nearest_neighbors
use type_curve, only: curvetype
use type_geom, only: geomtype
use type_hdata, only: hdatatype
use type_mpl, only: mpl,mpl_bcast,mpl_recv,mpl_send,mpl_barrier,mpl_split
use type_nam, only: namtype

implicit none

! B data derived type
type bdatatype
   ! Block name
   character(len=1024) :: cname                 !< Block name

   ! Namelist
   type(namtype),pointer :: nam                 !< Namelist

   ! Geometry
   type(geomtype),pointer :: geom               !< Geometry

   ! Data
   real(kind_real),allocatable :: coef_ens(:,:) !< Ensemble coefficient
   real(kind_real),allocatable :: rh0(:,:)      !< Fit support radius
   real(kind_real),allocatable :: rv0(:,:)      !< Fit support radius
   real(kind_real),allocatable :: coef_sta(:,:) !< Static coefficient
   real(kind_real) :: wgt                       !< Block weight

   ! Transforms
   real(kind_real),allocatable :: trans(:,:)    !< Direct transform
   real(kind_real),allocatable :: transinv(:,:) !< Inverse transform
end type bdatatype

integer :: nflt = 4 !< Number of neighbors for the grid filtering

interface diag_to_bdata
  module procedure diag_to_bdata
  module procedure diag_nc2_to_bdata
end interface

private
public :: bdatatype
public :: bdata_alloc,bdata_dealloc,diag_to_bdata,bdata_read,bdata_write

contains

!----------------------------------------------------------------------
! Subroutine: bdata_alloc
!> Purpose: bdata object allocation
!----------------------------------------------------------------------
subroutine bdata_alloc(bdata,auto_block)

implicit none

! Passed variables
type(bdatatype),intent(inout) :: bdata !< Sampling data
logical,intent(in) :: auto_block       !< Autocovariance block key

! Associate
associate(nam=>bdata%nam,geom=>bdata%geom)

! Allocation
allocate(bdata%coef_ens(geom%nc0,geom%nl0))
allocate(bdata%rh0(geom%nc0,geom%nl0))
allocate(bdata%rv0(geom%nc0,geom%nl0))
allocate(bdata%coef_sta(geom%nc0,geom%nl0))
if (nam%transform.and.auto_block) then
   allocate(bdata%trans(geom%nl0,geom%nl0))
   allocate(bdata%transinv(geom%nl0,geom%nl0))
end if

! Initialization
call msr(bdata%coef_ens)
call msr(bdata%rh0)
call msr(bdata%rv0)
call msr(bdata%coef_sta)
call msr(bdata%wgt)
if (nam%transform.and.auto_block) then
   call msr(bdata%trans)
   call msr(bdata%transinv)
end if

! End associate
end associate

end subroutine bdata_alloc

!----------------------------------------------------------------------
! Subroutine: bdata_dealloc
!> Purpose: bdata object deallocation
!----------------------------------------------------------------------
subroutine bdata_dealloc(bdata,auto_block)

implicit none

! Passed variables
type(bdatatype),intent(inout) :: bdata !< Sampling data
logical,intent(in) :: auto_block       !< Autocovariance block key

! Associate
associate(nam=>bdata%nam)

! Release memory
deallocate(bdata%coef_ens)
deallocate(bdata%rh0)
deallocate(bdata%rv0)
deallocate(bdata%coef_sta)
if (nam%transform.and.auto_block) then
   deallocate(bdata%trans)
   deallocate(bdata%transinv)
end if

! End associate
end associate

end subroutine bdata_dealloc

!----------------------------------------------------------------------
! Subroutine: diag_to_bdata
!> Purpose: copy diagnostics into bdata object
!----------------------------------------------------------------------
subroutine diag_to_bdata(hdata,ib,diag,bdata)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata
integer,intent(in) :: ib
type(curvetype),intent(in) :: diag
type(bdatatype),intent(inout) :: bdata !< Sampling data

! Local variables
integer :: il0

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

if (bpar%nicas_block(ib)) then
   do il0=1,geom%nl0
      bdata%coef_ens(:,il0) = diag%raw_coef_ens(il0)
      bdata%rh0(:,il0) = diag%fit_rh(il0)
      bdata%rv0(:,il0) = diag%fit_rv(il0)
      select case (trim(nam%method))
      case ('cor','loc')
         bdata%coef_sta(:,il0) = 0.0
      case ('hyb-avg','hyb-rnd')
         bdata%coef_sta(:,il0) = diag%raw_coef_sta
      case ('dual-ens')
         call msgerror('dual-ens not ready yet for B data')
      end select
   end do
end if
if (isanynotmsr(diag%raw_coef_ens)) then
   bdata%wgt = sum(diag%raw_coef_ens,mask=isnotmsr(diag%raw_coef_ens))/float(count(isnotmsr(diag%raw_coef_ens)))
else
   call msgerror('missing weight for global B data')
end if

! End associate
end associate

end subroutine diag_to_bdata

!----------------------------------------------------------------------
! Subroutine: diag_nc2_to_bdata
!> Purpose: copy local diagnostics into bdata object
!----------------------------------------------------------------------
subroutine diag_nc2_to_bdata(hdata,ib,diag,bdata)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata           !< HDIAG data
integer,intent(in) :: ib                      !< Block index
type(curvetype),intent(in) :: diag(hdata%nc2) !< Diagnostic curves
type(bdatatype),intent(inout) :: bdata        !< B data

! Local variables
integer :: i,ic2,il0,il0i,ic0
integer :: iproc,ic0_s(mpl%nproc),ic0_e(mpl%nproc),nc0_loc(mpl%nproc),ic0_loc,progint
integer,allocatable :: buf(:),nn_index(:,:,:)
real(kind_real) :: dum(nflt)
real(kind_real),allocatable :: fld_nc2(:,:,:)
real(kind_real),allocatable :: fld(:,:,:),fld_tmp(:,:,:)
logical,allocatable :: done(:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

if (bpar%nicas_block(ib)) then
   ! Allocation
   allocate(fld_nc2(hdata%nc2,hdata%geom%nl0,4))
   allocate(fld(geom%nc0,geom%nl0,4))
   allocate(fld_tmp(geom%nc0,geom%nl0,4))
   allocate(buf(nflt*geom%nc0))
   allocate(nn_index(nflt,geom%nc0,geom%nl0i))

   ! Copy data
   do ic2=1,hdata%nc2
      fld_nc2(ic2,:,1) = diag(ic2)%raw_coef_ens
      fld_nc2(ic2,:,2) = diag(ic2)%fit_rh
      fld_nc2(ic2,:,3) = diag(ic2)%fit_rv
      select case (trim(nam%method))
      case ('cor','loc')
         fld_nc2(ic2,:,4) = 0.0
      case ('hyb-avg','hyb-rnd')
         fld_nc2(ic2,:,4) = diag(ic2)%raw_coef_sta
      case ('dual-ens')
         call msgerror('dual-ens not ready yet for B data')
      end select
   end do
   if (isanynotmsr(fld_nc2(:,:,1))) then
      bdata%wgt = sum(fld_nc2(:,:,1),mask=isnotmsr(fld_nc2(:,:,1)))/float(count(isnotmsr(fld_nc2(:,:,1))))
   else
     call msgerror('missing weight for local B data')
   end if

   do i=1,4
      ! Median filter
      call diag_filter(hdata,'median',nam%diag_rhflt,fld_nc2(:,:,i))

      ! Interpolate
      call diag_interpolation(hdata,fld_nc2(:,:,i),fld(:,:,i))
   end do

   ! MPI splitting
   call mpl_split(geom%nc0,ic0_s,ic0_e,nc0_loc)

   ! Allocation
   allocate(done(nc0_loc(mpl%myproc)))

   ! Find neighbors
   do il0i=1,geom%nl0i
      write(mpl%unit,'(a7,a,i3,a)',advance='no') '','Independent level ',il0i,':'
      call prog_init(progint,done)

      do ic0_loc=1,nc0_loc(mpl%myproc)
         ! MPI offset
         ic0 = ic0_s(mpl%myproc)+ic0_loc-1

         ! Find nearest neighbors
         call find_nearest_neighbors(geom%ctree(il0i),geom%lon(ic0),geom%lat(ic0),nflt,buf((ic0-1)*nflt+1:ic0*nflt),dum)

         ! Print progression
         done(ic0_loc) = .true.
         call prog_print(progint,done)
      end do

      ! Communication
      if (mpl%main) then
         do iproc=1,mpl%nproc
            if (iproc/=mpl%ioproc) then
               ! Receive data on ioproc
               call mpl_recv(nc0_loc(iproc)*nflt,buf((ic0_s(iproc)-1)*nflt+1:ic0_e(iproc)*nflt),iproc,mpl%tag)
            end if
         end do
      else
         ! Send data to ioproc
         call mpl_send(nc0_loc(mpl%myproc)*nflt,buf((ic0_s(mpl%myproc)-1)*nflt+1:ic0_e(mpl%myproc)*nflt),mpl%ioproc,mpl%tag)
      end if
      mpl%tag = mpl%tag+1

      ! Broadcast
      call mpl_bcast(buf,mpl%ioproc)

      ! Format data
      do ic0=1,geom%nc0
         nn_index(:,ic0,il0i) = buf((ic0-1)*nflt+1:ic0*nflt)
      end do
   end do

   ! Average over neighbors
   do il0=1,geom%nl0
      il0i = min(il0,geom%nl0i)
      do ic0=1,geom%nc0
         do i=1,4
            if (isanynotmsr(fld(nn_index(:,ic0,il0i),il0,i))) then
               fld_tmp(ic0,il0,i) = sum(fld(nn_index(:,ic0,il0i),il0,i),mask=isnotmsr(fld(nn_index(:,ic0,il0i),il0,i))) &
                                  & /float(count(isnotmsr(fld(nn_index(:,ic0,il0i),il0,i))))
            else
               write(mpl%unit,*) il0,i,ic0,fld(nn_index(:,ic0,il0i),il0,i)
               call msgerror('missing value for local B data')
            end if
         end do
      end do
   end do

   ! Copy data
   bdata%coef_ens = fld_tmp(:,:,1)
   bdata%rh0 = fld_tmp(:,:,2)
   bdata%rv0 = fld_tmp(:,:,3)
   bdata%coef_sta = fld_tmp(:,:,4)
else
   ! Allocation
   allocate(fld_nc2(hdata%nc2,hdata%geom%nl0,1))

   ! Copy data
   do ic2=1,hdata%nc2
      fld_nc2(ic2,:,1) = diag(ic2)%raw_coef_ens
   end do
   if (isanynotmsr(fld_nc2(:,:,1))) then
      bdata%wgt = sum(fld_nc2(:,:,1),mask=isnotmsr(fld_nc2(:,:,1)))/float(count(isnotmsr(fld_nc2(:,:,1))))
   else
     call msgerror('missing weight for local B data')
   end if
end if

! End associate
end associate

end subroutine diag_nc2_to_bdata

!----------------------------------------------------------------------
! Subroutine: bdata_read
!> Purpose: read bdata object
!----------------------------------------------------------------------
subroutine bdata_read(bdata,auto_block,nicas_block)

implicit none

! Passed variables
type(bdatatype),intent(inout) :: bdata !< B data
logical,intent(in) :: auto_block       !< Autocovariance block key
logical,intent(in) :: nicas_block      !< NICAS block key

! Local variables
integer :: nc0_test,nl0_test,il0
integer :: info,ncid,nc0_id,nl0_id
integer :: coef_ens_id,rh0_id,rv0_id,coef_sta_id,trans_id,transinv_id
character(len=1024) :: subr = 'bdata_read'

! Associate
associate(nam=>bdata%nam,geom=>bdata%geom)

! Open file
info = nf90_open(trim(nam%datadir)//'/'//trim(nam%prefix)//'_'//trim(bdata%cname)//'.nc',nf90_nowrite,ncid)
if (info==nf90_noerr) then
   if (nicas_block) then
      ! Check dimensions
      call ncerr(subr,nf90_inq_dimid(ncid,'nc0',nc0_id))
      call ncerr(subr,nf90_inquire_dimension(ncid,nc0_id,len=nc0_test))
      call ncerr(subr,nf90_inq_dimid(ncid,'nl0',nl0_id))
      call ncerr(subr,nf90_inquire_dimension(ncid,nl0_id,len=nl0_test))
      if ((geom%nc0/=nc0_test).or.(geom%nl0/=nl0_test)) call msgerror('wrong dimension when reading B')

      ! Get arrays ID
      call ncerr(subr,nf90_inq_varid(ncid,'coef_ens',coef_ens_id))
      call ncerr(subr,nf90_inq_varid(ncid,'rh0',rh0_id))
      call ncerr(subr,nf90_inq_varid(ncid,'rv0',rv0_id))
      call ncerr(subr,nf90_inq_varid(ncid,'coef_sta',coef_sta_id))
      if (nam%transform.and.auto_block) then
         call ncerr(subr,nf90_inq_varid(ncid,'trans',trans_id))
         call ncerr(subr,nf90_inq_varid(ncid,'transinv',transinv_id))
      end if

      ! Read arrays
      call ncerr(subr,nf90_get_var(ncid,coef_ens_id,bdata%coef_ens))
      call ncerr(subr,nf90_get_var(ncid,rh0_id,bdata%rh0))
      call ncerr(subr,nf90_get_var(ncid,rv0_id,bdata%rv0))
      call ncerr(subr,nf90_get_var(ncid,coef_sta_id,bdata%coef_sta))
      if (nam%transform.and.auto_block) then
         call ncerr(subr,nf90_get_var(ncid,trans_id,bdata%trans))
         call ncerr(subr,nf90_get_var(ncid,transinv_id,bdata%transinv))
      end if
   end if

   ! Get main weight
   call ncerr(subr,nf90_get_att(ncid,nf90_global,'wgt',bdata%wgt))

   ! Close file
   call ncerr(subr,nf90_close(ncid))
else
   call msgwarning('cannot find B data to read, use namelist values')
   if (nicas_block) then
      bdata%coef_ens = 1.0
      do il0=1,geom%nl0
         bdata%rh0(:,il0) = nam%rh(il0)
         bdata%rv0(:,il0) = nam%rv(il0)
      end do
      bdata%coef_sta = 0.0
      if (nam%transform.and.auto_block) then
         bdata%trans = 0.0
         do il0=1,geom%nl0
            bdata%trans(il0,il0) = 1.0
         end do
         bdata%transinv = bdata%trans
      end if
   end if
   bdata%wgt = 1.0
end if

! Check
if (any((bdata%rh0<0.0).and.isnotmsr(bdata%rh0))) call msgerror('rh0 should be positive')
if (any((bdata%rv0<0.0).and.isnotmsr(bdata%rv0))) call msgerror('rv0 should be positive')

! End associate
end associate

end subroutine bdata_read

!----------------------------------------------------------------------
! Subroutine: bdata_write
!> Purpose: write bdata object
!----------------------------------------------------------------------
subroutine bdata_write(bdata,auto_block,nicas_block)

implicit none

! Passed variables
type(bdatatype),intent(in) :: bdata !< B data
logical,intent(in) :: auto_block    !< Autocovariance block key
logical,intent(in) :: nicas_block   !< NICAS block key

! Local variables
integer :: ncid,nc0_id,nl0_1_id,nl0_2_id
integer :: coef_ens_id,rh0_id,rv0_id,coef_sta_id,trans_id,transinv_id
character(len=1024) :: subr = 'bdata_write'

! Associate
associate(nam=>bdata%nam,geom=>bdata%geom)

! Processor verification
if (.not.mpl%main) call msgerror('only I/O proc should enter '//trim(subr))

! Create file
call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(nam%prefix)//'_'//trim(bdata%cname)//'.nc', &
 & or(nf90_clobber,nf90_64bit_offset),ncid))

if (nicas_block) then
   ! Define dimensions
   call ncerr(subr,nf90_def_dim(ncid,'nc0',geom%nc0,nc0_id))
   call ncerr(subr,nf90_def_dim(ncid,'nl0_1',geom%nl0,nl0_1_id))
   if (nam%transform.and.auto_block) call ncerr(subr,nf90_def_dim(ncid,'nl0_2',geom%nl0,nl0_2_id))

   ! Define arrays
   call ncerr(subr,nf90_def_var(ncid,'coef_ens',ncfloat,(/nc0_id,nl0_1_id/),coef_ens_id))
   call ncerr(subr,nf90_put_att(ncid,coef_ens_id,'_FillValue',msvalr))
   call ncerr(subr,nf90_def_var(ncid,'rh0',ncfloat,(/nc0_id,nl0_1_id/),rh0_id))
   call ncerr(subr,nf90_put_att(ncid,rh0_id,'_FillValue',msvalr))
   call ncerr(subr,nf90_def_var(ncid,'rv0',ncfloat,(/nc0_id,nl0_1_id/),rv0_id))
   call ncerr(subr,nf90_put_att(ncid,rv0_id,'_FillValue',msvalr))
   call ncerr(subr,nf90_def_var(ncid,'coef_sta',ncfloat,(/nc0_id,nl0_1_id/),coef_sta_id))
   call ncerr(subr,nf90_put_att(ncid,coef_sta_id,'_FillValue',msvalr))
   if (nam%transform.and.auto_block) then
      call ncerr(subr,nf90_def_var(ncid,'trans',ncfloat,(/nl0_1_id,nl0_2_id/),trans_id))
      call ncerr(subr,nf90_put_att(ncid,trans_id,'_FillValue',msvalr))
      call ncerr(subr,nf90_def_var(ncid,'transinv',ncfloat,(/nl0_1_id,nl0_2_id/),transinv_id))
      call ncerr(subr,nf90_put_att(ncid,transinv_id,'_FillValue',msvalr))
   end if
end if

! Write main weight
call ncerr(subr,nf90_put_att(ncid,nf90_global,'wgt',bdata%wgt))

! End definition mode
call ncerr(subr,nf90_enddef(ncid))

! Write arrays
if (nicas_block) then
   call ncerr(subr,nf90_put_var(ncid,coef_ens_id,bdata%coef_ens))
   call ncerr(subr,nf90_put_var(ncid,rh0_id,bdata%rh0))
   call ncerr(subr,nf90_put_var(ncid,rv0_id,bdata%rv0))
   call ncerr(subr,nf90_put_var(ncid,coef_sta_id,bdata%coef_sta))
   if (nam%transform.and.auto_block) then
      call ncerr(subr,nf90_put_var(ncid,trans_id,bdata%trans))
      call ncerr(subr,nf90_put_var(ncid,transinv_id,bdata%transinv))
   end if
end if

! Close file
call ncerr(subr,nf90_close(ncid))

! Write gridded data (for visualisation)
if (nicas_block) then
   call model_write(nam,geom,trim(nam%prefix)//'_gridded_'//trim(bdata%cname)//'.nc','coef_ens',bdata%coef_ens)
   call model_write(nam,geom,trim(nam%prefix)//'_gridded_'//trim(bdata%cname)//'.nc','rh0',bdata%rh0)
   call model_write(nam,geom,trim(nam%prefix)//'_gridded_'//trim(bdata%cname)//'.nc','rv0',bdata%rv0)
   call model_write(nam,geom,trim(nam%prefix)//'_gridded_'//trim(bdata%cname)//'.nc','coef_sta',bdata%coef_sta)
end if

! End associate
end associate

end subroutine bdata_write

end module type_bdata
