!----------------------------------------------------------------------
! Module: module_namelist
!> Purpose: namelist parameters management
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module module_namelist

use netcdf, only: nf90_put_att,nf90_global
use omp_lib, only: omp_get_num_procs
use tools_const, only: req
use tools_display, only: msgerror,msgwarning
use tools_kinds,only: kind_real
use tools_missing, only: msi,msr
use tools_nc, only: ncerr
use type_mpl, only: mpl,mpl_bcast

implicit none

! Namelist parameters maximum sizes
integer,parameter :: nvmax = 20                      !< Maximum number of variables
integer,parameter :: ntsmax = 20                      !< Maximum number of time slots
integer,parameter :: nlmax = 200                     !< Maximum number of levels
integer,parameter :: ncmax = 1000                    !< Maximum number of classes
integer,parameter :: nldwvmax = 100                  !< Maximum number of local diagnostic profiles
integer,parameter :: ndirmax = 100 !< Maximum number of diracs

type namtype
   ! general_param
   character(len=1024) :: datadir     !< Data directory
   character(len=1024) :: prefix      !< Files prefix
   character(len=1024) :: model       !< Model name ('aro', 'arp', 'gem', 'geos', 'gfs', 'ifs', 'mpas', 'nemo' or 'wrf')
   logical :: colorlog                !< Add colors to the log (for display on terminal)
   logical :: sam_default_seed        !< Default seed for random numbers
   
   ! driver_param
   character(len=1024) :: method      !< Localization/hybridization to compute ('cor', 'loc', 'hyb-avg', 'hyb-rnd' or 'dual-ens')
   character(len=1024) :: strategy    !< Localization strategy ('common', 'specific_univariate', 'specific_multivariate' or 'common_weighted')
   logical :: new_hdiag               !< Compute new hybrid_diag parameters (if false, read file)
   logical :: new_param               !< Compute new parameters (if false, read file)
   logical :: new_mpi                 !< Compute new mpi splitting (if false, read file)
   logical :: check_adjoints          !< Test adjoints
   logical :: check_pos_def           !< Test positive definiteness
   logical :: check_mpi               !< Test single proc/multi-procs equivalence
   logical :: check_dirac             !< Test NICAS application on diracs
   logical :: check_perf              !< Test NICAS performance
   
   ! model_param
   integer :: nl                      !< Number of levels
   integer :: levs(nlmax)             !< Levels
   logical :: logpres                                   !< Use pressure logarithm as vertical coordinate (model level if .false.)
   integer :: nv                                        !< Number of variables
   character(len=1024),dimension(nvmax) :: varname !< Variables names
   logical,dimension(nvmax) :: var3d !< 3D variable
   integer :: nts                                      !< Number of time slots
   integer,dimension(ntsmax) :: timeslot ! < Time slots
   
   ! ens1_param
   integer :: ens1_ne                                   !< Ensemble 1 size
   integer :: ens1_ne_offset                            !< Ensemble 1 index offset
   integer :: ens1_nsub                                 !< Ensemble 1 sub-ensembles number
   
   ! ens2_param
   integer :: ens2_ne                                   !< Ensemble 2 size
   integer :: ens2_ne_offset                            !< Ensemble 2 index offset
   integer :: ens2_nsub                                 !< Ensemble 2 sub-ensembles number
   
   ! sampling_param
   logical :: sam_write                                 !< Write sampling
   logical :: sam_read                                  !< Read sampling
   character(len=1024) :: mask_type                     !< Mask restriction type
   real(kind_real) ::  mask_th                                      !< Mask threshold
   logical :: mask_check                                !< Check that sampling couples and interpolations do not cross mask boundaries
   integer :: nc1                                        !< Number of sampling points
   integer :: ntry                                      !< Number of tries to get the most separated point for the zero-separation sampling
   integer :: nrep                                      !< Number of replacement to improve homogeneity of the zero-separation sampling
   integer :: nc                                        !< Number of classes
   real(kind_real) ::  dc                                           !< Class size (for sam_type='hor'), should be larger than the typical grid cell size
   
   ! diag_param
   integer :: ne                                        !< Ensemble sizes
   logical :: limited_memory                            !< Limited memory: ensemble members are not stored for diagnostics
   logical :: gau_approx                                !< Gaussian approximation for asymptotic quantities
   logical :: full_var                                  !< Compute full variances
   logical :: local_diag                                !< Activate local diagnostics
   real(kind_real) ::  local_rad                                    !< Local diagnostics calculation radius
   logical :: displ_diag                                !< Activate displacement diagnostics
   real(kind_real) ::  displ_rad                                    !< Displacement calculation radius
   logical :: displ_explicit                            !< Filtering with explicit support radius
   integer :: displ_niter                               !< Number of iteration for the displacement filtering (for displ_diag = .true.)
   real(kind_real) ::  displ_rhflt                                   !< Displacement initial filtering support radius (for displ_diag = .true.)
   real(kind_real) ::  displ_tol                                    !< Displacement tolerance for mesh check (for displ_diag = .true.)
   
   ! fit_param
   character(len=1024) :: fit_type                      !< Fit type ('none', 'fast' or 'full')
   logical :: fit_wgt                                   !< Apply a fit weight given by the curve on which localization is applied
   logical :: lhomh                                     !< Vertically homogenous horizontal support radius
   logical :: lhomv                                     !< Vertically homogenous vertical support radius
   real(kind_real) ::  rvflt                                      !< Vertical smoother support radius
   
   ! output_param
   logical :: norm_loc                                  !< Normalize localization functions
   logical :: spectrum                                  !< Compute eigenspectrum
   integer :: nldwh                                     !< Number of local diagnostics fields to write (for local_diag = .true.)
   integer :: il_ldwh(nlmax*ncmax)                      !< Levels of local diagnostics fields to write (for local_diag = .true.)
   integer :: ic_ldwh(nlmax*ncmax)                      !< Classes of local diagnostics fields to write (for local_diag = .true.)
   integer :: nldwv                                     !< Number of local diagnostics profiles to write (for local_diag = .true.)
   real(kind_real) ::  lon_ldwv(nldwvmax)                           !< Longitudes (in degrees) local diagnostics profiles to write (for local_diag = .true.)
   real(kind_real) ::  lat_ldwv(nldwvmax)                           !< Latitudes (in degrees) local diagnostics profiles to write (for local_diag = .true.)
   character(len=1024) :: flt_type                      !< Diagnostics filtering type ('none', 'average', 'gc99', 'median')
   real(kind_real) ::  diag_rhflt                                        !< Diagnostics filtering radius
   
   ! nicas_param
   logical :: lsqrt                   !< Square-root formulation
   real(kind_real) :: rh(nlmax)      !< Default horizontal support radius
   real(kind_real) :: rv(nlmax)      !< Default vertical support radius
   real(kind_real) :: resol           !< Resolution
   logical :: network                 !< Network-base convolution calculation (distance-based if false)
   integer :: nproc                   !< Number of tasks
   integer :: mpicom                  !< Number of communication steps
   integer :: ndir                    !< Number of Diracs
   real(kind_real) :: londir(ndirmax) !< Diracs longitudes
   real(kind_real) :: latdir(ndirmax) !< Diracs latitudes
   integer :: levdir(ndirmax)         !< Diracs level
   integer :: ivdir(ndirmax)          !< Diracs variable
   integer :: itsdir(ndirmax)         !< Diracs timeslot
   
   ! Unread parameters
   integer :: nb
   character(len=11),allocatable :: blockname(:)
   logical,allocatable :: diag_block(:)
   logical,allocatable :: avg_block(:)
   logical,allocatable :: fit_block(:)
   logical,allocatable :: nicas_block(:)
   integer,allocatable :: ib_to_iv(:)
   integer,allocatable :: ib_to_jv(:)
   integer,allocatable :: ib_to_its(:)
   integer,allocatable :: ib_to_jts(:)
   real(kind_real) :: disth(ncmax)
