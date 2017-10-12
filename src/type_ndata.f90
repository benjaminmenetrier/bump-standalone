!----------------------------------------------------------------------
! Module: type_ndata
!> Purpose: sampling data derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module type_ndata

use module_namelist, only: namtype,namncwrite
use netcdf
use tools_const, only: rad2deg
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msvali,msvalr,msi,msr
use tools_nc, only: ncerr,ncfloat
use type_com, only: comtype,com_dealloc,com_read,com_write
use type_geom, only: geomtype
use type_linop, only: linoptype,linop_alloc,linop_dealloc,linop_copy,linop_read,linop_write
use type_mpl, only: mpl

implicit none

! Sampling data derived type
type ndatatype
   ! Namelist
   type(namtype),pointer :: nam                    !< Namelist

   ! Geometry
   type(geomtype),pointer :: geom                  !< Geometry

   ! Sampling properties TODO : remove this
   logical,allocatable :: llev(:)          !< Vertical interpolation key

   ! Geometry
   integer :: nc1                          !< Number of points in subset Sc1
   integer,allocatable :: vbot(:)          !< Bottom level in grid Gh
   integer,allocatable :: vtop(:)          !< Top level in grid Gh
   integer :: nl1                          !< Number of levels in subset Sl1
   integer,allocatable :: nc2(:)           !< Number of points in subset Sc2
   integer :: ns                           !< Number of subgrid nodes

   ! Linear operators
   type(linoptype) :: c                    !< Convolution
   type(linoptype),allocatable :: h(:)     !< Horizontal interpolation
   type(linoptype) :: v     !< Vertical interpolation
   type(linoptype),allocatable :: s(:)     !< Subsample interpolation

   ! Normalization
   real(kind_real),allocatable :: norm(:,:) !< Normalization factor
   real(kind_real),allocatable :: norm_sqrt(:) !< Internal normalization factor for the square-root formulation

   ! Other data

   ! Parameters/normalization conversion
   integer,allocatable :: is_to_ic1(:)       !< Subgrid to subset Sc1
   integer,allocatable :: is_to_il1(:)       !< Subgrid to subset Sl1
   integer,allocatable :: is_to_ic2(:)       !< Subgrid to subset sc2
   integer,allocatable :: ic1_to_ic0(:)      !< Subset Sc1 to subset Sc0
   integer,allocatable :: il1_to_il0(:)      !< Subset Sl1 to subset Sl0
   integer,allocatable :: ic2il1_to_ic0(:,:) !< Grid Gs to subset Sc0
   integer,allocatable :: ic0_to_ic1(:)      !< Subset Sc0 to subset Sc1
   integer,allocatable :: il0_to_il1(:)      !< Subset Sl0 to subset Sl1
   integer,allocatable :: ic0il0_to_is(:,:)  !< Grid Gf to subgrid
   integer,allocatable :: ic2il1_to_is(:,:)  !< Grid Gs to subgrid
   integer,allocatable :: ic2il1_to_ic1(:,:) !< Grid Gs to subset Sc1
   integer,allocatable :: ic1il1_to_is(:,:)  !< Grid Gv to subgrid

   ! Illustration
   integer,allocatable :: halo(:)            !< Halo points for illustration
end type ndatatype

! Local sampling data derived type
type ndataloctype
   ! Namelist
   type(namtype),pointer :: nam                    !< Namelist

   ! Geometry
   type(geomtype),pointer :: geom                  !< Geometry

   ! Number of points
   integer :: nc1b                       !< Number of points in subset Sc1 on halo B
   integer :: nl1                        !< Number of levels in subset Sl1
   integer :: nl0i                       !< Number of independent levels
   integer,allocatable :: vbot(:)        !< Bottom level
   integer,allocatable :: vtop(:)        !< Bottom level
   integer,allocatable :: nc2b(:)        !< Number of points in subset Sc2 on halo B
   integer :: nsa                        !< Number of subgrid nodes on halo A
   integer :: nsb                        !< Number of subgrid nodes on halo B
   integer :: nsc                        !< Number of subgrid nodes on halo C

   ! Inter-halo conversions
   integer,allocatable :: isa_to_isb(:)  !< Subgrid, halo A to halo B
   integer,allocatable :: isa_to_isc(:)  !< Subgrid, halo A to halo C
   integer,allocatable :: isb_to_isc(:)  !< Subgrid, halo B to halo B

   ! Linear operators
   type(linoptype) :: c                  !< Convolution
   type(linoptype),allocatable :: h(:)   !< Horizontal interpolation
   type(linoptype) :: v   !< Vertical interpolation
   type(linoptype),allocatable :: s(:)   !< Subsample interpolation

   ! Copy conversions
   integer,allocatable :: isb_to_ic2b(:) !< Subgrid to subset Sc2 on halo B
   integer,allocatable :: isb_to_il1(:)  !< Subgrid to subset Sl1 on halo B

   ! Normalization
   real(kind_real),allocatable :: norm(:,:) !< Normalization factor
   real(kind_real),allocatable :: norm_sqrt(:) !< Internal normalization factor for the square-root formulation

   ! Communications
   type(comtype) :: AB                   !< Communication between halos A and B
   type(comtype) :: AC                   !< Communication between halos A and C
