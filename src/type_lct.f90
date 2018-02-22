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

use hdiag_tools, only: diag_com_lg
use model_interface, only: model_write
use tools_const, only: req,reqkm
use hdiag_tools, only: diag_filter,diag_interpolation
use tools_kinds, only: kind_real
use tools_missing, only: msr,isnotmsr,isallnotmsr
use type_hdata, only: hdatatype
use type_mpl, only: mpl

implicit none

! LCT data derived type
type lcttype
   ! LCT structure
   integer :: nscales                       !< Number of LCT scales
   integer,allocatable :: ncomp(:)          !< Number of LCT components
   real(kind_real),allocatable :: H(:)      !< LCT components
   real(kind_real),allocatable :: coef(:)   !< LCT coefficients

   ! LCT fit
   real(kind_real),allocatable :: raw(:,:)  !< Raw correlations
   real(kind_real),allocatable :: norm(:,:) !< Norm to take nsub into account
   real(kind_real),allocatable :: fit(:,:)  !< Fitted correlations
contains
   procedure :: lct_alloc_base
   procedure :: lct_alloc_block
   generic :: alloc => lct_alloc_base,lct_alloc_block
   procedure :: dealloc => lct_dealloc
end type lcttype

logical,parameter :: write_cor = .true. !< Write raw and fitted correlations

private
public :: lcttype
public :: lct_write

contains

!----------------------------------------------------------------------
! Subroutine: lct_alloc_base
!> Purpose: lct object base allocation
!----------------------------------------------------------------------
subroutine lct_alloc_base(lct,hdata)

implicit none

! Passed variables
class(lcttype),intent(inout) :: lct !< LCT
type(hdatatype),intent(in) :: hdata !< HDIAG data

! Local variables
integer :: iscales

! Associate
associate(nam=>hdata%nam)

! Number of scales and components
lct%nscales = nam%lct_nscales
allocate(lct%ncomp(lct%nscales))
do iscales=1,lct%nscales
   if (nam%lct_diag(iscales)) then
      lct%ncomp(iscales) = 3
   else
      lct%ncomp(iscales) = 4
   end if
end do

! Allocation
allocate(lct%H(sum(lct%ncomp)))
allocate(lct%coef(lct%nscales))

! Initialization
call msr(lct%H)
call msr(lct%coef)

! End associate
end associate

end subroutine lct_alloc_base

!----------------------------------------------------------------------
! Subroutine: lct_alloc_block
!> Purpose: lct object block allocation
!----------------------------------------------------------------------
subroutine lct_alloc_block(lct,hdata,ib)

implicit none

! Passed variables
class(lcttype),intent(inout) :: lct !< LCT
type(hdatatype),intent(in) :: hdata !< HDIAG data
integer,intent(in) :: ib            !< Block index

! Associate
associate(nam=>hdata%nam,bpar=>hdata%bpar)

! Basic allocation
call lct%alloc(hdata)

! Allocation
allocate(lct%raw(nam%nc3,bpar%nl0r(ib)))
allocate(lct%norm(nam%nc3,bpar%nl0r(ib)))
allocate(lct%fit(nam%nc3,bpar%nl0r(ib)))

! Initialization
lct%raw = 0.0
lct%norm = 0.0
call msr(lct%fit)

! End associate
end associate

end subroutine lct_alloc_block

!----------------------------------------------------------------------
! Subroutine: lct_dealloc
!> Purpose: lct object deallocation
!----------------------------------------------------------------------
subroutine lct_dealloc(lct)

implicit none

! Passed variables
class(lcttype),intent(inout) :: lct !< LCT

! Release memory
if (allocated(lct%ncomp)) deallocate(lct%ncomp)
if (allocated(lct%H)) deallocate(lct%H)
if (allocated(lct%coef)) deallocate(lct%coef)
if (allocated(lct%raw)) deallocate(lct%raw)
if (allocated(lct%norm)) deallocate(lct%norm)
if (allocated(lct%fit)) deallocate(lct%fit)

end subroutine lct_dealloc

