!----------------------------------------------------------------------
! Module: module_fv3
!> Purpose: FV3 model routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module model_fv3

use netcdf
use tools_const, only: deg2rad,pi,ps
use tools_kinds, only: kind_real
use tools_missing, only: msr,isanynotmsr
use tools_nc, only: ncfloat
use type_geom, only: geom_type
use type_mpl, only: mpl_type
use type_nam, only: nam_type

implicit none

integer,parameter :: ntile = 6 !< Number of tiles

private
public :: model_fv3_coord,model_fv3_read

contains

!----------------------------------------------------------------------
! Subroutine: model_fv3_coord
!> Purpose: get FV3 coordinates
!----------------------------------------------------------------------
subroutine model_fv3_coord(mpl,nam,geom)

implicit none

! Passed variables
type(mpl_type),intent(in) :: mpl      !< MPI data
type(nam_type),intent(in) :: nam      !< Namelist
type(geom_type),intent(inout) :: geom !< Geometry

! Local variables
integer :: ilon,ilat,ic0,itile
integer :: ncid,nlon_id,nlat_id,nlev_id,lon_id,lat_id,a_id,b_id
real(kind_real),allocatable :: lon(:,:,:),lat(:,:,:),a(:),b(:)
character(len=1024) :: subr = 'model_fv3_coord'