end type namtype

interface namncwrite_param
  module procedure namncwrite_integer
  module procedure namncwrite_integer_array
  module procedure namncwrite_real
  module procedure namncwrite_real_array
  module procedure namncwrite_logical
  module procedure namncwrite_string
end interface

private
public :: namtype
public :: namread,namcheck,namncwrite

contains

!----------------------------------------------------------------------
! Subroutine: namread
!> Purpose: read and check namelist parameters
!----------------------------------------------------------------------
subroutine namread(nam)

implicit none

! Passed variable
type(namtype),intent(out) :: nam !< Namelist variables

! Local variables
integer :: iv

! Namelist variables
integer :: nl,levs(nlmax),nv,nts,timeslot(ntsmax),ens1_ne,ens1_ne_offset,ens1_nsub,ens2_ne,ens2_ne_offset,ens2_nsub
logical :: colorlog,sam_default_seed,new_hdiag,new_param,new_mpi,check_adjoints,check_pos_def,check_mpi,check_dirac,check_perf
logical :: logpres,var3d(nvmax),sam_write,sam_read,spectrum
character(len=1024) :: datadir,prefix,model,strategy,method,mask_type  
character(len=1024),dimension(nvmax) :: varname

! TODO
real(kind_real) ::  mask_th                                      !< Mask threshold
logical :: mask_check                                !< Check that sampling couples and interpolations do not cross mask boundaries
integer :: nc1                                        !< Number of sampling points
integer :: ntry                                      !< Number of tries to get the most separated point for the zero-separation sampling
integer :: nrep                                      !< Number of replacement to improve homogeneity of the zero-separation sampling
integer :: nc                                        !< Number of classes
real(kind_real) ::  dc                                           !< Class size (for sam_type='hor'), should be larger than the typical grid cell size
integer :: ne
logical :: limited_memory
logical :: gau_approx                                !< Gaussian approximation for asymptotic quantities
logical :: full_var                                  !< Compute full variances
logical :: local_diag                                !< Activate local diagnostics
real(kind_real) ::  local_rad                                    !< Local diagnostics calculation radius
logical :: displ_diag                                !< Activate displacement diagnostics
real(kind_real) ::  displ_rad                                    !< Displacement calculation radius
logical :: displ_explicit                            !< Filtering with explicit support radius
integer :: displ_niter                               !< Number of iteration for the displacement filtering (for displ_diag = .true.)
real(kind_real) ::  displ_rhflt                                   !< Displacement initial filtering support radius (for displ_diag = .true.)
real(kind_real) ::  displ_tol                                    !< Displacement tolerance for mesh check (for displ_diag = .true.)
character(len=1024) :: fit_type                      !< Fit type ('none', or for sam_type='hor': 'dif', 'gas', 'gau' and for sam_type='ver': 'gau', 'gas', 'symgau', 'wm2013')
logical :: fit_wgt                                   !< Apply a fit weight given by the curve on which localization is applied
logical :: lhomh,lhomv
real(kind_real) ::  rvflt                                      !< Vertical smoother support radius
logical :: norm_loc                                  !< Normalize localization functions
integer :: nldwh                                     !< Number of local diagnostics fields to write (for local_diag = .true.)
integer :: il_ldwh(nlmax*ncmax)                      !< Levels of local diagnostics fields to write (for local_diag = .true.)
integer :: ic_ldwh(nlmax*ncmax)                      !< Classes of local diagnostics fields to write (for local_diag = .true.)
integer :: nldwv                                     !< Number of local diagnostics profiles to write (for local_diag = .true.)
real(kind_real) ::  lon_ldwv(nldwvmax)                           !< Longitudes (in degrees) local diagnostics profiles to write (for local_diag = .true.)
real(kind_real) ::  lat_ldwv(nldwvmax)                           !< Latitudes (in degrees) local diagnostics profiles to write (for local_diag = .true.)
character(len=1024) :: flt_type                      !< Diagnostics filtering type ('none', 'average', 'gc99', 'median')
real(kind_real) ::  diag_rhflt                                        !< Diagnostics filtering radius
logical :: lsqrt                   !< Square-root formulation
real(kind_real) :: rh(nlmax)      !< Horizontal support radius
real(kind_real) :: rv(nlmax)      !< Vertical support radius
real(kind_real) :: resol           !< Resolution
logical :: network                 !< Network-base convolution calculation (distance-based if false)
integer :: nproc                   !< Number of tasks
integer :: mpicom                  !< Number of communication steps
integer :: ndir                    !< Number of Diracs
real(kind_real) :: londir(ndirmax) !< Diracs longitudes
real(kind_real) :: latdir(ndirmax) !< Diracs latitudes
integer :: levdir(ndirmax)                  !< Diracs level
integer :: ivdir(ndirmax)          !< Diracs variable
integer :: itsdir(ndirmax)         !< Diracs 

