
!----------------------------------------------------------------------
! Subroutine: bump_run_offline
! Purpose: offline run
!----------------------------------------------------------------------
subroutine bump_run_offline(bump,namelname)

implicit none

! Passed variables
class(bump_type),intent(inout) :: bump   ! BUMP
character(len=*),intent(in) :: namelname ! Namelist name

! Local variables
type(timer_type) :: timer

! Initialize MPL
call bump%mpl%init

! Initialize timer
call timer%start(bump%mpl)

! Initialize, read and broadcast namelist
call bump%nam%init
call bump%nam%read(bump%mpl,namelname)
call bump%nam%bcast(bump%mpl)

! Initialize listing
call bump%mpl%init_listing(bump%nam%prefix,bump%nam%model,bump%nam%colorlog,bump%nam%logpres)

! Generic setup
call bump%setup_generic

! Initialize geometry
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%info,'(a)') '--- Initialize geometry'
call flush(bump%mpl%info)
call model_coord(bump%mpl,bump%rng,bump%nam,bump%geom)
call bump%geom%init(bump%mpl,bump%rng,bump%nam)

if (bump%nam%grid_output) then
   ! Initialize fields regridding
   write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%info,'(a)') '--- Initialize fields regridding'
   call flush(bump%mpl%info)
   call bump%io%grid_init(bump%mpl,bump%rng,bump%nam,bump%geom)
end if

! Initialize block parameters
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%info,'(a)') '--- Initialize block parameters'
call bump%bpar%alloc(bump%nam,bump%geom)

if (bump%nam%new_vbal.or.bump%nam%new_hdiag.or.bump%nam%new_lct.or.(bump%nam%check_dirac.and.(trim(bump%nam%method)/='cor'))) then
   write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%info,'(a)') '--- Load ensemble 1'
   call flush(bump%mpl%info)
   call bump%ens1%load(bump%mpl,bump%nam,bump%geom,'ens1')
end if

if (bump%nam%new_hdiag.and.((trim(bump%nam%method)=='hyb-rnd').or.(trim(bump%nam%method)=='dual-ens'))) then
   write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%info,'(a)') '--- Load ensemble 2'
   call flush(bump%mpl%info)
   call bump%ens2%load(bump%mpl,bump%nam,bump%geom,'ens2')
end if

if (bump%nam%new_obsop) then
   ! Generate observations locations
   write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
   write(bump%mpl%info,'(a)') '--- Generate observations locations'
   call flush(bump%mpl%info)
   call bump%obsop%generate(bump%mpl,bump%rng,bump%nam,bump%geom)
end if

! Run drivers
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%info,'(a)') '--- Run drivers'
call flush(bump%mpl%info)
bump%close_listing = .false.
call bump%run_drivers

! Execution stats
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%info,'(a)') '--- Execution stats'
call timer%display(bump%mpl)
call flush(bump%mpl%info)

! Close listings
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
write(bump%mpl%info,'(a)') '--- Close listings'
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
call flush(bump%mpl%info)
close(unit=bump%mpl%info)
call flush(bump%mpl%test)
close(unit=bump%mpl%test)

! Finalize MPL
call bump%mpl%final

end subroutine bump_run_offline
