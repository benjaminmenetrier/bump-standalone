!----------------------------------------------------------------------
! Module: type_model
! Purpose: model routines
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
module type_model

use netcdf
use tools_const, only: deg2rad,rad2deg,req,ps,pi
use tools_kinds,only: kind_real,nc_kind_real
use type_kdtree, only: kdtree_type
use type_mpl, only: mpl_type
use type_nam, only: nam_type,nvmax
use type_rng, only: rng_type

implicit none


type model_type
   ! Global dimensions
   integer :: nlon                               ! Longitude size
   integer :: nlat                               ! Latitude size
   integer :: nmg                                ! Number of model grid points
   integer :: nlev                               ! Number of levels
   integer :: nl0                                ! Number of levels in subset Sl0

   ! Packing arrays
   integer,allocatable :: mg_to_lon(:)           ! Model grid to longitude index
   integer,allocatable :: mg_to_lat(:)           ! Model grid to latgitude index
   integer,allocatable :: mg_to_tile(:)          ! Model grid to tile index

   ! Coordinates
   real(kind_real),allocatable :: lon(:)
   real(kind_real),allocatable :: lat(:)
   real(kind_real),allocatable :: area(:)
   real(kind_real),allocatable :: vunit(:,:)
   logical,allocatable :: mask(:,:)

   ! Local distribution
   integer :: nmga
   integer,allocatable :: mg_to_proc(:)
   integer,allocatable :: mg_to_mga(:)

   ! Local coordinates
   real(kind_real),allocatable :: lon_mga(:)
   real(kind_real),allocatable :: lat_mga(:)
   real(kind_real),allocatable :: area_mga(:)
   real(kind_real),allocatable :: vunit_mga(:,:)
   logical,allocatable :: mask_mga(:,:)
   logical,allocatable :: smask_mga(:,:)

   ! Ensembles
   integer :: ens1_ne
   integer :: ens1_nsub
   integer :: ens2_ne
   integer :: ens2_nsub
   real(kind_real),allocatable :: ens1(:,:,:,:,:)
   real(kind_real),allocatable :: ens2(:,:,:,:,:)

   ! Observations locations
   integer :: nobsa
   real(kind_real),allocatable :: lonobs(:)
   real(kind_real),allocatable :: latobs(:)
contains
   ! Model specific procedures
   procedure :: aro_coord => model_aro_coord
   procedure :: aro_read => model_aro_read
   procedure :: arp_coord => model_arp_coord
   procedure :: arp_read => model_arp_read
   procedure :: fv3_coord => model_fv3_coord
   procedure :: fv3_read => model_fv3_read
   procedure :: gem_coord => model_gem_coord
   procedure :: gem_read => model_gem_read
   procedure :: geos_coord => model_geos_coord
   procedure :: geos_read => model_geos_read
   procedure :: gfs_coord => model_gfs_coord
   procedure :: gfs_read => model_gfs_read
   procedure :: ifs_coord => model_ifs_coord
   procedure :: ifs_read => model_ifs_read
   procedure :: mpas_coord => model_mpas_coord
   procedure :: mpas_read => model_mpas_read
   procedure :: nemo_coord => model_nemo_coord
   procedure :: nemo_read => model_nemo_read
   procedure :: res_coord => model_res_coord
   procedure :: res_read => model_res_read
   procedure :: wrf_coord => model_wrf_coord
   procedure :: wrf_read => model_wrf_read

   ! Generic procedures
   procedure :: alloc => model_alloc
   procedure :: dealloc => model_dealloc
   procedure :: setup => model_setup
   procedure :: read => model_read
   procedure :: read_member => model_read_member
   procedure :: load_ens => model_load_ens
   procedure :: generate_obs => model_generate_obs
end type model_type

character(len=1024) :: zone = 'C+I'        ! Computation zone for AROME ('C', 'C+I' or 'C+I+E')
integer,parameter :: ntile = 6             ! Number of tiles for FV3
logical,parameter :: test_no_obs = .false. ! Test observation operator with no observation on the last MPI task
logical,parameter :: test_no_point = .false.      ! Test BUMP with no grid point on the last MPI task

private
public :: model_type

contains

! Include model interfaces
include "model_aro.inc"
include "model_arp.inc"
include "model_fv3.inc"
include "model_gem.inc"
include "model_geos.inc"
include "model_gfs.inc"
include "model_ifs.inc"
include "model_mpas.inc"
include "model_nemo.inc"
include "model_res.inc"
include "model_wrf.inc"