! Namelist blocks
namelist/general_param/datadir,prefix,model,colorlog,sam_default_seed
namelist/driver_param/method,strategy,new_hdiag,new_param,new_mpi,check_adjoints,check_pos_def,check_mpi,check_dirac,check_perf
namelist/model_param/nl,levs,logpres,nv,varname,var3d,nts,timeslot
namelist/ens1_param/ens1_ne,ens1_ne_offset,ens1_nsub
namelist/ens2_param/ens2_ne,ens2_ne_offset,ens2_nsub
namelist/sampling_param/sam_write,sam_read,mask_type,mask_th,mask_check,nc1,ntry,nrep,nc,dc
namelist/diag_param/ne,limited_memory,gau_approx,full_var,local_diag,local_rad, &
 & displ_diag,displ_rad,displ_explicit,displ_niter,displ_rhflt,displ_tol
namelist/fit_param/fit_type,fit_wgt,lhomh,lhomv,rvflt
namelist/output_param/norm_loc,spectrum,nldwh,il_ldwh,ic_ldwh,nldwv,lon_ldwv,lat_ldwv,flt_type,diag_rhflt
namelist/nicas_param/lsqrt,rh,rv,resol,network,nproc,mpicom,ndir,londir,latdir,levdir,ivdir,itsdir

! Default initialization

! general_param default
datadir = ''
prefix = ''
model = ''
colorlog = .false.
sam_default_seed = .false.

! driver_param default
method = ''
strategy = ''
new_hdiag = .false.
new_param = .false.
new_mpi = .false.
check_adjoints = .false.
check_pos_def = .false.
check_mpi = .false.
check_dirac = .false.
check_dirac = .false.

! model_param default
call msi(nl)
call msi(levs)
logpres = .false.
call msi(nv)
do iv=1,nvmax
   varname = ''
end do
var3d = .true.
call msi(nts)
call msi(timeslot)

! ens1_param default
call msi(ens1_ne)
call msi(ens1_ne_offset)
call msi(ens1_nsub)

! ens2_param default
call msi(ens2_ne)
call msi(ens2_ne_offset)
call msi(ens2_nsub)

! sampling_param default
sam_write = .false.
sam_read = .false.
mask_type = ''
call msr(mask_th)
mask_check = .false.
call msi(nc1)
call msi(ntry)
call msi(nrep)
call msi(nc)
call msr(dc)

! solver_param default
call msi(ne)
limited_memory = .false.
gau_approx = .false.
local_diag = .false.
call msr(local_rad)
displ_diag = .false.
call msr(displ_rad)
displ_explicit = .false.
call msi(displ_niter)
call msr(displ_rhflt)
call msr(displ_tol)

! fit_param default
fit_type = ''
fit_wgt = .false.
lhomh = .false.
lhomv = .false.
call msr(rvflt)

! output_param default
norm_loc = .false.
spectrum = .false.
call msi(nldwh)
call msi(il_ldwh)
call msi(ic_ldwh)
call msi(nldwv)
call msr(lon_ldwv)
call msr(lat_ldwv)
flt_type = ''
call msr(diag_rhflt)

! nicas_param default
lsqrt = .false.
call msr(rh)
call msr(rv)
call msr(resol)
network = .false.
call msi(nproc)
call msi(mpicom)
call msi(ndir)
call msr(londir)
call msr(latdir)
call msi(levdir)
call msi(ivdir)
call msi(itsdir)

