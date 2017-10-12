!----------------------------------------------------------------------
! Module: model_interface.f90
!> Purpose: model routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module model_interface

use model_aro, only: model_aro_coord,model_aro_read,model_aro_write
use model_arp, only: model_arp_coord,model_arp_read,model_arp_write
use model_gem, only: model_gem_coord,model_gem_read,model_gem_write
use model_geos, only: model_geos_coord,model_geos_read,model_geos_write
use model_gfs, only: model_gfs_coord,model_gfs_read,model_gfs_write
use model_ifs, only: model_ifs_coord,model_ifs_read,model_ifs_write
use model_mpas, only: model_mpas_coord,model_mpas_read,model_mpas_write
use model_nemo, only: model_nemo_coord,model_nemo_read,model_nemo_write
use model_oops, only: model_oops_write
use model_wrf, only: model_wrf_coord,model_wrf_read,model_wrf_write
use module_namelist, only: namtype
use netcdf
use tools_display, only: msgerror
use tools_kinds,only: kind_real
use tools_missing, only: msvalr,msr
use tools_nc, only: ncfloat,ncerr
use type_geom, only: geomtype
use type_mom, only: momtype
use type_mpl, only: mpl

implicit none

interface model_read
   module procedure model_read_fld
   module procedure model_read_member
end interface

private
public :: model_coord,model_read,model_write

contains

!----------------------------------------------------------------------
! Subroutine: model_coord
!> Purpose: get coordinates
!----------------------------------------------------------------------
subroutine model_coord(nam,geom)

implicit none

! Passed variables
type(namtype),intent(in) :: nam !< Namelist variables
type(geomtype),intent(inout) :: geom !< Sampling data

! Number of levels
geom%nl0 = nam%nl
if (any(.not.nam%var3d(1:nam%nv))) geom%nl0 = geom%nl0+1   

! Select model
if (trim(nam%model)=='aro') then
   call model_aro_coord(nam,geom)
elseif (trim(nam%model)=='arp') then
   call model_arp_coord(nam,geom)
elseif (trim(nam%model)=='gem') then
   call model_gem_coord(nam,geom)
elseif (trim(nam%model)=='geos') then
   call model_geos_coord(nam,geom)
elseif (trim(nam%model)=='gfs') then
   call model_gfs_coord(nam,geom)
elseif (trim(nam%model)=='ifs') then
   call model_ifs_coord(nam,geom)
elseif (trim(nam%model)=='mpas') then
   call model_mpas_coord(nam,geom)
elseif (trim(nam%model)=='nemo') then
   call model_nemo_coord(nam,geom)
elseif (trim(nam%model)=='oops') then
   call msgerror('specific interface in module_oops')
elseif (trim(nam%model)=='wrf') then
   call model_wrf_coord(nam,geom)
else
   call msgerror('wrong model')
end if

end subroutine model_coord

!----------------------------------------------------------------------
! Subroutine: model_read_fld
!> Purpose: read model field
!----------------------------------------------------------------------
subroutine model_read_fld(nam,geom,filename,varname,var3d,timeslot,fld)

implicit none

! Passed variables
type(namtype),intent(in) :: nam !< Namelist variables
type(geomtype),intent(in) :: geom                     !< Sampling data
character(len=*),intent(in) :: filename                 !< File name
character(len=*),intent(in) :: varname                  !< Variable name
logical,intent(in) :: var3d                  !< 3D variable
integer,intent(in) :: timeslot                            !< Timeslot
real(kind_real),intent(out) :: fld(geom%nc0,geom%nl0) !< Read field

! Local variables
integer :: ncid
character(len=1024) :: subr = 'model_read_fld'

