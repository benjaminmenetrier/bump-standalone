!----------------------------------------------------------------------
! Module: hdiag_sampling.f90
!> Purpose: sampling routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module hdiag_sampling

use omp_lib
use tools_const, only: pi,req,deg2rad,sphere_dist,vector_product,vector_triple_product
use tools_display, only: prog_init,prog_print,msgerror,msgwarning,black,green,peach
use tools_icos, only: closest_icos,build_icos
use tools_interp, only: compute_grid_interp,check_arc
use tools_kinds, only: kind_real
use tools_missing, only: msi,isnotmsi
use tools_stripack, only: trans
use type_ctree, only: ctreetype
use type_hdata, only: hdatatype
use type_mpl, only: mpl
use type_rng, only: rng
implicit none

integer,parameter :: irmax = 10000 !< Maximum number of random number draws

private
public :: setup_sampling,compute_sampling_zs,compute_sampling_lct

contains

!----------------------------------------------------------------------
! Subroutine: setup_sampling
!> Purpose: setup sampling
!----------------------------------------------------------------------
subroutine setup_sampling(hdata)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata !< HDIAG data

! Local variables
integer :: info,ic0,il0,ic1,ic2,ildw,jc3,i_s,il0i,jc1,kc1,ic2a,iproc
integer :: mask_ind(hdata%nam%nc1)
integer,allocatable :: vbot(:),vtop(:),nn_c1_index(:),c2a_to_c2(:)
real(kind_real) :: rh0(hdata%geom%nc0,hdata%geom%nl0),dum(1)
real(kind_real),allocatable :: nn_c1_dist(:)
type(ctreetype) :: ctree_diag

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Check subsampling size
if (nam%nc1>maxval(count(geom%mask,dim=1))) then
   call msgwarning('nc1 is too large for then mask, reset nc1 to the largest possible value')
   nam%nc1 = maxval(count(geom%mask,dim=1))
end if

! Define nc2
if (nam%new_lct) then
   hdata%nc2 = nam%nc1
elseif (nam%local_diag) then
   hdata%nc2 = int(2.0*maxval(geom%area)/(sqrt(3.0)*(nam%local_rad)**2))
   write(mpl%unit,'(a7,a,i8)') '','Estimated nc2 from local diagnostic radius: ',hdata%nc2
   hdata%nc2 = min(hdata%nc2,nam%nc1)
   write(mpl%unit,'(a7,a,i8)') '','Final nc2: ',hdata%nc2
elseif (nam%displ_diag) then
   hdata%nc2 = nam%nc1
end if

! Allocation
call hdata%alloc

! Read or compute sampling data
info = 1
if (nam%sam_read) call hdata%read(info)
if (info==1) then
   ! Compute zero-separation sampling
   call compute_sampling_zs(hdata)

   if (nam%new_lct) then
      ! Compute LCT sampling
      call compute_sampling_lct(hdata)
   else
      ! Compute positive separation sampling
      call compute_sampling_ps(hdata)
   end if

   ! Compute sampling mask
   call compute_sampling_mask(hdata)
end if