if (mpl%main) then
   ! Read namelist and copy into derived type

   ! general_param
   read(*,nml=general_param)
   nam%datadir = datadir
   nam%prefix = prefix
   nam%model = model
   nam%colorlog = colorlog
   nam%sam_default_seed = sam_default_seed

   ! driver_param
   read(*,nml=driver_param)
   nam%method = method
   nam%strategy = strategy
   nam%new_hdiag = new_hdiag
   nam%new_param = new_param
   nam%new_mpi = new_mpi
   nam%check_adjoints = check_adjoints
   nam%check_pos_def = check_pos_def
   nam%check_mpi = check_mpi
   nam%check_dirac = check_dirac
   nam%check_perf = check_perf

   ! model_param
   read(*,nml=model_param)
   nam%nl = nl
   nam%levs = levs
   nam%logpres = logpres
   nam%nv = nv
   nam%varname = varname
   nam%var3d = var3d
   nam%nts = nts
   nam%timeslot = timeslot

   ! ens1_param
   read(*,nml=ens1_param)
   nam%ens1_ne = ens1_ne
   nam%ens1_ne_offset = ens1_ne_offset
   nam%ens1_nsub = ens1_nsub

   ! ens2_param
   read(*,nml=ens2_param)
   nam%ens2_ne = ens2_ne
   nam%ens2_ne_offset = ens2_ne_offset
   nam%ens2_nsub = ens2_nsub

   ! sampling_param
   read(*,nml=sampling_param)
   nam%sam_write = sam_write
   nam%sam_read = sam_read
   nam%mask_type = mask_type
   nam%mask_th = mask_th
   nam%mask_check = mask_check
   nam%nc1 = nc1
   nam%ntry = ntry
   nam%nrep = nrep
   nam%nc = nc
   nam%dc = dc/req

   ! diag_param
   read(*,nml=diag_param)
   nam%ne = ne
   nam%limited_memory = limited_memory
   nam%gau_approx = gau_approx
   nam%full_var = full_var
   nam%local_diag = local_diag
   nam%local_rad = local_rad/req
   nam%displ_diag = displ_diag
   nam%displ_rad = displ_rad/req
   nam%displ_explicit = displ_explicit
   nam%displ_niter = displ_niter
   nam%displ_rhflt = displ_rhflt/req
   nam%displ_tol = displ_tol

   ! fit_param
   read(*,nml=fit_param)
   nam%fit_type = fit_type
   nam%fit_wgt = fit_wgt
   nam%lhomh = lhomh
   nam%lhomv = lhomv
   nam%rvflt = rvflt

   ! output_param
   read(*,nml=output_param)
   nam%norm_loc = norm_loc
   nam%spectrum = spectrum
   nam%nldwh = nldwh
   nam%il_ldwh = il_ldwh
   nam%ic_ldwh = ic_ldwh
   nam%nldwv = nldwv
   nam%lon_ldwv = lon_ldwv
   nam%lat_ldwv = lat_ldwv
   nam%flt_type = flt_type
   nam%diag_rhflt = diag_rhflt/req

   ! nicas_param
   read(*,nml=nicas_param) 
   nam%lsqrt = lsqrt
   nam%rh = rh/req
   nam%rv = rv
   nam%resol = resol
   nam%network = network
   nam%nproc = nproc
   nam%mpicom = mpicom
   nam%ndir = ndir
   nam%londir = londir
   nam%latdir = latdir
   nam%levdir = levdir
   nam%ivdir = ivdir
   nam%itsdir = itsdir
end if

! Broadcast parameters

! general_param
call mpl_bcast(nam%datadir,mpl%ioproc)
call mpl_bcast(nam%prefix,mpl%ioproc)
call mpl_bcast(nam%model,mpl%ioproc)
call mpl_bcast(nam%colorlog,mpl%ioproc)
call mpl_bcast(nam%sam_default_seed,mpl%ioproc)

! driver_param
call mpl_bcast(nam%method,mpl%ioproc)
call mpl_bcast(nam%strategy,mpl%ioproc)
call mpl_bcast(nam%new_hdiag,mpl%ioproc)
call mpl_bcast(nam%new_param,mpl%ioproc)
call mpl_bcast(nam%new_mpi,mpl%ioproc)
call mpl_bcast(nam%check_adjoints,mpl%ioproc)
call mpl_bcast(nam%check_pos_def,mpl%ioproc)
call mpl_bcast(nam%check_mpi,mpl%ioproc)
call mpl_bcast(nam%check_dirac,mpl%ioproc)
call mpl_bcast(nam%check_perf,mpl%ioproc)

! model_param
call mpl_bcast(nam%nl,mpl%ioproc)
call mpl_bcast(nam%levs,mpl%ioproc)
call mpl_bcast(nam%logpres,mpl%ioproc)
call mpl_bcast(nam%nv,mpl%ioproc)
call mpl_bcast(nam%varname,mpl%ioproc)
call mpl_bcast(nam%var3d,mpl%ioproc)
call mpl_bcast(nam%nts,mpl%ioproc)
call mpl_bcast(nam%timeslot,mpl%ioproc)

! ens1_param
call mpl_bcast(nam%ens1_ne,mpl%ioproc)
call mpl_bcast(nam%ens1_ne_offset,mpl%ioproc)
call mpl_bcast(nam%ens1_nsub,mpl%ioproc)

! ens2_param
call mpl_bcast(nam%ens2_ne,mpl%ioproc)
call mpl_bcast(nam%ens2_ne_offset,mpl%ioproc)
call mpl_bcast(nam%ens2_nsub,mpl%ioproc)

