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

use tools_kinds, only: kind_real
use tools_asa007, only: syminv
use type_min, only: mintype
implicit none

! Minimization parameter
integer,parameter :: niterout = 10
integer,parameter :: niterin = 30

private
public :: minim

contains

!----------------------------------------------------------------------
! subroutine: minim
!> Purpose: minimize ensuring bounds constraints
!----------------------------------------------------------------------
subroutine minim(mindata,func,jacobian)

implicit none

! Passed variables
type(mintype),intent(inout) :: mindata !< Minimization data
interface
   subroutine func(mindata,x,f)
   use tools_kinds, only: kind_real
   use type_min, only: mintype
   type(mintype),intent(in) :: mindata
   real(kind_real),intent(in) :: x(mindata%nx)
   real(kind_real),intent(out) :: f(mindata%ny)
   end subroutine
end interface
interface
   subroutine jacobian(mindata,x,jac)
   use tools_kinds, only: kind_real
   use type_min, only: mintype
   type(mintype),intent(in) :: mindata
   real(kind_real),intent(in) :: x(mindata%nx)
   real(kind_real),intent(out) :: jac(mindata%ny,mindata%nx)
   end subroutine
end interface

! Local variables
integer :: iterout,i,ix,jx,nullty,info,iterin
real(kind_real) :: cost,cost_prev,alpha
real(kind_real) :: guess(mindata%nx),f(mindata%ny),jac(mindata%ny,mindata%nx),d(mindata%ny)
real(kind_real) :: jtj(mindata%nx,mindata%nx),a((mindata%nx*(mindata%nx+1))/2)
real(kind_real) :: jtjinv(mindata%nx,mindata%nx),ainv((mindata%nx*(mindata%nx+1))/2)
real(kind_real) :: work(mindata%nx),x(mindata%nx)
logical :: valid

! Copy guess
guess = mindata%guess

! Compute nonlinear function
call func(mindata,guess,f)

! Compute nonlinear cost
cost_prev = sum(mindata%wgt*(mindata%obs-f)**2)

! Outer loop
do iterout=1,niterout
   ! Compute nonlinear function
   call func(mindata,guess,f)

   ! Compute jacobian
   call jacobian(mindata,guess,jac)

   ! Compute innovation
   d = mindata%obs-f

   ! Invert matrix
   jtj = matmul(transpose(jac),jac)
   i = 0
   do ix=1,mindata%nx
      do jx=1,ix
         i = i+1
         a(i) = jtj(ix,jx)
      end do
   end do
   call syminv(a,mindata%nx,ainv,work,nullty,info)
   i = 0
   do ix=1,mindata%nx
      do jx=1,ix
         i = i+1
         jtjinv(ix,jx) = ainv(i) 
         jtjinv(jx,ix) = ainv(i) 
      end do
   end do

   ! Simple line-search to compute the new solution
   valid = .false.
   do iterin=1,niterin
      alpha = 2.0*float(iterin)/float(niterin)
      x = guess + alpha*matmul(jtjinv,matmul(transpose(jac),d))

      ! Test bounds
      if (all(x>mindata%binf).and.all(x<mindata%bsup)) then
         ! Compute nonlinear function
         call func(mindata,x,f)

         ! Compute nonlinear cost
         cost = sum(mindata%wgt*(mindata%obs-f)**2)

         ! Test cost
         if (cost<cost_prev) then
            ! Update
            guess = x
            cost_prev = cost
            valid = .true.
         end if
      end if
   end do

   ! Exit
   if (.not.valid) exit
end do

! Copy
mindata%x = guess

end subroutine minim

end module tools_minim
