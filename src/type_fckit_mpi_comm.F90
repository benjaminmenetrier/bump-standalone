!----------------------------------------------------------------------
! Module: type_fckit_mpi_comm
! Purpose: FCKIT emulator for offline execution
! Author: Benjamin Menetrier
! Licensing: this code is distributed under the CeCILL-C license
! Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
!----------------------------------------------------------------------
module fckit_mpi_module

use iso_fortran_env, only : output_unit
use mpi
use tools_kinds, only: kind_real

implicit none

type fckit_mpi_comm
contains
   procedure :: final => fckit_mpi_comm_final
   procedure :: size => fckit_mpi_comm_size
   procedure :: rank => fckit_mpi_comm_rank
   procedure :: check => fckit_mpi_comm_check
   procedure :: abort => fckit_mpi_comm_abort
   procedure :: barrier => fckit_mpi_comm_barrier
   procedure :: fckit_mpi_comm_broadcast_integer_0d
   procedure :: fckit_mpi_comm_broadcast_integer_1d
   procedure :: fckit_mpi_comm_broadcast_integer_2d
   procedure :: fckit_mpi_comm_broadcast_real_0d
   procedure :: fckit_mpi_comm_broadcast_real_1d
   procedure :: fckit_mpi_comm_broadcast_real_2d
   procedure :: fckit_mpi_comm_broadcast_real_3d
   procedure :: fckit_mpi_comm_broadcast_real_4d
   procedure :: fckit_mpi_comm_broadcast_real_5d
   procedure :: fckit_mpi_comm_broadcast_real_6d
   procedure :: fckit_mpi_comm_broadcast_logical_0d
   procedure :: fckit_mpi_comm_broadcast_logical_1d
   procedure :: fckit_mpi_comm_broadcast_logical_2d
   procedure :: fckit_mpi_comm_broadcast_logical_3d
   procedure :: fckit_mpi_comm_broadcast_string_0d
   generic :: broadcast => fckit_mpi_comm_broadcast_integer_0d,fckit_mpi_comm_broadcast_integer_1d, &
                         & fckit_mpi_comm_broadcast_integer_2d,fckit_mpi_comm_broadcast_real_0d, &
                         & fckit_mpi_comm_broadcast_real_1d,fckit_mpi_comm_broadcast_real_2d, &
                         & fckit_mpi_comm_broadcast_real_3d,fckit_mpi_comm_broadcast_real_4d, &
                         & fckit_mpi_comm_broadcast_real_5d,fckit_mpi_comm_broadcast_real_6d, &
                         & fckit_mpi_comm_broadcast_logical_0d,fckit_mpi_comm_broadcast_logical_1d, &
                         & fckit_mpi_comm_broadcast_logical_2d,fckit_mpi_comm_broadcast_logical_3d, &
                         & fckit_mpi_comm_broadcast_string_0d
   procedure :: fckit_mpi_comm_receive_integer_0d
   procedure :: fckit_mpi_comm_receive_integer_1d
   procedure :: fckit_mpi_comm_receive_real_0d
   procedure :: fckit_mpi_comm_receive_real_1d
   procedure :: fckit_mpi_comm_receive_logical_1d
   generic :: receive => fckit_mpi_comm_receive_integer_0d,fckit_mpi_comm_receive_integer_1d, &
                       & fckit_mpi_comm_receive_real_0d,fckit_mpi_comm_receive_real_1d, &
                       & fckit_mpi_comm_receive_logical_1d
   procedure :: fckit_mpi_comm_send_integer_0d
   procedure :: fckit_mpi_comm_send_integer_1d
   procedure :: fckit_mpi_comm_send_real_0d
   procedure :: fckit_mpi_comm_send_real_1d
   procedure :: fckit_mpi_comm_send_logical_1d
   generic :: send => fckit_mpi_comm_send_integer_0d,fckit_mpi_comm_send_integer_1d, &
                    & fckit_mpi_comm_send_real_0d,fckit_mpi_comm_send_real_1d, &
                    & fckit_mpi_comm_send_logical_1d
   procedure :: fckit_mpi_comm_allgather_integer_0d
   procedure :: fckit_mpi_comm_allgather_real_0d
   procedure :: fckit_mpi_comm_allgather_logical_0d
   generic :: allgather => fckit_mpi_comm_allgather_integer_0d,fckit_mpi_comm_allgather_real_0d,fckit_mpi_comm_allgather_logical_0d
   procedure :: fckit_mpi_comm_alltoallv_real
   generic :: alltoallv => fckit_mpi_comm_alltoallv_real
   procedure :: fckit_mpi_comm_allreduce_integer_0d
   procedure :: fckit_mpi_comm_allreduce_real_0d
   procedure :: fckit_mpi_comm_allreduce_real_1d
   generic :: allreduce => fckit_mpi_comm_allreduce_integer_0d,fckit_mpi_comm_allreduce_real_0d, &
                         & fckit_mpi_comm_allreduce_real_1d
