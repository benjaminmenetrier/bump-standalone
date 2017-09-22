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
use tools_const, only: req,rad2deg,deg2rad,lonmod,sphere_dist,reduce_arc,vector_product
use tools_display, only: msgerror,prog_init,prog_print
use tools_kinds, only: kind_real
use tools_missing, only: msr,isnotmsr,isallnotmsr
use tools_qsort, only: qsort
use type_ctree, only: find_nearest_neighbors
use type_displ, only: displtype
use type_mesh, only: check_mesh
use type_mom, only: momtype
use type_mpl, only: mpl
use type_hdata, only: hdatatype
implicit none

real(kind_real),parameter :: cor_th = 0.0                 !< Correlation threshold
logical,parameter :: common_sampling = .false. !< Common sampling for all variables

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
integer :: ic1,jc1,ks,iv,il0,isub,ie,iter,jter,jterp,progint
integer :: count_com(hdata%nam%nc1,hdata%nam%nc1,hdata%geom%nl0),ic1icil0iv_to_ic0(hdata%nam%nc1)
integer,allocatable :: order(:)
real(kind_real) :: fac4,fac6,delta,delta0,varprod,drhflt,dum(1)
real(kind_real) :: fld(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv),fld_displ(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: m1(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv),m1_displ(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: m2(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: m2_displ(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: m11(hdata%nam%nc1,hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: var(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv),var_displ(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: lon,lat,lon_vec(hdata%nam%nc1),lat_vec(hdata%nam%nc1)
real(kind_real) :: dlon_ini(hdata%nam%nc1),dlat_ini(hdata%nam%nc1),dist(hdata%nam%nc1),dlon(hdata%nam%nc1),dlat(hdata%nam%nc1)
real(kind_real) :: cor_com(hdata%nam%nc1,hdata%nam%nc1,hdata%geom%nl0)
real(kind_real),allocatable :: cov(:),cor(:)
logical :: dichotomy,convergence
logical,allocatable :: done(:)
type(momtype) :: mom,mom_displ

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Copy members parameters
mom%ne_offset = nam%ens1_ne_offset
mom%nsub = nam%ens1_nsub
mom%input = nam%ens1_input(1:nam%nv)
mom%varname = nam%ens1_varname(1:nam%nv)
mom%time = nam%ens1_time(1:nam%nv)
mom_displ%ne_offset = nam%ens2_ne_offset
mom_displ%nsub = nam%ens2_nsub
mom_displ%input = nam%ens2_input(1:nam%nv)
mom_displ%varname = nam%ens2_varname(1:nam%nv)
mom_displ%time = nam%ens2_time(1:nam%nv)

! Initial point
do il0=1,geom%nl0
   do ic1=1,nam%nc1
      if (hdata%ic1il0_log(ic1,il0)) then
         displ%lon(ic1,il0) = geom%lon(hdata%ic1_to_ic0(ic1))
         displ%lat(ic1,il0) = geom%lat(hdata%ic1_to_ic0(ic1))
      end if
   end do
end do

! Compute moments
write(mpl%unit,'(a7,a)') '','Compute moments'

! Loop on sub-ensembles
do isub=1,nam%ens1_nsub
   if (mom%nsub==1) then
      write(mpl%unit,'(a10,a)',advance='no') '','Full ensemble, member:'
   else
      write(mpl%unit,'(a10,a,i4,a)',advance='no') '','Sub-ensemble ',isub,', member:'
   end if

   ! Initialization
   m1 = 0.0
   m1_displ = 0.0
   m2(:,:,:,isub) = 0.0
   m2_displ(:,:,:,isub) = 0.0
   m11(isub,:,:,:,:) = 0.0

   ! Compute centered moments iteratively
   do ie=1,nam%ens1_ne/nam%ens1_nsub
      write(mpl%unit,'(i4)',advance='no') mom%ne_offset+ie

      ! Computation factors
      fac4 = 1.0/float(ie)
      fac6 = float(ie-1)/float(ie)

      ! Load fields
      call model_read(nam,mom,ie,isub,geom,fld)
      call model_read(nam,mom_displ,ie,isub,geom,fld_displ)

      ! Update high-order moments
      if (ie>1) then
         do iv=1,nam%nv
            do il0=1,geom%nl0
               !$omp parallel do private(ic1,delta0,jc1,ks,delta)
               do ic1=1,nam%nc1
                  if (hdata%ic1il0_log(ic1,il0)) then
                     ! Ensemble perturbation
                     delta0 = fld(hdata%ic1_to_ic0(ic1),il0,iv)-m1(ic1,il0,iv)

                     ! Compute variance/covariance within a radius min(nam%displ_rad,bdist)
                     jc1 = 1
                     do while ((jc1==1).or.hdata%nn_nc1_dist(jc1,ic1,min(il0,geom%nl0i))<min(nam%displ_rad,hdata%bdist(ic1)))
                        ! Neighbor index
                        ks = hdata%nn_nc1_index(jc1,ic1,min(il0,geom%nl0i))

                        ! Ensemble perturbation
                        delta = fld_displ(hdata%ic1_to_ic0(ks),il0,iv)-m1_displ(ks,il0,iv)

                        ! Covariance
                        m11(ks,ic1,il0,iv,isub) = m11(ks,ic1,il0,iv,isub)+fac6*delta0*delta

                        ! Variance
                        if (jc1==1) m2_displ(ks,il0,iv,isub) = m2_displ(ks,il0,iv,isub)+fac6*delta**2

                        ! Update
                        jc1 = jc1+1
                     end do

                     ! Variance
                     m2(ic1,il0,iv,isub) = m2(ic1,il0,iv,isub)+fac6*delta0**2
                  end if
               end do
               !$omp end parallel do
            end do
         end do
      end if

      ! Update mean
      do il0=1,geom%nl0
         do iv=1,nam%nv
            !$omp parallel do private(ic1,delta0,delta)
            do ic1=1,nam%nc1
               if (hdata%ic1il0_log(ic1,il0)) then
                  ! Ensemble perturbation
                  delta0 = fld(hdata%ic1_to_ic0(ic1),il0,iv)-m1(ic1,il0,iv)
                  delta = fld_displ(hdata%ic1_to_ic0(ic1),il0,iv)-m1_displ(ic1,il0,iv)

                  ! Mean
                  m1(ic1,il0,iv) = m1(ic1,il0,iv)+fac4*delta0
                  m1_displ(ic1,il0,iv) = m1_displ(ic1,il0,iv)+fac4*delta
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

! Average variances over sub-ensembles
var = sum(m2,dim=4)/float(mom%nsub)
var_displ = sum(m2_displ,dim=4)/float(mom%nsub)

! Initialization
cor_com = 0.0
count_com = 0

do iv=1,nam%nvp
   do il0=1,geom%nl0
      !$omp parallel do private(ic1,cov,cor,order,jc1,ks,varprod,lon,lat)
      do ic1=1,nam%nc1
         ! Allocation
         allocate(cov(nam%nc1))
         allocate(cor(nam%nc1))
         allocate(order(nam%nc1))

         if (hdata%ic1il0_log(ic1,il0)) then
            ! Common variables initialization
            if (iv<=nam%nv) then
               ! Average covariance over sub-ensembles
               cov = sum(m11(:,ic1,il0,iv,:),dim=2)/float(mom%nsub)

               ! Compute correlation within a radius nam%displ_rad
               jc1 = 1
               do while ((jc1==1).or.hdata%nn_nc1_dist(jc1,ic1,min(il0,geom%nl0i))<min(nam%displ_rad,hdata%bdist(ic1)))
                  ! Neighbor index
                  ks = hdata%nn_nc1_index(jc1,ic1,min(il0,geom%nl0i))

                  ! Variance product
                  varprod = var(ic1,il0,iv)*var_displ(ks,il0,iv)

                  ! Correlation
                  if (varprod>0.0) then
                     cor(jc1) = cov(ks)/sqrt(varprod)
                     cor_com(jc1,ic1,il0) = cor_com(jc1,ic1,il0)+cor(jc1)
                     count_com(jc1,ic1,il0) = count_com(jc1,ic1,il0)+1
                  else
                     call msr(cor(jc1))
                  end if

                  ! Update
                  jc1 = jc1+1
                  if (jc1>nam%nc1) exit
               end do
            else
               ! Common correlation
               jc1 = 1
               do ks=1,nam%nc1
                  if (count_com(ks,ic1,il0)>0) then
                     cor(ks) = cor_com(ks,ic1,il0)/float(count_com(ks,ic1,il0))
                     jc1 = jc1+1
                  else
                     call msr(cor(ks))
                  end if
               end do
            end if
            jc1 = jc1-1

            ! Sort correlations
            call qsort(jc1,cor(1:jc1),order(1:jc1))

            ! Locate the maximum correlation, apply a threshold
            if (cor(jc1)>cor_th) then
               lon = displ%lon(hdata%nn_nc1_index(order(jc1),ic1,il0),min(il0,geom%nl0i))
               lat = displ%lat(hdata%nn_nc1_index(order(jc1),ic1,il0),min(il0,geom%nl0i))
               displ%dlon_raw(ic1,il0,iv) = lonmod(lon-displ%lon(ic1,il0))
               displ%dlat_raw(ic1,il0,iv) = lat-displ%lat(ic1,il0)
               call sphere_dist(displ%lon(ic1,il0),displ%lat(ic1,il0),lon,lat,displ%dist_raw(ic1,il0,iv))
            else
               displ%dlon_raw(ic1,il0,iv) = 0.0
               displ%dlat_raw(ic1,il0,iv) = 0.0
               displ%dist_raw(ic1,il0,iv) = 0.0
            end if
         end if

         ! Release memory
         deallocate(cov)
         deallocate(cor)
         deallocate(order)
      end do
      !$omp end parallel do
   end do
end do

do iv=1,nam%nvp
   do il0=1,geom%nl0
      ! Check raw mesh
      do ic1=1,nam%nc1
         lon_vec(ic1) = lonmod(displ%lon(ic1,il0)+displ%dlon_raw(ic1,il0,iv))
         lat_vec(ic1) = displ%lat(ic1,il0)+displ%dlat_raw(ic1,il0,iv)
      end do
      call check_mesh(nam%nc1,lon_vec,lat_vec,hdata%nt,hdata%ltri,displ%valid_raw(:,il0,iv))

      ! Copy raw mesh
      displ%dlon_flt(:,1,il0,iv) = displ%dlon_raw(:,il0,iv)
      displ%dlat_flt(:,1,il0,iv) = displ%dlat_raw(:,il0,iv)
   end do
end do

if (nam%displ_niter>0) then
   ! Filter displacement
   write(mpl%unit,'(a7,a)') '','Filter displacement'

   ! Allocation
   allocate(order(nam%nc1))

   do iv=1,nam%nvp
      do il0=1,geom%nl0
         write(mpl%unit,'(a10,a,i2,a,i3,a)') '','Variable ',iv,', level ',nam%levs(il0),':'

         ! Compute displacement
         do ic1=1,nam%nc1
            if (hdata%ic1il0_log(ic1,il0)) then
               dlon_ini(ic1) = cos(displ%lat(ic1,il0))*displ%dlon_raw(ic1,il0,iv)
               dlat_ini(ic1) = displ%dlat_raw(ic1,il0,iv)
            end if
         end do

         ! Iterative filtering
         convergence = .true.
         drhflt = 0.0
         dichotomy = .false.
         do iter=1,nam%displ_niter
            if (nam%displ_explicit) then
               ! Storing indices
               jter = iter
               jterp = max(iter+1,nam%displ_niter)

               ! Set support radius to an explicit value
               displ%rhflt(jter,il0,iv) = nam%displ_rhflt*float(jter)/float(nam%displ_niter)
            else
               ! Storing indices
               jter = 1
               jterp = 1

               if (iter==1) then
                  ! Dichotomy initialization
                  displ%rhflt(jter,il0,iv) = nam%displ_rhflt
               end if
            end if

            ! Copy increment
            dlon = dlon_ini
            dlat = dlat_ini

            ! Median filter to remove extreme values
            call diag_filter(hdata,'median',displ%rhflt(jter,il0,iv),il0,dlon)
            call diag_filter(hdata,'median',displ%rhflt(jter,il0,iv),il0,dlat)

            ! Average filter to smooth displacement
            call diag_filter(hdata,'average',displ%rhflt(jter,il0,iv),il0,dlon)
            call diag_filter(hdata,'average',displ%rhflt(jter,il0,iv),il0,dlat)

            ! Compute displaced location
            do ic1=1,nam%nc1
               if (hdata%ic1il0_log(ic1,il0)) then
                  displ%dlon_flt(ic1,jter,il0,iv) = dlon(ic1)/cos(displ%lat(ic1,il0))
                  displ%dlat_flt(ic1,jter,il0,iv) = dlat(ic1)
               end if
            end do

            ! Reduce distance with respect to boundary
            do ic1=1,nam%nc1
               if (hdata%ic1il0_log(ic1,il0)) then
                  lon = lonmod(displ%lon(ic1,il0)+displ%dlon_flt(ic1,jter,il0,iv))
                  lat = displ%lat(ic1,il0)+displ%dlat_flt(ic1,jter,il0,iv)
                  call reduce_arc(displ%lon(ic1,il0),displ%lat(ic1,il0),lon,lat,hdata%bdist(ic1),dist(ic1))
               end if
            end do

            ! Check mesh
            do ic1=1,nam%nc1
               lon_vec(ic1) = lonmod(displ%lon(ic1,il0)+displ%dlon_flt(ic1,jter,il0,iv))
               lat_vec(ic1) = displ%lat(ic1,il0)+displ%dlat_flt(ic1,jter,il0,iv)
            end do
            call check_mesh(nam%nc1,lon_vec,lat_vec,hdata%nt,hdata%ltri,displ%valid_flt(:,jter,il0,iv))

            ! Compute distances
            do ic1=1,nam%nc1
               if (hdata%ic1il0_log(ic1,il0)) then
                  lon = lonmod(displ%lon(ic1,il0)+displ%dlon_flt(ic1,jter,il0,iv))
                  lat = displ%lat(ic1,il0)+displ%dlat_flt(ic1,jter,il0,iv)
                  call sphere_dist(displ%lon(ic1,il0),displ%lat(ic1,il0),lon,lat,displ%dist_flt(ic1,jter,il0,iv))
               end if
            end do

            ! Print results
            write(mpl%unit,'(a13,a,i2,a,f8.2,a,f6.2,a,f6.2,a,f7.2,a)') '','Iteration ',iter,': rhflt = ', &
          & displ%rhflt(jter,il0,iv)*1.0e-3,' km, valid points: ',100.0*sum(displ%valid_raw(:,il0,iv))/float(nam%nc1), &
          & '% ~> ',100.0*sum(displ%valid_flt(:,jter,il0,iv),mask=hdata%ic1il0_log(:,il0))/count(hdata%ic1il0_log(:,il0)), &
          & '%, average support radius = ',sum(displ%dist_flt(:,jter,il0,iv))/float(nam%nc1)*1.0e-3,' km'

            if (.not.nam%displ_explicit) then
               ! Update support radius
               if (.not.(sum(displ%valid_flt(:,jter,il0,iv),mask=hdata%ic1il0_log(:,il0))< &
             & (1.0-nam%displ_tol)*count(hdata%ic1il0_log(:,il0)))) then
                  ! Convergence
                  convergence = .true.

                  ! Check dichotomy status
                  if (.not.dichotomy) then
                     dichotomy = .true.
                     drhflt = 0.5*displ%rhflt(jter,il0,iv)
                  end if

                  ! Decrease filtering support radius
                  displ%rhflt(jterp,il0,iv) = displ%rhflt(jter,il0,iv)-drhflt
               else
                  ! Increase filtering support radius
                  if (dichotomy) then
                     displ%rhflt(jterp,il0,iv) = displ%rhflt(jter,il0,iv)+drhflt
                  else
                     ! No convergence
                     convergence = .false.
                     displ%rhflt(jterp,il0,iv) = 2.0*displ%rhflt(jter,il0,iv)
                  end if
               end if
               if (dichotomy) drhflt = 0.5*drhflt
            end if
         end do

         ! Check convergence
         if (.not.convergence) call msgerror('iterative filtering failed')
      end do
   end do

   ! Deallocation
   deallocate(order)
end if

if (.not.nam%displ_explicit) then
   ! Recompute sampling
   write(mpl%unit,'(a7,a)',advance='no') '','Recompute sampling: '
   if (common_sampling) then
      ! Common sampling for all variables
      allocate(done(geom%nl0*nam%nc1))
      call prog_init(progint,done)
      do il0=1,geom%nl0
         do ic1=1,nam%nc1
            lon = lonmod(displ%lon(ic1,il0)+displ%dlon_flt(ic1,1,il0,nam%nvp))
            lat = displ%lat(ic1,il0)+displ%dlat_flt(ic1,1,il0,nam%nvp)
            call find_nearest_neighbors(hdata%ctree_cell(min(il0,geom%nl0i)),lon,lat,1,ic1icil0iv_to_ic0(ic1:ic1),dum)
            done((il0-1)*nam%nc1+ic1) = .true.
            call prog_print(progint,done)
         end do
         do iv=1,nam%nv
            hdata%ic1icil0iv_to_ic0(:,1,il0,iv) = ic1icil0iv_to_ic0
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
               lon = lonmod(displ%lon(ic1,il0)+displ%dlon_flt(ic1,1,il0,iv))
               lat = displ%lat(ic1,il0)+displ%dlat_flt(ic1,1,il0,iv)
               call find_nearest_neighbors(hdata%ctree_cell(min(il0,geom%nl0i)),lon,lat,1,ic1icil0iv_to_ic0(ic1:ic1),dum)
               done((iv-1)*geom%nl0*nam%nc1+(il0-1)*nam%nc1+ic1) = .true.
               call prog_print(progint,done)
            end do
            hdata%ic1icil0iv_to_ic0(:,1,il0,iv) = ic1icil0iv_to_ic0
         end do
      end do
      deallocate(done)
   end if
   write(mpl%unit,'(a)') '100%'
   call compute_sampling_ps(hdata)
end if

! Radian to degrees
displ%lon = displ%lon*rad2deg
displ%lat = displ%lat*rad2deg
displ%dlon_raw = displ%dlon_raw*rad2deg
displ%dlat_raw = displ%dlat_raw*rad2deg
displ%dlon_flt = displ%dlon_flt*rad2deg
displ%dlat_flt = displ%dlat_flt*rad2deg

! End associate
end associate

end subroutine compute_displacement

end module module_displacement
