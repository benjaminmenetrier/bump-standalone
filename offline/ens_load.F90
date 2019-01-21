
!----------------------------------------------------------------------
! Subroutine: ens_load
! Purpose: load ensemble data
!----------------------------------------------------------------------
subroutine ens_load(ens,mpl,nam,geom,filename)

implicit none

! Passed variables
class(ens_type),intent(inout) :: ens    ! Ensemble
type(mpl_type),intent(inout) :: mpl     ! MPI data
type(nam_type),intent(in) :: nam        ! Namelist
type(geom_type),intent(in) :: geom      ! Geometry
character(len=*),intent(in) :: filename ! Filename ('ens1' or 'ens2')

! Local variables
integer :: ne,ne_offset,nsub,isub,jsub,ie,ietot

! Setup
select case (trim(filename))
case ('ens1')
   ne = nam%ens1_ne
   ne_offset = nam%ens1_ne_offset
   nsub = nam%ens1_nsub
case ('ens2')
   ne = nam%ens2_ne
   ne_offset = nam%ens2_ne_offset
   nsub = nam%ens2_nsub
case default
   ne = mpl%msv%vali
   ne_offset = mpl%msv%vali
   nsub = mpl%msv%vali
   call mpl%abort('wrong filename in ens_load')
end select

! Allocation
call ens%alloc(nam,geom,ne,nsub)

! Initialization
ens%fld = mpl%msv%valr
ietot = 1

! Loop over sub-ensembles
do isub=1,ens%nsub
   if (ens%nsub==1) then
      write(mpl%info,'(a7,a)') '','Full ensemble, member:'
      call mpl%flush(.false.)
   else
      write(mpl%info,'(a7,a,i4,a)') '','Sub-ensemble ',isub,', member:'
      call mpl%flush(.false.)
   end if

   ! Loop over members for a given sub-ensemble
   do ie=1,ens%ne/ens%nsub
      write(mpl%info,'(i4)') ne_offset+ie
      call mpl%flush(.false.)

      ! Read member
      if (ens%nsub==1) then
         jsub = 0
      else
         jsub = isub
      end if
      call model_read(mpl,nam,geom,filename,ne_offset+ie,jsub,ens%fld(:,:,:,:,ietot))

      ! Update
      ietot = ietot+1
   end do
   write(mpl%info,'(a)') ''
   call mpl%flush
end do

end subroutine ens_load
