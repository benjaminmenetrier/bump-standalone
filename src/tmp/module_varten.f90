!----------------------------------------------------------------------
! Module: module_varten.f90
!> Purpose: variance and tensor computation and filtering routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code ic1 distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module module_varten

use model_interface, only: model_read
use module_diag_tools, only: diag_filter
use omp_lib
use tools_const, only: req,lonmod
use tools_kinds, only: kind_real
use tools_missing, only: msi,msr,isnotmsr,isallnotmsr,isanynotmsr
use type_ctree, only: find_nearest_neighbors
use type_hdata, only: hdatatype
use type_mom, only: momtype
use type_varten, only: vartentype
implicit none

private
public :: compute_varten

contains

!----------------------------------------------------------------------
! Subroutine: compute_varten
!> Purpose: compute variance and local correlation tensor
!----------------------------------------------------------------------
subroutine compute_varten(hdata,mom,varten)

implicit none

! Passed variables
type(hdatatype),intent(inout) :: hdata   !< Sampling data
type(momtype),intent(inout) :: mom       !< Moments
type(vartentype),intent(inout) :: varten !< Variance and tensor

! Local variables
integer :: ic1,iv,il0,isub,jsub,ie,ic0,n
real(kind_real) :: fac1,fac3,fac4,fac5,fac6,fac7,fac8
real(kind_real) :: P9,P20,P21
real(kind_real) :: fld(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: dlonf(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv),dlatf(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: m1dlonf(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv),m1dlatf(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv)
real(kind_real) :: Hlon(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: Hlat(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: Hlonlat(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv,hdata%nam%ens1_nsub)
real(kind_real) :: Lflt,rhs,Lfltlon,rhslon,Lfltlat,rhslat
real(kind_real) :: wgt(hdata%nam%nc1),raw_prod,det
real(kind_real) :: avgHlonsq(hdata%nam%ens1_nsub,hdata%nam%ens1_nsub),avgHlatsq(hdata%nam%ens1_nsub,hdata%nam%ens1_nsub)
real(kind_real) :: avgm4lon(hdata%nam%ens1_nsub),avgm4lat(hdata%nam%ens1_nsub)
real(kind_real) :: avgHlonasysq(hdata%nam%ens1_nsub,hdata%nam%ens1_nsub),avgHlatasysq(hdata%nam%ens1_nsub,hdata%nam%ens1_nsub)
real(kind_real),allocatable :: m4lon(:,:,:,:),m4lat(:,:,:,:),m3lon(:,:,:),m3lat(:,:,:)
logical :: isvalid(hdata%nam%nc1,hdata%geom%nl0,hdata%nam%nv)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Filter variance
write(*,'(a7,a)') '','Filter variance'

do iv=1,nam%nv
   do il0=1,geom%nl0
      ! Sum over sub-ensembles
      !$omp parallel do private(ic1)
      do ic1=1,nam%nc1
         if (hdata%ic1il0_log(ic1,il0)) varten%var_raw(ic1,il0,iv) = sum(mom%m2(ic1,1,il0,il0,iv,:))/float(nam%ens1_nsub)
      end do
      !$omp end parallel do

      ! Filter variances
      rhs = varten%varasysq(il0,iv)
      Lflt = nam%varten_Lflt
      varten%var_flt(:,il0,iv) = varten%var_raw(:,il0,iv)
      wgt = hdata%swgt(:,1,il0,il0,iv)
      call var_filter(hdata,rhs,il0,wgt,Lflt,varten%var_flt(:,il0,iv))
   end do
end do

! Compute tensor
write(*,'(a7,a)') '','Compute tensor'

! Setup gradient calculation
call grad_setup(hdata,varten)

! Allocation
if (.not.nam%gau_approx) then
   allocate(m4lon(nam%nc1,geom%nl0,nam%nv,nam%ens1_nsub))
   allocate(m4lat(nam%nc1,geom%nl0,nam%nv,nam%ens1_nsub))
   allocate(m3lon(nam%nc1,geom%nl0,nam%nv))
   allocate(m3lat(nam%nc1,geom%nl0,nam%nv))
end if

! Initialization
if (.not.nam%gau_approx) then
   m4lon = 0.0
   m4lat = 0.0
end if
Hlon = 0.0
Hlat = 0.0
Hlonlat = 0.0
do iv=1,nam%nv
   isvalid(:,:,iv) = hdata%ic1il0_log
end do

! Loop on sub-ensembles
do isub=1,nam%ens1_nsub
   if (nam%ens1_nsub==1) then
      write(*,'(a10,a)',advance='no') '','Full ensemble, member:'
   else
      write(*,'(a10,a,i4,a)',advance='no') '','Sub-ensemble ',isub,', member:'
   end if

   ! Initialization
   if (.not.nam%gau_approx) then
      m3lon = 0.0
      m3lat = 0.0
   end if
   m1dlonf = 0.0
   m1dlatf = 0.0

   ! Compute centered moments iteratively
   do ie=1,nam%ens1_ne/nam%ens1_nsub
      write(*,'(i4)',advance='no') nam%ens1_ne_offset+ie

      ! Computation factors
      fac1 = 4.0/float(ie)
      fac3 = float((ie-1)*(ie**2-3*ie+3))/float(ie**3)
      fac4 = 1.0/float(ie)
      fac5 = float((ie-1)*(ie-2))/float(ie**2)
      fac6 = float(ie-1)/float(ie)
      fac7 = 6.0/float(ie**2)
      fac8 = 3.0/float(ie)

      ! Load field
      call model_read(nam,mom,ie,isub,geom,fld)

      ! Center and normalize field
      !$omp parallel do private(ic0,il0,iv)
      do ic0=1,geom%nc0
         do il0=1,geom%nl0
            do iv=1,nam%nv
               if (mom%m2full(ic0,il0,iv,isub)>0.0) then
                  fld(ic0,il0,iv) = (fld(ic0,il0,iv)-mom%m1b(ic0,il0,iv,isub))/sqrt(mom%m2full(ic0,il0,iv,isub))
               else
                  call msr(fld(ic0,il0,iv))
               end if
            end do
         end do
      end do
      !$omp end parallel do

      ! Compute gradient
      call grad(hdata,varten,fld,dlonf,dlatf)

      ! Check validity
      isvalid = isvalid.and.isnotmsr(dlonf).and.isnotmsr(dlatf)
      do iv=1,nam%nv
         do il0=1,geom%nl0
            !$omp parallel do private(ic1)
            do ic1=1,nam%nc1
               if (hdata%ic1il0_log(ic1,il0).and.isvalid(ic1,il0,iv)) then
                  ! Update high-order moments
                  if (ie>1) then
                     if (.not.nam%gau_approx) then
                        ! Univariate fourth-order moments
                        m4lon(ic1,il0,iv,isub) = m4lon(ic1,il0,iv,isub) &
                          & -fac1*(dlonf(ic1,il0,iv)-m1dlonf(ic1,il0,iv))*m3lon(ic1,il0,iv) &
                          & +fac7*(dlonf(ic1,il0,iv)-m1dlonf(ic1,il0,iv))**2*Hlon(ic1,il0,iv,isub) &
                          & +fac3*(dlonf(ic1,il0,iv)-m1dlonf(ic1,il0,iv))**4
                        m4lat(ic1,il0,iv,isub) = m4lat(ic1,il0,iv,isub) &
                          & -fac1*(dlatf(ic1,il0,iv)-m1dlatf(ic1,il0,iv))*m3lat(ic1,il0,iv) &
                          & +fac7*(dlatf(ic1,il0,iv)-m1dlatf(ic1,il0,iv))**2*Hlat(ic1,il0,iv,isub) &
                          & +fac3*(dlatf(ic1,il0,iv)-m1dlatf(ic1,il0,iv))**4

                        ! Univariate third-order moments
                        m3lon(ic1,il0,iv) = m3lon(ic1,il0,iv) &
                          & -fac8*(dlonf(ic1,il0,iv)-m1dlonf(ic1,il0,iv))*Hlon(ic1,il0,iv,isub) &
                          & +fac5*(dlonf(ic1,il0,iv)-m1dlonf(ic1,il0,iv))**3
                        m3lat(ic1,il0,iv) = m3lat(ic1,il0,iv) &
                          & -fac8*(dlatf(ic1,il0,iv)-m1dlatf(ic1,il0,iv))*Hlat(ic1,il0,iv,isub) &
                          & +fac5*(dlatf(ic1,il0,iv)-m1dlatf(ic1,il0,iv))**3
                     end if

                     ! Variance
                     Hlon(ic1,il0,iv,isub) = Hlon(ic1,il0,iv,isub)+fac6*(dlonf(ic1,il0,iv)-m1dlonf(ic1,il0,iv))**2
                     Hlat(ic1,il0,iv,isub) = Hlat(ic1,il0,iv,isub)+fac6*(dlatf(ic1,il0,iv)-m1dlatf(ic1,il0,iv))**2

                     ! Covariance
                     Hlonlat(ic1,il0,iv,isub) = Hlonlat(ic1,il0,iv,isub)+fac6*(dlonf(ic1,il0,iv)-m1dlonf(ic1,il0,iv)) &
                                              & *(dlatf(ic1,il0,iv)-m1dlatf(ic1,il0,iv))
                  end if

                  ! Update mean
                  m1dlonf(ic1,il0,iv) = m1dlonf(ic1,il0,iv)+fac4*dlonf(ic1,il0,iv)
                  m1dlatf(ic1,il0,iv) = m1dlatf(ic1,il0,iv)+fac4*dlatf(ic1,il0,iv)
               end if
            end do
            !$omp end parallel do
         end do
      end do
   end do
   write(*,'(a)') ''
end do

! Ensemble size-dependent coefficients
n = nam%ens1_ne/nam%ens1_nsub
P9 = -float(n)/float((n-2)*(n-3))
P20 = float((n-1)*(n**2-3*n+3))/float(n*(n-2)*(n-3))
P21 = float(n-1)/float(n+1)

do iv=1,nam%nv
   do il0=1,geom%nl0
      ! Sum over sub-ensembles
      !$omp parallel do private(ic1)
      do ic1=1,nam%nc1
         if (isvalid(ic1,il0,iv)) then
            varten%Hlon_raw(ic1,il0,iv) = sum(Hlon(ic1,il0,iv,:))/float(nam%ens1_nsub)
            varten%Hlat_raw(ic1,il0,iv) = sum(Hlat(ic1,il0,iv,:))/float(nam%ens1_nsub)
            varten%Hlonlat_raw(ic1,il0,iv) = sum(Hlonlat(ic1,il0,iv,:))/float(nam%ens1_nsub)
         end if
      end do
      !$omp end parallel do

      ! Correct weights for missing values
      do ic1=1,nam%nc1
         if (isvalid(ic1,il0,iv)) then
            wgt(ic1) = hdata%swgt(ic1,1,il0,il0,iv)
         else
            wgt(ic1) = 0.0
         end if
      end do
      wgt = wgt/sum(wgt)

      ! Averages for diagnostics
      do isub=1,nam%ens1_nsub
         do jsub=1,nam%ens1_nsub
            avgHlonsq(isub,jsub) = sum(Hlon(:,il0,iv,isub)*Hlon(:,il0,iv,jsub)*wgt)
            avgHlatsq(isub,jsub) = sum(Hlat(:,il0,iv,isub)*Hlat(:,il0,iv,jsub)*wgt)
         end do
         if (.not.nam%gau_approx) then
            avgm4lon(isub) = sum(m4lon(:,il0,iv,isub)*wgt)
            avgm4lat(isub) = sum(m4lat(:,il0,iv,isub)*wgt)
         end if
      end do

      ! Asymptotic statistics
      do isub=1,nam%ens1_nsub
         do jsub=1,nam%ens1_nsub
            if (isub==jsub) then
               ! Diagonal terms
               if (nam%gau_approx) then
                  ! Gaussian approximation
                  avgHlonasysq(isub,jsub) = P20*avgHlonsq(isub,jsub)+P9*avgm4lon(isub)
                  avgHlatasysq(isub,jsub) = P20*avgHlatsq(isub,jsub)+P9*avgm4lat(isub)
               else
                  avgHlonasysq(isub,jsub) = P21*avgHlonsq(isub,jsub)
                  avgHlatasysq(isub,jsub) = P21*avgHlatsq(isub,jsub)
               end if
            else
               ! Off-diagonal terms
               avgHlonasysq(isub,jsub) = avgHlonsq(isub,jsub)
               avgHlatasysq(isub,jsub) = avgHlatsq(isub,jsub)
            end if
         end do
      end do

      ! Filter diagonal terms as variances
      Lfltlon = nam%varten_Lflt
      rhslon = sum(avgHlonasysq)/float(nam%ens1_nsub**2)
      varten%Hlon_flt(:,il0,iv) = varten%Hlon_raw(:,il0,iv)
      call var_filter(hdata,rhslon,il0,wgt,Lfltlon,varten%Hlon_flt(:,il0,iv))
      Lfltlat = nam%varten_Lflt
      rhslat = sum(avgHlatasysq)/float(nam%ens1_nsub**2)
      varten%Hlat_flt(:,il0,iv) = varten%Hlat_raw(:,il0,iv)
      call var_filter(hdata,rhslat,il0,wgt,Lfltlat,varten%Hlat_flt(:,il0,iv))

      ! Filter off-diagonal term correlation part
      !$omp parallel do private(ic1,raw_prod)
      do ic1=1,nam%nc1
         raw_prod = varten%Hlon_raw(ic1,il0,iv)*varten%Hlat_raw(ic1,il0,iv)
         if (isvalid(ic1,il0,iv).and.(raw_prod>0.0)) then
            varten%Hlonlat_flt(ic1,il0,iv) = varten%Hlonlat_raw(ic1,il0,iv)/sqrt(raw_prod)
         else
            call msr(varten%Hlonlat_flt(ic1,il0,iv))
         end if
      end do
      !$omp end parallel do
      call diag_filter(hdata,'average',sqrt(Lfltlon*Lfltlat),il0,varten%Hlonlat_flt(:,il0,iv))
      !$omp parallel do private(ic1)
      do ic1=1,nam%nc1
         if (isvalid(ic1,il0,iv)) then
            varten%Hlonlat_flt(ic1,il0,iv) = varten%Hlonlat_flt(ic1,il0,iv)*sqrt(varten%Hlon_flt(ic1,il0,iv) &
                                           & *varten%Hlat_flt(ic1,il0,iv))
         end if
      end do
      !$omp end parallel do

      !$omp parallel do private(ic1,det)
      do ic1=1,nam%nc1
         ! Compute length-scales
         if (isvalid(ic1,il0,iv)) then
            det = varten%Hlon_raw(ic1,il0,iv)*varten%Hlat_raw(ic1,il0,iv)-varten%Hlonlat_raw(ic1,il0,iv)**2
            if (det>0.0) varten%Lb_raw(ic1,il0,iv) = 1.0/sqrt(sqrt(det))
            det = varten%Hlon_flt(ic1,il0,iv)*varten%Hlat_flt(ic1,il0,iv)-varten%Hlonlat_flt(ic1,il0,iv)**2
            if (det>0.0) varten%Lb_flt(ic1,il0,iv) = 1.0/sqrt(sqrt(det))
         end if
      end do
      !$omp end parallel do
   end do
end do

! Release memory
if (.not.nam%gau_approx) then
   deallocate(m4lon)
   deallocate(m4lat)
   deallocate(m3lon)
   deallocate(m3lat)
end if

! End associate
end associate

end subroutine compute_varten

!----------------------------------------------------------------------
! Subroutine: var_filter
!> Purpose: objective variance filtering
!----------------------------------------------------------------------
subroutine var_filter(hdata,rhs,il0,wgt,Lflt,var)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata !< Sampling data
real(kind_real),intent(in) :: rhs              !< Right-hand side of the criterion
integer,intent(in) :: il0            !< Level
real(kind_real),intent(in) :: wgt(hdata%nam%nc1)          !< Average weights
real(kind_real),intent(inout) :: Lflt          !< Filtering length-scale
real(kind_real),intent(inout) :: var(hdata%nam%nc1)       !< Variance to filter

! Local variables
integer :: iter
real(kind_real) :: dLflt,var_save(hdata%nam%nc1),lhs
logical :: dichotomy

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Initialization
dLflt = 0.0
dichotomy = .false.
var_save = var

do iter=1,nam%varten_niter
   ! Copy initial variance
   var = var_save

   ! Average filter to smooth variance
   call diag_filter(hdata,'average',Lflt,il0,var)

   ! Compute left-hand side
   lhs = sum(var*var_save*wgt)

   ! Update length-scale
   if (lhs<rhs) then
      ! Check dichotomy status
      if (.not.dichotomy) then
         dichotomy = .true.
         dLflt = 0.5*Lflt
      end if

      ! Decrease filtering length-scales
      Lflt = Lflt-dLflt
   else
      ! Increase filtering length-scale
      if (dichotomy) then
         Lflt = Lflt+dLflt
      else
         ! No convergence
         Lflt = 2.0*Lflt
      end if
   end if
   if (dichotomy) dLflt = 0.5*dLflt
end do

! End associate
end associate

end subroutine var_filter

!----------------------------------------------------------------------
! Subroutine: grad_setup
!> Purpose: gradient computation setup
!----------------------------------------------------------------------
subroutine grad_setup(hdata,varten)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata      !< Sampling data
type(vartentype),intent(inout) :: varten !< Variance and tensor data

! Local variables
integer :: il0,ic1,i
real(kind_real) :: lon(hdata%nam%nc1,hdata%geom%nl0i),lat(hdata%nam%nc1,hdata%geom%nl0i)
real(kind_real) :: nn_ic0_dist(hdata%nam%varten_ngrad+1,hdata%nam%nc1,hdata%geom%nl0i)
real(kind_real) :: dist,det
real(kind_real),allocatable :: X(:,:),Wsq(:,:),A(:,:),Ainv(:,:),grad(:,:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

! Compute nearest neighbors
do il0=1,geom%nl0
   if ((il0==1).or.(geom%nl0i>1)) then
      !$omp parallel do private(ic1)
      do ic1=1,nam%nc1
         if (hdata%ic1il0_log(ic1,il0)) then
            lon(ic1,il0) = geom%lon(hdata%ic1_to_ic0(ic1))
            lat(ic1,il0) = geom%lat(hdata%ic1_to_ic0(ic1))
            call find_nearest_neighbors(hdata%ctree_cell(il0),lon(ic1,il0),lat(ic1,il0), &
          & nam%varten_ngrad+1,varten%nn_ic0(:,ic1,il0),nn_ic0_dist(:,ic1,il0))
         end if
      end do
      !$omp end parallel do
   end if
end do

do il0=1,geom%nl0
   if ((il0==1).or.(geom%nl0i>1)) then
      !$omp parallel do private(ic1,X,Wsq,A,Ainv,grad,i,dist,det)
      do ic1=1,nam%nc1
         ! Initialization
         call msr(varten%grad_dlon(:,ic1,il0))
         call msr(varten%grad_dlat(:,ic1,il0))

         if (hdata%ic1il0_log(ic1,il0)) then
            ! Allocation
            allocate(X(nam%varten_ngrad,2))
            allocate(Wsq(nam%varten_ngrad,nam%varten_ngrad))
            allocate(A(2,2))
            allocate(Ainv(2,2))
            allocate(grad(2,nam%varten_ngrad))

            ! Matrix X
            do i=1,nam%varten_ngrad
               X(i,1) = lonmod(geom%lon(varten%nn_ic0(i+1,ic1,il0))-lon(ic1,il0))
               X(i,2) = geom%lat(varten%nn_ic0(i+1,ic1,il0))-lat(ic1,il0)
            end do

            ! Matrix W^2
            Wsq = 0.0
            do i=1,nam%varten_ngrad
               Wsq(i,i) = 1.0/nn_ic0_dist(i+1,ic1,il0)**4
            end do

            ! Matrix A
            A = matmul(transpose(X),matmul(Wsq,X))

            ! Invert A and multiply by X^T W^2
            det = A(1,1)*A(2,2)-A(1,2)*A(2,1)
            if (det>0.0) then
               Ainv(1,1) = A(2,2)/det
               Ainv(2,2) = A(1,1)/det
               Ainv(1,2) = -A(1,2)/det
               Ainv(2,1) = -A(2,1)/det
               grad = matmul(Ainv,matmul(transpose(X),Wsq))
               varten%grad_dlon(:,ic1,il0) = grad(1,:)/req
               varten%grad_dlat(:,ic1,il0) = grad(2,:)/(req*cos(lat(ic1,il0)))
            end if

            ! Release memory
            deallocate(X)
            deallocate(Wsq)
            deallocate(A)
            deallocate(Ainv)
            deallocate(grad)
         end if
      end do
      !$omp end parallel do
   end if
end do

! End associate
end associate

end subroutine grad_setup

!----------------------------------------------------------------------
! Subroutine: grad
!> Purpose: compute gradient
!----------------------------------------------------------------------
subroutine grad(hdata,varten,fld,dlonf,dlatf)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata    !< Sampling data
type(vartentype),intent(in) :: varten  !< Variance and tensor data
real(kind_real) :: fld(hdata%geom%nc0,hdata%geom%nl0,hdata%nam%nv)        !< Field
real(kind_real),intent(out) :: dlonf(hdata%nam%nc1,hdata%geom%nl0)       !< Function x-derivative
real(kind_real),intent(out) :: dlatf(hdata%nam%nc1,hdata%geom%nl0)       !< Function y-derivative

! Local variables
integer :: ic1,il0,iv,i
integer,allocatable :: nn(:)
real(kind_real),allocatable :: b(:)

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom)

do iv=1,nam%nv
   do il0=1,geom%nl0
      !$omp parallel do private(ic1,nn,b,i)
      do ic1=1,nam%nc1
         ! Allocation
         allocate(nn(nam%varten_ngrad+1))
         allocate(b(nam%varten_ngrad))

         ! Vector b
         nn = varten%nn_ic0(:,ic1,min(il0,geom%nl0i))
         call msr(b)
         do i=1,nam%varten_ngrad
            if (isnotmsr(fld(nn(i+1),il0,iv)).and.isnotmsr(fld(nn(1),il0,iv))) b(i) = fld(nn(i+1),il0,iv)-fld(nn(1),il0,iv)
         end do

         ! Compute gradient
         if (isallnotmsr(varten%grad_dlon(:,ic1,min(il0,geom%nl0i))).and.isallnotmsr(b)) then
            dlonf(ic1,il0) = sum(varten%grad_dlon(:,ic1,min(il0,geom%nl0i))*b)
         else
            call msr(dlonf(ic1,il0))
         end if
         if (isallnotmsr(varten%grad_dlat(:,ic1,min(il0,geom%nl0i))).and.isallnotmsr(b)) then
            dlatf(ic1,il0) = sum(varten%grad_dlat(:,ic1,min(il0,geom%nl0i))*b)
         else
            call msr(dlatf(ic1,il0))
         end if

         ! Release memory
         deallocate(nn)
         deallocate(b)
      end do
      !$omp end parallel do
   end do
end do

! End associate
end associate

end subroutine grad

end module module_varten
