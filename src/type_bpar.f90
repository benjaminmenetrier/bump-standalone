!----------------------------------------------------------------------
! Module: type_bpar
!> Purpose: block parameters derived type
!> <br>
!> Author: Benjamin Menetrier
!> <br>
!> Licensing: this code is distributed under the CeCILL-C license
!> <br>
!> Copyright © 2017 METEO-FRANCE
!----------------------------------------------------------------------
module type_bpar

use tools_kinds,only: kind_real
use tools_missing, only: msi,msr
use type_geom, only: geomtype
use type_nam, only: namtype

implicit none

type bpartype
   ! Block parameters
   integer :: nb
   integer,allocatable :: il0min(:,:)
   integer,allocatable :: nl0(:)
   integer,allocatable :: icmax(:)
   logical,allocatable :: diag_block(:)
   logical,allocatable :: avg_block(:)
   logical,allocatable :: fit_block(:)
   logical,allocatable :: nicas_block(:)
   character(len=11),allocatable :: blockname(:)
   integer,allocatable :: ib_to_iv(:)
   integer,allocatable :: ib_to_jv(:)
   integer,allocatable :: ib_to_its(:)
   integer,allocatable :: ib_to_jts(:)
end type bpartype

private
public :: bpartype
public :: bpar_alloc

contains

!----------------------------------------------------------------------
! Subroutine: bpar_alloc
!> Purpose: allocate general parameters
!----------------------------------------------------------------------
subroutine bpar_alloc(nam,geom,bpar)

implicit none

! Passed variable
type(namtype),intent(in) :: nam !< Namelist variables
type(geomtype),intent(in) :: geom !< Geometry
type(bpartype),intent(inout) :: bpar !< Block parameters

! Local variables
integer :: ib,iv,jv,its,jts,jl0

! Number of blocks
bpar%nb = nam%nv**2*nam%nts**2

! Allocation
allocate(bpar%il0min(geom%nl0,bpar%nb+1))
allocate(bpar%nl0(bpar%nb+1))
allocate(bpar%icmax(bpar%nb+1))
allocate(bpar%diag_block(bpar%nb+1))
allocate(bpar%avg_block(bpar%nb+1))
allocate(bpar%fit_block(bpar%nb+1))
allocate(bpar%nicas_block(bpar%nb+1))
allocate(bpar%blockname(bpar%nb+1))
allocate(bpar%ib_to_iv(bpar%nb))
allocate(bpar%ib_to_jv(bpar%nb))
allocate(bpar%ib_to_its(bpar%nb))
allocate(bpar%ib_to_jts(bpar%nb))

! Individual blocks
ib = 1
do iv=1,nam%nv
   do jv=1,nam%nv
      do its=1,nam%nts
         do jts=1,nam%nts
            ! Classes and levels
            if ((iv==jv).and.(its==jts)) then
               bpar%il0min(:,ib) = 0
               bpar%nl0(ib) = geom%nl0
               bpar%icmax(ib) = nam%nc
            else
               do jl0=1,geom%nl0
                  bpar%il0min(jl0,ib) = jl0-1
               end do
               bpar%nl0(ib) = 1
               bpar%icmax(ib) = 1
            end if

            ! Select blocks
            select case (nam%strategy)
            case ('common')
               bpar%diag_block(ib) = (iv==jv).and.(its==1)
               bpar%avg_block(ib) = (iv==jv).and.(its==1).and.(jts==1)
               bpar%nicas_block(ib) = .false.
            case ('specific_univariate','specific_multivariate')
               bpar%diag_block(ib) = (iv==jv).and.(its==1)
               bpar%avg_block(ib) = .false.
               bpar%nicas_block(ib) = (iv==jv).and.(its==1)
            case ('common_weighted')
               bpar%diag_block(ib) = (its==1)
               bpar%avg_block(ib) = (iv==jv).and.(its==1).and.(jts==1)
               bpar%nicas_block(ib) = .false.
            end select
            bpar%fit_block(ib) = bpar%diag_block(ib).and.(iv==jv).and.(its==jts).and.(trim(nam%fit_type)/='none')

            ! Blocks information
            write(bpar%blockname(ib),'(i2.2,a,i2.2,a,i2.2,a,i2.2)') iv,'_',jv,'_',its,'_',jts
            bpar%ib_to_iv(ib) = iv
            bpar%ib_to_jv(ib) = jv
            bpar%ib_to_its(ib) = its
            bpar%ib_to_jts(ib) = jts

            ib = ib+1
         end do
      end do
   end do
end do

! Common block

! Classes and levels
bpar%il0min(:,bpar%nb+1) = 0
bpar%nl0(bpar%nb+1) = geom%nl0
bpar%icmax(bpar%nb+1) = nam%nc

! Select blocks
select case (nam%strategy)
case ('common','common_weighted')
   bpar%diag_block(bpar%nb+1) = .true. 
   bpar%avg_block(bpar%nb+1) = .false. 
   bpar%nicas_block(bpar%nb+1) = .true.
case ('specific_univariate','specific_multivariate')
   bpar%diag_block(bpar%nb+1) = .false.
   bpar%avg_block(bpar%nb+1) = .false. 
   bpar%nicas_block(bpar%nb+1) = .false. 
end select

! Blocks information
bpar%blockname(bpar%nb+1) = 'common'
bpar%fit_block(bpar%nb+1) = bpar%diag_block(bpar%nb+1).and.(trim(nam%fit_type)/='none')

end subroutine bpar_alloc

end module type_bpar