if (nam%local_diag.or.nam%displ_diag) then
   if ((info==1).or.(info==2)) then
      ! Define subsampling
      write(mpl%unit,'(a7,a)') '','Define subsampling'
      mask_ind = 1
      rh0 = 1.0
      if (mpl%main) call rng%initialize_sampling(nam%nc1,dble(geom%lon(hdata%c1_to_c0)),dble(geom%lat(hdata%c1_to_c0)),mask_ind, &
    & rh0,nam%ntry,nam%nrep,hdata%nc2,hdata%c2_to_c1)
      call mpl%bcast(hdata%c2_to_c1,mpl%ioproc)
      hdata%c2_to_c0 = hdata%c1_to_c0(hdata%c2_to_c1)
   end if

   if ((info==1).or.(info==2).or.(info==3).or.(info==4)) then
      if (trim(nam%flt_type)/='none') then
         ! Create cover trees
         write(mpl%unit,'(a7,a)') '','Create cover trees'
         do il0=1,geom%nl0
            if ((il0==1).or.(geom%nl0i>1)) then
               write(mpl%unit,'(a10,a,i3)') '','Level ',nam%levs(il0)
               call ctree_diag%create(hdata%nc2,geom%lon(hdata%c2_to_c0),geom%lat(hdata%c2_to_c0), &
                          & hdata%c1l0_log(hdata%c2_to_c1,il0))
               do ic2=1,hdata%nc2
                  ic1 = hdata%c2_to_c1(ic2)
                  ic0 = hdata%c2_to_c0(ic2)
                  if (hdata%c1l0_log(ic1,il0)) call ctree_diag%find_nearest_neighbors(geom%lon(ic0),geom%lat(ic0), &
                   & hdata%nc2,hdata%nn_c2_index(:,ic2,il0),hdata%nn_c2_dist(:,ic2,il0))
               end do
               call ctree_diag%delete
            end if
         end do
      end if
   end if

   ! Compute sampling mesh and triangles list
   write(mpl%unit,'(a7,a)') '','Compute sampling mesh and triangles list'
   call hdata%mesh%create(hdata%nc2,geom%lon(hdata%c2_to_c0),geom%lat(hdata%c2_to_c0),.false.)
   call hdata%mesh%trlist

   if ((info==1).or.(info==2).or.(info==3)) then
      ! Allocation
      allocate(nn_c1_index(nam%nc1))
      allocate(nn_c1_dist(nam%nc1))
      allocate(vbot(hdata%nc2))
      allocate(vtop(hdata%nc2))

      ! Compute nearest neighbors
      write(mpl%unit,'(a7,a)') '','Compute nearest neighbors'
      do il0i=1,geom%nl0i
         write(mpl%unit,'(a10,a,i3)') '','Independent level ',il0i
         call ctree_diag%create(nam%nc1,geom%lon(hdata%c1_to_c0),geom%lat(hdata%c1_to_c0),hdata%c1l0_log(:,il0i))
         do ic2=1,hdata%nc2
            ic1 = hdata%c2_to_c1(ic2)
            ic0 = hdata%c2_to_c0(ic2)
            if (hdata%c1l0_log(ic1,il0i)) then
               ! Find nearest neighbors
               call ctree_diag%find_nearest_neighbors(geom%lon(ic0),geom%lat(ic0),nam%nc1,nn_c1_index,nn_c1_dist)

               do jc1=1,nam%nc1
                  kc1 = nn_c1_index(jc1)
                  hdata%local_mask(kc1,ic2,il0i) = (jc1==1).or.(nn_c1_dist(jc1)<min(nam%local_rad,hdata%mesh%bdist(ic2)))
                  hdata%displ_mask(kc1,ic2,il0i) = (jc1==1).or.(nn_c1_dist(jc1)<min(nam%displ_rad,hdata%mesh%bdist(ic2)))
               end do
            end if
         end do
         call ctree_diag%delete
      end do

      ! Initialize vbot and vtop
      vbot = 1
      vtop = geom%nl0

      ! Compute grid interpolation to Sc0
      call compute_grid_interp(geom,hdata%nc2,hdata%c2_to_c0,nam%mask_check,vbot,vtop,nam%diag_interp,hdata%h)

      ! Compute grid interpolation to Sc1
      do il0i=1,geom%nl0i
         hdata%s(il0i)%prefix = 's'
         hdata%s(il0i)%n_src = hdata%nc2
         hdata%s(il0i)%n_dst = nam%nc1
         hdata%s(il0i)%n_s = 0
         do i_s=1,hdata%h(il0i)%n_s
            do ic1=1,nam%nc1
               if (hdata%c1_to_c0(ic1)==hdata%h(il0i)%row(i_s)) hdata%s(il0i)%n_s = hdata%s(il0i)%n_s+1
            end do
         end do
         call hdata%s(il0i)%alloc
         hdata%s(il0i)%n_s = 0
         do i_s=1,hdata%h(il0i)%n_s
            do ic1=1,nam%nc1
               if (hdata%c1_to_c0(ic1)==hdata%h(il0i)%row(i_s)) then
                  hdata%s(il0i)%n_s = hdata%s(il0i)%n_s+1
                  hdata%s(il0i)%row(hdata%s(il0i)%n_s) = ic1
                  hdata%s(il0i)%col(hdata%s(il0i)%n_s) = hdata%h(il0i)%col(i_s)
                  hdata%s(il0i)%S(hdata%s(il0i)%n_s) = hdata%h(il0i)%S(i_s)
               end if
            end do
         end do
      end do

      ! Release memory
      deallocate(nn_c1_index)
      deallocate(nn_c1_dist)
      deallocate(vbot)
      deallocate(vtop)
   end if

   ! MPI splitting
   do ic2=1,hdata%nc2
      ic0 = hdata%c2_to_c0(ic2)
      hdata%c2_to_proc(ic2) = geom%c0_to_proc(ic0)
   end do
   do iproc=1,mpl%nproc
      hdata%proc_to_nc2a(iproc) = count(hdata%c2_to_proc==iproc)
   end do
   hdata%nc2a = hdata%proc_to_nc2a(mpl%myproc)
   allocate(hdata%c2a_to_c2(hdata%nc2a))
   ic2a = 0
   do ic2=1,hdata%nc2
      if (hdata%c2_to_proc(ic2)==mpl%myproc) then
         ic2a = ic2a+1
         hdata%c2a_to_c2(ic2a) = ic2
      end if
   end do

   if (mpl%main) then
      do iproc=1,mpl%nproc
         ! Allocation
         allocate(c2a_to_c2(hdata%proc_to_nc2a(iproc)))

         if (iproc==mpl%ioproc) then
            ! Copy data
            c2a_to_c2 = hdata%c2a_to_c2
         else
            ! Receive data
            call mpl%recv(hdata%proc_to_nc2a(iproc),c2a_to_c2,iproc,mpl%tag)
         end if

         ! Translate index
         do ic2a=1,hdata%proc_to_nc2a(iproc)
            hdata%c2_to_c2a(c2a_to_c2(ic2a)) = ic2a
         end do

         ! Release memory
         deallocate(c2a_to_c2)
      end do
   else
      ! Send data
      call mpl%send(hdata%nc2a,hdata%c2a_to_c2,mpl%ioproc,mpl%tag)
   end if
   mpl%tag = mpl%tag+1
   write(mpl%unit,'(a7,a,i8)') '','Local nc2a: ',hdata%nc2a