!----------------------------------------------------------------------
! Subroutine: lct_write
!> Purpose: interpolate and write LCT
!----------------------------------------------------------------------
subroutine lct_write(hdata,lct)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata                                   !< HDIAG data
type(lcttype),intent(in) :: lct(hdata%nc1a,hdata%geom%nl0,hdata%bpar%nb) !< LCT array

! Local variables
integer :: ib,iv,il0,jl0r,jl0,ic1a,ic1,jc3,icomp,ic0,iscales,offset,i,iproc
real(kind_real) :: fac,det,rmse,rmse_count,rmse_tot,rmse_countg
real(kind_real),allocatable :: fld_c1a(:,:,:),fld_com(:,:),fld_c1(:,:,:),fld_c1_tmp(:,:),fld(:,:,:)
real(kind_real),allocatable :: sbuf(:),rbuf(:)
logical :: valid
logical,allocatable :: free(:,:)
character(len=1) :: iscaleschar

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

do ib=1,bpar%nb
   write(mpl%unit,'(a7,a,a)') '','Block: ',trim(bpar%blockname(ib))

   ! Initialization
   offset = 0

   do iscales=1,lct(1,1,ib)%nscales
      ! Allocation
      allocate(fld_c1a(hdata%nc1a,geom%nl0,lct(1,1,ib)%ncomp(iscales)+1))
      if (mpl%main) then
         allocate(fld_c1(nam%nc1,geom%nl0,lct(1,1,ib)%ncomp(iscales)+1))
         allocate(fld_c1_tmp(nam%nc1,lct(1,1,ib)%ncomp(iscales)+1))
         allocate(fld(geom%nc0,geom%nl0,lct(1,1,ib)%ncomp(iscales)+2))
      end if

      ! Copy
      do il0=1,geom%nl0
         do ic1a=1,hdata%nc1a
            fld_c1a(ic1a,il0,1:lct(1,1,ib)%ncomp(iscales)) = lct(ic1a,il0,ib)%H(offset+1:offset+lct(1,1,ib)%ncomp(iscales))
            fld_c1a(ic1a,il0,lct(1,1,ib)%ncomp(iscales)+1) = lct(ic1a,il0,ib)%coef(iscales)
         end do
      end do

      ! Local to global
      do icomp=1,lct(1,1,ib)%ncomp(iscales)+1
         ! Allocation
         allocate(fld_com(hdata%nc1a,geom%nl0))

         ! Copy
         fld_com = fld_c1a(:,:,icomp)

         ! Communication
         call diag_com_lg(hdata,fld_com)

         if (mpl%main) then
            ! Copy
            fld_c1(:,:,icomp) = fld_com

            ! Release memory
            deallocate(fld_com)
         end if
      end do

      if (mpl%main) then
         do il0=1,geom%nl0
            write(mpl%unit,'(a10,a,i3,a)') '','Level ',nam%levs(il0),': '

            ! Initialization
            fld_c1_tmp = fld_c1(:,il0,:)
            fac = 1.0

            ! Check invalid points
            valid = .true.
            do ic1=1,nam%nc1
               if (geom%mask(hdata%c1_to_c0(ic1),il0).and.(.not.isallnotmsr(fld_c1_tmp(ic1,:)))) valid = .false.
            end do

            do while (.not.valid)
               ! Copy
               fld_c1_tmp = fld_c1(:,il0,:)

               ! Filter LCT
               write(mpl%unit,'(a13,a,f9.2,a)') '','Filter LCT with radius ',fac*nam%diag_rhflt*reqkm,' km'
               do icomp=1,lct(1,1,ib)%ncomp(iscales)+1
                  call diag_filter(hdata,il0,'median',fac*nam%diag_rhflt,fld_c1_tmp(:,icomp))
                  call diag_filter(hdata,il0,'average',fac*nam%diag_rhflt,fld_c1_tmp(:,icomp))
               end do

               ! Check invalid points
               valid = .true.
               do ic1=1,nam%nc1
                  if (geom%mask(hdata%c1_to_c0(ic1),il0).and.(.not.isallnotmsr(fld_c1_tmp(ic1,:)))) valid = .false.
               end do

               ! Update fac (increase smoothing)
               fac = 2.0*fac
            end do

            ! Copy
            fld_c1(:,il0,:) = fld_c1_tmp
         end do

         ! Interpolate LCT
         write(mpl%unit,'(a10,a)') '','Interpolate LCT'
         do icomp=1,lct(1,1,ib)%ncomp(iscales)+1
            call diag_interpolation(hdata,fld_c1(:,:,icomp),fld(:,:,icomp))
         end do

         ! Compute horizontal length-scale
         do il0=1,geom%nl0
            do ic0=1,geom%nc0
               if (geom%mask(ic0,il0)) then
                  ! Compute determinant
                  if (lct(1,1,ib)%ncomp(iscales)==3) then
                     det = fld(ic0,il0,1)*fld(ic0,il0,2)
                  else
                     det = fld(ic0,il0,1)*fld(ic0,il0,2)-fld(ic0,il0,4)**2
                  end if

                  ! Length-scale = determinant^{1/4}
                  if (det>0.0) fld(ic0,il0,lct(1,1,ib)%ncomp(iscales)+2) = 1.0/sqrt(sqrt(det))
               end if
            end do
         end do

         ! Write LCT
         write(mpl%unit,'(a10,a)') '','Write LCT'
         iv = bpar%b_to_v2(ib)
         write(iscaleschar,'(i1)') iscales
         call model_write(nam,geom,trim(nam%prefix)//'_lct_gridded.nc',trim(nam%varname(iv))//'_H11_'//iscaleschar, &
       & fld(:,:,1)/req**2)
         call model_write(nam,geom,trim(nam%prefix)//'_lct_gridded.nc',trim(nam%varname(iv))//'_H22_'//iscaleschar, &
       & fld(:,:,2)/req**2)
         call model_write(nam,geom,trim(nam%prefix)//'_lct_gridded.nc',trim(nam%varname(iv))//'_H33_'//iscaleschar, &
       & fld(:,:,3))
         if (lct(1,1,ib)%ncomp(iscales)==4) call model_write(nam,geom,trim(nam%prefix)//'_lct_gridded.nc', &
       & trim(nam%varname(iv))//'_Hc12_'//iscaleschar,fld(:,:,4))
         call model_write(nam,geom,trim(nam%prefix)//'_lct_gridded.nc',trim(nam%varname(iv))//'_coef_'//iscaleschar, &
       & fld(:,:,lct(1,1,ib)%ncomp(iscales)+1))
         call model_write(nam,geom,trim(nam%prefix)//'_lct_gridded.nc',trim(nam%varname(iv))//'_Lh_'//iscaleschar, &
       & fld(:,:,lct(1,1,ib)%ncomp(iscales)+2)*reqkm)
      end if

      ! Release memory
      deallocate(fld_c1a)
      if (mpl%main) then
         deallocate(fld_c1_tmp)
         deallocate(fld_c1)
         deallocate(fld)
      end if
   end do

   ! Compute RMSE
   rmse = 0.0
   rmse_count = 0.0
   do il0=1,geom%nl0
      do ic1a=1,hdata%nc1a
         ic1 = hdata%c1a_to_c1(ic1a)
         do jl0r=1,bpar%nl0r(ib)
            jl0 = bpar%l0rl0b_to_l0(jl0r,il0,ib)
            do jc3=1,nam%nc3
               if (hdata%c1l0_log(ic1,il0).and.hdata%c1c3l0_log(ic1,jc3,jl0)) then
                  if (isnotmsr(lct(ic1a,il0,ib)%fit(jc3,jl0))) then
                     rmse = rmse+(lct(ic1a,il0,ib)%fit(jc3,jl0)-lct(ic1a,il0,ib)%raw(jc3,jl0))**2
                     rmse_count = rmse_count+1.0
                  end if
               end if
            end do
         end do
      end do
   end do
   call mpl%allreduce_sum(rmse,rmse_tot)
   call mpl%allreduce_sum(rmse_count,rmse_countg)
   if (rmse_countg>0.0) rmse_tot = sqrt(rmse_tot/rmse_countg)
   write(mpl%unit,'(a7,a,e15.8,a,i8,a)') '','LCT diag RMSE: ',rmse_tot,' for ',int(rmse_countg),' diagnostic points'

   if (write_cor) then
      ! Allocation
      allocate(free(geom%nc0,geom%nl0))
      if (mpl%main) then
         allocate(rbuf(nam%nc3*bpar%nl0r(ib)*2))
         allocate(fld(geom%nc0,geom%nl0,2))
      end if

      ! Select level
      il0 = 1

      ! Prepare field
      if (mpl%main) call msr(fld)
      free = .true.
      do ic1=1,nam%nc1
         ! Select tensor to plot
         valid  = .true.
         do jl0r=1,bpar%nl0r(ib)
            jl0 = bpar%l0rl0b_to_l0(jl0r,il0,ib)
            do jc3=1,nam%nc3
               if (valid.and.hdata%c1l0_log(ic1,il0).and.hdata%c1c3l0_log(ic1,jc3,jl0)) &
            &  valid = valid.and.free(hdata%c1c3_to_c0(ic1,jc3),jl0)
            end do
         end do

         if (valid) then
            ! Find processor
            iproc = hdata%c2_to_proc(ic1)
            if (iproc==mpl%myproc) then
               ! Allocate buffer
               allocate(sbuf(nam%nc3*bpar%nl0r(ib)*2))

               ! Prepare buffer
               call msr(sbuf)
               ic1a = hdata%c1_to_c1a(ic1)
               i = 1
               do jl0r=1,bpar%nl0r(ib)
                  jl0 = bpar%l0rl0b_to_l0(jl0r,il0,ib)
                  do jc3=1,nam%nc3
                     if (hdata%c1l0_log(ic1,il0).and.hdata%c1c3l0_log(ic1,jc3,jl0)) then
                        sbuf(i) = lct(ic1a,il0,ib)%raw(jc3,jl0)
                        sbuf(i+1) = lct(ic1a,il0,ib)%fit(jc3,jl0)
                     end if
                     i = i+2
                  end do
               end do
            end if

            if (mpl%main) then
               if (iproc==mpl%ioproc) then
                  ! Copy
                  rbuf = sbuf
               else
                  ! Receive data
                  call mpl%recv(nam%nc3*bpar%nl0r(ib)*2,rbuf,iproc,mpl%tag)
               end if

               ! Fill field
               i = 1
               do jl0r=1,bpar%nl0r(ib)
                  jl0 = bpar%l0rl0b_to_l0(jl0r,il0,ib)
                  do jc3=1,nam%nc3
                     if (hdata%c1l0_log(ic1,il0).and.hdata%c1c3l0_log(ic1,jc3,jl0)) then
                        fld(hdata%c1c3_to_c0(ic1,jc3),jl0,1) = rbuf(i)
                        fld(hdata%c1c3_to_c0(ic1,jc3),jl0,2) = rbuf(i+1)
                     end if
                     i = i+2
                  end do
               end do
            else
               ! Send data
               if (iproc==mpl%myproc) call mpl%send(nam%nc3*bpar%nl0r(ib)*2,sbuf,mpl%ioproc,mpl%tag)
            end if
            mpl%tag = mpl%tag+1

            ! Release memory
            if (iproc==mpl%myproc) deallocate(sbuf)
         end if
      end do

     if (mpl%main) then
         ! Write LCT diagnostics
         write(mpl%unit,'(a7,a)') '','Write LCT diagnostics'
         iv = bpar%b_to_v2(ib)
         call model_write(nam,geom,trim(nam%prefix)//'_lct_gridded.nc',trim(nam%varname(iv))//'_raw',fld(:,:,1))
         call model_write(nam,geom,trim(nam%prefix)//'_lct_gridded.nc',trim(nam%varname(iv))//'_fit',fld(:,:,2))

         ! Release memory
         deallocate(free)
         deallocate(rbuf)
         deallocate(fld)
      end if
   end if
end do

! End associate
end associate

end subroutine lct_write

end module type_lct

