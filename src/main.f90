!----------------------------------------------------------------------
! Program: main
!> Purpose: initialization, drivers, finalization
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
program main

use, intrinsic :: iso_fortran_env, only : output_unit
use mpi
use tools_const, only: rad2deg,req
use tools_kinds, only: kind_real
use type_bump, only: bump_type
use type_rng, only: rng

implicit none

! Parameter
logical :: online_test = .true.

! Local variables
integer :: len,info,info_loc,myproc,narg
integer :: nmga,nl0,nv,nts,ens1_ne,ens2_ne,nobs
real(kind_real),allocatable :: lon(:),lat(:),area(:),vunit(:,:)
real(kind_real),allocatable :: ens1(:,:,:,:,:),ens2(:,:,:,:,:),rh(:,:,:,:),rv(:,:,:,:),lonobs(:),latobs(:)
logical :: lens1,lens2,lr,lobs
logical,allocatable :: lmask(:,:)
character(len=mpi_max_error_string) :: message
character(len=1024) :: namelname
type(bump_type) :: bump,bump_test

! Initialize MPI
call mpi_init(info)
if (info/=mpi_success) then
   call mpi_error_string(info,message,len,info_loc)
   write(output_unit,'(a)') trim(message)
   call mpi_finalize(info)
   stop
end if
call mpi_comm_rank(mpi_comm_world,myproc,info)

! Parse arguments
narg = command_argument_count()
if (narg==0) then
   if (myproc==0) then
      write(output_unit,'(a)') 'Error: a namelist path should be provided as argument'
      call flush(output_unit)
   end if
   call mpi_finalize(info)
   stop
elseif (narg==1) then
   call get_command_argument(1,namelname)
else
   if (myproc==0) then
      write(output_unit,'(a)') 'Warning: one arguments only required (namelist path)'
      call flush(output_unit)
   end if
end if

! Offline setup
call bump%setup_offline(mpi_comm_world,namelname)

! Online setup
if (online_test) then
   ! Initialize, read and broadcast namelist
   call bump_test%nam%init
   call bump_test%nam%read(namelname)
   call bump_test%nam%bcast

   ! Modify prefix
   bump_test%nam%prefix = trim(bump_test%nam%prefix)//'_online'

   ! Reset seed
   if (bump_test%nam%default_seed) call rng%reseed

   ! Copy offline dimensions
   nmga = bump%geom%nc0a
   nl0 = bump%geom%nl0
   nv = bump%nam%nv
   nts = bump%nam%nts

   ! Check offline output
   lens1 = allocated(bump%ens1%fld)
   lens2 = allocated(bump%ens2%fld)
   lr = allocated(bump%rh).and.allocated(bump%rv)
   lobs = allocated(bump%obsop%lonobs).and.allocated(bump%obsop%latobs)

   ! Allocation
   allocate(lon(nmga))
   allocate(lat(nmga))
   allocate(area(nmga))
   allocate(vunit(nmga,nl0))
   allocate(lmask(nmga,nl0))
   if (lens1) then
      ens1_ne = bump%ens1%ne
      allocate(ens1(nmga,nl0,nv,nts,ens1_ne))
   end if
   if (lens2) then
      ens2_ne = bump%ens2%ne
      allocate(ens2(nmga,nl0,nv,nts,ens2_ne))
   end if
   if (lr) then
      allocate(rh(nmga,nl0,nv,nts))
      allocate(rv(nmga,nl0,nv,nts))
   end if
   if (lobs) then
      nobs = bump%obsop%nobs
      allocate(lonobs(nobs))
      allocate(latobs(nobs))
   end if

   ! Copy offline data
   lon = bump%geom%lon(bump%geom%c0a_to_c0)*rad2deg
   lat = bump%geom%lat(bump%geom%c0a_to_c0)*rad2deg
   area = maxval(bump%geom%area)/real(maxval(count(bump%geom%mask,dim=1)),kind_real)*req**2
   vunit = bump%geom%vunit(bump%geom%c0a_to_c0,:)
   lmask = bump%geom%mask(bump%geom%c0a_to_c0,:)
   if (lens1) ens1 = bump%ens1%fld
   if (lens2) ens2 = bump%ens2%fld
   if (lr) then
      rh = bump%rh*req
      rv = bump%rv
   end if
   if (lobs) then
      lonobs = bump%obsop%lonobs*rad2deg
      latobs = bump%obsop%latobs*rad2deg
   end if

   ! Run online setup
   if (lens1.and.lens2.and.lobs) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & ens1_ne=ens1_ne,ens1=ens1, &
                                & ens2_ne=ens2_ne,ens2=ens2, &
                                & nobs=nobs,lonobs=lonobs,latobs=latobs)
   elseif (lens1.and.lr.and.lobs) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & ens1_ne=ens1_ne,ens1=ens1, &
                                & rh=rh,rv=rv, &
                                & nobs=nobs,lonobs=lonobs,latobs=latobs)
   elseif (lens1.and.lens2) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & ens1_ne=ens1_ne,ens1=ens1, &
                                & ens2_ne=ens2_ne,ens2=ens2)
   elseif (lens1.and.lr) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & ens1_ne=ens1_ne,ens1=ens1, &
                                & rh=rh,rv=rv)
   elseif (lens1.and.lobs) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & ens1_ne=ens1_ne,ens1=ens1, &
                                & nobs=nobs,lonobs=lonobs,latobs=latobs)
   elseif (lr.and.lobs) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & rh=rh,rv=rv, &
                                & nobs=nobs,lonobs=lonobs,latobs=latobs)
   elseif (lens1) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & ens1_ne=ens1_ne,ens1=ens1)
   elseif (lr) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & rh=rh,rv=rv)
   elseif (lobs) then
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask, &
                                & nobs=nobs,lonobs=lonobs,latobs=latobs)
   else
      call bump_test%setup_online(mpi_comm_world,nmga,nl0,nv,nts,lon,lat,area,vunit,lmask)
   end if
end if

! Finalize MPI
call mpi_finalize(info)
stop

end program main
