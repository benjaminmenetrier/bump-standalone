!----------------------------------------------------------------------
! Module: type_ens
! Purpose: ensemble derived type
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
module type_ens

use fckit_mpi_module, only: fckit_mpi_sum
use tools_const, only: deg2rad
use model_interface, only: model_read
use tools_kinds, only: kind_real
use tools_missing, only: msi,msr,isnotmsi
use type_geom, only: geom_type
use type_io, only: io_type
use type_mpl, only: mpl_type
use type_nam, only: nam_type

implicit none

! Ensemble derived type
type ens_type
   ! Attributes
   integer :: ne                                  ! Ensemble size
   integer :: nsub                                ! Number of sub-ensembles

   ! Data
   real(kind_real),allocatable :: fld(:,:,:,:,:)  ! Ensemble perturbation
   real(kind_real),allocatable :: mean(:,:,:,:,:) ! Ensemble mean
contains
   procedure :: alloc => ens_alloc
   procedure :: dealloc => ens_dealloc
   procedure :: load => ens_load
   procedure :: copy => ens_copy
   procedure :: remove_mean => ens_remove_mean
   procedure :: from => ens_from
   procedure :: apply_bens => ens_apply_bens
   procedure :: cortrack => ens_cortrack
end type ens_type

private
public :: ens_type

contains

!----------------------------------------------------------------------
! Subroutine: ens_alloc
! Purpose: ensemble data allocation
!----------------------------------------------------------------------
subroutine ens_alloc(ens,nam,geom,ne,nsub)

implicit none

! Passed variables
class(ens_type),intent(inout) :: ens ! Ensemble
type(nam_type),intent(in) :: nam     ! Namelist
type(geom_type),intent(in) :: geom   ! Geometry
integer,intent(in) :: ne             ! Ensemble size
integer,intent(in) :: nsub           ! Number of sub-ensembles

! Allocate
if (ne>0) then
   allocate(ens%fld(geom%nc0a,geom%nl0,nam%nv,nam%nts,ne))
   allocate(ens%mean(geom%nc0a,geom%nl0,nam%nv,nam%nts,nsub))
end if

! Initialization
ens%ne = ne
ens%nsub = nsub
if (ens%ne>0) then
   call msr(ens%fld)
   call msr(ens%mean)
end if

end subroutine ens_alloc

!----------------------------------------------------------------------
! Subroutine: ens_dealloc
! Purpose: ensemble data deallocation
!----------------------------------------------------------------------
subroutine ens_dealloc(ens)

implicit none

! Passed variables
class(ens_type),intent(inout) :: ens ! Ensemble

! Release memory
if (allocated(ens%fld)) deallocate(ens%fld)
if (allocated(ens%mean)) deallocate(ens%mean)

end subroutine ens_dealloc

!----------------------------------------------------------------------
! Subroutine: ens_load
! Purpose: load ensemble data
!----------------------------------------------------------------------
subroutine ens_load(ens,mpl,nam,geom,filename)

implicit none

! Passed variables
class(ens_type),intent(inout) :: ens    ! Ensemble
type(mpl_type),intent(inout) :: mpl     ! MPI data
type(nam_type),intent(in) :: nam        ! Namelist
type(geom_type),intent(in) :: geom      ! Geometry
character(len=*),intent(in) :: filename ! Filename ('ens1' or 'ens2')

! Local variables
integer :: ne,ne_offset,nsub,isub,jsub,ie,ietot

! Setup
select case (trim(filename))
case ('ens1')
   ne = nam%ens1_ne
   ne_offset = nam%ens1_ne_offset
   nsub = nam%ens1_nsub
case ('ens2')
   ne = nam%ens2_ne
   ne_offset = nam%ens2_ne_offset
   nsub = nam%ens2_nsub
case default
   call msi(ne)
   call msi(ne_offset)
   call msi(nsub)
   call mpl%abort('wrong filename in ens_load')
end select

! Allocation
call ens%alloc(nam,geom,ne,nsub)

! Initialization
call msr(ens%fld)
ietot = 1