end type fckit_mpi_comm

interface fckit_mpi_comm
  module procedure fckit_mpi_comm_init
end interface

type fckit_mpi_status
   integer,dimension(mpi_status_size) :: mpi_status
end type fckit_mpi_status

private
public :: fckit_mpi_comm,fckit_mpi_sum,fckit_mpi_min,fckit_mpi_max,fckit_mpi_status

contains

!----------------------------------------------------------------------
! Function: fckit_mpi_comm_init
! Purpose: initialize fckit MPI communicator
!----------------------------------------------------------------------
function fckit_mpi_comm_init() result(f_comm)

implicit none

! Result
type(fckit_mpi_comm) :: f_comm

! Local variables
integer :: len,info,info_loc
logical :: init
character(len=mpi_max_error_string) :: message

! Check if MPI is already initialized
call mpi_initialized(init,info)
if (info/=mpi_success) then
   call mpi_error_string(info,message,len,info_loc)
   write(output_unit,'(a)') '!!! Error:',trim(message)
   call flush(output_unit)
   call mpi_abort(mpi_comm_world,1,info)
end if

if (.not.init) then
   ! Initialize MPI
   call mpi_init(info)
   if (info/=mpi_success) then
      call mpi_error_string(info,message,len,info_loc)
      write(output_unit,'(a)') '!!! Error:',trim(message)
      call flush(output_unit)
      call mpi_abort(mpi_comm_world,1,info)
   end if
end if

end function fckit_mpi_comm_init

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_final
! Purpose: finalize fckit MPI communicator
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_final(f_comm)

implicit none

! Passed variables
class(fckit_mpi_comm) :: f_comm

! Local variables
integer :: len,info,info_loc
character(len=mpi_max_error_string) :: message

! Finalize MPI
call mpi_finalize(info)
if (info/=mpi_success) then
   call mpi_error_string(info,message,len,info_loc)
   write(output_unit,'(a)') '!!! Error:',trim(message)
   call flush(output_unit)
   call mpi_abort(mpi_comm_world,1,info)
end if

end subroutine fckit_mpi_comm_final

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_rank
! Purpose: get MPI rank
!----------------------------------------------------------------------
function fckit_mpi_comm_rank(f_comm) result(rank)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator

! Result
integer :: rank

! Local variables
integer :: info

! Get rank
call mpi_comm_rank(mpi_comm_world,rank,info)

! Check
call f_comm%check(info)

end function fckit_mpi_comm_rank

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_size
! Purpose: get MPI size
!----------------------------------------------------------------------
function fckit_mpi_comm_size(f_comm) result(size)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator

! Result
integer :: size

! Local variables
integer :: info

! Get size
call mpi_comm_size(mpi_comm_world,size,info)

! Check
call f_comm%check(info)

end function fckit_mpi_comm_size

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_check
! Purpose: check MPI error
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_check(f_comm,info)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,intent(in) :: info                 ! Error index

! Local variables
integer :: len,info_loc
character(len=mpi_max_error_string) :: message

if (info/=mpi_success) then
   ! Get string
   call mpi_error_string(info,message,len,info_loc)

   ! Write message
   write(output_unit,'(a,i4.4,a)') '!!! ABORT on task #',f_comm%rank(),': '//trim(message)
   call flush(output_unit)

   ! Abort MPI
   call f_comm%abort(1)
end if

end subroutine fckit_mpi_comm_check

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_abort
! Purpose: abort
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_abort(f_comm,code)

implicit none

! Passed variable
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,intent(in) :: code                 ! Exit code

! Local variables
integer :: info