!----------------------------------------------------------------------
! Subroutine: model_alloc
! Purpose: allocation
!----------------------------------------------------------------------
subroutine model_alloc(model)

implicit none

! Passed variables
class(model_type),intent(inout) :: model ! Model

! Allocation
allocate(model%mg_to_lon(model%nmg))
allocate(model%mg_to_lat(model%nmg))
allocate(model%mg_to_tile(model%nmg))
allocate(model%lon(model%nmg))
allocate(model%lat(model%nmg))
allocate(model%area(model%nmg))
allocate(model%mask(model%nmg,model%nl0))

end subroutine model_alloc

!----------------------------------------------------------------------
! Subroutine: model_dealloc
! Purpose: release memory
!----------------------------------------------------------------------
subroutine model_dealloc(model)

implicit none

! Passed variables
class(model_type),intent(inout) :: model ! Model

! Release memory
if (allocated(model%lon)) deallocate(model%lon)
if (allocated(model%lat)) deallocate(model%lat)
if (allocated(model%area)) deallocate(model%area)
if (allocated(model%mask)) deallocate(model%mask)
if (allocated(model%mg_to_proc)) deallocate(model%mg_to_proc)
if (allocated(model%mg_to_mga)) deallocate(model%mg_to_mga)
if (allocated(model%lon_mga)) deallocate(model%lon_mga)
if (allocated(model%lat_mga)) deallocate(model%lat_mga)
if (allocated(model%area_mga)) deallocate(model%area_mga)
if (allocated(model%mask_mga)) deallocate(model%mask_mga)
if (allocated(model%smask_mga)) deallocate(model%smask_mga)
if (allocated(model%ens1)) deallocate(model%ens1)
if (allocated(model%ens2)) deallocate(model%ens2)
if (allocated(model%lonobs)) deallocate(model%lonobs)
if (allocated(model%latobs)) deallocate(model%latobs)

end subroutine model_dealloc

!----------------------------------------------------------------------
! Subroutine: model_setup
! Purpose: setup model
!----------------------------------------------------------------------
subroutine model_setup(model,mpl,rng,nam)

implicit none

! Passed variables
class(model_type),intent(inout) :: model ! Model
type(mpl_type),intent(inout) :: mpl      ! MPI data
type(rng_type),intent(inout) :: rng      ! Random number generator
type(nam_type),intent(inout) :: nam      ! Namelist variables

! Local variables
integer :: iv,img,info,iproc,imga,nmga,ny,nres,iy,delta,ix,nv_save
integer :: ncid,nmg_id,mg_to_proc_id,mg_to_mga_id,lon_id,lat_id
integer :: nn_index(1),bnd(0)
integer,allocatable :: center_to_mg(:),nx(:),imga_arr(:)
real(kind_real) :: nn_dist(1),dlat,dlon
real(kind_real),allocatable :: rh(:),lon_center(:),lat_center(:),fld(:,:,:)
logical,allocatable :: mask_hor(:)
character(len=4) :: nprocchar
character(len=1024) :: filename_nc
character(len=1024),dimension(nvmax) :: varname_save,addvar2d_save
character(len=1024),parameter :: subr = 'model_define_distribution'
type(kdtree_type) :: kdtree

! Number of levels
model%nl0 = nam%nl
do iv=1,nam%nv
   if (trim(nam%addvar2d(iv))/='') model%nl0 = nam%nl+1
end do

! Select model
if (trim(nam%model)=='aro') call model%aro_coord(mpl,nam)
if (trim(nam%model)=='arp') call model%arp_coord(mpl,nam)
if (trim(nam%model)=='fv3') call model%fv3_coord(mpl,nam)
if (trim(nam%model)=='gem') call model%gem_coord(mpl,nam)
if (trim(nam%model)=='geos') call model%geos_coord(mpl,nam)
if (trim(nam%model)=='gfs') call model%gfs_coord(mpl,nam)
if (trim(nam%model)=='ifs') call model%ifs_coord(mpl,nam)
if (trim(nam%model)=='mpas') call model%mpas_coord(mpl,nam)
if (trim(nam%model)=='nemo') call model%nemo_coord(mpl,nam)
if (trim(nam%model)=='res') call model%res_coord(mpl,nam)
if (trim(nam%model)=='wrf') call model%wrf_coord(mpl,nam)

