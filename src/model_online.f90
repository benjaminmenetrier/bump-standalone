!----------------------------------------------------------------------
! Module: model_online.f90
!> Purpose: model routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module model_online

use netcdf
use tools_const, only: rad2deg,req
use tools_kinds,only: kind_real
use tools_missing, only: msvalr,msi,isnotmsi,isanynotmsr
use tools_nc, only: ncfloat,ncerr
use type_com, only: com_type
use type_geom, only: geom_type
use type_mpl, only: mpl

implicit none

private
public :: model_online_coord,model_online_from_file,model_online_to_file,model_online_write

contains

!----------------------------------------------------------------------
! Subroutine: model_online_coord
!> Purpose: read online coordinates
!----------------------------------------------------------------------
subroutine model_online_coord(geom,lon,lat,area,vunit,lmask)

implicit none

! Passed variables
type(geom_type),intent(inout) :: geom          !< Geometry
real(kind_real),intent(in) :: lon(geom%nga)    !< Longitudes
real(kind_real),intent(in) :: lat(geom%nga)    !< Latitudes
real(kind_real),intent(in) :: area(geom%nga)   !< Area
real(kind_real),intent(in) :: vunit(geom%nl0)  !< Vertical unit
logical,intent(in) :: lmask(geom%nga,geom%nl0) !< Mask

! Local variables
integer :: ic0,ic0a,il0,offset,iproc,ig,iga,nc0a,nga
integer,allocatable :: c0a_to_c0(:),ga_to_g(:),c0a_to_ga(:)
real(kind_real),allocatable :: lon_g(:),lat_g(:),area_g(:)
logical,allocatable :: lmask_g(:,:)
type(com_type) :: com_g(mpl%nproc)

! Allocation
allocate(geom%proc_to_nga(mpl%nproc))

! Communication
call mpl%allgather(1,(/geom%nga/),geom%proc_to_nga)

! Global number of gridpoints
geom%ng = sum(geom%proc_to_nga)

! Allocation
allocate(lon_g(geom%ng))
allocate(lat_g(geom%ng))
allocate(area_g(geom%ng))
allocate(lmask_g(geom%ng,geom%nl0))
allocate(geom%g_to_proc(geom%ng))
allocate(geom%g_to_ga(geom%ng))
allocate(geom%ga_to_g(geom%nga))

! Communication and reordering of gridpoints
if (mpl%main) then
   ! Allocation
   offset = 0
   do iproc=1,mpl%nproc
      if (iproc==mpl%ioproc) then
         ! Copy data
         lon_g(offset+1:offset+geom%proc_to_nga(iproc)) = lon
         lat_g(offset+1:offset+geom%proc_to_nga(iproc)) = lat
         area_g(offset+1:offset+geom%proc_to_nga(iproc)) = area
         do il0=1,geom%nl0
            lmask_g(offset+1:offset+geom%proc_to_nga(iproc),il0) = lmask(:,il0)
         end do
      else
         ! Receive data on ioproc
         call mpl%recv(geom%proc_to_nga(iproc),lon_g(offset+1:offset+geom%proc_to_nga(iproc)),iproc,mpl%tag)
         call mpl%recv(geom%proc_to_nga(iproc),lat_g(offset+1:offset+geom%proc_to_nga(iproc)),iproc,mpl%tag+1)
         call mpl%recv(geom%proc_to_nga(iproc),area_g(offset+1:offset+geom%proc_to_nga(iproc)),iproc,mpl%tag+2)
         do il0=1,geom%nl0
            call mpl%recv(geom%proc_to_nga(iproc),lmask_g(offset+1:offset+geom%proc_to_nga(iproc),il0),iproc,mpl%tag+2+il0)
         end do
      end if

      !  Update offset
      offset = offset+geom%proc_to_nga(iproc)
   end do
else
   ! Send data to ioproc
   call mpl%send(geom%nga,lon,mpl%ioproc,mpl%tag)
   call mpl%send(geom%nga,lat,mpl%ioproc,mpl%tag+1)
   call mpl%send(geom%nga,area,mpl%ioproc,mpl%tag+2)
   do il0=1,geom%nl0
      call mpl%send(geom%nga,lmask(:,il0),mpl%ioproc,mpl%tag+2+il0)
   end do
end if
mpl%tag = mpl%tag+3+geom%nl0