! Abort MPI
call mpi_abort(mpi_comm_world,code,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_abort

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_barrier
! Purpose: MPI barrier
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_barrier(f_comm)

implicit none

! Passed variable
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator

! Local variables
integer :: info

! Wait
call mpi_barrier(mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_barrier

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_integer_0d
! Purpose: broadcast integer
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_integer_0d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,intent(in) :: var                  ! Integer
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,1,mpi_integer,root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_integer_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_integer_1d
! Purpose: broadcast 1d integer array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_integer_1d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,dimension(:),intent(in) :: var     ! Integer array, 1d
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),mpi_integer,root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_integer_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_integer_2d
! Purpose: broadcast 2d integer array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_integer_2d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,dimension(:,:),intent(in) :: var   ! Integer array, 2d
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),mpi_integer,root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_integer_2d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_real_0d
! Purpose: broadcast real
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_real_0d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
real(kind_real),intent(in) :: var          ! Real
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,1,fckit_mpi_real(),root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_real_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_real_1d
! Purpose: broadcast 1d real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_real_1d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm     ! FCKIT communicator
real(kind_real),dimension(:),intent(in) :: var ! Real array, 1d
integer,intent(in) :: root                     ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),fckit_mpi_real(),root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_real_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_real_2d
! Purpose: broadcast 2d real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_real_2d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm       ! FCKIT communicator
real(kind_real),dimension(:,:),intent(in) :: var ! Real array, 2d
integer,intent(in) :: root                       ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),fckit_mpi_real(),root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_real_2d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_real_3d
! Purpose: broadcast 3d real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_real_3d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm         ! FCKIT communicator
real(kind_real),dimension(:,:,:),intent(in) :: var ! Real array, 3d
integer,intent(in) :: root                         ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),fckit_mpi_real(),root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_real_3d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_real_4d
! Purpose: broadcast 4d real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_real_4d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm           ! FCKIT communicator
real(kind_real),dimension(:,:,:,:),intent(in) :: var ! Real array, 4d
integer,intent(in) :: root                           ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),fckit_mpi_real(),root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_real_4d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_real_5d
! Purpose: broadcast 5d real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_real_5d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm             ! FCKIT communicator
real(kind_real),dimension(:,:,:,:,:),intent(in) :: var ! Real array, 5d
integer,intent(in) :: root                             ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),fckit_mpi_real(),root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_real_5d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_real_6d
! Purpose: broadcast 6d real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_real_6d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm               ! FCKIT communicator
real(kind_real),dimension(:,:,:,:,:,:),intent(in) :: var ! Real array, 6d
integer,intent(in) :: root                               ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),fckit_mpi_real(),root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_real_6d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_logical_0d
! Purpose: broadcast logical
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_logical_0d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
logical,intent(in) :: var                  ! Logical
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,1,mpi_logical,root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_logical_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_logical_1d
! Purpose: broadcast 1d logical array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_logical_1d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
logical,dimension(:),intent(in) :: var     ! Logical array, 1d
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),mpi_logical,root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_logical_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_logical_2d
! Purpose: broadcast 2d logical array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_logical_2d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
logical,dimension(:,:),intent(in) :: var   ! Logical array, 1d
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),mpi_logical,root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_logical_2d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_logical_3d
! Purpose: broadcast 3d logical array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_logical_3d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
logical,dimension(:,:,:),intent(in) :: var ! Logical array, 1d
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,size(var),mpi_logical,root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_logical_3d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_broadcast_string_0d
! Purpose: broadcast string
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_broadcast_string_0d(f_comm,var,root)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
character(len=*),intent(in) :: var         ! String
integer,intent(in) :: root                 ! Root task

! Local variable
integer :: info

