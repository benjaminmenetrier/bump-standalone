!----------------------------------------------------------------------
! Module: module_displacement.f90
!> Purpose: displacement computation routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module module_displacement

use model_interface, only: model_read
use module_diag_tools, only: diag_filter
use module_sampling, only: compute_sampling_ps
use omp_lib
use tools_const, only: req,reqkm,rad2deg,deg2rad,lonmod,sphere_dist,reduce_arc,vector_product
use tools_display, only: msgerror,prog_init,prog_print
use tools_kinds, only: kind_real
use tools_missing, only: msr,isnotmsr,isallnotmsr
use tools_qsort, only: qsort
use type_ctree, only: find_nearest_neighbors
use type_displ, only: displtype,displ_alloc
use type_linop, only: apply_linop
use type_mesh, only: check_mesh
use type_mom, only: momtype
use type_mpl, only: mpl
use type_hdata, only: hdatatype
implicit none

real(kind_real),parameter :: cor_th = 0.0     !< Correlation threshold
logical,parameter :: common_sampling = .true. !< Common sampling for all variables

private
public :: compute_displacement

contains

!----------------------------------------------------------------------
! Subroutine: compute_displacement
!> Purpose: compute correlation maximum displacement
!----------------------------------------------------------------------
subroutine compute_displacement(hdata,displ)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata !< Sampling data
type(displtype),intent(inout) :: displ !< Displacement data