! Broadcast data
call mpl%bcast(lon_g,mpl%ioproc)
call mpl%bcast(lat_g,mpl%ioproc)
call mpl%bcast(area_g,mpl%ioproc)
call mpl%bcast(lmask_g,mpl%ioproc)

! Find redundant points
call geom%find_redundant(lon_g,lat_g)

! Allocation
call geom%alloc
allocate(geom%proc_to_nc0a(mpl%nproc))
allocate(geom%c0_to_proc(geom%nc0))
allocate(geom%c0_to_c0a(geom%nc0))

! Gridpoints conversions and Sc0 size on halo A
ig = 0
geom%proc_to_nc0a = 0
do iproc=1,mpl%nproc
   do iga=1,geom%proc_to_nga(iproc)
      ig = ig+1
      geom%g_to_proc(ig) = iproc
      geom%g_to_ga(ig) = iga
      geom%ga_to_g(iga) = ig
      if (.not.isnotmsi(geom%redundant(ig))) geom%proc_to_nc0a(iproc) = geom%proc_to_nc0a(iproc)+1
   end do
end do
geom%nc0a = geom%proc_to_nc0a(mpl%myproc)

! Subset Sc0 conversions
allocate(geom%c0a_to_c0(geom%nc0a))
ic0 = 0
do iproc=1,mpl%nproc
   do ic0a=1,geom%proc_to_nc0a(iproc)
      ic0 = ic0+1
      geom%c0_to_proc(ic0) = iproc
      geom%c0_to_c0a(ic0) = ic0a
      if (iproc==mpl%myproc) geom%c0a_to_c0(ic0a) = ic0
   end do
end do

! Inter-halo conversions
allocate(geom%c0a_to_ga(geom%nc0a))
do ic0a=1,geom%nc0a
   ic0 = geom%c0a_to_c0(ic0a)
   ig = geom%c0_to_g(ic0)
   iga = geom%g_to_ga(ig)
   geom%c0a_to_ga(ic0a) = iga
end do

! Get global distribution of the subgrid on ioproc
if (mpl%main) then
   do iproc=1,mpl%nproc
      if (iproc==mpl%ioproc) then
         ! Copy dimension
         nc0a = geom%nc0a
      else
         ! Receive dimension on ioproc
         call mpl%recv(nc0a,iproc,mpl%tag)
      end if

      ! Allocation
      allocate(c0a_to_c0(nc0a))

      if (iproc==mpl%ioproc) then
         ! Copy data
         c0a_to_c0 = geom%c0a_to_c0
      else
         ! Receive data on ioproc
         call mpl%recv(nc0a,c0a_to_c0,iproc,mpl%tag+1)
      end if

      ! Fill c0_to_c0a
      do ic0a=1,nc0a
         geom%c0_to_c0a(c0a_to_c0(ic0a)) = ic0a
      end do

      ! Release memory
      deallocate(c0a_to_c0)
   end do
else
   ! Send dimensions to ioproc
   call mpl%send(geom%nc0a,mpl%ioproc,mpl%tag)

   ! Send data to ioproc
   call mpl%send(geom%nc0a,geom%c0a_to_c0,mpl%ioproc,mpl%tag+1)
end if
mpl%tag = mpl%tag+2

! Setup communications
if (mpl%main) then
   do iproc=1,mpl%nproc
      ! Communicate dimensions
      if (iproc==mpl%ioproc) then
         ! Copy dimensions
         nc0a = geom%nc0a
         nga = geom%nga
      else
         ! Receive dimensions on ioproc
         call mpl%recv(nc0a,iproc,mpl%tag)
         call mpl%recv(nga,iproc,mpl%tag+1)
      end if

      ! Allocation
      allocate(ga_to_g(nga))
      allocate(c0a_to_ga(nc0a))

      ! Communicate data
      if (iproc==mpl%ioproc) then
         ! Copy data
         ga_to_g = geom%ga_to_g
         c0a_to_ga = geom%c0a_to_ga
      else
         ! Receive data on ioproc
         call mpl%recv(nga,ga_to_g,iproc,mpl%tag+2)
         call mpl%recv(nc0a,c0a_to_ga,iproc,mpl%tag+3)
      end if

      ! Allocation
      com_g(iproc)%nred = nc0a
      com_g(iproc)%next = nga
      allocate(com_g(iproc)%ext_to_proc(com_g(iproc)%next))
      allocate(com_g(iproc)%ext_to_red(com_g(iproc)%next))
      allocate(com_g(iproc)%red_to_ext(com_g(iproc)%nred))

      ! Communication
      do iga=1,nga
         ig = ga_to_g(iga)
         ic0 = geom%g_to_c0(ig)
         com_g(iproc)%ext_to_proc(iga) = geom%c0_to_proc(ic0)
         ic0a = geom%c0_to_c0a(ic0)
         com_g(iproc)%ext_to_red(iga) = ic0a
      end do
      com_g(iproc)%red_to_ext = c0a_to_ga

      ! Release memory
      deallocate(ga_to_g)
      deallocate(c0a_to_ga)
   end do