! Define distribution
if (mpl%nproc==1) then
   ! All points on a single processor
   model%mg_to_proc = 1
   do img=1,model%nmg
      model%mg_to_mga(img) = img
   end do
elseif (mpl%nproc>1) then
   if (mpl%main) then
      ! Open file
      write(nprocchar,'(i4.4)') mpl%nproc
      filename_nc = trim(nam%prefix)//'_distribution_'//nprocchar//'.nc'
      info = nf90_open(trim(nam%datadir)//'/'//trim(filename_nc),nf90_nowrite,ncid)
   end if
   call mpl%f_comm%broadcast(info,mpl%ioproc-1)

   if (info==nf90_noerr) then
      ! Read local distribution
      write(mpl%info,'(a7,a,i4,a)') '','Read local distribution for: ',mpl%nproc,' MPI tasks'
      call mpl%flush

      if (mpl%main) then
         ! Get variables ID
         call mpl%ncerr(subr,nf90_inq_varid(ncid,'mg_to_proc',mg_to_proc_id))
         call mpl%ncerr(subr,nf90_inq_varid(ncid,'mg_to_mga',mg_to_mga_id))

         ! Read varaibles
         call mpl%ncerr(subr,nf90_get_var(ncid,mg_to_proc_id,model%mg_to_proc))
         call mpl%ncerr(subr,nf90_get_var(ncid,mg_to_mga_id,model%mg_to_mga))

         ! Close file
         call mpl%ncerr(subr,nf90_close(ncid))
      end if

      ! Broadcast distribution
      call mpl%f_comm%broadcast(model%mg_to_proc,mpl%ioproc-1)
      call mpl%f_comm%broadcast(model%mg_to_mga,mpl%ioproc-1)

      ! Check
      if (maxval(model%mg_to_proc)>mpl%nproc) call mpl%abort(subr,'wrong distribution')
   else
      ! Generate a distribution

      ! Allocation
      allocate(lon_center(mpl%nproc))
      allocate(lat_center(mpl%nproc))
      allocate(imga_arr(mpl%nproc))

      ! Define distribution centers
      if (.false.) then
         ! Using a random sampling

         ! Allocation
         allocate(mask_hor(model%nmg))
         allocate(rh(model%nmg))
         allocate(center_to_mg(mpl%nproc))

         ! Initialization
         mask_hor = any(model%mask,dim=2)
         rh = 1.0

         ! Compute sampling
         write(mpl%info,'(a7,a)') '','Define distribution centers:'
         call mpl%flush(.false.)
         call rng%initialize_sampling(mpl,model%nmg,model%lon,model%lat,mask_hor,0,bnd,rh,nam%ntry,nam%nrep, &
       & mpl%nproc,center_to_mg)

         ! Define centers coordinates
         lon_center = model%lon(center_to_mg)
         lat_center = model%lat(center_to_mg)

         ! Release memory
         deallocate(mask_hor)
         deallocate(rh)
         deallocate(center_to_mg)
      else
         ! Using a regular splitting

         ! Allocation
         ny = nint(sqrt(real(mpl%nproc,kind_real)))
         if (ny**2<mpl%nproc) ny = ny+1
         allocate(nx(ny))
         nres = mpl%nproc
         do iy=1,ny
            delta = mpl%nproc/ny
            if (nres>(ny-iy+1)*delta) delta = delta+1
            nx(iy) = delta
            nres = nres-delta
         end do
         if (sum(nx)/=mpl%nproc) call mpl%abort(subr,'wrong number of tiles in define_distribution')
         dlat = (maxval(model%lat)-minval(model%lat))/ny
         iproc = 0
         do iy=1,ny
            dlon = (maxval(model%lon)-minval(model%lon))/nx(iy)
            do ix=1,nx(iy)
               iproc = iproc+1
               lat_center(iproc) = minval(model%lat)+(real(iy,kind_real)-0.5)*dlat
               lon_center(iproc) = minval(model%lon)+(real(ix,kind_real)-0.5)*dlon
            end do
         end do
      end if

      if (mpl%main) then
         ! Allocation
         call kdtree%alloc(mpl,mpl%nproc)

         ! Initialization
         call kdtree%init(mpl,lon_center,lat_center)

         ! Local processor
         do img=1,model%nmg
            call kdtree%find_nearest_neighbors(mpl,model%lon(img),model%lat(img),1,nn_index,nn_dist)
            model%mg_to_proc(img) = nn_index(1)
         end do

         ! Local index
         imga_arr = 0
         do img=1,model%nmg
            iproc = model%mg_to_proc(img)
            imga_arr(iproc) = imga_arr(iproc)+1
            model%mg_to_mga(img) = imga_arr(iproc)
         end do
      end if

      ! Broadcast distribution
      call mpl%f_comm%broadcast(model%mg_to_proc,mpl%ioproc-1)
      call mpl%f_comm%broadcast(model%mg_to_mga,mpl%ioproc-1)


      if (test_no_point) then
         ! Count points on the penultimate processor
         nmga = count(model%mg_to_proc==mpl%nproc-1)

         ! Move all point from the last to the penultimate processor
         do img=1,model%nmg
            if (model%mg_to_proc(img)==mpl%nproc) then
               nmga = nmga+1
               model%mg_to_proc(img) = mpl%nproc-1
               model%mg_to_mga(img) = nmga
            end if
         end do
      end if

      ! Write distribution
      if (mpl%main) then
         ! Create file
         call mpl%ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename_nc),or(nf90_clobber,nf90_64bit_offset),ncid))

         ! Write namelist parameters
         call nam%write(mpl,ncid)

         ! Define dimension
         call mpl%ncerr(subr,nf90_def_dim(ncid,'nmg',model%nmg,nmg_id))

         ! Define variables
         call mpl%ncerr(subr,nf90_def_var(ncid,'lon',nc_kind_real,(/nmg_id/),lon_id))
         call mpl%ncerr(subr,nf90_def_var(ncid,'lat',nc_kind_real,(/nmg_id/),lat_id))
         call mpl%ncerr(subr,nf90_def_var(ncid,'mg_to_proc',nf90_int,(/nmg_id/),mg_to_proc_id))
         call mpl%ncerr(subr,nf90_def_var(ncid,'mg_to_mga',nf90_int,(/nmg_id/),mg_to_mga_id))

         ! End definition mode
         call mpl%ncerr(subr,nf90_enddef(ncid))

         ! Write variables
         call mpl%ncerr(subr,nf90_put_var(ncid,lon_id,model%lon*rad2deg))
         call mpl%ncerr(subr,nf90_put_var(ncid,lat_id,model%lat*rad2deg))
         call mpl%ncerr(subr,nf90_put_var(ncid,mg_to_proc_id,model%mg_to_proc))
         call mpl%ncerr(subr,nf90_put_var(ncid,mg_to_mga_id,model%mg_to_mga))

         ! Close file
         call mpl%ncerr(subr,nf90_close(ncid))
      end if

      ! Release memory
      deallocate(lon_center)
      deallocate(lat_center)
      deallocate(imga_arr)
   end if