! Broadcast
call mpi_bcast(var,len(var),mpi_character,root,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_broadcast_string_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_receive_integer_0d
! Purpose: receive integer
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_receive_integer_0d(f_comm,var,src,tag,status)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm   ! FCKIT communicator
integer,intent(out) :: var                   ! Integer
integer,intent(in) :: src                    ! Source task
integer,intent(in) :: tag                    ! Tag
type(fckit_mpi_status),intent(out) :: status ! Status

! Local variable
integer :: info

! Receive
call mpi_recv(var,1,mpi_integer,src,tag,mpi_comm_world,status%mpi_status,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_receive_integer_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_receive_integer_1d
! Purpose: receive 1d integer array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_receive_integer_1d(f_comm,var,src,tag,status)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm   ! FCKIT communicator
integer,dimension(:),intent(inout) :: var    ! Integer array, 1d
integer,intent(in) :: src                    ! Source task
integer,intent(in) :: tag                    ! Tag
type(fckit_mpi_status),intent(out) :: status ! Status

! Local variable
integer :: info

! Receive
call mpi_recv(var,size(var),mpi_integer,src,tag,mpi_comm_world,status%mpi_status,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_receive_integer_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_receive_real_0d
! Purpose: receive real
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_receive_real_0d(f_comm,var,src,tag,status)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm   ! FCKIT communicator
real(kind_real),intent(out) :: var           ! Real
integer,intent(in) :: src                    ! Source task
integer,intent(in) :: tag                    ! Tag
type(fckit_mpi_status),intent(out) :: status ! Status

! Local variable
integer :: info

! Receive
call mpi_recv(var,1,fckit_mpi_real(),src,tag,mpi_comm_world,status%mpi_status,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_receive_real_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_receive_real_1d
! Purpose: receive 1d real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_receive_real_1d(f_comm,var,src,tag,status)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm        ! FCKIT communicator
real(kind_real),dimension(:),intent(inout) :: var ! Real array, 1d
integer,intent(in) :: src                         ! Source task
integer,intent(in) :: tag                         ! Tag
type(fckit_mpi_status),intent(out) :: status      ! Status

! Local variable
integer :: info

! Receive
call mpi_recv(var,size(var),fckit_mpi_real(),src,tag,mpi_comm_world,status%mpi_status,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_receive_real_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_receive_logical_1d
! Purpose: receive 1d logical array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_receive_logical_1d(f_comm,var,src,tag,status)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm   ! FCKIT communicator
logical,dimension(:),intent(inout) :: var    ! Logical array, 1d
integer,intent(in) :: src                    ! Source task
integer,intent(in) :: tag                    ! Tag
type(fckit_mpi_status),intent(out) :: status ! Status

! Local variable
integer :: info

! Receive
call mpi_recv(var,size(var),mpi_logical,src,tag,mpi_comm_world,status%mpi_status,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_receive_logical_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_send_integer_0d
! Purpose: send integer
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_send_integer_0d(f_comm,var,dst,tag)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,intent(in) :: var                  ! Integer
integer,intent(in) :: dst                  ! Destination task
integer,intent(in) :: tag                  ! Tag

! Local variable
integer :: info

! Send
call mpi_send(var,1,mpi_integer,dst,tag,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_send_integer_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_send_integer_1d
! Purpose: send 1d integer array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_send_integer_1d(f_comm,var,dst,tag)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,dimension(:),intent(in) :: var     ! Integer array, 1d
integer,intent(in) :: dst                  ! Destination task
integer,intent(in) :: tag                  ! Tag

! Local variable
integer :: info

! Send
call mpi_send(var,size(var),mpi_integer,dst,tag,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_send_integer_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_send_real_0d
! Purpose: send real
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_send_real_0d(f_comm,var,dst,tag)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
real(kind_real),intent(in) :: var          ! Real
integer,intent(in) :: dst                  ! Destination task
integer,intent(in) :: tag                  ! Tag

! Local variable
integer :: info

! Send
call mpi_send(var,1,fckit_mpi_real(),dst,tag,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_send_real_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_send_integer_1d
! Purpose: send 1d real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_send_real_1d(f_comm,var,dst,tag)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm     ! FCKIT communicator
real(kind_real),dimension(:),intent(in) :: var ! Real array, 1d
integer,intent(in) :: dst                      ! Destination task
integer,intent(in) :: tag                      ! Tag

! Local variable
integer :: info

! Send
call mpi_send(var,size(var),fckit_mpi_real(),dst,tag,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_send_real_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_send_logical_1d
! Purpose: send 1d logical array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_send_logical_1d(f_comm,var,dst,tag)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
logical,dimension(:),intent(in) :: var     ! Logical array, 1d
integer,intent(in) :: dst                  ! Destination task
integer,intent(in) :: tag                  ! Tag

! Local variable
integer :: info

! Send
call mpi_send(var,size(var),mpi_logical,dst,tag,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_send_logical_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_allgather_integer_0d
! Purpose: allgather for a integer
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_allgather_integer_0d(f_comm,sbuf,rbuf)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,intent(in) :: sbuf                 ! Sent buffer
integer,dimension(:),intent(inout) :: rbuf ! Received buffer

! Local variable
integer :: info
integer :: sbuf_vec(1)

! Initialization
sbuf_vec = (/sbuf/)

! Allgather
call mpi_allgather(sbuf_vec,1,mpi_integer,rbuf,1,mpi_integer,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_allgather_integer_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_allgather_real_0d
! Purpose: allgather for a real
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_allgather_real_0d(f_comm,sbuf,rbuf)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm         ! FCKIT communicator
real(kind_real),intent(in) :: sbuf                 ! Sent buffer
real(kind_real),dimension(:),intent(inout) :: rbuf ! Received buffer

! Local variable
integer :: info
real(kind_real) :: sbuf_vec(1)

! Initialization
sbuf_vec = (/sbuf/)

! Allgather
call mpi_allgather(sbuf_vec,1,fckit_mpi_real(),rbuf,1,fckit_mpi_real(),mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_allgather_real_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_allgather_logical_0d
! Purpose: allgather for a logical
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_allgather_logical_0d(f_comm,sbuf,rbuf)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
logical,intent(in) :: sbuf                 ! Sent buffer
logical,dimension(:),intent(inout) :: rbuf ! Received buffer

! Local variable
integer :: info
logical :: sbuf_vec(1)

! Initialization
sbuf_vec = (/sbuf/)

! Allgather
call mpi_allgather(sbuf_vec,1,mpi_logical,rbuf,1,mpi_logical,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_allgather_logical_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_alltoallv_real
! Purpose: alltoallv for a real array
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_alltoallv_real(f_comm,sbuf,scounts,sdispl,rbuf,rcounts,rdispl)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm         ! FCKIT communicator
real(kind_real),dimension(:),intent(in) :: sbuf    ! Sent buffer
integer,dimension(:),intent(in) :: scounts         ! Sending counts
integer,dimension(:),intent(in) :: sdispl          ! Sending displacement
real(kind_real),dimension(:),intent(inout) :: rbuf ! Received buffer
integer,dimension(:),intent(in) :: rcounts         ! Receiving counts
integer,dimension(:),intent(in) :: rdispl          ! Receiving displacement

! Local variable
integer :: info

! Alltoallv
call mpi_alltoallv(sbuf,scounts,sdispl,fckit_mpi_real(),rbuf,rcounts,rdispl,fckit_mpi_real(),mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_alltoallv_real

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_allreduce_integer_0d
! Purpose: allreduce for an integer
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_allreduce_integer_0d(f_comm,var_in,var_out,mpi_op)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
integer,intent(in) :: var_in               ! Input integer
integer,intent(out) :: var_out             ! Output integer
integer,intent(in) :: mpi_op               ! MPI operation

! Local variable
integer :: info

! Allreduce
call mpi_allreduce(var_in,var_out,1,mpi_integer,mpi_op,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_allreduce_integer_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_allreduce_real_0d
! Purpose: allreduce for a real number
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_allreduce_real_0d(f_comm,var_in,var_out,mpi_op)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm ! FCKIT communicator
real(kind_real),intent(in) :: var_in       ! Input real
real(kind_real),intent(out) :: var_out     ! Output real
integer,intent(in) :: mpi_op               ! MPI operation

! Local variable
integer :: info

! Allreduce
call mpi_allreduce(var_in,var_out,1,fckit_mpi_real(),mpi_op,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_allreduce_real_0d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_comm_allreduce_real_1d
! Purpose: allreduce for a real array, 1d
!----------------------------------------------------------------------
subroutine fckit_mpi_comm_allreduce_real_1d(f_comm,var_in,var_out,mpi_op)

implicit none

! Passed variables
class(fckit_mpi_comm),intent(in) :: f_comm            ! FCKIT communicator
real(kind_real),dimension(:),intent(in) :: var_in     ! Input real
real(kind_real),dimension(:),intent(inout) :: var_out ! Output real
integer,intent(in) :: mpi_op                          ! MPI operation

! Local variable
integer :: info

! Allreduce
call mpi_allreduce(var_in,var_out,size(var_in),fckit_mpi_real(),mpi_op,mpi_comm_world,info)

! Check
call f_comm%check(info)

end subroutine fckit_mpi_comm_allreduce_real_1d

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_sum
! Purpose: get MPI sum index
!----------------------------------------------------------------------
function fckit_mpi_sum()

! Returned value
integer :: fckit_mpi_sum

! Copy value
fckit_mpi_sum = mpi_sum

end function fckit_mpi_sum

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_min
! Purpose: get MPI min index
!----------------------------------------------------------------------
function fckit_mpi_min()

! Returned value
integer :: fckit_mpi_min

! Copy value
fckit_mpi_min = mpi_min

end function fckit_mpi_min

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_max
! Purpose: get MPI max index
!----------------------------------------------------------------------
function fckit_mpi_max()

! Returned value
integer :: fckit_mpi_max

! Copy value
fckit_mpi_max = mpi_max

end function fckit_mpi_max

!----------------------------------------------------------------------
! Subroutine: fckit_mpi_real
! Purpose: get MPI real index
!----------------------------------------------------------------------
function fckit_mpi_real()

! Returned value
integer :: fckit_mpi_real

! Copy value
if (kind_real==4) then
   fckit_mpi_real = mpi_real
elseif (kind_real==8) then
   fckit_mpi_real = mpi_double
end if

end function fckit_mpi_real

end module fckit_mpi_module
