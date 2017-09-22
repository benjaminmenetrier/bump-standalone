!----------------------------------------------------------------------
! Module: module_mpi.f90
!> Purpose: compute NICAS parameters MPI distribution
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module module_mpi

use module_namelist, only: namtype
use netcdf
use omp_lib
use tools_const, only: pi,rad2deg,req,sphere_dist
use tools_display, only: msgerror,prog_init,prog_print
use tools_missing, only: msvali,msvalr,msi,msr,isnotmsr,isnotmsi
use tools_nc, only: ncfloat,ncerr
use type_com, only: comtype,com_dealloc,com_copy,com_setup
use type_linop, only: linop_alloc,linop_copy,linop_reorder
use type_mpl, only: mpl,mpl_barrier
use type_ndata, only: ndatatype,ndataloctype
use type_randgen, only: initialize_sampling

implicit none

! Conversion derived type (private to module_mpi)
type convtype
   integer,allocatable :: isa_to_is(:)   !< Subgrid, halo A to global
   integer,allocatable :: is_to_isa(:)   !< Subgrid, global to halo A
   integer,allocatable :: isb_to_is(:)   !< Subgrid, halo B to global
   integer,allocatable :: is_to_isb(:)   !< Subgrid, global to halo B
   integer,allocatable :: isc_to_is(:)   !< Subgrid, halo C to global
   integer,allocatable :: is_to_isc(:)   !< Subgrid, global to halo C
end type

private
public :: compute_mpi

contains

!----------------------------------------------------------------------
! Subroutine: compute_mpi
!> Purpose: compute NICAS MPI distribution
!----------------------------------------------------------------------
subroutine compute_mpi(ndata,ndataloc)

implicit none

! Passed variables
type(ndatatype),intent(inout) :: ndata       !< Sampling data
type(ndataloctype),intent(inout) :: ndataloc !< Sampling data, local

! Local variables
integer :: il0i,ic0,ic0a,ic1,ic2,jc2,ic1b,ic2b,il0,il1,isa,isb,isc,i_s,i_s_loc,is,js,jproc,s_n_s_max,s_n_s_max_loc
integer :: interph_row_proc(ndata%h(1)%n_s,ndata%geom%nl0i)
integer,allocatable :: ic1b_to_ic1(:),ic1_to_ic1b(:),ic2il1_to_ic2b(:,:)
integer,allocatable :: interph_i_s_lg(:,:),interps_i_s_lg(:,:),convol_i_s_lg(:)
logical :: lcheck_nc1b(ndata%nc1),lcheck_nc2b(ndata%nc1,ndata%nl1)
logical :: lcheck_nsa(ndata%ns),lcheck_nsb(ndata%ns),lcheck_nsc(ndata%ns)
logical :: lcheck_h(ndata%h(1)%n_s,ndata%geom%nl0i),lcheck_c(ndata%c%n_s)
logical,allocatable :: lcheck_s(:,:)
type(comtype) :: comAB(ndata%nam%nproc),comAC(ndata%nam%nproc)
type(convtype) :: conv(ndata%nam%nproc)

! Associate
associate(nam=>ndata%nam,geom=>ndata%geom)

! Allocation
s_n_s_max = 0
do il1=1,ndata%nl1
   s_n_s_max = max(s_n_s_max,ndata%s(il1)%n_s)
end do
allocate(lcheck_s(s_n_s_max,ndata%nl1))

! Find on which processor are the grid-points and what is their local index for interpolation
do il0i=1,geom%nl0i
   interph_row_proc(1:ndata%h(il0i)%n_s,il0i) = geom%ic0_to_iproc(ndata%h(il0i)%row)