end type ndataloctype

private
public :: ndatatype,ndataloctype
public :: ndata_read_param,ndata_read_mpi, &
 & ndata_write_param,ndata_write_mpi,ndata_write_mpi_summary

contains

!----------------------------------------------------------------------
! Subroutine: ndata_read_param
!> Purpose: read ndata object
!----------------------------------------------------------------------
subroutine ndata_read_param(ndata)

implicit none

! Passed variables
type(ndatatype),intent(inout) :: ndata !< Sampling data

! Local variables
integer :: ncid
integer :: nc1_id,nl1_id,ns_id
integer :: vbot_id,vtop_id,nc2_id,is_to_ic1_id,is_to_il1_id,is_to_ic2_id,ic0il0_to_is_id,ic2il1_to_ic0_id
integer :: ic2il1_to_is_id,ic1_to_ic0_id,il1_to_il0_id,ic0_to_ic1_id,il0_to_il1_id,ic2il1_to_ic1_id
integer :: ic1il1_to_is_id,norm_id,norm_sqrt_id
character(len=1024) :: filename
character(len=1024) :: subr = 'ndata_read_param'

! Associate
associate(nam=>ndata%nam,geom=>ndata%geom)

! Open file and get dimensions
filename = trim(nam%prefix)//'_param.nc'
call ncerr(subr,nf90_open(trim(nam%datadir)//'/'//trim(filename),nf90_nowrite,ncid))
call ncerr(subr,nf90_inq_dimid(ncid,'nc1',nc1_id))
call ncerr(subr,nf90_inquire_dimension(ncid,nc1_id,len=ndata%nc1))
call ncerr(subr,nf90_inq_dimid(ncid,'nl1',nl1_id))
call ncerr(subr,nf90_inquire_dimension(ncid,nl1_id,len=ndata%nl1))
call ncerr(subr,nf90_inq_dimid(ncid,'ns',ns_id))
call ncerr(subr,nf90_inquire_dimension(ncid,ns_id,len=ndata%ns))

! Allocation
allocate(ndata%vbot(ndata%nc1))
allocate(ndata%vtop(ndata%nc1))
allocate(ndata%nc2(ndata%nl1))
allocate(ndata%is_to_ic1(ndata%ns))
allocate(ndata%is_to_il1(ndata%ns))
allocate(ndata%is_to_ic2(ndata%ns))
allocate(ndata%ic0il0_to_is(geom%nc0,geom%nl0))
allocate(ndata%ic2il1_to_ic0(ndata%nc1,ndata%nl1))
allocate(ndata%ic2il1_to_is(ndata%nc1,ndata%nl1))
allocate(ndata%ic1_to_ic0(ndata%nc1))
allocate(ndata%il1_to_il0(ndata%nl1))
allocate(ndata%ic0_to_ic1(geom%nc0))
allocate(ndata%il0_to_il1(geom%nl0))
allocate(ndata%ic2il1_to_ic1(ndata%nc1,ndata%nl1))
allocate(ndata%ic1il1_to_is(ndata%nc1,ndata%nl1))
allocate(ndata%norm(geom%nc0,geom%nl0))
if (nam%lsqrt) allocate(ndata%norm_sqrt(ndata%ns))

! Read data
call ncerr(subr,nf90_inq_varid(ncid,'vbot',vbot_id))
call ncerr(subr,nf90_inq_varid(ncid,'vtop',vtop_id))
call ncerr(subr,nf90_inq_varid(ncid,'nc2',nc2_id))
call ncerr(subr,nf90_inq_varid(ncid,'is_to_ic1',is_to_ic1_id))
call ncerr(subr,nf90_inq_varid(ncid,'is_to_il1',is_to_il1_id))
call ncerr(subr,nf90_inq_varid(ncid,'is_to_ic2',is_to_ic2_id))
call ncerr(subr,nf90_inq_varid(ncid,'ic0il0_to_is',ic0il0_to_is_id))
call ncerr(subr,nf90_inq_varid(ncid,'ic2il1_to_ic0',ic2il1_to_ic0_id))
call ncerr(subr,nf90_inq_varid(ncid,'ic2il1_to_is',ic2il1_to_is_id))
call ncerr(subr,nf90_inq_varid(ncid,'ic1_to_ic0',ic1_to_ic0_id))
call ncerr(subr,nf90_inq_varid(ncid,'il1_to_il0',il1_to_il0_id))
call ncerr(subr,nf90_inq_varid(ncid,'ic0_to_ic1',ic0_to_ic1_id))
call ncerr(subr,nf90_inq_varid(ncid,'il0_to_il1',il0_to_il1_id))
call ncerr(subr,nf90_inq_varid(ncid,'ic2il1_to_ic1',ic2il1_to_ic1_id))
call ncerr(subr,nf90_inq_varid(ncid,'ic1il1_to_is',ic1il1_to_is_id))
call ncerr(subr,nf90_inq_varid(ncid,'norm',norm_id))
if (nam%lsqrt) call ncerr(subr,nf90_inq_varid(ncid,'norm_sqrt',norm_sqrt_id))
call ncerr(subr,nf90_get_var(ncid,vbot_id,ndata%vbot))
call ncerr(subr,nf90_get_var(ncid,vtop_id,ndata%vtop))
call ncerr(subr,nf90_get_var(ncid,nc2_id,ndata%nc2))
call ncerr(subr,nf90_get_var(ncid,is_to_ic1_id,ndata%is_to_ic1))
call ncerr(subr,nf90_get_var(ncid,is_to_il1_id,ndata%is_to_il1))
call ncerr(subr,nf90_get_var(ncid,is_to_ic2_id,ndata%is_to_ic2))
call ncerr(subr,nf90_get_var(ncid,ic0il0_to_is_id,ndata%ic0il0_to_is))
call ncerr(subr,nf90_get_var(ncid,ic2il1_to_ic0_id,ndata%ic2il1_to_ic0))
call ncerr(subr,nf90_get_var(ncid,ic2il1_to_is_id,ndata%ic2il1_to_is))
call ncerr(subr,nf90_get_var(ncid,ic1_to_ic0_id,ndata%ic1_to_ic0))
call ncerr(subr,nf90_get_var(ncid,il1_to_il0_id,ndata%il1_to_il0))
call ncerr(subr,nf90_get_var(ncid,ic0_to_ic1_id,ndata%ic0_to_ic1))
call ncerr(subr,nf90_get_var(ncid,il0_to_il1_id,ndata%il0_to_il1))
call ncerr(subr,nf90_get_var(ncid,ic2il1_to_ic1_id,ndata%ic2il1_to_ic1))
call ncerr(subr,nf90_get_var(ncid,ic1il1_to_is_id,ndata%ic1il1_to_is))
call ncerr(subr,nf90_get_var(ncid,norm_id,ndata%norm))
if (nam%lsqrt) call ncerr(subr,nf90_get_var(ncid,norm_sqrt_id,ndata%norm_sqrt))

! Read linear operators
call linop_read(ncid,'c',ndata%c)
call linop_read(ncid,'h',ndata%h)
call linop_read(ncid,'v',ndata%v)
call linop_read(ncid,'s',ndata%s)

! Close file
call ncerr(subr,nf90_close(ncid))

! End associate
end associate

end subroutine ndata_read_param

!----------------------------------------------------------------------
! Subroutine: ndata_read_mpi
!> Purpose: read ndata object
!----------------------------------------------------------------------
subroutine ndata_read_mpi(ndataloc)

implicit none

! Passed variables
type(ndataloctype),intent(inout) :: ndataloc !< Sampling data, local

! Local variables
integer :: ncid,info
integer :: nc0a_id,nc1b_id,nl1_id,nsa_id,nsb_id
integer :: vbot_id,vtop_id,nc2b_id,isb_to_ic2b_id,isb_to_il1_id
integer :: isa_to_isb_id,isa_to_isc_id,isb_to_isc_id
integer :: norm_id
character(len=1) :: mpicomchar
character(len=4) :: nprocchar,myprocchar
character(len=1024) :: filename
character(len=1024) :: subr = 'ndata_read_mpi'

! Associate
associate(nam=>ndataloc%nam,geom=>ndataloc%geom)

! Open file and get dimensions
write(mpicomchar,'(i1)') nam%mpicom
write(nprocchar,'(i4.4)') nam%nproc
write(myprocchar,'(i4.4)') mpl%myproc
filename = trim(nam%prefix)//'_mpi-'//mpicomchar//'_'//nprocchar//'-'//myprocchar//'.nc'
call ncerr(subr,nf90_open(trim(nam%datadir)//'/'//trim(filename),nf90_nowrite,ncid))
call ncerr(subr,nf90_inq_dimid(ncid,'nc0a',nc0a_id))
call ncerr(subr,nf90_inquire_dimension(ncid,nc0a_id,len=geom%nc0a))
info = nf90_inq_dimid(ncid,'nc1b',nc1b_id)
if (info==nf90_noerr) then
   call ncerr(subr,nf90_inquire_dimension(ncid,nc1b_id,len=ndataloc%nc1b))
else
   ndataloc%nc1b = 0
end if
call ncerr(subr,nf90_inq_dimid(ncid,'nl1',nl1_id))
call ncerr(subr,nf90_inquire_dimension(ncid,nl1_id,len=ndataloc%nl1))
info = nf90_inq_dimid(ncid,'nsa',nsa_id)
if (info==nf90_noerr) then
   call ncerr(subr,nf90_inquire_dimension(ncid,nsa_id,len=ndataloc%nsa))
else
   ndataloc%nsa = 0
end if
info = nf90_inq_dimid(ncid,'nsb',nsb_id)
if (info==nf90_noerr) then
   call ncerr(subr,nf90_inquire_dimension(ncid,nsb_id,len=ndataloc%nsb))
else
   ndataloc%nsb = 0
end if
call ncerr(subr,nf90_get_att(ncid,nf90_global,'nsc',ndataloc%nsc))

! Allocation
if (ndataloc%nc1b>0) allocate(ndataloc%vbot(ndataloc%nc1b))
if (ndataloc%nc1b>0) allocate(ndataloc%vtop(ndataloc%nc1b))
allocate(ndataloc%nc2b(ndataloc%nl1))
if (ndataloc%nsb>0) allocate(ndataloc%isb_to_ic2b(ndataloc%nsb))
if (ndataloc%nsb>0) allocate(ndataloc%isb_to_il1(ndataloc%nsb))
if (ndataloc%nsa>0) allocate(ndataloc%isa_to_isb(ndataloc%nsa))
if (ndataloc%nsa>0) allocate(ndataloc%isa_to_isc(ndataloc%nsa))
if (ndataloc%nsb>0) allocate(ndataloc%isb_to_isc(ndataloc%nsb))
allocate(ndataloc%norm(geom%nc0a,geom%nl0))

! Read data
if (ndataloc%nc1b>0) call ncerr(subr,nf90_inq_varid(ncid,'vbot',vbot_id))
if (ndataloc%nc1b>0) call ncerr(subr,nf90_inq_varid(ncid,'vtop',vtop_id))
call ncerr(subr,nf90_inq_varid(ncid,'nc2b',nc2b_id))
if (ndataloc%nsb>0) call ncerr(subr,nf90_inq_varid(ncid,'isb_to_ic2b',isb_to_ic2b_id))
if (ndataloc%nsb>0) call ncerr(subr,nf90_inq_varid(ncid,'isb_to_il1',isb_to_il1_id))
if (ndataloc%nsa>0) call ncerr(subr,nf90_inq_varid(ncid,'isa_to_isb',isa_to_isb_id))
if (ndataloc%nsa>0) call ncerr(subr,nf90_inq_varid(ncid,'isa_to_isc',isa_to_isc_id))
if (ndataloc%nsb>0) call ncerr(subr,nf90_inq_varid(ncid,'isb_to_isc',isb_to_isc_id))
call ncerr(subr,nf90_inq_varid(ncid,'norm',norm_id))
if (ndataloc%nc1b>0) call ncerr(subr,nf90_get_var(ncid,vbot_id,ndataloc%vbot))
if (ndataloc%nc1b>0) call ncerr(subr,nf90_get_var(ncid,vtop_id,ndataloc%vtop))
call ncerr(subr,nf90_get_var(ncid,nc2b_id,ndataloc%nc2b))
if (ndataloc%nsb>0) call ncerr(subr,nf90_get_var(ncid,isb_to_ic2b_id,ndataloc%isb_to_ic2b))
if (ndataloc%nsb>0) call ncerr(subr,nf90_get_var(ncid,isb_to_il1_id,ndataloc%isb_to_il1))
if (ndataloc%nsa>0) call ncerr(subr,nf90_get_var(ncid,isa_to_isb_id,ndataloc%isa_to_isb))
if (ndataloc%nsa>0) call ncerr(subr,nf90_get_var(ncid,isa_to_isc_id,ndataloc%isa_to_isc))
if (ndataloc%nsb>0) call ncerr(subr,nf90_get_var(ncid,isb_to_isc_id,ndataloc%isb_to_isc))
call ncerr(subr,nf90_get_var(ncid,norm_id,ndataloc%norm))

! Read communications
call com_read(nam%nproc,ncid,'AB',ndataloc%AB)
call com_read(nam%nproc,ncid,'AC',ndataloc%AC)

! Read linear operators
call linop_read(ncid,'c',ndataloc%c)
call linop_read(ncid,'h',ndataloc%h)
call linop_read(ncid,'v',ndataloc%v)
call linop_read(ncid,'s',ndataloc%s)

! Close file
call ncerr(subr,nf90_close(ncid))

! End associate
end associate

end subroutine ndata_read_mpi

!----------------------------------------------------------------------
! Subroutine: ndata_write_param
!> Purpose: write ndata object
!----------------------------------------------------------------------
subroutine ndata_write_param(ndata)

implicit none

! Passed variables
type(ndatatype),intent(inout) :: ndata !< Sampling data

! Local variables
integer :: ncid
integer :: nc0_id,nc1_id,nl0_id,nl1_id,ns_id
integer :: vbot_id,vtop_id,nc2_id,is_to_ic1_id,is_to_il1_id,is_to_ic2_id,ic0il0_to_is_id,ic2il1_to_ic0_id
integer :: ic2il1_to_is_id,ic1_to_ic0_id,il1_to_il0_id,ic0_to_ic1_id,il0_to_il1_id,ic2il1_to_ic1_id
integer :: ic1il1_to_is_id,norm_id,norm_sqrt_id
character(len=1024) :: filename
character(len=1024) :: subr = 'ndata_write_param'

! Associate
associate(nam=>ndata%nam,geom=>ndata%geom)

! Processor verification
if (.not.mpl%main) call msgerror('only I/O proc should enter '//trim(subr))

! Create file
filename = trim(nam%prefix)//'_param.nc'
call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))

! Write namelist parameters
call namncwrite(nam,ncid)

! Define dimensions
call ncerr(subr,nf90_def_dim(ncid,'nc0',geom%nc0,nc0_id))
call ncerr(subr,nf90_def_dim(ncid,'nc1',ndata%nc1,nc1_id))
call ncerr(subr,nf90_def_dim(ncid,'nl0',geom%nl0,nl0_id))
call ncerr(subr,nf90_put_att(ncid,nf90_global,'nl0i',geom%nl0i))
call ncerr(subr,nf90_def_dim(ncid,'nl1',ndata%nl1,nl1_id))
call ncerr(subr,nf90_def_dim(ncid,'ns',ndata%ns,ns_id))

! Define variables
call ncerr(subr,nf90_def_var(ncid,'vbot',nf90_int,(/nc1_id/),vbot_id))
call ncerr(subr,nf90_def_var(ncid,'vtop',nf90_int,(/nc1_id/),vtop_id))
call ncerr(subr,nf90_def_var(ncid,'nc2',nf90_int,(/nl1_id/),nc2_id))
call ncerr(subr,nf90_def_var(ncid,'is_to_ic1',nf90_int,(/ns_id/),is_to_ic1_id))
call ncerr(subr,nf90_def_var(ncid,'is_to_il1',nf90_int,(/ns_id/),is_to_il1_id))
call ncerr(subr,nf90_def_var(ncid,'is_to_ic2',nf90_int,(/ns_id/),is_to_ic2_id))
call ncerr(subr,nf90_def_var(ncid,'ic0il0_to_is',nf90_int,(/nc0_id,nl0_id/),ic0il0_to_is_id))
call ncerr(subr,nf90_def_var(ncid,'ic2il1_to_ic0',nf90_int,(/nc1_id,nl1_id/),ic2il1_to_ic0_id))
call ncerr(subr,nf90_def_var(ncid,'ic2il1_to_is',nf90_int,(/nc1_id,nl1_id/),ic2il1_to_is_id))
call ncerr(subr,nf90_def_var(ncid,'ic1_to_ic0',nf90_int,(/nc1_id/),ic1_to_ic0_id))
call ncerr(subr,nf90_def_var(ncid,'il1_to_il0',nf90_int,(/nl1_id/),il1_to_il0_id))
call ncerr(subr,nf90_def_var(ncid,'ic0_to_ic1',nf90_int,(/nc0_id/),ic0_to_ic1_id))
call ncerr(subr,nf90_def_var(ncid,'il0_to_il1',nf90_int,(/nl0_id/),il0_to_il1_id))
call ncerr(subr,nf90_def_var(ncid,'ic2il1_to_ic1',nf90_int,(/nc1_id,nl1_id/),ic2il1_to_ic1_id))
call ncerr(subr,nf90_def_var(ncid,'ic1il1_to_is',nf90_int,(/nc1_id,nl1_id/),ic1il1_to_is_id))
call ncerr(subr,nf90_def_var(ncid,'norm',ncfloat,(/nc0_id,nl0_id/),norm_id))
if (nam%lsqrt) call ncerr(subr,nf90_def_var(ncid,'norm_sqrt',ncfloat,(/ns_id/),norm_sqrt_id))
call ncerr(subr,nf90_enddef(ncid))

! Write variables
call ncerr(subr,nf90_put_var(ncid,vbot_id,ndata%vbot))
call ncerr(subr,nf90_put_var(ncid,vtop_id,ndata%vtop))
call ncerr(subr,nf90_put_var(ncid,nc2_id,ndata%nc2))
call ncerr(subr,nf90_put_var(ncid,is_to_ic1_id,ndata%is_to_ic1))
call ncerr(subr,nf90_put_var(ncid,is_to_il1_id,ndata%is_to_il1))
call ncerr(subr,nf90_put_var(ncid,is_to_ic2_id,ndata%is_to_ic2))
call ncerr(subr,nf90_put_var(ncid,ic0il0_to_is_id,ndata%ic0il0_to_is))
call ncerr(subr,nf90_put_var(ncid,ic2il1_to_ic0_id,ndata%ic2il1_to_ic0))
call ncerr(subr,nf90_put_var(ncid,ic2il1_to_is_id,ndata%ic2il1_to_is))
call ncerr(subr,nf90_put_var(ncid,ic1_to_ic0_id,ndata%ic1_to_ic0))
call ncerr(subr,nf90_put_var(ncid,il1_to_il0_id,ndata%il1_to_il0))
call ncerr(subr,nf90_put_var(ncid,ic0_to_ic1_id,ndata%ic0_to_ic1))
call ncerr(subr,nf90_put_var(ncid,il0_to_il1_id,ndata%il0_to_il1))
call ncerr(subr,nf90_put_var(ncid,ic2il1_to_ic1_id,ndata%ic2il1_to_ic1))
call ncerr(subr,nf90_put_var(ncid,ic1il1_to_is_id,ndata%ic1il1_to_is))
call ncerr(subr,nf90_put_var(ncid,norm_id,ndata%norm))
if (nam%lsqrt) call ncerr(subr,nf90_put_var(ncid,norm_sqrt_id,ndata%norm_sqrt))

! Write linear operators
call linop_write(ncid,ndata%c)
call linop_write(ncid,ndata%h)
call linop_write(ncid,ndata%v)
call linop_write(ncid,ndata%s)

! Close file
call ncerr(subr,nf90_close(ncid))

! End associate
end associate

end subroutine ndata_write_param

!----------------------------------------------------------------------
! Subroutine: ndata_write_mpi
!> Purpose: write ndata object
!----------------------------------------------------------------------
subroutine ndata_write_mpi(ndataloc)

implicit none

! Passed variables
type(ndataloctype),intent(in) :: ndataloc !< Sampling data, local

! Local variables
integer :: ncid
integer :: nc0a_id,nl0_id,nc1b_id,nl1_id,nsa_id,nsb_id
integer :: vbot_id,vtop_id,nc2b_id,isb_to_ic2b_id,isb_to_il1_id
integer :: isa_to_isb_id,isa_to_isc_id,isb_to_isc_id
integer :: norm_id
character(len=1) :: mpicomchar
character(len=4) :: nprocchar,myprocchar
character(len=1024) :: filename
character(len=1024) :: subr = 'ndata_write_mpi'

! Associate
associate(nam=>ndataloc%nam,geom=>ndataloc%geom)

! Filename suffix
write(mpicomchar,'(i1)') nam%mpicom
write(nprocchar,'(i4.4)') nam%nproc

! Create file
write(myprocchar,'(i4.4)') mpl%myproc
filename = trim(nam%prefix)//'_mpi-'//mpicomchar//'_'//nprocchar//'-'//myprocchar//'.nc'
call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))

! Write namelist parameters
call namncwrite(nam,ncid)

! Define dimensions
call ncerr(subr,nf90_def_dim(ncid,'nc0a',geom%nc0a,nc0a_id))
call ncerr(subr,nf90_def_dim(ncid,'nl0',geom%nl0,nl0_id))
call ncerr(subr,nf90_put_att(ncid,nf90_global,'nl0i',geom%nl0i))
if (ndataloc%nc1b>0) call ncerr(subr,nf90_def_dim(ncid,'nc1b',ndataloc%nc1b,nc1b_id))
call ncerr(subr,nf90_def_dim(ncid,'nl1',ndataloc%nl1,nl1_id))
if (ndataloc%nsa>0) call ncerr(subr,nf90_def_dim(ncid,'nsa',ndataloc%nsa,nsa_id))
if (ndataloc%nsb>0) call ncerr(subr,nf90_def_dim(ncid,'nsb',ndataloc%nsb,nsb_id))
call ncerr(subr,nf90_put_att(ncid,nf90_global,'nsc',ndataloc%nsc))

! Define variables
if (ndataloc%nc1b>0) call ncerr(subr,nf90_def_var(ncid,'vbot',nf90_int,(/nc1b_id/),vbot_id))
if (ndataloc%nc1b>0) call ncerr(subr,nf90_def_var(ncid,'vtop',nf90_int,(/nc1b_id/),vtop_id))
call ncerr(subr,nf90_def_var(ncid,'nc2b',nf90_int,(/nl1_id/),nc2b_id))
if (ndataloc%nsb>0) call ncerr(subr,nf90_def_var(ncid,'isb_to_ic2b',nf90_int,(/nsb_id/),isb_to_ic2b_id))
if (ndataloc%nsb>0) call ncerr(subr,nf90_def_var(ncid,'isb_to_il1',nf90_int,(/nsb_id/),isb_to_il1_id))
if (ndataloc%nsa>0) call ncerr(subr,nf90_def_var(ncid,'isa_to_isb',nf90_int,(/nsa_id/),isa_to_isb_id))
if (ndataloc%nsa>0) call ncerr(subr,nf90_def_var(ncid,'isa_to_isc',nf90_int,(/nsa_id/),isa_to_isc_id))
if (ndataloc%nsb>0) call ncerr(subr,nf90_def_var(ncid,'isb_to_isc',nf90_int,(/nsb_id/),isb_to_isc_id))
call ncerr(subr,nf90_def_var(ncid,'norm',ncfloat,(/nc0a_id,nl0_id/),norm_id))
if (ndataloc%nsa>0) call ncerr(subr,nf90_put_att(ncid,isa_to_isb_id,'_FillValue',msvali))
if (ndataloc%nsa>0) call ncerr(subr,nf90_put_att(ncid,isa_to_isc_id,'_FillValue',msvali))
if (ndataloc%nsb>0) call ncerr(subr,nf90_put_att(ncid,isb_to_isc_id,'_FillValue',msvali))
call ncerr(subr,nf90_put_att(ncid,norm_id,'_FillValue',msvalr))
call ncerr(subr,nf90_enddef(ncid))

! Write variables
if (ndataloc%nc1b>0) call ncerr(subr,nf90_put_var(ncid,vbot_id,ndataloc%vbot))
if (ndataloc%nc1b>0) call ncerr(subr,nf90_put_var(ncid,vtop_id,ndataloc%vtop))
call ncerr(subr,nf90_put_var(ncid,nc2b_id,ndataloc%nc2b))
if (ndataloc%nsb>0) call ncerr(subr,nf90_put_var(ncid,isb_to_ic2b_id,ndataloc%isb_to_ic2b))
if (ndataloc%nsb>0) call ncerr(subr,nf90_put_var(ncid,isb_to_il1_id,ndataloc%isb_to_il1))
if (ndataloc%nsa>0) call ncerr(subr,nf90_put_var(ncid,isa_to_isb_id,ndataloc%isa_to_isb))
if (ndataloc%nsa>0) call ncerr(subr,nf90_put_var(ncid,isa_to_isc_id,ndataloc%isa_to_isc))
if (ndataloc%nsb>0) call ncerr(subr,nf90_put_var(ncid,isb_to_isc_id,ndataloc%isb_to_isc))
call ncerr(subr,nf90_put_var(ncid,norm_id,ndataloc%norm))

! Write communications
call com_write(nam%nproc,ncid,ndataloc%AB)
call com_write(nam%nproc,ncid,ndataloc%AC)

! Write linear operators
call linop_write(ncid,ndataloc%c)
call linop_write(ncid,ndataloc%h)
call linop_write(ncid,ndataloc%v)
call linop_write(ncid,ndataloc%s)

! Close file
call ncerr(subr,nf90_close(ncid))

! End associate
end associate

end subroutine ndata_write_mpi

!----------------------------------------------------------------------
! Subroutine: ndata_write_mpi_summary
!> Purpose: write ndata object
!----------------------------------------------------------------------
subroutine ndata_write_mpi_summary(ndata)

implicit none

! Passed variables
type(ndatatype),intent(in) :: ndata !< Sampling data

! Local variables
integer :: ncid
integer :: nc0_id
integer :: lon_id,lat_id,ic0_to_iproc_id,halo_id
character(len=1) :: mpicomchar
character(len=4) :: nprocchar
character(len=1024) :: filename
character(len=1024) :: subr = 'ndata_write_mpi_summary'

! Associate
associate(nam=>ndata%nam,geom=>ndata%geom)

! Processor verification
if (.not.mpl%main) call msgerror('only I/O proc should enter '//trim(subr))

! Filename suffix
write(mpicomchar,'(i1)') nam%mpicom
write(nprocchar,'(i4.4)') nam%nproc

! Create summary file
write(mpicomchar,'(i1)') nam%mpicom
write(nprocchar,'(i4.4)') nam%nproc
filename = trim(nam%prefix)//'_mpi-'//mpicomchar//'_'//nprocchar//'_summary.nc'
call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))