! Loop over sub-ensembles
do isub=1,ens%nsub
   if (ens%nsub==1) then
      write(mpl%info,'(a7,a)',advance='no') '','Full ensemble, member:'
   else
      write(mpl%info,'(a7,a,i4,a)',advance='no') '','Sub-ensemble ',isub,', member:'
   end if
   call flush(mpl%info)

   ! Loop over members for a given sub-ensemble
   do ie=1,ens%ne/ens%nsub
      write(mpl%info,'(i4)',advance='no') ne_offset+ie
      call flush(mpl%info)

      ! Read member
      if (ens%nsub==1) then
         jsub = 0
      else
         jsub = isub
      end if
      call model_read(mpl,nam,geom,filename,ne_offset+ie,jsub,ens%fld(:,:,:,:,ietot))

      ! Update
      ietot = ietot+1
   end do
   write(mpl%info,'(a)') ''
   call flush(mpl%info)
end do

end subroutine ens_load

!----------------------------------------------------------------------
! Subroutine: ens_copy
! Purpose: ensemble data copy
!----------------------------------------------------------------------
subroutine ens_copy(ens_out,ens_in)

implicit none

! Passed variables
class(ens_type),intent(inout) :: ens_out ! Ensemble
type(ens_type),intent(in) :: ens_in      ! Ensemble

! Allocate
if (ens_in%ne>0) then
   allocate(ens_out%fld(size(ens_in%fld,1),size(ens_in%fld,2),size(ens_in%fld,3),size(ens_in%fld,4),size(ens_in%fld,5)))
   allocate(ens_out%mean(size(ens_in%mean,1),size(ens_in%mean,2),size(ens_in%mean,3),size(ens_in%mean,4),size(ens_in%mean,5)))
end if

! Initialization
ens_out%ne = ens_in%ne
ens_out%nsub = ens_in%nsub
if (ens_in%ne>0) then
   ens_out%fld = ens_in%fld
   ens_out%mean = ens_in%mean
end if

end subroutine ens_copy

!----------------------------------------------------------------------
! Subroutine: ens_remove_mean
! Purpose: remove ensemble mean
!----------------------------------------------------------------------
subroutine ens_remove_mean(ens)

implicit none

! Passed variables
class(ens_type),intent(inout) :: ens ! Ensemble

! Local variables
integer :: isub,ie_sub,ie

if (ens%ne>0) then
   ! Loop over sub-ensembles
   do isub=1,ens%nsub
      ! Compute mean
      ens%mean(:,:,:,:,isub) = 0.0
      do ie_sub=1,ens%ne/ens%nsub
         ie = ie_sub+(isub-1)*ens%ne/ens%nsub
         ens%mean(:,:,:,:,isub) = ens%mean(:,:,:,:,isub)+ens%fld(:,:,:,:,ie)
      end do
      ens%mean(:,:,:,:,isub) = ens%mean(:,:,:,:,isub)/(ens%ne/ens%nsub)

      ! Remove mean
      do ie_sub=1,ens%ne/ens%nsub
         ie = ie_sub+(isub-1)*ens%ne/ens%nsub
         ens%fld(:,:,:,:,ie) = ens%fld(:,:,:,:,ie)-ens%mean(:,:,:,:,isub)
      end do
   end do
end if

end subroutine ens_remove_mean

!----------------------------------------------------------------------
! Subroutine: ens_from
! Purpose: copy ensemble array into ensemble data
!----------------------------------------------------------------------
subroutine ens_from(ens,nam,geom,ne,ens_mga)

implicit none

! Passed variables
class(ens_type),intent(inout) :: ens                                        ! Ensemble
type(nam_type),intent(in) :: nam                                            ! Namelist
type(geom_type),intent(in) :: geom                                          ! Geometry
integer,intent(in) :: ne                                                    ! Ensemble size
real(kind_real),intent(in) :: ens_mga(geom%nmga,geom%nl0,nam%nv,nam%nts,ne) ! Ensemble on model grid, halo A

! Local variables
integer :: ie,its,iv,il0

! Allocation
call ens%alloc(nam,geom,ne,1)

if (ens%ne>0) then
   ! Copy
   do ie=1,ens%ne
      do its=1,nam%nts
         do iv=1,nam%nv
            do il0=1,geom%nl0
               ens%fld(:,il0,iv,its,ie) = ens_mga(geom%c0a_to_mga,il0,iv,its,ie)
            end do
         end do
      end do
   end do

   ! Remove mean
   call ens%remove_mean
end if

end subroutine ens_from

!----------------------------------------------------------------------
! Subroutine: ens_apply_bens
! Purpose: apply raw ensemble covariance
!----------------------------------------------------------------------
subroutine ens_apply_bens(ens,mpl,nam,geom,fld)