end do

   ! Copy number of levels
   ndataloc%nl1 = ndata%nl1

   ! Allocation
   allocate(ndataloc%nc2b(ndataloc%nl1))
   allocate(ndataloc%h(geom%nl0i))
   allocate(ndataloc%s(ndataloc%nl1))

   ! Halo definitions

   ! Halo A
   lcheck_nsa = .false.
   do is=1,ndata%ns
      ic1 = ndata%is_to_ic1(is)
      ic0 = ndata%ic1_to_ic0(ic1)
      il1 = ndata%is_to_il1(is)
      il0 = ndata%il1_to_il0(il1)
      if (geom%mask(ic0,il0).and.(geom%ic0_to_iproc(ic0)==mpl%myproc)) lcheck_nsa(is) = .true.
   end do
   ndataloc%nsa = count(lcheck_nsa)

   ! Halo B

   ! Horizontal interpolation
   lcheck_h = .false.
   lcheck_nc1b = .false.
   do il0i=1,geom%nl0i
      do i_s=1,ndata%h(il0i)%n_s
         if (interph_row_proc(i_s,il0i)==mpl%myproc) then
            ic1 = ndata%h(il0i)%col(i_s)
            lcheck_h(i_s,il0i) = .true.
            lcheck_nc1b(ic1) = .true.
         end if
      end do
      ndataloc%h(il0i)%n_s = count(lcheck_h(:,il0i))
   end do
   ndataloc%nc1b = count(lcheck_nc1b)

   ! Subsampling horizontal interpolation
   lcheck_nc2b = .false.
   lcheck_nsb = .false.
   lcheck_s = .false.
   s_n_s_max_loc = 0
   do il1=1,ndataloc%nl1
      do i_s=1,ndata%s(il1)%n_s
         ic1 = ndata%s(il1)%row(i_s)
         if (lcheck_nc1b(ic1)) then
            jc2 = ndata%s(il1)%col(i_s)
            js = ndata%ic2il1_to_is(jc2,il1)
            lcheck_nc2b(jc2,il1) = .true.
            lcheck_nsb(js) = .true.
            lcheck_s(i_s,il1) = .true.
         end if
      end do
      ndataloc%nc2b(il1) = count(lcheck_nc2b(:,il1))
      ndataloc%s(il1)%n_s = count(lcheck_s(:,il1))
      s_n_s_max_loc = max(s_n_s_max_loc,ndataloc%s(il1)%n_s)
   end do
   ndataloc%nsb = count(lcheck_nsb)

   ! Halo C
   if (nam%mpicom==1) then
      ! 1 communication step
      lcheck_nsc = lcheck_nsb
      lcheck_c = .false.
      do i_s=1,ndata%c%n_s
         is = ndata%c%row(i_s)
         js = ndata%c%col(i_s)
         if (lcheck_nsb(is).or.lcheck_nsb(js)) then
            lcheck_nsc(is) = .true.
            lcheck_nsc(js) = .true.
            lcheck_c(i_s) = .true.
         end if
      end do
   elseif (nam%mpicom==2) then
      ! 2 communication steps
      lcheck_nsc = lcheck_nsb
      lcheck_c = .false.
      do i_s=1,ndata%c%n_s
         is = ndata%c%row(i_s)
         js = ndata%c%col(i_s)
         if (lcheck_nsa(is).or.lcheck_nsa(js)) then
            lcheck_nsc(is) = .true.
            lcheck_nsc(js) = .true.
            lcheck_c(i_s) = .true.
         end if
      end do
   end if
   ndataloc%nsc = count(lcheck_nsc)
   ndataloc%c%n_s = count(lcheck_c)

   ! Check halos consistency
   do is=1,ndata%ns
      if (lcheck_nsa(is).and.(.not.lcheck_nsb(is))) then
         call msgerror('point in halo A but not in halo B')
      end if
      if (lcheck_nsa(is).and.(.not.lcheck_nsc(is))) then
         call msgerror('point in halo A but not in halo C')
      end if
      if (lcheck_nsb(is).and.(.not.lcheck_nsc(is))) then
         call msgerror('point in halo B but not in halo C')
      end if
   end do

   ! Global <-> local conversions for fields

   ! Halo A
   if (ndataloc%nsa>0) allocate(conv(mpl%myproc)%isa_to_is(ndataloc%nsa))
   allocate(conv(mpl%myproc)%is_to_isa(ndata%ns))
   call msi(conv(mpl%myproc)%is_to_isa)
   isa = 0
   do is=1,ndata%ns
      if (lcheck_nsa(is)) then
         isa = isa+1
         if (ndataloc%nsa>0) conv(mpl%myproc)%isa_to_is(isa) = is
         conv(mpl%myproc)%is_to_isa(is) = isa
      end if
   end do

   ! Halo B
   if (ndataloc%nc1b>0) allocate(ic1b_to_ic1(ndataloc%nc1b))
   allocate(ic1_to_ic1b(ndata%nc1))
   call msi(ic1_to_ic1b)
   ic1b = 0
   do ic1=1,ndata%nc1
      if (lcheck_nc1b(ic1)) then
         ic1b = ic1b+1
         if (ndataloc%nc1b>0) ic1b_to_ic1(ic1b) = ic1
         ic1_to_ic1b(ic1) = ic1b
      end if
   end do

   allocate(ic2il1_to_ic2b(ndata%nc1,ndata%nl1))
   call msi(ic2il1_to_ic2b)
   do il1=1,ndataloc%nl1
      if (ndataloc%nc2b(il1)>0) then
         ic2b = 0
         do ic2=1,ndata%nc2(il1)
            if (lcheck_nc2b(ic2,il1)) then
               ic2b = ic2b+1
               ic2il1_to_ic2b(ic2,il1) = ic2b
            end if
         end do
      end if
   end do

   if (ndataloc%nsb>0) allocate(conv(mpl%myproc)%isb_to_is(ndataloc%nsb))
   allocate(conv(mpl%myproc)%is_to_isb(ndata%ns))
   call msi(conv(mpl%myproc)%is_to_isb)
   isb = 0
   do is=1,ndata%ns
      if (lcheck_nsb(is)) then
         isb = isb+1
         if (ndataloc%nsb>0) conv(mpl%myproc)%isb_to_is(isb) = is
         conv(mpl%myproc)%is_to_isb(is) = isb
      end if
   end do

   ! Halo C
   if (ndataloc%nsc>0) allocate(conv(mpl%myproc)%isc_to_is(ndataloc%nsc))
   allocate(conv(mpl%myproc)%is_to_isc(ndata%ns))
   call msi(conv(mpl%myproc)%is_to_isc)
   isc = 0
   do is=1,ndata%ns
      if (lcheck_nsc(is)) then
         isc = isc+1
         if (ndataloc%nsc>0) conv(mpl%myproc)%isc_to_is(isc) = is
         conv(mpl%myproc)%is_to_isc(is) = isc
      end if
   end do

   ! Inter-halo conversions
   if ((ndataloc%nsa>0).and.(ndataloc%nsb>0).and.(ndataloc%nsc>0)) then
      allocate(ndataloc%isa_to_isb(ndataloc%nsa))
      allocate(ndataloc%isa_to_isc(ndataloc%nsa))
      do isa=1,ndataloc%nsa
         is = conv(mpl%myproc)%isa_to_is(isa)
         isb = conv(mpl%myproc)%is_to_isb(is)
         isc = conv(mpl%myproc)%is_to_isc(is)
         ndataloc%isa_to_isb(isa) = isb
         ndataloc%isa_to_isc(isa) = isc
      end do
      allocate(ndataloc%isb_to_isc(ndataloc%nsb))
      do isb=1,ndataloc%nsb
         is = conv(mpl%myproc)%isb_to_is(isb)
         isc = conv(mpl%myproc)%is_to_isc(is)
         ndataloc%isb_to_isc(isb) = isc
      end do
   end if

   ! Global <-> local conversions for data
   allocate(interph_i_s_lg(ndataloc%h(1)%n_s,geom%nl0i))
   do il0i=1,geom%nl0i
      i_s_loc = 0
      do i_s=1,ndata%h(il0i)%n_s
         if (lcheck_h(i_s,il0i)) then
            i_s_loc = i_s_loc+1
            interph_i_s_lg(i_s_loc,il0i) = i_s
         end if
      end do
   end do
   if (s_n_s_max_loc>0) then
      allocate(interps_i_s_lg(s_n_s_max_loc,ndataloc%nl1))
      do il1=1,ndataloc%nl1
         i_s_loc = 0
         do i_s=1,ndata%s(il1)%n_s
            if (lcheck_s(i_s,il1)) then
               i_s_loc = i_s_loc+1
               interps_i_s_lg(i_s_loc,il1) = i_s
            end if
         end do
      end do
   end if
   if (ndataloc%c%n_s>0) then
      allocate(convol_i_s_lg(ndataloc%c%n_s))
      i_s_loc = 0
      do i_s=1,ndata%c%n_s
         if (lcheck_c(i_s)) then
            i_s_loc = i_s_loc+1
            convol_i_s_lg(i_s_loc) = i_s
         end if
      end do
   end if

   ! Number of cells
   ndataloc%nc0a = geom%mpl%myproc_to_nc0a(mpl%myproc)

   ! Local data

   ! Horizontal interpolation
   do il0i=1,geom%nl0i
      ndataloc%h(il0i)%prefix = 'h'
      ndataloc%h(il0i)%n_src = ndataloc%nc1b
      ndataloc%h(il0i)%n_dst = ndataloc%nc0a
      call linop_alloc(ndataloc%h(il0i))
      do i_s_loc=1,ndataloc%h(il0i)%n_s
         i_s = interph_i_s_lg(i_s_loc,il0i)
         ndataloc%h(il0i)%row(i_s_loc) = geom%ic0_to_ic0a(ndata%h(il0i)%row(i_s))
         ndataloc%h(il0i)%col(i_s_loc) = ic1_to_ic1b(ndata%h(il0i)%col(i_s))
         ndataloc%h(il0i)%S(i_s_loc) = ndata%h(il0i)%S(i_s)
      end do
      call linop_reorder(ndataloc%h(il0i))
   end do

   ! Vertical interpolation
   call linop_copy(ndata%v,ndataloc%v)
   if (ndataloc%nc1b>0) then
      allocate(ndataloc%vbot(ndataloc%nc1b))
      allocate(ndataloc%vtop(ndataloc%nc1b))
      ndataloc%vbot = ndata%vbot(ic1b_to_ic1)
      ndataloc%vtop = ndata%vtop(ic1b_to_ic1)
   end if

   ! Subsampling horizontal interpolation
   do il1=1,ndata%nl1
      ndataloc%s(il1)%prefix = 's'
      ndataloc%s(il1)%n_src = ndataloc%nc2b(il1)
      ndataloc%s(il1)%n_dst = ndataloc%nc1b
      if (ndataloc%s(il1)%n_s>0) then
         call linop_alloc(ndataloc%s(il1))
         do i_s_loc=1,ndataloc%s(il1)%n_s
            i_s = interps_i_s_lg(i_s_loc,il1)
            ndataloc%s(il1)%row(i_s_loc) = ic1_to_ic1b(ndata%s(il1)%row(i_s))
            ndataloc%s(il1)%col(i_s_loc) = ic2il1_to_ic2b(ndata%s(il1)%col(i_s),il1)
            ndataloc%s(il1)%S(i_s_loc) = ndata%s(il1)%S(i_s)
         end do
         call linop_reorder(ndataloc%s(il1))
      end if
   end do

   ! Copy
   if (ndataloc%nsb>0) then
      allocate(ndataloc%isb_to_ic2b(ndataloc%nsb))
      allocate(ndataloc%isb_to_il1(ndataloc%nsb))
      call msi(ndataloc%isb_to_ic2b)
      do isb=1,ndataloc%nsb
         is = conv(mpl%myproc)%isb_to_is(isb)
         il1 = ndata%is_to_il1(is)
         ic2 = ndata%is_to_ic2(is)
         ic2b = ic2il1_to_ic2b(ic2,il1)
         ndataloc%isb_to_ic2b(isb) = ic2b
         ndataloc%isb_to_il1(isb) = il1
      end do
   end if

   ! Convolution
   if (ndataloc%c%n_s>0) then
      ndataloc%c%prefix = 'c'
      ndataloc%c%n_src = ndataloc%nsc
      ndataloc%c%n_dst = ndataloc%nsc
      call linop_alloc(ndataloc%c)
      do i_s_loc=1,ndataloc%c%n_s
         i_s = convol_i_s_lg(i_s_loc)
         ndataloc%c%row(i_s_loc) = conv(mpl%myproc)%is_to_isc(ndata%c%row(i_s))
         ndataloc%c%col(i_s_loc) = conv(mpl%myproc)%is_to_isc(ndata%c%col(i_s))
         ndataloc%c%S(i_s_loc) = ndata%c%S(i_s)
      end do
      call linop_reorder(ndataloc%c)
   end if

   ! Print local parameters
   write(mpl%unit,'(a7,a,i4)') '','Local parameters for processor #',mpl%myproc
   write(mpl%unit,'(a10,a,i8)') '','nc0a =      ',ndataloc%nc0a
   write(mpl%unit,'(a10,a,i8)') '','nc1b =      ',ndataloc%nc1b
   do il1=1,ndataloc%nl1
      write(mpl%unit,'(a10,a,i3,a,i8)') '','nc2b(',il1,') =  ',ndataloc%nc2b(il1)
   end do
   write(mpl%unit,'(a10,a,i8)') '','nsa =       ',ndataloc%nsa
   write(mpl%unit,'(a10,a,i8)') '','nsb =       ',ndataloc%nsb
   write(mpl%unit,'(a10,a,i8)') '','nsc =       ',ndataloc%nsc
   do il0i=1,geom%nl0i
      write(mpl%unit,'(a10,a,i3,a,i8)') '','h(',il0i,')%n_s = ',ndataloc%h(il0i)%n_s
   end do
   write(mpl%unit,'(a10,a,i8)') '','v%n_s =     ',ndataloc%v%n_s
   do il1=1,ndataloc%nl1
      write(mpl%unit,'(a10,a,i3,a,i8)') '','s(',il1,')%n_s = ',ndataloc%s(il1)%n_s
   end do
   write(mpl%unit,'(a10,a,i8)') '','c%n_s =     ',ndataloc%c%n_s

   if (mpl%myproc==nam%nproc/2) then
      ! Illustration
      allocate(ndata%halo(geom%nc0))
      ndata%halo = 0
      do i_s=1,ndataloc%c%n_s
         ic0 = ndata%ic1_to_ic0(ndata%is_to_ic1(conv(mpl%myproc)%isc_to_is(ndataloc%c%row(i_s))))
         ndata%halo(ic0) = 1
         ic0 = ndata%ic1_to_ic0(ndata%is_to_ic1(conv(mpl%myproc)%isc_to_is(ndataloc%c%col(i_s))))
         ndata%halo(ic0) = 1
      end do
      do i_s=1,ndataloc%h(1)%n_s
         ic0 = ndata%ic1_to_ic0(ic1b_to_ic1(ndataloc%h(1)%col(i_s)))
         ndata%halo(ic0) = 2
      end do
      do isa=1,ndataloc%nsa
         ic0 = ndata%ic1_to_ic0(ndata%is_to_ic1(conv(mpl%myproc)%isa_to_is(isa)))
         ndata%halo(ic0) = 3
      end do
   end if

   ! Release memory
   deallocate(ic2il1_to_ic2b)
   if (ndataloc%nc1b>0) then
      deallocate(ic1b_to_ic1)
      deallocate(ic1_to_ic1b)
   end if
   deallocate(interph_i_s_lg)
   if (s_n_s_max_loc>0) deallocate(interps_i_s_lg)
   if (ndataloc%c%n_s>0) deallocate(convol_i_s_lg)
