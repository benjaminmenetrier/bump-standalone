!----------------------------------------------------------------------
! Module: module_res
! Purpose: RES model routines
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
module model_res

use netcdf
use tools_const, only: pi,req,rad2deg
use tools_kinds,only: kind_real
use tools_nc, only: ncfloat
use type_geom, only: geom_type
use type_mpl, only: mpl_type
use type_nam, only: nam_type

implicit none

private
public :: model_res_coord,model_res_read

contains

!----------------------------------------------------------------------
! Subroutine: model_res_coord
! Purpose: get RES coordinates
!----------------------------------------------------------------------
subroutine model_res_coord(mpl,nam,geom)

implicit none

! Passed variables
type(mpl_type),intent(inout) :: mpl   ! MPI data
type(nam_type),intent(in) :: nam      ! Namelist
type(geom_type),intent(inout) :: geom ! Geometry

! Local variables
integer :: ic0,il0
integer :: ncid,nmg_id,nlev_id,lon_id,lat_id,alt_id,area_id,mask_id
real(kind_real),allocatable :: lon(:,:),lat(:,:),alt(:,:),area(:,:),mask(:,:)
real(kind_real),allocatable :: lon_mg(:),lat_mg(:),area_mg(:)
logical,allocatable :: lmask_mg(:,:)
character(len=1024),parameter :: subr = 'model_res_coord'

! Open file and get dimensions
geom%nlon = mpl%msv%vali
geom%nlat = mpl%msv%vali
call mpl%ncerr(subr,nf90_open(trim(nam%datadir)//'/grid.nc',nf90_share,ncid))
call mpl%ncerr(subr,nf90_inq_dimid(ncid,'nhcells',nmg_id))
call mpl%ncerr(subr,nf90_inquire_dimension(ncid,nmg_id,len=geom%nmg))
call mpl%ncerr(subr,nf90_inq_dimid(ncid,'nlev',nlev_id))
call mpl%ncerr(subr,nf90_inquire_dimension(ncid,nlev_id,len=geom%nlev))

! Allocation
allocate(lon(geom%nmg,geom%nlev))
allocate(lat(geom%nmg,geom%nlev))
allocate(alt(geom%nmg,geom%nlev))
allocate(area(geom%nmg,geom%nlev))
allocate(mask(geom%nmg,geom%nlev))
allocate(lon_mg(geom%nmg))
allocate(lat_mg(geom%nmg))
allocate(area_mg(geom%nmg))
allocate(lmask_mg(geom%nmg,geom%nl0))

! Read data and close file
call mpl%ncerr(subr,nf90_inq_varid(ncid,'longitude',lon_id))
call mpl%ncerr(subr,nf90_inq_varid(ncid,'latitude',lat_id))
call mpl%ncerr(subr,nf90_inq_varid(ncid,'altitude',alt_id))
call mpl%ncerr(subr,nf90_inq_varid(ncid,'horzArea',area_id))
call mpl%ncerr(subr,nf90_inq_varid(ncid,'activeCells',mask_id))
call mpl%ncerr(subr,nf90_get_var(ncid,lon_id,lon))
call mpl%ncerr(subr,nf90_get_var(ncid,lat_id,lat))
call mpl%ncerr(subr,nf90_get_var(ncid,alt_id,alt))
call mpl%ncerr(subr,nf90_get_var(ncid,area_id,area))
call mpl%ncerr(subr,nf90_get_var(ncid,mask_id,mask))
call mpl%ncerr(subr,nf90_close(ncid))

! Model grid
lon_mg = (sum(lon,dim=2)/real(geom%nlev,kind_real))/req
lat_mg = (sum(lat,dim=2)/real(geom%nlev,kind_real))/req
area_mg = sum(area,dim=2)/real(geom%nlev,kind_real)/req**2
lmask_mg = (mask(:,nam%levs(1:geom%nl0))>0.5)

! Sc0 subset
call geom%find_sc0(mpl,lon_mg,lat_mg,.false.)

! Pack
call geom%alloc
geom%lon = lon_mg(geom%c0_to_mg)
geom%lat = lat_mg(geom%c0_to_mg)
do il0=1,geom%nl0
   geom%mask_c0(:,il0) = lmask_mg(geom%c0_to_mg,il0)
   geom%area(il0) = sum(area_mg(geom%c0_to_mg),geom%mask_c0(:,il0))
end do

! Vertical unit
if (nam%logpres) call mpl%abort(subr,'pressure logarithm vertical coordinate is not available for this model')
do il0=1,geom%nl0
   do ic0=1,geom%nc0
      geom%vunit(ic0,il0) = alt(geom%c0_to_mg(ic0),nam%levs(il0))
   end do
end do
mpl%vunitchar = 'm'

! Release memory
deallocate(lon)
deallocate(lat)
deallocate(alt)
deallocate(area)
deallocate(mask)

end subroutine model_res_coord

!----------------------------------------------------------------------
! Subroutine: model_res_read
! Purpose: read RES field
!----------------------------------------------------------------------
subroutine model_res_read(mpl,nam,geom,filename,its,fld)

implicit none

! Passed variables
type(mpl_type),intent(inout) :: mpl                           ! MPI data
type(nam_type),intent(in) :: nam                              ! Namelist
type(geom_type),intent(in) :: geom                            ! Geometry
character(len=*),intent(in) :: filename                       ! File name
integer,intent(in) :: its                                     ! Timeslot index
real(kind_real),intent(out) :: fld(geom%nc0a,geom%nl0,nam%nv) ! Field

! Local variables
integer :: iv,il0,img,ic0
integer :: ncid,fld_id
real(kind_real) :: fld_c0(geom%nc0,geom%nl0)
real(kind_real),allocatable :: fld_tmp(:,:)
character(len=1024),parameter :: subr = 'model_res_read'

if (mpl%main) then
   ! Allocation
   allocate(fld_tmp(geom%nmg,geom%nl0))

   ! Open file
   call mpl%ncerr(subr,nf90_open(trim(nam%datadir)//'/'//trim(filename),nf90_nowrite,ncid))
end if

do iv=1,nam%nv
   if (mpl%main) then
      ! 3d variable

      ! Get variable id
      call mpl%ncerr(subr,nf90_inq_varid(ncid,trim(nam%varname(iv)),fld_id))

      ! Read data
      do il0=1,nam%nl
         call mpl%ncerr(subr,nf90_get_var(ncid,fld_id,fld_tmp(:,il0),(/1,nam%levs(il0)/),(/geom%nmg,1/)))
      end do

      if (trim(nam%addvar2d(iv))/='') then
         ! 2d variable

         ! Get id
         call mpl%ncerr(subr,nf90_inq_varid(ncid,trim(nam%addvar2d(iv)),fld_id))

         ! Read data
         call mpl%ncerr(subr,nf90_get_var(ncid,fld_id,fld_tmp(:,il0)))
      end if
   end if

   ! Global to local
   if (mpl%main) then
     do il0=1,geom%nl0
         do ic0=1,geom%nc0
            img = geom%c0_to_mg(ic0)
            fld_c0(ic0,il0) = fld_tmp(img,il0)
         end do
      end do
   end if
   call mpl%glb_to_loc(geom%nl0,geom%nc0,geom%c0_to_proc,geom%c0_to_c0a,fld_c0,geom%nc0a,fld(:,:,iv))
end do

if (mpl%main) then
   ! Close file
   call mpl%ncerr(subr,nf90_close(ncid))

   ! Release memory
   deallocate(fld_tmp)
end if

end subroutine model_res_read

end module model_res
