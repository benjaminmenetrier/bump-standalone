!----------------------------------------------------------------------
! Module: hdiag_lct.f90
!> Purpose: LCT routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module hdiag_lct

use hdiag_fit_lct, only: compute_fit_lct
use omp_lib
use tools_display, only: msgerror
use tools_kinds, only: kind_real
use tools_missing, only: msr,isnotmsr
use type_lct, only: lcttype
use type_mom, only: momtype
use type_mpl, only: mpl
use type_hdata, only: hdatatype
implicit none

private
public :: compute_lct

contains

!----------------------------------------------------------------------
! Subroutine: compute_lct
!> Purpose: compute LCT
!----------------------------------------------------------------------
subroutine compute_lct(hdata,mom,lct)

implicit none

! Passed variables
type(hdatatype),intent(in) :: hdata                                       !< HDIAG data
type(momtype),intent(in) :: mom(hdata%bpar%nb)                            !< Moments
type(lcttype),intent(out) :: lct(hdata%nc1a,hdata%geom%nl0,hdata%bpar%nb) !< LCT


! Local variables
integer :: ib,jsub,jl0,il0,jc3,ic1a
real(kind_real) :: den

! Associate
associate(nam=>hdata%nam,geom=>hdata%geom,bpar=>hdata%bpar)

do ib=1,bpar%nb
   write(mpl%unit,'(a7,a,a)') '','Block: ',trim(bpar%blockname(ib))

   ! Allocation
   do jl0=1,geom%nl0
      do ic1a=1,hdata%nc1a
         call lct(ic1a,jl0,ib)%alloc(hdata,ib)
      end do
   end do

   ! Compute correlations
   write(mpl%unit,'(a10,a)') '','Compute correlations'
   do jsub=1,mom(ib)%nsub
      do il0=1,geom%nl0
         do jl0=1,bpar%nl0r(ib)
            do jc3=1,nam%nc3
               do ic1a=1,hdata%nc1a
                  den = mom(ib)%m2_1(ic1a,jc3,jl0,il0,jsub)*mom(ib)%m2_2(ic1a,jc3,jl0,il0,jsub)
                  if (den>0.0) then
                     lct(ic1a,il0,ib)%raw(jc3,jl0) = lct(ic1a,il0,ib)%raw(jc3,jl0)+mom(ib)%m11(ic1a,jc3,jl0,il0,jsub)/sqrt(den)
                     lct(ic1a,il0,ib)%norm(jc3,jl0) = lct(ic1a,il0,ib)%norm(jc3,jl0)+1.0
                  end if
               end do
            end do
         end do
      end do
   end do
   do il0=1,geom%nl0
      do jl0=1,bpar%nl0r(ib)
         do jc3=1,nam%nc3
            do ic1a=1,hdata%nc1a
               if (lct(ic1a,il0,ib)%norm(jc3,jl0)>0.0) lct(ic1a,il0,ib)%raw(jc3,jl0) = lct(ic1a,il0,ib)%raw(jc3,jl0) &
                                                                                     & /lct(ic1a,il0,ib)%norm(jc3,jl0)
            end do
         end do
      end do
   end do

   ! Compute LCT fit
   write(mpl%unit,'(a10,a)') '','Compute LCT fit'
   call compute_fit_lct(hdata,ib,lct(:,:,ib))
end do

! End associate
end associate

end subroutine compute_lct

end module hdiag_lct
