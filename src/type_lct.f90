!----------------------------------------------------------------------
! Module: type_lct
!> Purpose: LCT data derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module type_lct

use model_interface, only: model_write
use module_diag_tools, only: diag_filter,diag_interpolation
use tools_const, only: req,reqkm
use tools_kinds, only: kind_real
use tools_interp, only: compute_grid_interp_bilin
use tools_missing, only: msr,isnotmsr,isallnotmsr
use type_hdata, only: hdatatype
use type_mpl, only: mpl

implicit none

! LCT data derived type
type lcttype
   integer :: npack                         !< Pack buffer size

   ! LCT coefficients
   real(kind_real) :: H(4)                  !< LCT components

   ! LCT fit
   real(kind_real),allocatable :: raw(:,:)  !< Raw correlations
   real(kind_real),allocatable :: norm(:,:) !< Norm to take nsub into account
   real(kind_real),allocatable :: fit(:,:)  !< Fitted correlations
end type lcttype

logical :: write_cor = .true. !< Write raw and fitted correlations

private
public :: lcttype
public :: lct_alloc,lct_dealloc,lct_pack,lct_unpack,lct_write

contains

!----------------------------------------------------------------------
! Subroutine: lct_alloc
!> Purpose: lct object allocation
!----------------------------------------------------------------------
subroutine lct_alloc(hdata,ib,lct)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< HDIAG data
integer,intent(in) :: ib            !< Block index
type(lcttype),intent(inout) :: lct  !< lct

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Allocation
allocate(lct%raw(nam%nc,bpar%nl0(ib)))
allocate(lct%norm(nam%nc,bpar%nl0(ib)))
allocate(lct%fit(nam%nc,bpar%nl0(ib)))

! Initialization
lct%npack = 4+nam%nc*bpar%nl0(ib)
call msr(lct%H)
lct%raw = 0.0
lct%norm = 0.0
call msr(lct%fit)

! End associate
end associate

end subroutine lct_alloc

!----------------------------------------------------------------------
! Subroutine: lct_dealloc
!> Purpose: lct object deallocation
!----------------------------------------------------------------------
subroutine lct_dealloc(lct)

implicit none

! Passed variables
type(lcttype),intent(inout) :: lct !< LCT

! Release memory
deallocate(lct%raw)
deallocate(lct%norm)
deallocate(lct%fit)

end subroutine lct_dealloc

!----------------------------------------------------------------------
! Subroutine: lct_pack
!> Purpose: LCT packing
!----------------------------------------------------------------------
subroutine lct_pack(hdata,ib,lct,buf)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata           !< HDIAG data
integer,intent(in) :: ib                      !< Block index
type(lcttype),intent(in) :: lct               !< LCT
real(kind_real),intent(out) :: buf(lct%npack) !< Buffer

! Local variables
integer :: offset

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Pack
offset = 0
buf(offset+1:offset+4) = lct%H
offset = offset+4
buf(offset+1:offset+nam%nc*bpar%nl0(ib)) = pack(lct%fit,.true.)

! End associate
end associate

end subroutine lct_pack

!----------------------------------------------------------------------
! Subroutine: lct_unpack
!> Purpose: LCT unpacking
!----------------------------------------------------------------------
subroutine lct_unpack(hdata,ib,lct,buf)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata          !< HDIAG data
integer,intent(in) :: ib                     !< Block index
type(lcttype),intent(inout) :: lct           !< LCT
real(kind_real),intent(in) :: buf(lct%npack) !< Buffer

