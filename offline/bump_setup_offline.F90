
!----------------------------------------------------------------------
! Subroutine: bump_setup_offline
!> Purpose: offline setup
!----------------------------------------------------------------------
subroutine bump_setup_offline(bump,mpi_comm,namelname)

implicit none

! Passed variables
class(bump_type),intent(inout) :: bump   !< BUMP
integer,intent(in) :: mpi_comm           !< MPI communicator
character(len=*),intent(in) :: namelname !< Namelist name

! Local variables
type(timer_type) :: timer

! Initialize MPL
call bump%mpl%init(mpi_comm)

! Initialize timer
if (bump%mpl%main) call timer%start

! Initialize, read and broadcast namelist
call bump%nam%init
call bump%nam%read(bump%mpl,namelname)
call bump%nam%bcast(bump%mpl)

! Initialize listing
call bump%mpl%init_listing(bump%nam%prefix,bump%nam%model,bump%nam%colorlog,bump%nam%logpres)

! Generic setup, first step
call bump%setup_generic

! Initialize geometry
write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%unit,'(a)') '--- Initialize geometry'
call flush(bump%mpl%unit)
call model_coord(bump%mpl,bump%rng,bump%nam,bump%geom)
call bump%geom%init(bump%mpl,bump%rng,bump%nam)

if (bump%nam%grid_output) then
   ! Initialize fields regridding
   write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%unit,'(a)') '--- Initialize fields regridding'
   call flush(bump%mpl%unit)
   call bump%io%grid_init(bump%mpl,bump%rng,bump%nam,bump%geom)
end if

! Initialize block parameters
write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%unit,'(a)') '--- Initialize block parameters'
call bump%bpar%alloc(bump%nam,bump%geom)

if (bump%nam%new_vbal.or.bump%nam%new_hdiag.or.bump%nam%new_lct.or.bump%nam%check_dirac) then
   write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%unit,'(a)') '--- Load ensemble 1'
   call flush(bump%mpl%unit)
   call bump%ens1%load(bump%mpl,bump%nam,bump%geom,'ens1')
end if

if (bump%nam%new_hdiag.and.((trim(bump%nam%method)=='hyb-rnd').or.(trim(bump%nam%method)=='dual-ens'))) then
   write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%unit,'(a)') '--- Load ensemble 2'
   call flush(bump%mpl%unit)
   call bump%ens2%load(bump%mpl,bump%nam,bump%geom,'ens2')
end if

if (bump%nam%new_obsop) then
   ! Generate observations locations
   write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%unit,'(a)') '--- Generate observations locations'
   call flush(bump%mpl%unit)
   call bump%obsop%generate(bump%mpl,bump%rng,bump%nam,bump%geom)
end if

! Run drivers
write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%unit,'(a)') '--- Run drivers'
call flush(bump%mpl%unit)
bump%close_listing = .false.
call bump%run_drivers

! Execution stats
if (bump%mpl%main) then
   write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%unit,'(a)') '--- Execution stats'
   call timer%display(bump%mpl)
end if
call flush(bump%mpl%unit)

! Close listings
write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%unit,'(a)') '--- Close listings'
write(bump%mpl%unit,'(a)') '-------------------------------------------------------------------'
call flush(bump%mpl%unit)
close(unit=bump%mpl%unit)

end subroutine bump_setup_offline