end do

! Copy norm over processors
allocate(ndataloc%norm(ndataloc%nc0a,geom%nl0))
if (nam%lsqrt) allocate(ndataloc%norm_sqrt(ndataloc%nsb))
do ic0=1,geom%nc0
   if (geom%ic0_to_iproc(ic0)==mpl%myproc) then
      ic0a = geom%ic0_to_ic0a(ic0)
      ndataloc%norm(ic0a,1:geom%nl0) = ndata%norm(ic0,1:geom%nl0)
   end if
end do
if (nam%lsqrt) then
   do isb=1,ndataloc%nsb
      is = conv(mpl%myproc)%isb_to_is(isb)
      ndataloc%norm_sqrt(isb) = ndata%norm_sqrt(is)
   end do
end if

! Allocation
comAB(mpl%myproc)%nred = ndataloc%nsa
comAB(mpl%myproc)%next = ndataloc%nsb
allocate(comAB(mpl%myproc)%iext_to_iproc(comAB(mpl%myproc)%next))
allocate(comAB(mpl%myproc)%iext_to_ired(comAB(mpl%myproc)%next))
allocate(comAB(mpl%myproc)%ired_to_iext(comAB(mpl%myproc)%nred))
comAC(mpl%myproc)%nred = ndataloc%nsa
comAC(mpl%myproc)%next = ndataloc%nsc
allocate(comAC(mpl%myproc)%iext_to_iproc(comAC(mpl%myproc)%next))
allocate(comAC(mpl%myproc)%iext_to_ired(comAC(mpl%myproc)%next))
allocate(comAC(mpl%myproc)%ired_to_iext(comAC(mpl%myproc)%nred))

