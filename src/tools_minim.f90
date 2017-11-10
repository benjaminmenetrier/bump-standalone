!----------------------------------------------------------------------
! Module: tools_minim
!> Purpose: bound constrained minimization routines
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-B license
!> <br>
!> Copyright © 2015 UCAR, CERFACS and METEO-FRANCE
!----------------------------------------------------------------------
module tools_minim

use tools_asa047, only: nelmin
use tools_compass_search, only: compass_search
use tools_display, only: msgwarning
use tools_kinds, only: kind_real
use tools_praxis, only: praxis
use type_min, only: mintype
use type_mpl, only: mpl

implicit none

! Minimization parameters
real(kind_real),parameter :: reqmin = 1.0e-8
integer,parameter :: konvge = 10
integer,parameter :: kcount = 1000
real(kind_real),parameter :: delta_tol = 1.0e-3
integer,parameter :: k_max = 500
real(kind_real),parameter :: t0 = 1.0e-3

private
public :: minim

contains

!----------------------------------------------------------------------
! subroutine: minim
!> Purpose: minimize ensuring bounds constraints
!----------------------------------------------------------------------
subroutine minim(mindata,func)

implicit none

! Passed variables
type(mintype),intent(inout) :: mindata !< Minimization data
interface
   subroutine func(mindata,x,f)
   use tools_kinds, only: kind_real
   use type_min, only: mintype
   type(mintype),intent(in) :: mindata
   real(kind_real),intent(inout) :: x(mindata%nx)
   real(kind_real),intent(out) :: f
   end subroutine
end interface

! Local variables
integer :: icount,numres,info
real(kind_real) :: guess(mindata%nx),xmin(mindata%nx),y,ynewlo,step(mindata%nx)
real(kind_real) :: delta_init,h0

! Associate
associate(nam=>mindata%nam)

! Initialization
guess = 1.0

! Initial cost
mindata%f_guess = 0.0
call func(mindata,guess,y)
mindata%f_guess = y

select case (trim(nam%fit_type))
case ('nelder_mead')
   ! Initialization
   step = 0.1
     
   ! Nelder-Mead algorithm
   call nelmin(mindata,func,mindata%nx,guess,xmin,ynewlo,reqmin,step,konvge,kcount,icount,numres,info)
case ('compass_search')
   ! Initialization  
   delta_init = 0.1
  
   ! Compass search
   call compass_search(mindata,func,mindata%nx,guess,delta_tol,delta_init,k_max,xmin,ynewlo,icount)
case ('praxis')
   ! Initialization
   h0 = 0.1
   xmin = guess

   ! Praxis
   ynewlo = praxis(mindata,func,t0,h0,mindata%nx,0,xmin)
end select

! Test
if (ynewlo<y) then
   mindata%x = xmin*mindata%guess
   write(mpl%unit,'(a7,a,f6.1,a)') '','Minimizer '//trim(nam%fit_type)//', cost function decrease:',abs(ynewlo-y)/y*100.0,'%'
else
   mindata%x = mindata%guess
   call msgwarning('Minimizer '//trim(nam%fit_type)//' failed')
end if

! End associate
end associate

end subroutine minim

end module tools_minim