! Write namelist parameters
call namncwrite(nam,ncid)

! Define dimensions
call ncerr(subr,nf90_def_dim(ncid,'nc0',geom%nc0,nc0_id))

! Define variables
call ncerr(subr,nf90_def_var(ncid,'lon',ncfloat,(/nc0_id/),lon_id))
call ncerr(subr,nf90_def_var(ncid,'lat',ncfloat,(/nc0_id/),lat_id))
call ncerr(subr,nf90_def_var(ncid,'ic0_to_iproc',nf90_int,(/nc0_id/),ic0_to_iproc_id))
call ncerr(subr,nf90_def_var(ncid,'halo',nf90_int,(/nc0_id/),halo_id))
call ncerr(subr,nf90_enddef(ncid))

! Write variables
call ncerr(subr,nf90_put_var(ncid,lon_id,ndata%geom%lon*rad2deg))
call ncerr(subr,nf90_put_var(ncid,lat_id,ndata%geom%lat*rad2deg))
call ncerr(subr,nf90_put_var(ncid,ic0_to_iproc_id,ndata%geom%ic0_to_iproc))
call ncerr(subr,nf90_put_var(ncid,halo_id,ndata%halo))

! Close summary file
call ncerr(subr,nf90_close(ncid))

! End associate
end associate

end subroutine ndata_write_mpi_summary

end module type_ndata