! Initialization
do isb=1,ndataloc%nsb
   ! Check for points that are in zone B but are not in zone A
   is = conv(mpl%myproc)%isb_to_is(isb)
   ic1 = ndata%is_to_ic1(is)
   ic0 = ndata%ic1_to_ic0(ic1)
   jproc = geom%ic0_to_iproc(ic0)
   comAB(mpl%myproc)%iext_to_iproc(isb) = jproc
   isa = conv(jproc)%is_to_isa(is)
   comAB(mpl%myproc)%iext_to_ired(isb) = isa
end do
comAB(mpl%myproc)%ired_to_iext = ndataloc%isa_to_isb
do isc=1,ndataloc%nsc
   ! Check for points that are in zone C but are not in zone A
   is = conv(mpl%myproc)%isc_to_is(isc)
   ic1 = ndata%is_to_ic1(is)
   ic0 = ndata%ic1_to_ic0(ic1)
   jproc = geom%ic0_to_iproc(ic0)
   isa =  conv(jproc)%is_to_isa(is)
   comAC(mpl%myproc)%iext_to_iproc(isc) = jproc
   comAC(mpl%myproc)%iext_to_ired(isc) = isa
end do
comAC(mpl%myproc)%ired_to_iext = ndataloc%isa_to_isc

! Communication broadcast TODO
call com_bcast(nam%nproc,comAB)
call com_bcast(nam%nproc,comAC)

! Communications setup
call com_setup(nam%nproc,comAB)
call com_setup(nam%nproc,comAC)

! Communications copy
comAB(mpl%myproc)%prefix = 'AB'
call com_copy(nam%nproc,comAB(mpl%myproc),ndataloc%AB)
comAC(mpl%myproc)%prefix = 'AC'
call com_copy(nam%nproc,comAC(mpl%myproc),ndataloc%AC)

! Release memory
call com_dealloc(comAB(mpl%myproc))
call com_dealloc(comAC(mpl%myproc))

! End associate
end associate

end subroutine compute_mpi

end module module_mpi