end if

! Size of tiles
model%nmga = count(model%mg_to_proc==mpl%myproc)

! Allocation
allocate(model%lon_mga(model%nmga))
allocate(model%lat_mga(model%nmga))
allocate(model%area_mga(model%nmga))
allocate(model%mask_mga(model%nmga,model%nl0))
allocate(model%smask_mga(model%nmga,model%nl0))

! Conversion
imga = 0
do img=1,model%nmg
   if (model%mg_to_proc(img)==mpl%myproc) then
      imga = imga+1
      model%lon_mga(imga) = model%lon(img)
      model%lat_mga(imga) = model%lat(img)
      model%area_mga(imga) = model%area(img)
      model%vunit_mga(imga,:) = model%vunit(img,:)
      model%mask_mga(imga,:) = model%mask(img,:)
   end if
end do

! Define sampling mask
select case(trim(nam%mask_type))
case ('none','lat','ldwv','stddev')
   ! All points accepted in sampling
   model%smask_mga = .true.
case default
   ! Save namelist parameters
   nv_save = nam%nv
   varname_save = nam%varname
   addvar2d_save = nam%addvar2d

   ! Set namelist parameters
   nam%nv = 1
   nam%varname(1) = 'MASK'
   if (nam%nl<model%nl0) nam%addvar2d(1) = 'MASK'

   ! Read file
   allocate(fld(model%nmga,model%nl0,nam%nv))
   call model%read(mpl,nam,nam%mask_type,1,fld)
   model%smask_mga = (fld(:,:,1)>nam%mask_th)

   ! Reset namelist parameters
   nam%nv = nv_save
   nam%varname = varname_save
   nam%addvar2d = addvar2d_save
