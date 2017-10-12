!----------------------------------------------------------------------
! Module: type_displ
!> Purpose: displacement data derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module type_displ

use module_namelist, only: namncwrite
use netcdf
use tools_const, only: rad2deg
use tools_kinds, only: kind_real
use tools_missing, only: msvali,msvalr,msi,msr
use tools_nc, only: ncfloat,ncerr
use type_hdata, only: hdatatype
implicit none

! Displacement data derived type
type displtype
   integer :: niter                                  !< Number of stored iterations
   real(kind_real),allocatable :: dist(:,:,:)        !< Displacement distance
   real(kind_real),allocatable :: valid(:,:,:)       !< Displacement validity
   real(kind_real),allocatable :: rhflt(:,:,:)       !< Displacement filtering support radius

   real(kind_real),allocatable :: dlon_raw(:,:,:)    !< Longitude displacement, raw
   real(kind_real),allocatable :: dlat_raw(:,:,:)    !< Latitude displacement, raw
   real(kind_real),allocatable :: dlon_flt(:,:,:)    !< Longitude displacement, filtered
   real(kind_real),allocatable :: dlat_flt(:,:,:)    !< Latitude displacement, filtered
end type displtype

private
public :: displtype
public :: displ_alloc,displ_dealloc,displ_write

contains

!----------------------------------------------------------------------
! Subroutine: displ_alloc
!> Purpose: displacement data allocation
!----------------------------------------------------------------------
subroutine displ_alloc(hdata,displ)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
type(displtype),intent(inout) :: displ !< Displacement data

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Allocation
allocate(displ%dist(0:nam%displ_niter,geom%nl0,nam%nb))
allocate(displ%valid(0:nam%displ_niter,geom%nl0,nam%nb))
allocate(displ%rhflt(0:nam%displ_niter,geom%nl0,nam%nb))
allocate(displ%dlon_raw(geom%nc0,geom%nl0,nam%nb))
allocate(displ%dlat_raw(geom%nc0,geom%nl0,nam%nb))
allocate(displ%dlon_flt(geom%nc0,geom%nl0,nam%nb))
allocate(displ%dlat_flt(geom%nc0,geom%nl0,nam%nb))

! Initialization
call msr(displ%dist)
call msr(displ%valid)
call msr(displ%rhflt)
call msr(displ%dlon_raw)
call msr(displ%dlat_raw)
call msr(displ%dlon_flt)
call msr(displ%dlat_flt)

! End associate
end associate

end subroutine displ_alloc

!----------------------------------------------------------------------
! Subroutine: displ_dealloc
!> Purpose: displacement data deallocation
!----------------------------------------------------------------------
subroutine displ_dealloc(displ)

implicit none

! Passed variables
type(displtype),intent(inout) :: displ !< Displacement data

! Deallocation
deallocate(displ%dist)
deallocate(displ%valid)
deallocate(displ%rhflt)
deallocate(displ%dlon_raw)
deallocate(displ%dlat_raw)
deallocate(displ%dlon_flt)
deallocate(displ%dlat_flt)

end subroutine displ_dealloc

!----------------------------------------------------------------------
! Subroutine: displ_dealloc
!> Purpose: displacement data deallocation
!----------------------------------------------------------------------
subroutine displ_write(hdata,filename,displ)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !<
character(len=*),intent(in) :: filename
type(displtype),intent(in) :: displ !< Displacement data

! Local variables
integer :: ncid,nb_id,nl0_1_id,na_id,two_id,displ_niter_id,vunit_id,larc_id,valid_id,dist_id,rhflt_id
integer :: ib
character(len=1024) :: subr = 'displ_write'

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
call namncwrite(nam,ncid)
call ncerr(subr,nf90_def_dim(ncid,'nb',nam%nb,nb_id))
call ncerr(subr,nf90_def_dim(ncid,'nl0',geom%nl0,nl0_1_id))
call ncerr(subr,nf90_def_dim(ncid,'na',3*hdata%nc2-6,na_id))
call ncerr(subr,nf90_def_dim(ncid,'two',2,two_id))
call ncerr(subr,nf90_def_dim(ncid,'niter',nam%displ_niter,displ_niter_id))
call ncerr(subr,nf90_def_var(ncid,'vunit',ncfloat,(/nl0_1_id/),vunit_id))
call ncerr(subr,nf90_def_var(ncid,'larc',nf90_int,(/two_id,na_id/),larc_id))
call ncerr(subr,nf90_put_att(ncid,larc_id,'_FillValue',msvali))
call ncerr(subr,nf90_def_var(ncid,'valid',ncfloat,(/displ_niter_id,nl0_1_id,nb_id/),valid_id))
call ncerr(subr,nf90_put_att(ncid,valid_id,'_FillValue',msvalr))
call ncerr(subr,nf90_def_var(ncid,'dist',ncfloat,(/displ_niter_id,nl0_1_id,nb_id/),dist_id))
call ncerr(subr,nf90_put_att(ncid,dist_id,'_FillValue',msvalr))
call ncerr(subr,nf90_def_var(ncid,'rhflt',ncfloat,(/displ_niter_id,nl0_1_id,nb_id/),rhflt_id))
call ncerr(subr,nf90_put_att(ncid,rhflt_id,'_FillValue',msvalr))
call ncerr(subr,nf90_enddef(ncid))
call ncerr(subr,nf90_put_var(ncid,vunit_id,geom%vunit))
call ncerr(subr,nf90_put_var(ncid,larc_id,hdata%larc))
call ncerr(subr,nf90_put_var(ncid,valid_id,displ%valid))
call ncerr(subr,nf90_put_var(ncid,dist_id,displ%dist))
call ncerr(subr,nf90_put_var(ncid,rhflt_id,displ%rhflt))
call ncerr(subr,nf90_close(ncid))
! TODO: right number of displacement: nv
!do ib=1,nam%nb
!   call model_write(nam,geom,filename,trim(nam%blockname(ib))//'_dlon_raw',displ%dlon_raw(:,:,ib))
!   call model_write(nam,geom,filename,trim(nam%blockname(ib))//'_dlat_raw',displ%dlat_raw(:,:,ib))
!   call model_write(nam,geom,filename,trim(nam%blockname(ib))//'_dlon_flt',displ%dlon_flt(:,:,ib))
!   call model_write(nam,geom,filename,trim(nam%blockname(ib))//'_dlat_flt',displ%dlat_flt(:,:,ib))
!end do

! End associate
end associate

end subroutine displ_write

end module type_displ