else
   ! Send dimensions to ioproc
   call mpl%send(geom%nc0a,mpl%ioproc,mpl%tag)
   call mpl%send(geom%nga,mpl%ioproc,mpl%tag+1)

   ! Send data to ioproc
   call mpl%send(geom%nga,geom%ga_to_g,mpl%ioproc,mpl%tag+2)
   call mpl%send(geom%nc0a,geom%c0a_to_ga,mpl%ioproc,mpl%tag+3)
end if
mpl%tag = mpl%tag+4
call geom%com_g%setup(com_g,'com_g')

! Print summary
write(mpl%unit,'(a7,a)') '','Distribution summary:'
do iproc=1,mpl%nproc
   write(mpl%unit,'(a10,a,i3,a,i8,a)') '','Proc #',iproc,': ',geom%proc_to_nc0a(iproc),' grid-points'
end do
write(mpl%unit,'(a10,a,i8,a)') '','Total: ',geom%nc0,' grid-points'
call flush(mpl%unit)

! Deal with mask on redundant points
do il0=1,geom%nl0
   do ig=1,geom%ng
      if (isnotmsi(geom%redundant(ig))) lmask_g(ig,il0) = lmask_g(ig,il0).or.lmask_g(geom%redundant(ig),il0)
   end do
end do

! Remove redundant points
geom%lon = lon_g(geom%c0_to_g)
geom%lat = lat_g(geom%c0_to_g)
do il0=1,geom%nl0
   geom%mask(:,il0) = lmask_g(geom%c0_to_g,il0)
   geom%area(il0) = sum(area_g(geom%c0_to_g),geom%mask(:,il0))/req**2
end do

! Vertical unit
geom%vunit = vunit

end subroutine model_online_coord

!----------------------------------------------------------------------
! Subroutine: model_online_from_file
!> Purpose: read online data from file (for tests)
!----------------------------------------------------------------------
subroutine model_online_from_file(prefix,nga,nl0,nv,nts,lon,lat,area,vunit,lmask,ens1,rh0,rv0,lonobs,latobs)

implicit none

! Passed variables
character(len=*),intent(in) :: prefix                               !< Prefix
integer,intent(out) :: nga                                          !< Halo A size
integer,intent(out) :: nl0                                          !< Number of levels in subset Sl0
integer,intent(out) :: nv                                           !< Number of variables
integer,intent(out) :: nts                                          !< Number of time slots
real(kind_real),allocatable,intent(out) :: lon(:)                   !< Longitude
real(kind_real),allocatable,intent(out) :: lat(:)                   !< Latitude
real(kind_real),allocatable,intent(out) :: area(:)                  !< Area
real(kind_real),allocatable,intent(out) :: vunit(:)                 !< Vertical unit
logical,allocatable,intent(out) :: lmask(:,:)                       !< Mask
real(kind_real),allocatable,intent(out),optional :: ens1(:,:,:,:,:) !< Ensemble 1
real(kind_real),allocatable,intent(out),optional :: rh0(:,:,:,:)    !< Horizontal support radius for covariance
real(kind_real),allocatable,intent(out),optional :: rv0(:,:,:,:)    !< Vertical support radius for covariance
real(kind_real),allocatable,intent(out),optional :: lonobs(:)       !< Observations longitudes
real(kind_real),allocatable,intent(out),optional :: latobs(:)       !< Observations latitudes

! Local variables
integer :: iga,il0,info,info1,info2,ens1_ne,nobs
integer :: ncid,nga_id,nl0_id,nv_id,nts_id,lon_id,lat_id,area_id,vunit_id,imask_id
integer :: ens1_ne_id,ens1_id,rh0_id,rv0_id,nobs_id,lonobs_id,latobs_id
integer,allocatable :: imask(:,:)
character(len=1024) :: filename
character(len=1024) :: subr = 'model_online_from_file'