! sampling_param
call mpl_bcast(nam%sam_write,mpl%ioproc)
call mpl_bcast(nam%sam_read,mpl%ioproc)
call mpl_bcast(nam%mask_type,mpl%ioproc)
call mpl_bcast(nam%mask_th,mpl%ioproc)
call mpl_bcast(nam%mask_check,mpl%ioproc)
call mpl_bcast(nam%nc1,mpl%ioproc)
call mpl_bcast(nam%ntry,mpl%ioproc)
call mpl_bcast(nam%nrep,mpl%ioproc)
call mpl_bcast(nam%nc,mpl%ioproc)
call mpl_bcast(nam%dc,mpl%ioproc)

! diag_param
call mpl_bcast(nam%ne,mpl%ioproc)
call mpl_bcast(nam%limited_memory,mpl%ioproc)
call mpl_bcast(nam%gau_approx,mpl%ioproc)
call mpl_bcast(nam%full_var,mpl%ioproc)
call mpl_bcast(nam%local_diag,mpl%ioproc)
call mpl_bcast(nam%local_rad,mpl%ioproc)
call mpl_bcast(nam%displ_diag,mpl%ioproc)
call mpl_bcast(nam%displ_rad,mpl%ioproc)
call mpl_bcast(nam%displ_explicit,mpl%ioproc)
call mpl_bcast(nam%displ_niter,mpl%ioproc)
call mpl_bcast(nam%displ_rhflt,mpl%ioproc)
call mpl_bcast(nam%displ_tol,mpl%ioproc)

! fit_param
call mpl_bcast(nam%fit_type,mpl%ioproc)
call mpl_bcast(nam%fit_wgt,mpl%ioproc)
call mpl_bcast(nam%lhomh,mpl%ioproc)
call mpl_bcast(nam%lhomv,mpl%ioproc)
call mpl_bcast(nam%rvflt,mpl%ioproc)

! output_param
call mpl_bcast(nam%norm_loc,mpl%ioproc)
call mpl_bcast(nam%spectrum,mpl%ioproc)
call mpl_bcast(nam%nldwh,mpl%ioproc)
call mpl_bcast(nam%il_ldwh,mpl%ioproc)
call mpl_bcast(nam%ic_ldwh,mpl%ioproc)
call mpl_bcast(nam%nldwv,mpl%ioproc)
call mpl_bcast(nam%lon_ldwv,mpl%ioproc)
call mpl_bcast(nam%lat_ldwv,mpl%ioproc)
call mpl_bcast(nam%flt_type,mpl%ioproc)
call mpl_bcast(nam%diag_rhflt,mpl%ioproc)

! nicas_param
call mpl_bcast(nam%lsqrt,mpl%ioproc)
call mpl_bcast(nam%rh,mpl%ioproc)
call mpl_bcast(nam%rv,mpl%ioproc)
call mpl_bcast(nam%resol,mpl%ioproc)
call mpl_bcast(nam%network,mpl%ioproc)
call mpl_bcast(nam%nproc,mpl%ioproc)
call mpl_bcast(nam%mpicom,mpl%ioproc)
call mpl_bcast(nam%ndir,mpl%ioproc)
call mpl_bcast(nam%londir,mpl%ioproc)
call mpl_bcast(nam%latdir,mpl%ioproc)
call mpl_bcast(nam%levdir,mpl%ioproc)
call mpl_bcast(nam%ivdir,mpl%ioproc)
call mpl_bcast(nam%itsdir,mpl%ioproc)

end subroutine namread

!----------------------------------------------------------------------
! Subroutine: namcheck
!> Purpose: check namelist parameters
!----------------------------------------------------------------------
subroutine namcheck(nam)

implicit none

! Passed variable
type(namtype),intent(inout) :: nam !< Namelist variables

! Local variables
integer :: ib,iv,jv,its,jts,il,idir,ic
character(len=2) :: ivchar

! Check general_param
if (trim(nam%datadir)=='') call msgerror('datadir not specified')
if (trim(nam%prefix)=='') call msgerror('prefix not specified')
select case (trim(nam%model))
case ('aro','arp','gem','geos','gfs','ifs','mpas','nemo','oops','wrf')
case default
   call msgerror('wrong model')
end select

! Check driver_param
select case (trim(nam%method))
case ('cor','loc','hyb-avg','hyb-rnd','dual-ens')
case default
   call msgerror('wrong method')
end select
select case (trim(nam%strategy))
case ('common','specific_univariate','specific_multivariate','common_weighted')
case default
   call msgerror('wrong strategy')
end select
if (nam%new_param.and.(.not.nam%new_mpi)) then
   call msgwarning('new parameters calculation implies new MPI splitting, resetting new_mpi to .true.')
   nam%new_mpi = .true.
end if

! Check model_param
if (nam%nl<=0) call msgerror('nl should be positive')
do il=1,nam%nl
   if (nam%levs(il)<=0) call msgerror('levs should be positive')
   if (count(nam%levs(1:nam%nl)==nam%levs(il))>1) call msgerror('redundant levels')
end do
if (nam%logpres) then
   select case (trim(nam%model))
   case ('aro','arp','gem','geos','gfs','mpas','wrf')
   case default
      call msgwarning('pressure logarithm vertical coordinate is not available for this model, resetting to model level index')
      nam%logpres = .false.
   end select