! Open file and get dimensions
call mpl%ncerr(subr,nf90_open(trim(nam%datadir)//'/grid.nc',nf90_share,ncid))
call mpl%ncerr(subr,nf90_inq_dimid(ncid,'xaxis_1',nlon_id))
call mpl%ncerr(subr,nf90_inq_dimid(ncid,'yaxis_2',nlat_id))
call mpl%ncerr(subr,nf90_inquire_dimension(ncid,nlon_id,len=geom%nlon))
call mpl%ncerr(subr,nf90_inquire_dimension(ncid,nlat_id,len=geom%nlat))
geom%nmg = geom%nlon*geom%nlat*ntile
call mpl%ncerr(subr,nf90_inq_dimid(ncid,'xaxis_1_ab',nlev_id))
call mpl%ncerr(subr,nf90_inquire_dimension(ncid,nlev_id,len=geom%nlev))

! Allocation
allocate(lon(geom%nlon,geom%nlat,ntile))
allocate(lat(geom%nlon,geom%nlat,ntile))
allocate(a(geom%nlev))
allocate(b(geom%nlev))

! Read data and close file
call mpl%ncerr(subr,nf90_inq_varid(ncid,'grid_lon',lon_id))
call mpl%ncerr(subr,nf90_inq_varid(ncid,'grid_lat',lat_id))
call mpl%ncerr(subr,nf90_inq_varid(ncid,'ak',a_id))
call mpl%ncerr(subr,nf90_inq_varid(ncid,'bk',b_id))
call mpl%ncerr(subr,nf90_get_var(ncid,lon_id,lon))
call mpl%ncerr(subr,nf90_get_var(ncid,lat_id,lat))
call mpl%ncerr(subr,nf90_get_var(ncid,a_id,a))
call mpl%ncerr(subr,nf90_get_var(ncid,b_id,b))
call mpl%ncerr(subr,nf90_close(ncid))

! Convert to radian
lon = (lon-180.0)*deg2rad
lat = lat*deg2rad

! Not redundant grid
call geom%find_redundant(mpl)

! Pack
call geom%alloc
ic0 = 0
do itile=1,ntile
   do ilon=1,geom%nlon
      do ilat=1,geom%nlat
         ic0 = ic0+1
         geom%c0_to_lon(ic0) = ilon
         geom%c0_to_lat(ic0) = ilat
         geom%c0_to_tile(ic0) = itile
         geom%lon(ic0) = lon(ilon,ilat,itile)
         geom%lat(ic0) = lat(ilon,ilat,itile)
         geom%mask(ic0,:) = .true.
      end do
   end do
end do

! Compute normalized area
geom%area = 4.0*pi

! Vertical unit
do ic0=1,geom%nc0
   if (nam%logpres) then
      geom%vunit(ic0,1:nam%nl) = log(0.5*(a(nam%levs(1:nam%nl))+a(nam%levs(1:nam%nl)+1)) &
                               & +0.5*(b(nam%levs(1:nam%nl))+b(nam%levs(1:nam%nl)+1))*ps)
      if (geom%nl0>nam%nl) geom%vunit(ic0,geom%nl0) = log(ps)
   else
      geom%vunit(ic0,:) = real(nam%levs(1:geom%nl0),kind_real)
   end if
end do

! Release memory
deallocate(lon)
deallocate(lat)
deallocate(a)
deallocate(b)

end subroutine model_fv3_coord

!----------------------------------------------------------------------
! Subroutine: model_fv3_read
!> Purpose: read FV3 field
!----------------------------------------------------------------------
subroutine model_fv3_read(mpl,nam,geom,filename,fld)

implicit none

! Passed variables
type(mpl_type),intent(in) :: mpl                              !< MPI data
type(nam_type),intent(in) :: nam                              !< Namelist
type(geom_type),intent(in) :: geom                            !< Geometry
character(len=*),intent(in) :: filename                       !< File name
real(kind_real),intent(out) :: fld(geom%nc0a,geom%nl0,nam%nv) !< Field

! Local variables
integer :: iv,il0,ic0,ilon,ilat,itile
integer :: ncid,fld_id
real(kind_real) :: fld_c0(geom%nc0)
real(kind_real),allocatable :: fld_tmp(:,:,:,:)
character(len=1024) :: subr = 'model_fv3_read'

if (mpl%main) then
   ! Allocation
   allocate(fld_tmp(geom%nlon,geom%nlat,geom%nl0,ntile))

   ! Open file
   call mpl%ncerr(subr,nf90_open(trim(nam%datadir)//'/'//trim(filename),nf90_nowrite,ncid))
end if

do iv=1,nam%nv
   if (mpl%main) then
      ! 3d variable

      ! Get variable id
      call mpl%ncerr(subr,nf90_inq_varid(ncid,trim(nam%varname(iv)),fld_id))

      ! Read data
      do itile=1,ntile
         do il0=1,nam%nl
            call mpl%ncerr(subr,nf90_get_var(ncid,fld_id,fld_tmp(:,:,il0,itile),(/1,1,nam%levs(il0),itile/), &
          & (/geom%nlon,geom%nlat,1,1/)))
         end do
      end do

      if (trim(nam%addvar2d(iv))/='') then
         ! 2d variable

         ! Get id
         call mpl%ncerr(subr,nf90_inq_varid(ncid,trim(nam%addvar2d(iv)),fld_id))

         ! Read data
         do itile=1,ntile
            call mpl%ncerr(subr,nf90_get_var(ncid,fld_id,fld_tmp(:,:,geom%nl0,itile),(/1,1,itile/),(/geom%nlon,geom%nlat,1/)))
         end do
      end if
   end if

   ! Global to local
   do il0=1,geom%nl0
      if (mpl%main) then
         do ic0=1,geom%nc0
            ilon = geom%c0_to_lon(ic0)
            ilat = geom%c0_to_lat(ic0)
            itile = geom%c0_to_tile(ic0)
            fld_c0(ic0) = fld_tmp(ilon,ilat,il0,itile)
         end do
      end if
      call mpl%glb_to_loc(geom%nc0,geom%c0_to_proc,geom%c0_to_c0a,fld_c0,geom%nc0a,fld(:,il0,iv))
   end do
end do

if (mpl%main) then
   ! Close file
   call mpl%ncerr(subr,nf90_close(ncid))

   ! Release memory
   deallocate(fld_tmp)
end if

end subroutine model_fv3_read

end module model_fv3