! Build file name
write(filename,'(a,a,i4.4,a,i4.4,a)') trim(prefix),'_',mpl%nproc,'-',mpl%myproc,'.nc'

! Open file and get dimensions
call ncerr(subr,nf90_open(trim(filename),nf90_nowrite,ncid))
call ncerr(subr,nf90_inq_dimid(ncid,'nga',nga_id))
call ncerr(subr,nf90_inq_dimid(ncid,'nl0',nl0_id))
call ncerr(subr,nf90_inq_dimid(ncid,'nv',nv_id))
call ncerr(subr,nf90_inq_dimid(ncid,'nts',nts_id))
call ncerr(subr,nf90_inquire_dimension(ncid,nga_id,len=nga))
call ncerr(subr,nf90_inquire_dimension(ncid,nl0_id,len=nl0))
call ncerr(subr,nf90_inquire_dimension(ncid,nv_id,len=nv))
call ncerr(subr,nf90_inquire_dimension(ncid,nts_id,len=nts))

! Allocation
allocate(lon(nga))
allocate(lat(nga))
allocate(area(nga))
allocate(vunit(nl0))
allocate(imask(nga,nl0))
allocate(lmask(nga,nl0))

! Get variables ID
call ncerr(subr,nf90_inq_varid(ncid,'lon',lon_id))
call ncerr(subr,nf90_inq_varid(ncid,'lat',lat_id))
call ncerr(subr,nf90_inq_varid(ncid,'area',area_id))
call ncerr(subr,nf90_inq_varid(ncid,'vunit',vunit_id))
call ncerr(subr,nf90_inq_varid(ncid,'imask',imask_id))

! Get data
call ncerr(subr,nf90_get_var(ncid,lon_id,lon))
call ncerr(subr,nf90_get_var(ncid,lat_id,lat))
call ncerr(subr,nf90_get_var(ncid,area_id,area))
call ncerr(subr,nf90_get_var(ncid,vunit_id,vunit))
call ncerr(subr,nf90_get_var(ncid,imask_id,imask))

! Transform logical to integer
do il0=1,nl0
   do iga=1,nga
      if (imask(iga,il0)==1) then
         lmask(iga,il0) = .true.
      else
         lmask(iga,il0) = .false.
      end if
   end do
end do

! Optional variables
info = nf90_inq_varid(ncid,'ens1',ens1_id)
if (info==nf90_noerr) then
   ! Get dimension
   call ncerr(subr,nf90_inq_dimid(ncid,'ens1_ne',ens1_ne_id))
   call ncerr(subr,nf90_inquire_dimension(ncid,ens1_ne_id,len=ens1_ne))

   ! Allocate
   allocate(ens1(nga,nl0,nv,nts,ens1_ne))

   ! Get data
   call ncerr(subr,nf90_get_var(ncid,ens1_id,ens1))
end if
info1 = nf90_inq_varid(ncid,'rh0',rh0_id)
info2 = nf90_inq_varid(ncid,'rv0',rv0_id)
if ((info1==nf90_noerr).and.(info2==nf90_noerr)) then
   ! Allocate
   allocate(rh0(nga,nl0,nv,nts))
   allocate(rv0(nga,nl0,nv,nts))

   ! Get data
   call ncerr(subr,nf90_get_var(ncid,rh0_id,rh0))
   call ncerr(subr,nf90_get_var(ncid,rv0_id,rv0))
end if
info1 = nf90_inq_varid(ncid,'lonobs',lonobs_id)
info2 = nf90_inq_varid(ncid,'latobs',latobs_id)
if ((info1==nf90_noerr).and.(info2==nf90_noerr)) then
   ! Get dimension
   call ncerr(subr,nf90_inq_dimid(ncid,'nobs',nobs_id))
   call ncerr(subr,nf90_inquire_dimension(ncid,nobs_id,len=nobs))

   ! Allocation
   allocate(lonobs(nobs))
   allocate(latobs(nobs))

   ! Get data
   call ncerr(subr,nf90_get_var(ncid,lonobs_id,lonobs))
   call ncerr(subr,nf90_get_var(ncid,latobs_id,latobs))
end if

! Close file
call ncerr(subr,nf90_close(ncid))

end subroutine model_online_from_file

!----------------------------------------------------------------------
! Subroutine: model_online_to_file
!> Purpose: write online data to file (for tests)
!----------------------------------------------------------------------
subroutine model_online_to_file(prefix,nga,nl0,nv,nts,lon,lat,area,vunit,lmask,ens1,rh0,rv0,lonobs,latobs)

