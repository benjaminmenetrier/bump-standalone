!----------------------------------------------------------------------
! Module: type_ens
!> Purpose: ensemble derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module type_ens

use model_interface, only: model_read
use module_namelist, only: namtype
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use type_geom, only: geomtype,fld_com_gl,fld_com_lg
use type_mpl, only: mpl,mpl_bcast
implicit none

! Averaged statistics derived type
type enstype
   character(len=1024) :: filename
   integer :: ne                                !< Ensemble size
   integer :: ne_offset                                !< Ensemble size
   integer :: nsub                                !< Ensemble size
   real(kind_real),allocatable :: pert(:,:,:,:,:,:) !< Perturbations
   real(kind_real),allocatable :: mean(:,:,:,:)    !< Mean
end type enstype

private
public :: enstype
public :: ens_read,load_field

contains

!----------------------------------------------------------------------
! Subroutine: ens_read
!> Purpose: read ensemble
!----------------------------------------------------------------------
subroutine ens_read(nam,geom,filename,ens)

implicit none

! Passed variables
type(namtype),intent(in) :: nam
type(geomtype),intent(in) :: geom
character(len=*) :: filename
type(enstype),intent(inout) :: ens !< Ensemble

! Local variables
integer :: isub,jsub,ie,its,iv
real(kind_real),allocatable :: fld(:,:,:,:)

! Attributes
ens%filename = filename
select case (trim(filename))
case ('ens1')
   ens%ne = nam%ens1_ne
   ens%ne_offset = nam%ens1_ne_offset
   ens%nsub = nam%ens1_nsub
case ('ens2')
   ens%ne = nam%ens2_ne
   ens%ne_offset = nam%ens2_ne_offset
   ens%nsub = nam%ens2_nsub
case default
   call msgerror('wrong filename in ens_read')
end select

if (nam%limited_memory) then
   write(mpl%unit,'(a10,a)') '','Ensemble members will be read when needed (limited memory)'
else
   ! Allocation
   allocate(ens%pert(geom%nc0a,geom%nl0,nam%nv,nam%nts,ens%ne/ens%nsub,ens%nsub))
   allocate(ens%mean(geom%nc0a,geom%nl0,nam%nv,nam%nts))
   
   ! Initialization
   ens%mean = 0.0
   
   ! Loop over members
   do isub=1,ens%nsub
      if (ens%nsub==1) then
         write(mpl%unit,'(a10,a)',advance='no') '','Full ensemble '//trim(filename)//', member:'
      else
         write(mpl%unit,'(a10,a,i4,a)',advance='no') '','Sub-ensemble '//trim(filename)//'-',isub,' member:'
      end if
   
      do ie=1,ens%ne/ens%nsub
         write(mpl%unit,'(i4)',advance='no') ens%ne_offset+ie
   
         if (ens%nsub==1) then
            jsub = 0
         else
            jsub = isub
         end if
   
         if (mpl%main) then
            ! Allocation
            allocate(fld(geom%nc0,geom%nl0,nam%nv,nam%nts))
   
            ! Read data
            do its=1,nam%nts
               do iv=1,nam%nv
                  call model_read(nam,geom,filename,nam%varname(iv),nam%var3d(iv),nam%timeslot(its),ens%ne_offset+ie, &
                & jsub,fld(:,:,iv,its))
               end do
            end do
         end if
   
         ! Global to local
         call fld_com_gl(nam,geom,fld)
   
         ! Copy
         ens%pert(:,:,:,:,ie,isub) = fld
         ens%mean = ens%mean+fld
   
         ! Release memory
         deallocate(fld)
      end do
   end do
   write(mpl%unit,'(a)') ''
   
   ! Compute perturbations
   ens%mean = ens%mean/float(ens%ne)
   do isub=1,ens%nsub
      do ie=1,ens%ne/ens%nsub
         ens%pert(:,:,:,:,ie,isub) = ens%pert(:,:,:,:,ie,isub)-ens%mean
      end do
   end do
end if

end subroutine ens_read

!----------------------------------------------------------------------
! Subroutine: load_field
!> Purpose: load field, global
!----------------------------------------------------------------------
subroutine load_field(nam,geom,ens,iv,its,ie,isub,local,fld)

implicit none

! Passed variables
type(namtype),intent(in) :: nam
type(geomtype),intent(in) :: geom
type(enstype),intent(in) :: ens
integer,intent(in) :: iv
integer,intent(in) :: its
integer,intent(in) :: ie
integer,intent(in) :: isub
logical,intent(in) :: local
real(kind_real),allocatable :: fld(:,:)

! Local variables
integer :: jsub

! Deallocate
if (allocated(fld)) deallocate(fld)

if (local) then
   if (nam%limited_memory) then 
      if (mpl%main) then
         ! Allocation
         allocate(fld(geom%nc0,geom%nl0))

         ! Read field
         if (ens%nsub==1) then
            jsub = 0
         else
            jsub = isub
         end if
         call model_read(nam,geom,ens%filename,nam%varname(iv),nam%var3d(iv),nam%timeslot(its),ens%ne_offset+ie,jsub,fld)
      end if
   
      ! Global to local
      call fld_com_gl(geom,fld)
   else
      ! Allocation
      allocate(fld(geom%nc0a,geom%nl0))
   
      ! Copy field
      fld = ens%pert(:,:,iv,its,ie,isub)
   end if
else
   if (nam%limited_memory) then
      ! Allocation
      allocate(fld(geom%nc0,geom%nl0))
   
      if (mpl%main) then
         ! Read field
         if (ens%nsub==1) then
            jsub = 0
         else
            jsub = isub
         end if
         call model_read(nam,geom,ens%filename,nam%varname(iv),nam%var3d(iv),nam%timeslot(its),ens%ne_offset+ie,jsub,fld)
      end if
   else
      ! Allocation
      allocate(fld(geom%nc0a,geom%nl0))
   
      ! Copy field
      fld = ens%pert(:,:,iv,its,ie,isub)
   
      ! Local to global
      call fld_com_lg(geom,fld)

      ! Allocation
      if (.not.mpl%main) allocate(fld(geom%nc0,geom%nl0))
   end if
   
   ! Broadcast
   call mpl_bcast(fld,mpl%ioproc)
end if

end subroutine load_field

end module type_ens