! Local variables
integer :: ic0,ic1,ic2,jc0,iv,il0,isub,ie,iter,progint
integer :: count_com(hdata%nam%nc1,hdata%nc2,hdata%geom%nl0),ind(hdata%nam%nc1)
integer,allocatable :: order(:)
real(kind_real) :: fac4,fac6,m11_avg,m2m2_avg,drhflt,dum(1),lon_tmp,lat_tmp
real(kind_real) :: fldb(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv),fld(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: m1b(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv),m1(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: m2b(hdata%nam%nc1,hdata%nc2,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: m2(hdata%nam%nc1,hdata%nc2,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: m11(hdata%nam%nc1,hdata%nc2,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: lon(hdata%nc2,hdata%geom%nl0),lat(hdata%nc2,hdata%geom%nl0)
real(kind_real) :: dlon(hdata%nc2,hdata%geom%nl0,hdata%nam%nvp),dlat(hdata%nc2,hdata%geom%nl0,hdata%nam%nvp)
real(kind_real) :: dist(hdata%nc2),lon_vec(hdata%nc2),lat_vec(hdata%nc2),valid(hdata%nc2)
real(kind_real) :: dlon_ini(hdata%nc2),dlat_ini(hdata%nc2)
real(kind_real) :: cor_com(hdata%nam%nc1,hdata%nc2,hdata%geom%nl0)
real(kind_real) :: dlon_tmp(hdata%nam%nc1),dlat_tmp(hdata%nam%nc1)
real(kind_real) :: lon_interp(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nvp),lat_interp(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nvp)
real(kind_real),allocatable :: cor(:)
logical :: dichotomy,convergence
logical,allocatable :: done(:)
type(momtype) :: momb,mom

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Allocation
call displ_alloc(hdata,displ)

! Copy members parameters
momb%ne_offset = nam%ens1_ne_offset
momb%nsub = nam%ens1_nsub
momb%input = nam%ens1_input(1:nam%nv)
momb%varname = nam%ens1_varname(1:nam%nv)
momb%time = nam%ens1_time(1:nam%nv)
mom%ne_offset = nam%ens2_ne_offset
mom%nsub = nam%ens2_nsub
mom%input = nam%ens2_input(1:nam%nv)
mom%varname = nam%ens2_varname(1:nam%nv)
mom%time = nam%ens2_time(1:nam%nv)

! Initial point
do il0=1,geom%nl0
   do ic2=1,hdata%nc2
      if (hdata%ic1il0_log(hdata%ic2_to_ic1(ic2),il0)) then
         lon(ic2,il0) = geom%lon(hdata%ic2_to_ic0(ic2))
         lat(ic2,il0) = geom%lat(hdata%ic2_to_ic0(ic2))
      end if
   end do
end do

! Compute moments
write(mpl%unit,'(a7,a)') '','Compute moments'

! Loop on sub-ensembles
do isub=1,nam%ens1_nsub
   if (momb%nsub==1) then
      write(mpl%unit,'(a10,a)',advance='no') '','Full ensemble, member:'
   else
      write(mpl%unit,'(a10,a,i4,a)',advance='no') '','Sub-ensemble ',isub,', member:'
   end if

   ! Initialization
   m1b = 0.0
   m1 = 0.0
   m2b(:,:,:,:,isub) = 0.0
   m2(:,:,:,:,isub) = 0.0
   m11(:,:,:,:,isub) = 0.0

   ! Compute centered moments iteratively
   do ie=1,nam%ens1_ne/nam%ens1_nsub
      write(mpl%unit,'(i4)',advance='no') momb%ne_offset+ie

      ! Computation factors
      fac4 = 1.0/float(ie)
      fac6 = float(ie-1)/float(ie)

      ! Load fields
      call model_read(nam,momb,ie,isub,geom,fldb)
      fldb = fldb - m1b
      call model_read(nam,mom,ie,isub,geom,fld)
      fld = fld - m1

      ! Update high-order moments
      if (ie>1) then
         do iv=1,nam%nv
            do il0=1,geom%nl0
               !$omp parallel do private(ic2,ic1,ic0,jc0)
               do ic2=1,hdata%nc2
                  if (hdata%ic1il0_log(hdata%ic2_to_ic1(ic2),il0)) then
                     do ic1=1,nam%nc1
                        if (hdata%displ_mask(ic1,ic2,min(il0,geom%nl0i))) then
                           ! Indices
                           ic0 = hdata%ic1_to_ic0(ic1)
                           jc0 = hdata%ic2_to_ic0(ic2)

                           ! Covariance
                           m11(ic1,ic2,il0,iv,isub) = m11(ic1,ic2,il0,iv,isub)+fac6*fldb(jc0,il0,iv)*fld(ic0,il0,iv)

                           ! Variances
                           m2b(ic1,ic2,il0,iv,isub) = m2b(ic1,ic2,il0,iv,isub)+fac6*fldb(jc0,il0,iv)**2
                           m2(ic1,ic2,il0,iv,isub) = m2(ic1,ic2,il0,iv,isub)+fac6*fld(ic0,il0,iv)**2
                        end if
                     end do
                  end if
               end do
               !$omp end parallel do
            end do
         end do
      end if

      ! Update means
      do iv=1,nam%nv
         do il0=1,geom%nl0
            !$omp parallel do private(ic0)
            do ic0=1,geom%nc0
               if (geom%mask(ic0,il0)) then
                  m1b(ic0,il0,iv) = m1b(ic0,il0,iv)+fac4*fldb(ic0,il0,iv)
                  m1(ic0,il0,iv) = m1(ic0,il0,iv)+fac4*fld(ic0,il0,iv)
               end if
            end do
            !$omp end parallel do
         end do
      end do
   end do
   write(mpl%unit,'(a)') ''
end do

! Find correlation maximum propagation
write(mpl%unit,'(a7,a)') '','Find correlation maximum propagation'

! Initialization
cor_com = 0.0
count_com = 0
dlon = 0.0
dlat = 0.0
dist = 0.0

do iv=1,nam%nvp
   do il0=1,geom%nl0
      !$omp parallel do private(ic2,cor,order,ic1,m11_avg,m2m2_avg)
      do ic2=1,hdata%nc2
         if (hdata%ic1il0_log(hdata%ic2_to_ic1(ic2),il0)) then
            ! Allocation
            allocate(cor(nam%nc1))
            allocate(order(nam%nc1))

            ! Initialization
            call msr(cor)

            ! Common variables initialization
            if (iv<=nam%nv) then
               do ic1=1,nam%nc1
                  if (hdata%displ_mask(ic1,ic2,min(il0,geom%nl0i))) then
                     ! Correlation
                     m11_avg = sum(m11(ic1,ic2,il0,iv,:))/float(momb%nsub)
                     m2m2_avg = sum(m2b(ic1,ic2,il0,iv,:))*sum(m2(ic1,ic2,il0,iv,:))/float(momb%nsub**2)
                     if (m2m2_avg>0.0) then
                        cor(ic1) = m11_avg/sqrt(m2m2_avg)
                        cor_com(ic1,ic2,il0) = cor_com(ic1,ic2,il0)+cor(ic1)
                        count_com(ic1,ic2,il0) = count_com(ic1,ic2,il0)+1
                     else
                        call msr(cor(ic1))
                     end if
                  end if
               end do
            else
               do ic1=1,nam%nc1
                  if (hdata%displ_mask(ic1,ic2,min(il0,geom%nl0i))) cor(ic1) = cor_com(ic1,ic2,il0)/float(count_com(ic1,ic2,il0))
               end do
            end if

            ! Sort correlations
            call qsort(nam%nc1,cor,order)

            ! Locate the maximum correlation, with a correlation threshold
            if (cor(nam%nc1)>cor_th) then
               dlon(ic2,il0,iv) = lonmod(geom%lon(hdata%ic1_to_ic0(order(nam%nc1)))-lon(ic2,il0))
               dlat(ic2,il0,iv) = geom%lat(hdata%ic1_to_ic0(order(nam%nc1)))-lat(ic2,il0)
               call sphere_dist(lon(ic2,il0),lat(ic2,il0),geom%lon(hdata%ic1_to_ic0(order(nam%nc1))), &
             & geom%lat(hdata%ic1_to_ic0(order(nam%nc1))),dist(ic2))
            end if
         end if

         ! Release memory
         deallocate(cor)
         deallocate(order)
      end do
      !$omp end parallel do

      ! Average distance
      displ%dist(0,il0,iv) = sum(dist,mask=hdata%ic1il0_log(hdata%ic2_to_ic1,il0)) &
    & /count(hdata%ic1il0_log(hdata%ic2_to_ic1,il0))
   end do
end do

do iv=1,nam%nvp
   do il0=1,geom%nl0
      ! Check raw mesh
      do ic2=1,hdata%nc2
         lon_vec(ic2) = lonmod(lon(ic2,il0)+dlon(ic2,il0,iv))
         lat_vec(ic2) = lat(ic2,il0)+dlat(ic2,il0,iv)
      end do
      call check_mesh(hdata%nc2,lon_vec,lat_vec,hdata%nt,hdata%ltri,valid)
      displ%valid(0,il0,iv) = sum(valid,mask=hdata%ic1il0_log(hdata%ic2_to_ic1,il0)) &
    & /count(hdata%ic1il0_log(hdata%ic2_to_ic1,il0))
      displ%rhflt(0,il0,iv) = 0.0
   end do
end do

! Raw displacement interpolation
write(mpl%unit,'(a7,a)') '','Raw displacement interpolation'
do iv=1,nam%nvp
   do il0=1,geom%nl0
      call apply_linop(hdata%h(min(il0,geom%nl0i)),dlon(:,il0,iv),displ%dlon_raw(:,il0,iv))
      call apply_linop(hdata%h(min(il0,geom%nl0i)),dlat(:,il0,iv),displ%dlat_raw(:,il0,iv))
   end do
end do
displ%dlon_raw = displ%dlon_raw*rad2deg
displ%dlat_raw = displ%dlat_raw*rad2deg

if (nam%displ_niter>0) then
   ! Filter displacement
   write(mpl%unit,'(a7,a)') '','Filter displacement'

   ! Allocation
   allocate(order(hdata%nc2))

   do iv=1,nam%nvp
      do il0=1,geom%nl0
         write(mpl%unit,'(a10,a,i2,a,i3,a)') '','Variable ',iv,', level ',nam%levs(il0),':'

         ! Compute displacement
         dlon_ini = cos(lat(:,il0))*dlon(:,il0,iv)
         dlat_ini = dlat(:,il0,iv)

         ! Iterative filtering
         convergence = .true.
         drhflt = 0.0
         dichotomy = .false.

         ! Dichotomy initialization
         displ%rhflt(1,il0,iv) = nam%displ_rhflt

         do iter=1,nam%displ_niter
            ! Copy increment
            dlon(:,il0,iv) = dlon_ini
            dlat(:,il0,iv) = dlat_ini

            ! Median filter to remove extreme values
            call diag_filter(hdata,'median',displ%rhflt(iter,il0,iv),il0,dlon(:,il0,iv))
            call diag_filter(hdata,'median',displ%rhflt(iter,il0,iv),il0,dlat(:,il0,iv))

            ! Average filter to smooth displacement
            call diag_filter(hdata,'average',displ%rhflt(iter,il0,iv),il0,dlon(:,il0,iv))
            call diag_filter(hdata,'average',displ%rhflt(iter,il0,iv),il0,dlat(:,il0,iv))

            ! Compute displaced location
            dlon(:,il0,iv) = dlon(:,il0,iv)/cos(lat(:,il0))

            ! Reduce distance with respect to boundary
            do ic2=1,hdata%nc2
               if (hdata%ic1il0_log(hdata%ic2_to_ic1(ic2),il0)) then
                  lon_tmp = lonmod(lon(ic2,il0)+dlon(ic2,il0,iv))
                  lat_tmp = lat(ic2,il0)+dlat(ic2,il0,iv)
                  call reduce_arc(lon(ic2,il0),lat(ic2,il0),lon_tmp,lat_tmp,hdata%bdist(ic2),dist(ic2))
                  dlon(ic2,il0,iv) = lonmod(lon(ic2,il0)-lon_tmp)
                  dlat(ic2,il0,iv) = lat(ic2,il0)-lat_tmp
               end if
            end do

            ! Check mesh
            do ic2=1,hdata%nc2
               lon_vec(ic2) = lonmod(lon(ic2,il0)+dlon(ic2,il0,iv))
               lat_vec(ic2) = lat(ic2,il0)+dlat(ic2,il0,iv)
            end do
            call check_mesh(hdata%nc2,lon_vec,lat_vec,hdata%nt,hdata%ltri,valid)
            displ%valid(iter,il0,iv) = sum(valid,mask=hdata%ic1il0_log(hdata%ic2_to_ic1,il0)) &
          & /count(hdata%ic1il0_log(hdata%ic2_to_ic1,il0))

            ! Compute distances
            do ic2=1,hdata%nc2
               if (hdata%ic1il0_log(hdata%ic2_to_ic1(ic2),il0)) then
                  call sphere_dist(lon(ic2,il0),lat(ic2,il0),lonmod(lon(ic2,il0)+dlon(ic2,il0,iv)), &
                & lat(ic2,il0)+dlat(ic2,il0,iv),dist(ic2))
               end if
            end do
            displ%dist(iter,il0,iv) = sum(dist,mask=hdata%ic1il0_log(hdata%ic2_to_ic1,il0)) &
          & /count(hdata%ic1il0_log(hdata%ic2_to_ic1,il0))

            ! Print results
            write(mpl%unit,'(a13,a,i2,a,f8.2,a,f6.2,a,f6.2,a,f7.2,a)') '','Iteration ',iter,': rhflt = ', &
          & displ%rhflt(iter,il0,iv)*reqkm,' km, valid points: ',100.0*displ%valid(0,il0,iv),'% ~> ', &
          & 100.0*displ%valid(iter,il0,iv),'%, average displacement = ',displ%dist(iter,il0,iv)*reqkm,' km'

            ! Update support radius
            if (displ%valid(iter,il0,iv)<1.0-nam%displ_tol) then
               ! Increase filtering support radius
               if (dichotomy) then
                  if (iter<nam%displ_niter) displ%rhflt(iter+1,il0,iv) = displ%rhflt(iter,il0,iv)+drhflt
               else
                  ! No convergence
                  convergence = .false.
                  if (iter<nam%displ_niter) displ%rhflt(iter+1,il0,iv) = 2.0*displ%rhflt(iter,il0,iv)
               end if
            else
               ! Convergence
               convergence = .true.

               ! Check dichotomy status
               if (.not.dichotomy) then
                  dichotomy = .true.
                  drhflt = 0.5*displ%rhflt(iter,il0,iv)
               end if

               ! Decrease filtering support radius
               if (iter<nam%displ_niter) displ%rhflt(iter+1,il0,iv) = displ%rhflt(iter,il0,iv)-drhflt
            end if
            if (dichotomy) drhflt = 0.5*drhflt
         end do

         ! Check convergence
         if (.not.convergence) call msgerror('iterative filtering failed')
      end do
   end do

   ! Deallocation
   deallocate(order)
end if

! Filtered displacement interpolation
write(mpl%unit,'(a7,a)') '','Filtered displacement interpolation'
do iv=1,nam%nvp
   do il0=1,geom%nl0
      call apply_linop(hdata%h(min(il0,geom%nl0i)),dlon(:,il0,iv),displ%dlon_flt(:,il0,iv))
      call apply_linop(hdata%h(min(il0,geom%nl0i)),dlat(:,il0,iv),displ%dlat_flt(:,il0,iv))
   end do
end do
displ%dlon_flt = displ%dlon_flt*rad2deg
displ%dlat_flt = displ%dlat_flt*rad2deg

! Resampling interpolation
write(mpl%unit,'(a7,a)') '','Resampling interpolation'
do iv=1,nam%nvp
   do il0=1,geom%nl0
      call apply_linop(hdata%s(min(il0,geom%nl0i)),dlon(:,il0,iv),dlon_tmp)
      call apply_linop(hdata%s(min(il0,geom%nl0i)),dlat(:,il0,iv),dlat_tmp)
      do ic1=1,nam%nc1
         lon_interp(ic1,il0,iv) = lonmod(geom%lon(hdata%ic1_to_ic0(ic1))+dlon_tmp(ic1))
         lat_interp(ic1,il0,iv) = geom%lat(hdata%ic1_to_ic0(ic1))+dlat_tmp(ic1)
      end do
   end do
end do

! Recompute sampling
write(mpl%unit,'(a7,a)',advance='no') '','Recompute sampling: '
if (common_sampling) then
   ! Common sampling for all variables
   allocate(done(geom%nl0*nam%nc1))
   call prog_init(progint,done)
   do il0=1,geom%nl0
      do ic1=1,nam%nc1
         call find_nearest_neighbors(geom%ctree(min(il0,geom%nl0i)),lon_interp(ic1,il0,nam%nvp),lat_interp(ic1,il0,nam%nvp), &
       & 1,ind(ic1),dum)
         done((il0-1)*nam%nc1+ic1) = .true.
         call prog_print(progint,done)
      end do
      do iv=1,nam%nv
         hdata%ic1icil0iv_to_ic0(:,1,il0,iv) = ind
      end do
   end do
   deallocate(done)
else
   ! Different sampling for each variable
   allocate(done(nam%nv*geom%nl0*nam%nc1))
   call prog_init(progint,done)
   do iv=1,nam%nv
      do il0=1,geom%nl0
         do ic1=1,nam%nc1
            call find_nearest_neighbors(geom%ctree(min(il0,geom%nl0i)),lon_interp(ic1,il0,iv),lat_interp(ic1,il0,iv), &
          & 1,ind(ic1),dum)
            done((iv-1)*geom%nl0*nam%nc1+(il0-1)*nam%nc1+ic1) = .true.
            call prog_print(progint,done)
         end do
         hdata%ic1icil0iv_to_ic0(:,1,il0,iv) = ind
      end do
   end do
   deallocate(done)
end if
write(mpl%unit,'(a)') '100%'
call compute_sampling_ps(hdata)

! End associate
end associate

end subroutine compute_displacement

end module module_displacement