end if
if (nam%nv<=0) call msgerror('nv should be positive')
do iv=1,nam%nv
   write(ivchar,'(i2.2)') iv
   if (trim(nam%varname(iv))=='') call msgerror('varname not specified for variable '//ivchar)
end do
do its=1,nam%nts
   if (nam%timeslot(its)<0) call msgerror('timeslot should be non-negative')
end do

! Check ens1_param
if (nam%ens1_ne_offset<0) call msgerror('ens1_ne_offset should be non-negative')
if (nam%ens1_nsub<1) call msgerror('ens1_nsub should be positive')
if (mod(nam%ens1_ne,nam%ens1_nsub)/=0) call msgerror('ens1_nsub should be a divider of ens1_ne')
if (nam%ens1_ne/nam%ens1_nsub<=3) call msgerror('ens1_ne/ens1_nsub should be larger than 3')

! Check ens2_param
select case (trim(nam%method))
case ('hyb-rnd','dual-ens')
   if (nam%ens2_ne_offset<0) call msgerror('ens2_ne_offset should be non-negative')
   if (nam%ens2_nsub<1) call msgerror('ens2_nsub should be non-negative')
   if (mod(nam%ens2_ne,nam%ens2_nsub)/=0) call msgerror('ens2_nsub should be a divider of ens2_ne')
   if (nam%ens2_ne/nam%ens2_nsub<=3) call msgerror('ens2_ne/ens2_nsub should be larger than 3')
end select

! Check sampling_param
if (nam%sam_write.and.nam%sam_read) call msgerror('sam_write and sam_read are both true')
if (nam%nc1<=0) call msgerror('nc1 should be positive')
if (nam%ntry<=0) call msgerror('ntry should be positive')
if (nam%nrep<0) call msgerror('nrep should be non-negative')
if (nam%nc<=0) call msgerror('nc should be positive')
if (nam%dc<0.0) call msgerror('dc should be positive')

! Check diag_param
if (nam%ne<=3) call msgerror('ne should be larger than 3')
if (nam%local_diag) then
   if (nam%local_rad<0.0) call msgerror('local_rad should be non-negative')
end if
if (nam%displ_diag) then
   if (nam%displ_rad<0.0) call msgerror('displ_rad should be non-negative')
   if (nam%displ_niter<0) call msgerror('displ_niter should be positive')
   if (nam%displ_rhflt<0.0) call msgerror('displ_rhflt should be non-negative')
   if (nam%displ_tol<0.0) call msgerror('displ_tol should be non-negative')
end if

! Check fit_param
select case (trim(nam%fit_type))
case ('none','fast','full')
case default
   call msgerror('wrong fit_type')
end select
if (nam%rvflt<0) call msgerror('rvflt should be non-negative')

! Check output_param
if (nam%local_diag) then
   if (nam%nldwh<0) call msgerror('nldwh should be non-negative')
   if (any(nam%il_ldwh(1:nam%nldwh)<0)) call msgerror('il_ldwh should be non-negative')
   if (any(nam%il_ldwh(1:nam%nldwh)>nam%nl)) call msgerror('il_ldwh should be lower than nl')
   if (any(nam%ic_ldwh(1:nam%nldwh)<0)) call msgerror('ic_ldwh should be non-negative')
   if (any(nam%ic_ldwh(1:nam%nldwh)>nam%nc)) call msgerror('ic_ldwh should be lower than nc')
   if (nam%nldwv<0) call msgerror('nldwv should be non-negative')
   if (any(nam%lon_ldwv(1:nam%nldwv)<-180.0).or.any(nam%lon_ldwv(1:nam%nldwv)>180.0)) call msgerror('wrong lon_ldwv')
   if (any(nam%lat_ldwv(1:nam%nldwv)<-90.0).or.any(nam%lat_ldwv(1:nam%nldwv)>90.0)) call msgerror('wrong lat_ldwv')
end if
if (nam%local_diag.or.nam%displ_diag) then
   select case (trim(nam%flt_type))
   case ('average','gc99','median')
      if (nam%diag_rhflt<0.0) call msgerror('diag_rhflt should be non-negative')
   case ('none')
   case default
      call msgerror('wrong filtering type')
   end select
end if

! Check nicas_param
if (.not.(nam%resol>0.0)) call msgerror('resol should be positive')
if (nam%nproc<1) call msgerror('nproc should be positive')
if (nam%new_mpi.or.nam%check_mpi.or.nam%check_dirac) then
   if (nam%nproc/=mpl%nproc) call msgerror('nam%nproc should be equal to mpl%nproc')
end if
if ((nam%mpicom/=1).and.(nam%mpicom/=2)) call msgerror('mpicom should be 1 or 2')
if (nam%check_dirac) then
   if (nam%ndir<1) call msgerror('ndir should be positive')
   do idir=1,nam%ndir
      if ((nam%londir(idir)<-180.0).or.(nam%londir(idir)>180.0)) call msgerror('Dirac longitude should lie between -180 and 180')
      if ((nam%latdir(idir)<-90.0).or.(nam%latdir(idir)>90.0)) call msgerror('Dirac latitude should lie between -90 and 90')
      if (.not.any(nam%levdir(idir)==nam%levs(1:nam%nl))) call msgerror('wrong level for a Dirac')
      if ((nam%ivdir(idir)<1).or.(nam%ivdir(idir)>nam%nv)) call msgerror('wrong variable for a Dirac')
      if ((nam%itsdir(idir)<1).or.(nam%itsdir(idir)>nam%nts)) call msgerror('wrong timeslot for a Dirac')
   end do
end if

! Check ensemble sizes
if (trim(nam%method)/='cor') then
   if (nam%ne>nam%ens1_ne) call msgwarning('ensemble size larger than ens1_ne (might enhance sampling noise)')
   if (nam%ne>nam%ens2_ne) call msgwarning('ensemble size larger than ens2_ne (might enhance sampling noise)')
end if

! Check OOPS
if (trim(nam%model)=='oops') then
   if (nam%limited_memory) call msgerror('limited memory not compatible with OOPS')
end if


! Build unread parameters
nam%nb = nam%nv**2*nam%nts**2
allocate(nam%diag_block(nam%nb+1))
allocate(nam%avg_block(nam%nb+1))
allocate(nam%fit_block(nam%nb+1))
allocate(nam%nicas_block(nam%nb+1))
allocate(nam%blockname(nam%nb+1))
allocate(nam%ib_to_iv(nam%nb))
allocate(nam%ib_to_jv(nam%nb))
allocate(nam%ib_to_its(nam%nb))
allocate(nam%ib_to_jts(nam%nb))
ib = 1
do iv=1,nam%nv
   do jv=1,nam%nv
      do its=1,nam%nts
         do jts=1,nam%nts
            ! Select diagnostic blocks
            select case (nam%strategy)
            case ('common')
               nam%diag_block(ib) = (iv==jv).and.(its==1)
               nam%avg_block(ib) = (iv==jv).and.(its==1)
               nam%nicas_block(ib) = .false.
            case ('specific_univariate','specific_multivariate')
               nam%diag_block(ib) = (iv==jv).and.(its==1)
               nam%avg_block(ib) = .false.
               nam%nicas_block(ib) = (iv==jv).and.(its==1)
            case ('common_weighted')
               nam%diag_block(ib) = (its==1)
               nam%avg_block(ib) = (iv==jv).and.(its==1)
               nam%nicas_block(ib) = .false.
            end select
            nam%fit_block(ib) = nam%diag_block(ib).and.(iv==jv).and.(its==jts).and.(trim(nam%fit_type)/='none')

            ! Blocks information
            write(nam%blockname(ib),'(i2.2,a,i2.2,a,i2.2,a,i2.2)') iv,'_',jv,'_',its,'_',jts
            nam%ib_to_iv(ib) = iv
            nam%ib_to_jv(ib) = jv
            nam%ib_to_its(ib) = its
            nam%ib_to_jts(ib) = jts

            ib = ib+1
         end do
      end do
   end do
end do
select case (nam%strategy)
case ('common','common_weighted')
   nam%diag_block(nam%nb+1) = .true. 
   nam%avg_block(nam%nb+1) = .false. 
   nam%nicas_block(nam%nb+1) = .true.
case ('specific_univariate','specific_multivariate')
   nam%diag_block(nam%nb+1) = .false.
   nam%avg_block(nam%nb+1) = .false. 
   nam%nicas_block(nam%nb+1) = .false. 
end select
nam%fit_block(nam%nb+1) = nam%diag_block(nam%nb+1).and.(trim(nam%fit_type)/='none')
nam%blockname(nam%nb+1) = 'common'
do ic=1,nam%nc
   nam%disth(ic) = float(ic-1)*nam%dc
end do

! Clean files
if (nam%check_dirac) call system('rm -f '//trim(nam%datadir)//'/'//trim(nam%prefix)//'_dirac.nc')

end subroutine namcheck

!----------------------------------------------------------------------
! Subroutine: namncwrite
!> Purpose: write namelist parameters as NetCDF attributes
!----------------------------------------------------------------------
subroutine namncwrite(nam,ncid)

implicit none

! Passed variable
type(namtype),intent(in) :: nam !< Namelist variables
integer,intent(in) :: ncid !< NetCDF file id

! TODO : add hdiag variables

! general_param
call namncwrite_param(ncid,'general_param_datadir',trim(nam%datadir))
call namncwrite_param(ncid,'general_param_prefix',trim(nam%prefix))
call namncwrite_param(ncid,'general_param_colorlog',nam%colorlog)
call namncwrite_param(ncid,'general_param_model',trim(nam%model))
call namncwrite_param(ncid,'general_param_nl',nam%nl)
call namncwrite_param(ncid,'general_param_levs',nam%nl,nam%levs)
call namncwrite_param(ncid,'general_param_new_param',nam%new_param)
call namncwrite_param(ncid,'general_param_new_mpi',nam%new_mpi)
call namncwrite_param(ncid,'general_param_check_adjoints',nam%check_adjoints)
call namncwrite_param(ncid,'general_param_check_pos_def',nam%check_pos_def)
call namncwrite_param(ncid,'general_param_check_mpi',nam%check_mpi)
call namncwrite_param(ncid,'general_param_check_dirac',nam%check_dirac)
call namncwrite_param(ncid,'general_param_ndir',nam%ndir)
call namncwrite_param(ncid,'general_param_londir',nam%ndir,nam%londir)
call namncwrite_param(ncid,'general_param_latdir',nam%ndir,nam%latdir)

! sampling_param
call namncwrite_param(ncid,'sampling_param_sam_default_seed',nam%sam_default_seed)
call namncwrite_param(ncid,'sampling_param_mask_check',nam%mask_check)
call namncwrite_param(ncid,'sampling_param_ntry',nam%ntry)
call namncwrite_param(ncid,'sampling_param_nrep',nam%nrep)
call namncwrite_param(ncid,'sampling_param_logpres',nam%logpres)

! nicas_param
call namncwrite_param(ncid,'nicas_param_lsqrt',nam%lsqrt)
call namncwrite_param(ncid,'nicas_param_rh',nam%nl,nam%rh)
call namncwrite_param(ncid,'nicas_param_rv',nam%nl,nam%rv)
call namncwrite_param(ncid,'nicas_param_resol',nam%resol)
call namncwrite_param(ncid,'nicas_param_network',nam%network)
call namncwrite_param(ncid,'nicas_param_nproc',nam%nproc)
call namncwrite_param(ncid,'nicas_param_mpicom',nam%mpicom)

end subroutine namncwrite

!----------------------------------------------------------------------
! Subroutine: namncwrite_integer
!> Purpose: write namelist integer as NetCDF attribute
!----------------------------------------------------------------------
subroutine namncwrite_integer(ncid,varname,var)

implicit none

! Passed variables
integer,intent(in) :: ncid             !< NetCDF file id
character(len=*),intent(in) :: varname !< Variable name
integer,intent(in) :: var              !< Integer

! Local variables
character(len=1024) :: subr='namncwrite_integer'

! Write integer
call ncerr(subr,nf90_put_att(ncid,nf90_global,trim(varname),var))

end subroutine namncwrite_integer

!----------------------------------------------------------------------
! Subroutine: namncwrite_integer_array
!> Purpose: write namelist integer array as NetCDF attribute
!----------------------------------------------------------------------
subroutine namncwrite_integer_array(ncid,varname,n,var)

implicit none

! Passed variables
integer,intent(in) :: ncid             !< NetCDF file id
character(len=*),intent(in) :: varname !< Variable name
integer,intent(in) :: n                !< Integer array size
integer,intent(in) :: var(n)           !< Integer array

! Local variables
integer :: i
character(len=1024) :: str,fullstr
character(len=1024) :: subr='namncwrite_integer_array'

! Write integer array as a string
if (n>0) then
   write(fullstr,'(i3.3)') var(1)
   do i=2,n
      write(str,'(i3.3)') var(i)
      fullstr = trim(fullstr)//':'//trim(str)
   end do
   call ncerr(subr,nf90_put_att(ncid,nf90_global,trim(varname),trim(fullstr)))
end if

end subroutine namncwrite_integer_array

!----------------------------------------------------------------------
! Subroutine: namncwrite_real
!> Purpose: write namelist real as NetCDF attribute
!----------------------------------------------------------------------
subroutine namncwrite_real(ncid,varname,var)

implicit none

! Passed variables
integer,intent(in) :: ncid             !< NetCDF file id
character(len=*),intent(in) :: varname !< Variable name
real(kind_real),intent(in) :: var      !< Real

! Local variables
character(len=1024) :: subr='namncwrite_real'

! Write real
call ncerr(subr,nf90_put_att(ncid,nf90_global,trim(varname),var))

end subroutine namncwrite_real

!----------------------------------------------------------------------
! Subroutine: namncwrite_real_array
!> Purpose: write namelist real array as NetCDF attribute
!----------------------------------------------------------------------
subroutine namncwrite_real_array(ncid,varname,n,var)

implicit none

! Passed variables
integer,intent(in) :: ncid             !< NetCDF file id
character(len=*),intent(in) :: varname !< Variable name
integer,intent(in) :: n                !< Real array size
real(kind_real),intent(in) :: var(n)   !< Real array

! Local variables
integer :: i
character(len=1024) :: str,fullstr
character(len=1024) :: subr='namncwrite_real_array'

! Write real array as a string
if (n>0) then
   write(fullstr,'(e10.3)') var(1)
   do i=2,n
      write(str,'(e10.3)') var(i)
      fullstr = trim(fullstr)//':'//trim(str)
   end do
   call ncerr(subr,nf90_put_att(ncid,nf90_global,trim(varname),trim(fullstr)))
end if

end subroutine namncwrite_real_array

!----------------------------------------------------------------------
! Subroutine: namncwrite_logical
!> Purpose: write namelist logical as NetCDF attribute
!----------------------------------------------------------------------
subroutine namncwrite_logical(ncid,varname,var)

implicit none

! Passed variables
integer,intent(in) :: ncid             !< NetCDF file id
character(len=*),intent(in) :: varname !< Variable name
logical,intent(in) :: var              !< Logical

! Local variables
character(len=1024) :: subr='namncwrite_logical'

! Write logical as a string
if (var) then
   call ncerr(subr,nf90_put_att(ncid,nf90_global,trim(varname),'.true.'))
else
   call ncerr(subr,nf90_put_att(ncid,nf90_global,trim(varname),'.false.'))
end if

end subroutine namncwrite_logical

!----------------------------------------------------------------------
! Subroutine: namncwrite_string
!> Purpose: write namelist string as NetCDF attribute
!----------------------------------------------------------------------
subroutine namncwrite_string(ncid,varname,var)

implicit none

! Passed variables
integer,intent(in) :: ncid             !< NetCDF file id
character(len=*),intent(in) :: varname !< Variable name
character(len=*),intent(in) :: var     !< String

! Local variables
character(len=1024) :: subr='namncwrite_string'

! Write string
call ncerr(subr,nf90_put_att(ncid,nf90_global,trim(varname),trim(var)))

end subroutine namncwrite_string

end module module_namelist