implicit none

! Passed variables
character(len=*),intent(in) :: prefix                  !< Prefix
integer,intent(in) :: nga                              !< Halo A size
integer,intent(in) :: nl0                              !< Number of levels in subset Sl0
integer,intent(in) :: nv                               !< Number of variables
integer,intent(in) :: nts                              !< Number of time slots
real(kind_real),intent(in) :: lon(nga)                 !< Longitude
real(kind_real),intent(in) :: lat(nga)                 !< Latitude
real(kind_real),intent(in) :: area(nga)                !< Area
real(kind_real),intent(in) :: vunit(nl0)               !< Vertical unit
logical,intent(in) :: lmask(nga,nl0)                   !< Mask
real(kind_real),intent(in),optional :: ens1(:,:,:,:,:) !< Ensemble 1
real(kind_real),intent(in),optional :: rh0(:,:,:,:)    !< Horizontal support radius for covariance
real(kind_real),intent(in),optional :: rv0(:,:,:,:)    !< Vertical support radius for covariance
real(kind_real),intent(in),optional :: lonobs(:)       !< Observations longitudes
real(kind_real),intent(in),optional :: latobs(:)       !< Observations latitudes

! Local variables
integer :: iga,il0
integer :: ncid,nga_id,nl0_id,nv_id,nts_id,lon_id,lat_id,area_id,vunit_id,imask_id
integer :: ens1_ne_id,ens1_id,rh0_id,rv0_id,nobs_id,lonobs_id,latobs_id
integer :: imask(nga,nl0)
character(len=1024) :: filename
character(len=1024) :: subr = 'model_online_to_file'

! Build file name
write(filename,'(a,a,i4.4,a,i4.4,a)') trim(prefix),'_',mpl%nproc,'-',mpl%myproc,'.nc'

! Create file
call ncerr(subr,nf90_create(trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))

! Define dimensions
call ncerr(subr,nf90_def_dim(ncid,'nga',nga,nga_id))
call ncerr(subr,nf90_def_dim(ncid,'nl0',nl0,nl0_id))
call ncerr(subr,nf90_def_dim(ncid,'nv',nv,nv_id))
call ncerr(subr,nf90_def_dim(ncid,'nts',nts,nts_id))
if (present(ens1)) call ncerr(subr,nf90_def_dim(ncid,'ens1_ne',size(ens1,5),ens1_ne_id))
if (present(lonobs).and.present(latobs)) call ncerr(subr,nf90_def_dim(ncid,'nobs',size(lonobs,1),nobs_id))

! Define variables
call ncerr(subr,nf90_def_var(ncid,'lon',ncfloat,(/nga_id/),lon_id))
call ncerr(subr,nf90_def_var(ncid,'lat',ncfloat,(/nga_id/),lat_id))
call ncerr(subr,nf90_def_var(ncid,'area',ncfloat,(/nga_id/),area_id))
call ncerr(subr,nf90_def_var(ncid,'vunit',ncfloat,(/nl0_id/),vunit_id))
call ncerr(subr,nf90_def_var(ncid,'imask',nf90_int,(/nga_id,nl0_id/),imask_id))
if (present(ens1)) call ncerr(subr,nf90_def_var(ncid,'ens1',ncfloat,(/nga_id,nl0_id,nv_id,nts_id,ens1_ne_id/),ens1_id))
if (present(rh0).and.present(rv0)) then
   call ncerr(subr,nf90_def_var(ncid,'rh0',ncfloat,(/nga_id,nl0_id,nv_id,nts_id/),rh0_id))
   call ncerr(subr,nf90_def_var(ncid,'rv0',ncfloat,(/nga_id,nl0_id,nv_id,nts_id/),rv0_id))
end if
if (present(lonobs).and.present(latobs)) then
   call ncerr(subr,nf90_def_var(ncid,'lonobs',ncfloat,(/nga_id,nl0_id,nv_id,nts_id/),lonobs_id))
   call ncerr(subr,nf90_def_var(ncid,'latobs',ncfloat,(/nga_id,nl0_id,nv_id,nts_id/),latobs_id))
end if

! End definition mode
call ncerr(subr,nf90_enddef(ncid))