end if

! Write sampling data
if (nam%sam_write.and.mpl%main) call hdata%write

! Compute nearest neighbors for local diagnostics output
if (nam%local_diag.and.(nam%nldwv>0)) then
   write(mpl%unit,'(a7,a)') '','Compute nearest neighbors for local diagnostics output'
   allocate(hdata%nn_ldwv_index(nam%nldwv))
   call ctree_diag%create(hdata%nc2,geom%lon(hdata%c2_to_c0), &
                geom%lat(hdata%c2_to_c0),hdata%c1l0_log(hdata%c2_to_c1,1))
   do ildw=1,nam%nldwv
      call ctree_diag%find_nearest_neighbors(nam%lon_ldwv(ildw)*deg2rad,nam%lat_ldwv(ildw)*deg2rad, &
    & 1,hdata%nn_ldwv_index(ildw:ildw),dum)
   end do
   call ctree_diag%delete
end if

! Print results
write(mpl%unit,'(a7,a)') '','Sampling efficiency (%):'
do il0=1,geom%nl0
   write(mpl%unit,'(a10,a,i3,a)',advance='no') '','Level ',nam%levs(il0),' ~> '
   do jc3=1,nam%nc3
      if (count(hdata%c1c3l0_log(:,jc3,il0))>=nam%nc1/2) then
         ! Sucessful sampling
         write(mpl%unit,'(a,i3,a)',advance='no') trim(green), &
       & int(100.0*float(count(hdata%c1c3l0_log(:,jc3,il0)))/float(nam%nc1)),trim(black)
      else
         ! Insufficient sampling
         write(mpl%unit,'(a,i3,a)',advance='no') trim(peach), &
       & int(100.0*float(count(hdata%c1c3l0_log(:,jc3,il0)))/float(nam%nc1)),trim(black)
      end if
      if (jc3<nam%nc3) write(mpl%unit,'(a)',advance='no') '-'
   end do
   write(mpl%unit,'(a)') ' '