! Local variables
integer :: offset
logical,allocatable :: mask_unpack(:,:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

! Allocation
allocate(mask_unpack(nam%nc,bpar%nl0(ib)))
mask_unpack = .true.

! Unpack
offset = 0
lct%H = buf(offset+1:offset+4)
offset = offset+4
lct%fit = unpack(buf(offset+1:offset+nam%nc*bpar%nl0(ib)),mask_unpack,lct%fit)

! End associate
end associate

end subroutine lct_unpack

!----------------------------------------------------------------------
! Subroutine: lct_write
!> Purpose: interpolate and write LCT
!----------------------------------------------------------------------
subroutine lct_write(hdata,lct)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata                                      !< HDIAG data
type(lcttype),intent(in) :: lct(hdata%nam%nc1,hdata%geom%nl0,hdata%bpar%nb) !< LCT array

! Local variables
integer :: ib,iv,il0,jl0,il0r,ic1,ic,i,ic0
real(kind_real) :: fac,fld_nc1(hdata%nam%nc1,hdata%geom%nl0,4),fld(hdata%geom%nc0,hdata%geom%nl0,5)
logical :: valid

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

do ib=1,bpar%nb
   ! Initialization
   fac = 1.0
   call msr(fld_nc1)

   do while (.not.isallnotmsr(fld_nc1))
      ! Copy LCT
      call msr(fld_nc1)
      do jl0=1,geom%nl0
         do ic1=1,nam%nc1
            fld_nc1(ic1,jl0,:) = lct(ic1,jl0,ib)%H
         end do
      end do

      ! Filter LCT
      write(mpl%unit,'(a7,a,f9.2,a)') '','Filter LCT with radius ',fac*nam%diag_rhflt*reqkm,' km'
      hdata%nc2 = nam%nc1
      do i=1,4
         call diag_filter(hdata,'median',fac*nam%diag_rhflt,fld_nc1(:,:,i))
         call diag_filter(hdata,'average',fac*nam%diag_rhflt,fld_nc1(:,:,i))
      end do

      ! Update fac (increase smoothing)
      fac = 2.0*fac
   end do

   ! Interpolate LCT
   write(mpl%unit,'(a7,a)') '','Interpolate LCT'
   do i=1,4
      call diag_interpolation(hdata,fld_nc1(:,:,i),fld(:,:,i))
   end do

   ! Compute horizontal length-scale
   do il0=1,geom%nl0
      do ic0=1,geom%nc0
         if (geom%mask(ic0,il0)) then
            if (fld(ic0,il0,1)*fld(ic0,il0,2)-fld(ic0,il0,4)**2>0.0) then
               fld(ic0,il0,5) = 1.0/sqrt(sqrt(fld(ic0,il0,1)*fld(ic0,il0,2)-fld(ic0,il0,4)**2))
            else
               write(mpl%unit,*) ic0,fld(ic0,il0,1),fld(ic0,il0,2),fld(ic0,il0,4),fld(ic0,il0,1)*fld(ic0,il0,2)-fld(ic0,il0,4)**2
            end if
         end if
      end do
   end do

   if (mpl%main) then
      ! Write LCT
      write(mpl%unit,'(a7,a)') '','Write LCT'
      iv = bpar%ib_to_iv(ib)
      call model_write(nam,geom,trim(nam%prefix)//'_lct.nc',trim(nam%varname(iv))//'_H11',fld(:,:,1)/req**2)
      call model_write(nam,geom,trim(nam%prefix)//'_lct.nc',trim(nam%varname(iv))//'_H22',fld(:,:,2)/req**2)
      call model_write(nam,geom,trim(nam%prefix)//'_lct.nc',trim(nam%varname(iv))//'_H33',fld(:,:,3))
      call model_write(nam,geom,trim(nam%prefix)//'_lct.nc',trim(nam%varname(iv))//'_H12',fld(:,:,4)/req**2)
      call model_write(nam,geom,trim(nam%prefix)//'_lct.nc',trim(nam%varname(iv))//'_Lh',fld(:,:,5)*reqkm)

      if (write_cor) then
         ! Select level
         jl0 = 1

         ! Write raw LCT
         write(mpl%unit,'(a7,a)') '','Write LCT diag'
         call msr(fld)
         do ic1=1,nam%nc1
            ! Check diagnostic area
            valid = .true.
            do il0r=1,bpar%nl0(ib)
               il0 = bpar%il0rjl0ib_to_il0(il0r,jl0,ib)
               do ic=1,nam%nc
                  if (valid.and.hdata%ic1il0_log(ic1,jl0).and.hdata%ic1icil0_log(ic1,ic,il0)) &
               &  valid = valid.and.(.not.isnotmsr(fld(hdata%ic1icil0_to_ic0(ic1,ic,il0),il0,1)))
               end do
            end do
            if (valid) then
               do il0r=1,bpar%nl0(ib)
                  il0 = bpar%il0rjl0ib_to_il0(il0r,jl0,ib)
                  do ic=1,nam%nc
                     if (hdata%ic1il0_log(ic1,jl0).and.hdata%ic1icil0_log(ic1,ic,il0)) then
                        fld(hdata%ic1icil0_to_ic0(ic1,ic,il0),il0,1) = lct(ic1,jl0,ib)%raw(ic,il0)
                        fld(hdata%ic1icil0_to_ic0(ic1,ic,il0),il0,2) = lct(ic1,jl0,ib)%fit(ic,il0)
                     end if
                  end do
               end do
            end if
         end do
         call model_write(nam,geom,trim(nam%prefix)//'_lct.nc',trim(nam%varname(iv))//'_raw',fld(:,:,1))
         call model_write(nam,geom,trim(nam%prefix)//'_lct.nc',trim(nam%varname(iv))//'_fit',fld(:,:,2))
      end if
   end if
end do

! End associate
end associate

end subroutine lct_write

end module type_lct
