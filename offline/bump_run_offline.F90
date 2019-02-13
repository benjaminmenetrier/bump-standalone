
!----------------------------------------------------------------------
! Subroutine: bump_run_offline
! Purpose: offline run
!----------------------------------------------------------------------
subroutine bump_run_offline(bump,namelname)

implicit none

! Passed variables
class(bump_type),intent(inout) :: bump            ! BUMP
character(len=*),intent(in) :: namelname          ! Namelist name

! Local variables
type(timer_type) :: timer

! Set missing values
call bump%mpl%msv%init(-999,-999.0_kind_real)

! Initialize MPL
call bump%mpl%init

! Initialize timer
call timer%start(bump%mpl)

! Initialize, read and broadcast namelist
call bump%nam%init
call bump%nam%read(bump%mpl,namelname)
call bump%nam%bcast(bump%mpl)

! Initialize listing
call bump%mpl%init_listing(bump%nam%prefix,bump%nam%model,bump%nam%verbosity,bump%nam%colorlog,bump%nam%logpres)

! Generic setup
call bump%setup_generic

! Initialize geometry
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
call bump%mpl%flush
write(bump%mpl%info,'(a)') '--- Initialize geometry'
call bump%mpl%flush
call model_coord(bump%mpl,bump%rng,bump%nam,bump%geom)
call bump%geom%init(bump%mpl,bump%rng,bump%nam)
if (bump%nam%default_seed) call bump%rng%reseed(bump%mpl)

if (bump%nam%grid_output) then
   ! Initialize fields regridding
   write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
   call bump%mpl%flush
   write(bump%mpl%info,'(a)') '--- Initialize fields regridding'
   call bump%mpl%flush
   call bump%io%grid_init(bump%mpl,bump%rng,bump%nam,bump%geom)
   if (bump%nam%default_seed) call bump%rng%reseed(bump%mpl)
end if

! Initialize block parameters
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
call bump%mpl%flush
write(bump%mpl%info,'(a)') '--- Initialize block parameters'
call bump%mpl%flush
call bump%bpar%alloc(bump%nam,bump%geom)
call bump%bpar%init(bump%nam,bump%geom)

if (bump%nam%new_cortrack.or.bump%nam%new_vbal.or.bump%nam%new_hdiag.or.bump%nam%new_lct.or. &
 & (bump%nam%check_dirac.and.(trim(bump%nam%method)/='cor'))) then
   write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
   call bump%mpl%flush
   write(bump%mpl%info,'(a)') '--- Load ensemble 1'
   call bump%mpl%flush
   call bump%ens1%load(bump%mpl,bump%nam,bump%geom,'ens1')
end if

if (bump%nam%new_hdiag.and.((trim(bump%nam%method)=='hyb-rnd').or.(trim(bump%nam%method)=='dual-ens'))) then
   write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
   call bump%mpl%flush
   write(bump%mpl%info,'(a)') '--- Load ensemble 2'
   call bump%mpl%flush
   call bump%ens2%load(bump%mpl,bump%nam,bump%geom,'ens2')
end if

if (bump%nam%new_obsop) then
   ! Generate observations locations
   write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
   call bump%mpl%flush
   write(bump%mpl%info,'(a)') '--- Generate observations locations'
   call bump%mpl%flush
   call bump%obsop%generate(bump%mpl,bump%rng,bump%nam,bump%geom)
   if (bump%nam%default_seed) call bump%rng%reseed(bump%mpl)
end if

! Run drivers
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
call bump%mpl%flush
write(bump%mpl%info,'(a)') '--- Run drivers'
call bump%mpl%flush
bump%close_listing = .false.
call bump%run_drivers

! Execution stats
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
call bump%mpl%flush
write(bump%mpl%info,'(a)') '--- Execution stats'
call timer%display(bump%mpl)
call bump%mpl%flush

! Close listings
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
call bump%mpl%flush
write(bump%mpl%info,'(a)') '--- Close listings'
call bump%mpl%flush
write(bump%mpl%info,'(a)') '-------------------------------------------------------------------'
call bump%mpl%flush
call bump%mpl%close_listing

! Finalize MPL
call bump%mpl%final

end subroutine bump_run_offline