end do

! End associate
end associate

end subroutine setup_sampling

!----------------------------------------------------------------------
! Subroutine: compute_sampling_zs
!> Purpose: compute zero-separation sampling
!----------------------------------------------------------------------
subroutine compute_sampling_zs(hdata)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata !< HDIAG data

! Local variables
integer :: ic0,ic1,fac,np,ip
integer :: mask_ind_col(hdata%geom%nc0),nn_index(1)
real(kind_real) :: rh0(hdata%geom%nc0),dum(1)
real(kind_real),allocatable :: lon(:),lat(:)
character(len=5) :: ic1char

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Initialize mask
mask_ind_col = 0
do ic0=1,geom%nc0
   if (any(geom%mask(ic0,:))) mask_ind_col(ic0) = 1
end do

! Initialize support radius to 1.0
rh0 = 1.0

! Compute subset
write(mpl%unit,'(a7,a)') '','Compute horizontal subset C1'
if (nam%nc1<maxval(count(geom%mask,dim=1))) then
   if (mpl%main) then
      if (.true.) then
         ! Random draw
         call rng%initialize_sampling(geom%nc0,dble(geom%lon),dble(geom%lat),mask_ind_col,rh0,nam%ntry,nam%nrep, &
       & nam%nc1,hdata%c1_to_c0)
      else
         ! Compute icosahedron size
         call closest_icos(nam%nc1,fac,np)

         ! Allocation
         allocate(lon(np))
         allocate(lat(np))

         ! Compute icosahedron
         call build_icos(fac,np,lon,lat)

         ! Fill c1_to_c0
         ic1 = 0
         do ip=1,np
            ! Find nearest neighbor
            call geom%ctree%find_nearest_neighbors(lon(ip),lat(ip),1,nn_index,dum)
            ic0 = nn_index(1)

            ! Check mask
            if (mask_ind_col(ic0)==1) then
               ic1 = ic1+1
               if (ic1<=nam%nc1) hdata%c1_to_c0(ic1) = ic0
            end if
         end do

         ! Check size
         if (ic1<nam%nc1) then
            write(ic1char,'(i5)') ic1
            call msgerror('nc1 should be decreased to '//ic1char)
         end if
         if (ic1>nam%nc1) then
            write(ic1char,'(i5)') ic1
            call msgwarning('nc1 could be increased to '//ic1char)
         end if

         ! Release memory
         deallocate(lon)
         deallocate(lat)
      end if
   end if
   call mpl%bcast(hdata%c1_to_c0,mpl%ioproc)
else
   ic1 = 0
   do ic0=1,geom%nc0
      if (any(geom%mask(ic0,:))) then
         ic1 = ic1+1
         hdata%c1_to_c0(ic1) = ic0
      end if
   end do
end if

! End associate
end associate

end subroutine compute_sampling_zs

!----------------------------------------------------------------------
! Subroutine: compute_sampling_ps
!> Purpose: compute positive separation sampling
!----------------------------------------------------------------------
subroutine compute_sampling_ps(hdata)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata !< HDIAG data

! Local variables
integer :: irmaxloc,progint,jc3,ic1,ir,ic0,jc0,i,nvc0,ivc0,icinf,icsup,ictest
integer,allocatable :: vic0(:)
real(kind_real) :: d
real(kind_real),allocatable :: x(:),y(:),z(:),v1(:),v2(:),va(:),vp(:),t(:)
logical :: found,done(hdata%nam%nc3*hdata%nam%nc1)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! First class
hdata%c1c3_to_c0(:,1) = hdata%c1_to_c0

if (nam%nc3>1) then
   write(mpl%unit,'(a7,a)',advance='no') '','Compute positive separation sampling: '

   ! Initialize
   do jc3=1,nam%nc3
      if (jc3/=1) call msi(hdata%c1c3_to_c0(:,jc3))
   end do

   ! Define valid nodes vector
   nvc0 = count(any(geom%mask,dim=2))
   allocate(vic0(nvc0))
   ivc0 = 0
   do ic0=1,geom%nc0
      if (any(geom%mask(ic0,:))) then
         ivc0 = ivc0+1
         vic0(ivc0) = ic0
      end if
   end do

   ! Sample classes of positive separation
   call prog_init(progint)
   ir = 0
   irmaxloc = irmax
   do while ((.not.all(isnotmsi(hdata%c1c3_to_c0))).and.(nvc0>1).and.(ir<=irmaxloc))
      ! Try a random point
      if (mpl%main) call rng%rand_integer(1,nvc0,i)
      call mpl%bcast(i,mpl%ioproc)
      ir = ir+1
      jc0 = vic0(i)

      !$omp parallel do schedule(static) private(ic1,ic0,d,jc3,icinf,icsup,found,ictest) firstprivate(x,y,z,v1,v2,va,vp,t)
      do ic1=1,nam%nc1
         ! Allocation
         allocate(x(2))
         allocate(y(2))
         allocate(z(2))
         allocate(v1(3))
         allocate(v2(3))
         allocate(va(3))
         allocate(vp(3))
         allocate(t(4))

         ! Check if there is a valid first point
         if (isnotmsi(hdata%c1_to_c0(ic1))) then
            ! Compute the distance
            ic0 = hdata%c1_to_c0(ic1)
            call sphere_dist(geom%lon(ic0),geom%lat(ic0),geom%lon(jc0),geom%lat(jc0),d)

            ! Find the class (dichotomy method)
            if ((d>0.0).and.(d<(float(nam%nc3)-0.5)*nam%dc)) then
               jc3 = 1
               icinf = 1
               icsup = nam%nc3
               found = .false.
               do while (.not.found)
                  ! New value
                  ictest = (icsup+icinf)/2

                  ! Update
                  if (d<(float(ictest)-0.5)*nam%dc) icsup = ictest
                  if (d>(float(ictest)-0.5)*nam%dc) icinf = ictest

                  ! Exit test
                  if (icsup==icinf+1) then
                     if (abs((float(icinf)-0.5)*nam%dc-d)<abs((float(icsup)-0.5)*nam%dc-d)) then
                        jc3 = icinf
                     else
                        jc3 = icsup
                     end if
                     found = .true.
                  end if
               end do

               ! Find if this class has not been aready filled
               if ((jc3/=1).and.(.not.isnotmsi(hdata%c1c3_to_c0(ic1,jc3)))) hdata%c1c3_to_c0(ic1,jc3) = jc0
            end if
         end if

         ! Release memory
         deallocate(x)
         deallocate(y)
         deallocate(z)
         deallocate(v1)
         deallocate(v2)
         deallocate(va)
         deallocate(vp)
         deallocate(t)
      end do
      !$omp end parallel do

      ! Update valid nodes vector
      vic0(i) = vic0(nvc0)
      nvc0 = nvc0-1

      ! Print progression
      done = pack(isnotmsi(hdata%c1c3_to_c0),mask=.true.)
      call prog_print(progint,done)
   end do
   write(mpl%unit,'(a)') '100%'

   ! Release memory
   deallocate(vic0)
end if

! End associate
end associate

end subroutine compute_sampling_ps

!----------------------------------------------------------------------
! Subroutine: compute_sampling_mask
!> Purpose: compute sampling mask
!----------------------------------------------------------------------
subroutine compute_sampling_mask(hdata)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata !< HDIAG data

! Local variables
integer :: jc3,ic1,ic0,jc0,il0
logical :: valid

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! First point
do il0=1,geom%nl0
   hdata%c1l0_log(:,il0) = geom%mask(hdata%c1_to_c0,il0)
end do

! Second point
do il0=1,geom%nl0
   do jc3=1,nam%nc3
      do ic1=1,nam%nc1
         ! Indices
         ic0 = hdata%c1c3_to_c0(ic1,jc3)
         jc0 = hdata%c1c3_to_c0(ic1,1)

         ! Check point index
         valid = isnotmsi(ic0).and.isnotmsi(jc0)

         if (valid) then
            ! Check mask
            valid = geom%mask(ic0,il0).and.geom%mask(jc0,il0)

            ! Check mask bounds
            if (nam%mask_check.and.valid) call check_arc(geom,il0,geom%lon(ic0),geom%lat(ic0),geom%lon(jc0),geom%lat(jc0),valid)
         end if
         hdata%c1c3l0_log(ic1,jc3,il0) = valid
      end do
   end do
end do

! End associate
end associate

end subroutine compute_sampling_mask

!----------------------------------------------------------------------
! Subroutine: compute_sampling_lct
!> Purpose: compute LCT sampling
!----------------------------------------------------------------------
subroutine compute_sampling_lct(hdata)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata !< HDIAG data

! Local variables
integer :: i,il0,ic1,ic0,jc0,ibnd,ic3,progint
integer :: nn(hdata%nam%nc3)
integer :: iproc,ic1_s(mpl%nproc),ic1_e(mpl%nproc),nc1_loc(mpl%nproc),ic1_loc
integer,allocatable :: sbufi(:),rbufi(:)
real(kind_real) :: dum(hdata%nam%nc3)
real(kind_real),allocatable :: x(:),y(:),z(:),v1(:),v2(:),va(:),vp(:),t(:)
logical,allocatable :: sbufl(:),rbufl(:),done(:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

write(mpl%unit,'(a7,a)',advance='no') '','Compute LCT sampling: '

! MPI splitting
call mpl%split(nam%nc1,ic1_s,ic1_e,nc1_loc)

! Allocation
allocate(done(nc1_loc(mpl%myproc)))

! Initialization
call prog_init(progint)

do ic1_loc=1,nc1_loc(mpl%myproc)
   ! MPI offset
   ic1 = ic1_s(mpl%myproc)+ic1_loc-1

   ! Check location validity
   if (isnotmsi(hdata%c1_to_c0(ic1))) then
      ! Find neighbors
      call geom%ctree%find_nearest_neighbors(dble(geom%lon(hdata%c1_to_c0(ic1))),dble(geom%lat(hdata%c1_to_c0(ic1))), &
    & nam%nc3,nn,dum)

      ! Copy neighbor index
      do ic3=1,nam%nc3
         jc0 = nn(ic3)
         hdata%c1c3_to_c0(ic1,ic3) = nn(ic3)
         do il0=1,geom%nl0
            hdata%c1c3l0_log(ic1,ic3,il0) = geom%mask(jc0,il0)
         end do
      end do

      if (nam%mask_check) then
         ! Check that great circle to neighbors is not crossing mask boundaries
         do il0=1,geom%nl0
            !$omp parallel do schedule(static) private(ic3,ic0,jc0) firstprivate(x,y,z,v1,v2,va,vp,t)
            do ic3=1,nam%nc3
               ! Allocation
               allocate(x(2))
               allocate(y(2))
               allocate(z(2))
               allocate(v1(3))
               allocate(v2(3))
               allocate(va(3))
               allocate(vp(3))
               allocate(t(4))

               ! Indices
               ic0 = hdata%c1_to_c0(ic1)
               jc0 = hdata%c1c3_to_c0(ic1,ic3)

               ! Transform to cartesian coordinates
               call trans(2,geom%lat((/ic0,jc0/)),geom%lon((/ic0,jc0/)),x,y,z)

               ! Compute arc orthogonal vector
               v1 = (/x(1),y(1),z(1)/)
               v2 = (/x(2),y(2),z(2)/)
               call vector_product(v1,v2,va)

               ! Check if arc is crossing boundary arcs
               do ibnd=1,geom%nbnd(il0)
                  call vector_product(va,geom%vbnd(:,ibnd,il0),vp)
                  v1 = (/x(1),y(1),z(1)/)
                  call vector_triple_product(v1,va,vp,t(1))
                  v1 = (/x(2),y(2),z(2)/)
                  call vector_triple_product(v1,va,vp,t(2))
                  v1 = (/geom%xbnd(1,ibnd,il0),geom%ybnd(1,ibnd,il0),geom%zbnd(1,ibnd,il0)/)
                  call vector_triple_product(v1,geom%vbnd(:,ibnd,il0),vp,t(3))
                  v1 = (/geom%xbnd(2,ibnd,il0),geom%ybnd(2,ibnd,il0),geom%zbnd(2,ibnd,il0)/)
                  call vector_triple_product(v1,geom%vbnd(:,ibnd,il0),vp,t(4))
                  t(1) = -t(1)
                  t(3) = -t(3)
                  if (all(t>0).or.(all(t<0))) then
                     hdata%c1c3l0_log(ic1,ic3,il0) = .false.
                     exit
                  end if
               end do

               ! Memory release
               deallocate(x)
               deallocate(y)
               deallocate(z)
               deallocate(v1)
               deallocate(v2)
               deallocate(va)
               deallocate(vp)
               deallocate(t)
            end do
            !$omp end parallel do
         end do
      end if
   end if

   ! Print progression
   done(ic1_loc) = .true.
   call prog_print(progint,done)
end do
write(mpl%unit,'(a)') '100%'

! Communication
if (mpl%main) then
   do iproc=1,mpl%nproc
      if (iproc/=mpl%ioproc) then
         ! Allocation
         allocate(rbufi(nc1_loc(iproc)*nam%nc3))
         allocate(rbufl(nc1_loc(iproc)*nam%nc3*geom%nl0))

         ! Receive data on ioproc
         call mpl%recv(nc1_loc(iproc)*nam%nc3,rbufi,iproc,mpl%tag)
         call mpl%recv(nc1_loc(iproc)*nam%nc3*geom%nl0,rbufl,iproc,mpl%tag+1)

         ! Format data
         i = 0
         do ic3=1,nam%nc3
            do ic1_loc=1,nc1_loc(iproc)
               i = i+1
               ic1 = ic1_s(iproc)+ic1_loc-1
               hdata%c1c3_to_c0(ic1,ic3) = rbufi(i)
            end do
         end do
         i = 0
         do il0=1,geom%nl0
            do ic3=1,nam%nc3
               do ic1_loc=1,nc1_loc(iproc)
                  i = i+1
                  ic1 = ic1_s(iproc)+ic1_loc-1
                  hdata%c1c3l0_log(ic1,ic3,il0) = rbufl(i)
               end do
            end do
         end do

         ! Release memory
         deallocate(rbufi)
         deallocate(rbufl)
      end if
   end do
else
   ! Allocation
   allocate(sbufi(nc1_loc(mpl%myproc)*nam%nc3))
   allocate(sbufl(nc1_loc(mpl%myproc)*nam%nc3*geom%nl0))

   ! Prepare buffers
   i = 0
   do ic3=1,nam%nc3
      do ic1_loc=1,nc1_loc(mpl%myproc)
         i = i+1
         ic1 = ic1_s(mpl%myproc)+ic1_loc-1
         sbufi(i) = hdata%c1c3_to_c0(ic1,ic3)
      end do
   end do
   i = 0
   do il0=1,geom%nl0
      do ic3=1,nam%nc3
         do ic1_loc=1,nc1_loc(mpl%myproc)
            i = i+1
            ic1 = ic1_s(mpl%myproc)+ic1_loc-1
            sbufl(i) = hdata%c1c3l0_log(ic1,ic3,il0)
         end do
      end do
   end do

   ! Send data to ioproc
   call mpl%send(nc1_loc(mpl%myproc)*nam%nc3,sbufi,mpl%ioproc,mpl%tag)
   call mpl%send(nc1_loc(mpl%myproc)*nam%nc3*geom%nl0,sbufl,mpl%ioproc,mpl%tag+1)

   ! Release memory
   deallocate(sbufi)
   deallocate(sbufl)
end if
mpl%tag = mpl%tag+2

! Broadcast data
call mpl%bcast(hdata%c1c3_to_c0,mpl%ioproc)
call mpl%bcast(hdata%c1c3l0_log,mpl%ioproc)

! End associate
end associate

end subroutine compute_sampling_lct

end module hdiag_sampling