end select

end subroutine model_setup

!----------------------------------------------------------------------
! Subroutine: model_read
! Purpose: read member field
!----------------------------------------------------------------------
subroutine model_read(model,mpl,nam,filename,its,fld)

implicit none

! Passed variables
class(model_type),intent(inout) :: model                        ! Model
type(mpl_type),intent(inout) :: mpl                             ! MPI data
type(nam_type),intent(in) :: nam                                ! Namelist
character(len=*),intent(in) :: filename                         ! File name
integer,intent(in) :: its                                       ! Timeslot index
real(kind_real),intent(out) :: fld(model%nmga,model%nl0,nam%nv) ! Field

! Initialization
fld = mpl%msv%valr

! Select model
if (trim(nam%model)=='aro') call model%aro_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='arp') call model%arp_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='fv3') call model%fv3_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='gem') call model%gem_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='geos') call model%geos_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='gfs') call model%gfs_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='ifs') call model%ifs_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='mpas') call model%mpas_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='nemo') call model%nemo_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='res') call model%res_read(mpl,nam,filename,its,fld)
if (trim(nam%model)=='wrf') call model%wrf_read(mpl,nam,filename,its,fld)

end subroutine model_read

!----------------------------------------------------------------------
! Subroutine: model_read_member
! Purpose: read member field
!----------------------------------------------------------------------
subroutine model_read_member(model,mpl,nam,filename,ie,jsub,fld)

implicit none

! Passed variables
class(model_type),intent(inout) :: model ! Model
type(mpl_type),intent(inout) :: mpl                                     ! MPI data
type(nam_type),intent(in) :: nam                                        ! Namelist
character(len=*),intent(in) :: filename                                 ! File name
integer,intent(in) :: ie                                                ! Ensemble member index
integer,intent(in) :: jsub                                              ! Sub-ensemble index
real(kind_real),intent(out) :: fld(model%nmga,model%nl0,nam%nv,nam%nts) ! Field

! Local variables
integer :: its
character(len=1024) :: fullname

! Initialization
fld = mpl%msv%valr

do its=1,nam%nts
   ! Define filename
   if (jsub==0) then
      write(fullname,'(a,a,i2.2,a,i4.4,a)') trim(filename),'_',nam%timeslot(its),'_',ie,'.nc'
   else
      write(fullname,'(a,a,i2.2,a,i4.4,a,i4.4,a)') trim(filename),'_',nam%timeslot(its),'_',jsub,'_',ie,'.nc'
   end if

   ! Read file
   call model%read(mpl,nam,fullname,its,fld(:,:,:,its))
end do

end subroutine model_read_member

!----------------------------------------------------------------------
! Subroutine: model_load_ens
! Purpose: load ensemble data
!----------------------------------------------------------------------
subroutine model_load_ens(model,mpl,nam,filename)

implicit none

! Passed variables
class(model_type),intent(inout) :: model ! Model
type(mpl_type),intent(inout) :: mpl      ! MPI data
type(nam_type),intent(in) :: nam         ! Namelist
character(len=*),intent(in) :: filename  ! Filename ('ens1' or 'ens2')

! Local variables
integer :: ne,nsub,isub,jsub,ie,ietot
real(kind_real),allocatable :: mean(:,:,:,:,:)
character(len=1024),parameter :: subr = 'model_load_ens'

select case (trim(filename))
case ('ens1')
   ! Initialization
   ne = nam%ens1_ne
   nsub = nam%ens1_nsub
   model%ens1_ne = nam%ens1_ne
   model%ens1_nsub = nam%ens1_nsub

   if (ne>0) then
      ! Allocation
      allocate(model%ens1(model%nmga,model%nl0,nam%nv,nam%nts,ne))

      ! Initialization
      model%ens1 = mpl%msv%valr
   end if
case ('ens2')
   ! Initialization
   ne = nam%ens2_ne
   nsub = nam%ens2_nsub
   model%ens2_ne = nam%ens2_ne
   model%ens2_nsub = nam%ens2_nsub

   if (ne>0) then
      ! Allocation
      allocate(model%ens2(model%nmga,model%nl0,nam%nv,nam%nts,ne))

      ! Initialization
      model%ens2 = mpl%msv%valr
   end if