! Transform logical to integer
do il0=1,nl0
   do iga=1,nga
      if (lmask(iga,il0)) then
         imask(iga,il0) = 1
      else
         imask(iga,il0) = 0
      end if
   end do
end do

! Write variables
call ncerr(subr,nf90_put_var(ncid,lon_id,lon))
call ncerr(subr,nf90_put_var(ncid,lat_id,lat))
call ncerr(subr,nf90_put_var(ncid,area_id,area))
call ncerr(subr,nf90_put_var(ncid,vunit_id,vunit))
call ncerr(subr,nf90_put_var(ncid,imask_id,imask))
if (present(ens1)) call ncerr(subr,nf90_put_var(ncid,ens1_id,ens1))
if (present(rh0).and.present(rv0)) then
   call ncerr(subr,nf90_put_var(ncid,rh0_id,rh0))
   call ncerr(subr,nf90_put_var(ncid,rv0_id,rv0))
end if
if (present(lonobs).and.present(latobs)) then
   call ncerr(subr,nf90_put_var(ncid,lonobs_id,lonobs))
   call ncerr(subr,nf90_put_var(ncid,latobs_id,latobs))
end if

! Close file
call ncerr(subr,nf90_close(ncid))

end subroutine model_online_to_file

!----------------------------------------------------------------------
! Subroutine: model_online_write
!> Purpose: write online field
!----------------------------------------------------------------------
subroutine model_online_write(geom,ncid,varname,fld)

implicit none

! Passed variables
type(geom_type),intent(in) :: geom                    !< Geometry
integer,intent(in) :: ncid                            !< NetCDF file ID
character(len=*),intent(in) :: varname                !< Variable name
real(kind_real),intent(in) :: fld(geom%nc0a,geom%nl0) !< Field

! Local variables
integer :: il0,info
integer :: nc0_id,nl0_id,fld_id,lon_id,lat_id
real(kind_real) :: fld_glb(geom%nc0,geom%nl0)
character(len=1024) :: subr = 'model_online_write'

! Local to global
call geom%fld_com_lg(fld,fld_glb)

if (mpl%main) then
   ! Get variable id
   info = nf90_inq_varid(ncid,trim(varname),fld_id)

   ! Define dimensions and variable if necessary
   if (info/=nf90_noerr) then
      call ncerr(subr,nf90_redef(ncid))
      info = nf90_inq_dimid(ncid,'nc0',nc0_id)
      if (info/=nf90_noerr) call ncerr(subr,nf90_def_dim(ncid,'nc0',geom%nc0,nc0_id))
      info = nf90_inq_dimid(ncid,'nl0',nl0_id)
      if (info/=nf90_noerr) call ncerr(subr,nf90_def_dim(ncid,'nl0',geom%nl0,nl0_id))
      call ncerr(subr,nf90_def_var(ncid,trim(varname),ncfloat,(/nl0_id,nc0_id/),fld_id))
      call ncerr(subr,nf90_put_att(ncid,fld_id,'_FillValue',msvalr))
      call ncerr(subr,nf90_enddef(ncid))
   end if

   ! Write data
   do il0=1,geom%nl0
      if (isanynotmsr(fld_glb(:,il0))) then
         call ncerr(subr,nf90_put_var(ncid,fld_id,fld_glb(:,il0),(/il0,1/),(/1,geom%nc0/)))
      end if
   end do

   ! Write coordinates
   info = nf90_inq_varid(ncid,'lon',lon_id)
   if (info/=nf90_noerr) then
      call ncerr(subr,nf90_redef(ncid))
      call ncerr(subr,nf90_def_var(ncid,'lon',ncfloat,(/nc0_id/),lon_id))
      call ncerr(subr,nf90_put_att(ncid,lon_id,'_FillValue',msvalr))
      call ncerr(subr,nf90_put_att(ncid,lon_id,'unit','degrees_north'))
      call ncerr(subr,nf90_def_var(ncid,'lat',ncfloat,(/nc0_id/),lat_id))
      call ncerr(subr,nf90_put_att(ncid,lat_id,'_FillValue',msvalr))
      call ncerr(subr,nf90_put_att(ncid,lat_id,'unit','degrees_east'))
      call ncerr(subr,nf90_enddef(ncid))
      call ncerr(subr,nf90_put_var(ncid,lon_id,geom%lon*rad2deg))
      call ncerr(subr,nf90_put_var(ncid,lat_id,geom%lat*rad2deg))
   end if
end if

end subroutine model_online_write

end module model_online