! Open file
call ncerr(subr,nf90_open(trim(nam%datadir)//'/'//trim(filename),nf90_nowrite,ncid))

! Select model
if (trim(nam%model)=='aro') then
   call model_aro_read(nam,geom,ncid,varname,var3d,timeslot,fld)
elseif (trim(nam%model)=='arp') then
   call model_arp_read(nam,geom,ncid,varname,var3d,timeslot,fld)
elseif (trim(nam%model)=='gem') then
   call model_gem_read(nam,geom,ncid,varname,var3d,timeslot,fld)
elseif (trim(nam%model)=='geos') then
   call model_geos_read(nam,geom,ncid,varname,var3d,timeslot,fld)
elseif (trim(nam%model)=='gfs') then
   call model_gfs_read(nam,geom,ncid,varname,var3d,timeslot,fld)
elseif (trim(nam%model)=='ifs') then
   call model_ifs_read(nam,geom,ncid,varname,var3d,timeslot,fld)
elseif (trim(nam%model)=='mpas') then
   call model_mpas_read(nam,geom,ncid,varname,var3d,timeslot,fld)
elseif (trim(nam%model)=='nemo') then
   call model_nemo_read(nam,geom,ncid,varname,var3d,timeslot,fld)
elseif (trim(nam%model)=='oops') then
   call msgerror('not implemented yet')
elseif (trim(nam%model)=='wrf') then
   call model_wrf_read(nam,geom,ncid,varname,var3d,timeslot,fld)
else
   call msgerror('wrong model')
end if

! Close file
call ncerr(subr,nf90_close(ncid))

end subroutine model_read_fld

!----------------------------------------------------------------------
! Subroutine: model_read_member
!> Purpose: read model field
!----------------------------------------------------------------------
subroutine model_read_member(nam,geom,filename,varname,var3d,timeslot,ie,jsub,fld)

implicit none

! Passed variables
type(namtype),intent(in) :: nam                   !< Namelist
type(geomtype),intent(in) :: geom              !< Sampling data
character(len=*),intent(in) :: filename
character(len=*),intent(in) :: varname
logical,intent(in) :: var3d                  !< 3D variable
integer,intent(in) :: timeslot
integer,intent(in) :: ie                          !< Ensemble member index
integer,intent(in) :: jsub                        !< Sub-ensemble index
real(kind_real),intent(out) :: fld(geom%nc0,geom%nl0) !< Read field

! Local variables
character(len=2) :: timeslotchar
character(len=4) :: iechar,jsubchar

! Initialization
call msr(fld)

! Open file
write(timeslotchar,'(i2.2)') timeslot
write(iechar,'(i4.4)') ie

! Read field
if (jsub==0) then
   call model_read_fld(nam,geom,trim(filename)//'_'//timeslotchar//'_'//iechar//'.nc',varname,var3d,timeslot,fld)
else
   write(jsubchar,'(i4.4)') jsub
   call model_read_fld(nam,geom,trim(filename)//'_'//timeslotchar//'_'//jsubchar//'_'//iechar//'.nc',varname,var3d,timeslot,fld)
end if

end subroutine model_read_member

!----------------------------------------------------------------------
! Subroutine: model_write
!> Purpose: write model field
!----------------------------------------------------------------------
subroutine model_write(nam,geom,filename,varname,fld)

implicit none

! Passed variables
type(namtype),intent(in) :: nam !< Namelist variables
type(geomtype),intent(in) :: geom                     !< Sampling data
character(len=*),intent(in) :: filename                 !< File name
character(len=*),intent(in) :: varname                  !< Variable name
real(kind_real),intent(in) :: fld(geom%nc0,geom%nl0) !< Written field

! Local variables
integer :: ic0,il0,ierr
integer :: ncid
real(kind_real) :: fld_loc(geom%nc0,geom%nl0)
character(len=1024) :: subr = 'model_write'

! Processor verification
if (.not.mpl%main) call msgerror('only I/O proc should enter '//trim(subr))

! Apply mask
do il0=1,geom%nl0
   do ic0=1,geom%nc0
      if (geom%mask(ic0,il0)) then
         fld_loc(ic0,il0) = fld(ic0,il0)
      else
         call msr(fld_loc(ic0,il0))
      end if
   end do
end do

! Check if the file exists
ierr = nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_noclobber,nf90_64bit_offset),ncid)
if (ierr/=nf90_noerr) then
   call ncerr(subr,nf90_open(trim(nam%datadir)//'/'//trim(filename),nf90_write,ncid))
   call ncerr(subr,nf90_redef(ncid))
   call ncerr(subr,nf90_put_att(ncid,nf90_global,'_FillValue',msvalr))
end if
call ncerr(subr,nf90_enddef(ncid))

! Select model
if (trim(nam%model)=='aro') then
   call model_aro_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='arp') then
   call model_arp_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='gem') then
   call model_gem_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='geos') then
   call model_geos_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='gfs') then
   call model_gfs_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='ifs') then
   call model_ifs_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='mpas') then
   call model_mpas_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='nemo') then
   call model_nemo_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='oops') then
   call model_oops_write(nam,geom,ncid,varname,fld_loc)
elseif (trim(nam%model)=='wrf') then
   call model_wrf_write(nam,geom,ncid,varname,fld_loc)
else
   call msgerror('wrong model')
end if

! Close file
call ncerr(subr,nf90_close(ncid))

end subroutine model_write

end module model_interface