implicit none

! Passed variables
class(ens_type),intent(in) :: ens                                       ! Ensemble
type(mpl_type),intent(in) :: mpl                                        ! MPI data
type(nam_type),intent(in) :: nam                                        ! Namelist
type(geom_type),intent(in) :: geom                                      ! Geometry
real(kind_real),intent(inout) :: fld(geom%nc0a,geom%nl0,nam%nv,nam%nts) ! Field

! Local variable
integer :: ie,ic0a,il0,iv,its
real(kind_real) :: alpha,norm
real(kind_real) :: fld_copy(geom%nc0a,geom%nl0,nam%nv,nam%nts)
real(kind_real) :: pert(geom%nc0a,geom%nl0,nam%nv,nam%nts)

! Initialization
fld_copy = fld

! Apply localized ensemble covariance formula
fld = 0.0
norm = sqrt(real(nam%ens1_ne-1,kind_real))
do ie=1,nam%ens1_ne
   ! Compute perturbation
   !$omp parallel do schedule(static) private(its,iv,il0,ic0a)
   do its=1,nam%nts
      do iv=1,nam%nv
         do il0=1,geom%nl0
            do ic0a=1,geom%nc0a
               if (geom%mask_c0a(ic0a,il0)) pert(ic0a,il0,iv,its) = ens%fld(ic0a,il0,iv,its,ie)/norm
            end do
         end do
      end do
   end do
   !$omp end parallel do

   ! Dot product
   call mpl%dot_prod(pert,fld_copy,alpha)

   ! Schur product
   fld = fld+alpha*pert
end do

end subroutine ens_apply_bens

!----------------------------------------------------------------------
! Subroutine: ens_cortrack
! Purpose: correlation tracker
!----------------------------------------------------------------------
subroutine ens_cortrack(ens,mpl,nam,geom,io)

implicit none

! Passed variables
class(ens_type),intent(in) :: ens   ! Ensemble
type(mpl_type),intent(inout) :: mpl ! MPI data
type(nam_type),intent(in) :: nam    ! Namelist
type(geom_type),intent(in) :: geom  ! Geometry
type(io_type),intent(in) :: io      ! I/O

! Local variable
integer :: ic0a_ct,il0_ct,iv_ct,ic0a,ic0,ie,its
integer :: nn_index(1)
real(kind_real) :: lon_ct,lat_ct,nn_dist(1),var_dirac
real(kind_real) :: var(geom%nc0a,geom%nl0,nam%nv,nam%nts)
real(kind_real) :: dirac(geom%nc0a,geom%nl0,nam%nv,nam%nts),fld(geom%nc0a,geom%nl0,nam%nv,nam%nts)
character(len=2) :: itschar
character(len=1024) :: filename

! Set dirac coordinates
lon_ct = 0.0
lat_ct = 50.0
il0_ct = 1
iv_ct = 1

! Convert to radian
lon_ct = lon_ct*deg2rad
lat_ct = lat_ct*deg2rad

! Find local dirac index
call geom%kdtree%find_nearest_neighbors(lon_ct,lat_ct,1,nn_index,nn_dist)
call msi(ic0a_ct)
do ic0a=1,geom%nc0a
   ic0 = geom%c0a_to_c0(ic0a)
   if (ic0==nn_index(1)) ic0a_ct = ic0a
end do

! Generate dirac field
dirac = 0.0
if (isnotmsi(ic0a_ct)) dirac(ic0a_ct,il0_ct,iv_ct,1) = 1.0

! Compute variance
var = 0.0
do ie=1,ens%ne
   var = var +ens%fld(:,:,:,:,ie)**2
end do
var = var/real(ens%ne-ens%nsub,kind_real)
call mpl%f_comm%allreduce(sum(dirac*var),var_dirac,fckit_mpi_sum())

! Apply raw ensemble covariance
fld = dirac
call ens%apply_bens(mpl,nam,geom,fld)

! Normalize
fld = fld/sqrt(var*var_dirac)

! Write field
filename = trim(nam%prefix)//'_cortrack'
do its=1,nam%nts
   write(itschar,'(i2.2)') its
   call io%fld_write(mpl,nam,geom,filename,'fld_'//itschar,fld(:,:,iv_ct,its))
end do

end subroutine ens_cortrack

end module type_ens