case default
   call mpl%abort(subr,'wrong filename in model_load_ens')
end select

! Allocation
if (ne>0) allocate(mean(model%nmga,model%nl0,nam%nv,nam%nts,nsub))

! Initialization
ietot = 1

! Loop over sub-ensembles
do isub=1,nsub
   if (nsub==1) then
      write(mpl%info,'(a7,a)') '','Full ensemble, member:'
      call mpl%flush(.false.)
   else
      write(mpl%info,'(a7,a,i4,a)') '','Sub-ensemble ',isub,', member:'
      call mpl%flush(.false.)
   end if

   ! Loop over members for a given sub-ensemble
   do ie=1,ne/nsub
      write(mpl%info,'(i4)') ie
      call mpl%flush(.false.)

      ! Read member
      if (nsub==1) then
         jsub = 0
      else
         jsub = isub
      end if
      select case (trim(filename))
      case ('ens1')
         call model%read_member(mpl,nam,filename,ie,jsub,model%ens1(:,:,:,:,ietot))
      case ('ens2')
         call model%read_member(mpl,nam,filename,ie,jsub,model%ens2(:,:,:,:,ietot))
      end select

      ! Update
      ietot = ietot+1
   end do
   write(mpl%info,'(a)') ''
   call mpl%flush
end do

end subroutine model_load_ens

!----------------------------------------------------------------------
! Subroutine: model_generate_obs
! Purpose: generate observations locations
!----------------------------------------------------------------------
subroutine model_generate_obs(model,mpl,rng,nam)

implicit none

! Passed variables
class(model_type),intent(inout) :: model ! Model
type(mpl_type),intent(inout) :: mpl      ! MPI data
type(rng_type),intent(inout) :: rng      ! Random number generator
type(nam_type),intent(in) :: nam         ! Namelist

! Local variables
integer :: iobs,jobs,iproc,iobsa,nproc_max
integer,allocatable :: order(:),obs_to_proc(:)
real(kind_real),allocatable :: lonobs(:),latobs(:),list(:)
logical :: valid
character(len=1024),parameter :: subr = 'model_generate_obs'

! Check observation number
if (nam%nobs<1) call mpl%abort(subr,'nobs should be positive for offline observation operator')

! Allocation
allocate(lonobs(nam%nobs))
allocate(latobs(nam%nobs))
allocate(obs_to_proc(nam%nobs))

if (mpl%main) then
   ! Generate random observation network
   call rng%rand_real(-pi,pi,lonobs)
   call rng%rand_real(-0.5*pi,0.5*pi,latobs)
end if

! Broadcast data
call mpl%f_comm%broadcast(lonobs,mpl%ioproc-1)
call mpl%f_comm%broadcast(latobs,mpl%ioproc-1)

! Split observations between processors
if (test_no_obs.and.(mpl%nproc==1)) call mpl%abort(subr,'at least 2 MPI tasks required for test_no_obs')
if (mpl%main) then
   ! Allocation
   allocate(list(nam%nobs))
   allocate(order(nam%nobs))

   ! Generate random order
   call rng%rand_real(0.0_kind_real,1.0_kind_real,list)
   call qsort(nam%nobs,list,order)

   ! Split observations
   iproc = 1
   if (test_no_obs) then
      nproc_max = mpl%nproc-1
   else
      nproc_max = mpl%nproc
   end  if
   do iobs=1,nam%nobs
      jobs = order(iobs)
      obs_to_proc(jobs) = iproc
      iproc = iproc+1
      if (iproc>nproc_max) iproc = 1
   end do

   ! Release memory
   deallocate(list)
   deallocate(order)
end if

! Broadcast
call mpl%f_comm%broadcast(obs_to_proc,mpl%ioproc-1)
model%nobsa = count(obs_to_proc==mpl%myproc)

! Allocation
allocate(model%lonobs(model%nobsa))
allocate(model%latobs(model%nobsa))

! Copy local observations
iobsa = 0
do iobs=1,nam%nobs
   iproc = obs_to_proc(iobs)
   if (mpl%myproc==iproc) then
      iobsa = iobsa+1
      model%lonobs(iobsa) = lonobs(iobs)
      model%latobs(iobsa) = latobs(iobs)
   end if
end do

! Release memory
deallocate(lonobs)
deallocate(latobs)
deallocate(obs_to_proc)

end subroutine model_generate_obs

end module type_model
