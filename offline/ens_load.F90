
!----------------------------------------------------------------------
! Subroutine: ens_load
!> Purpose: load ensemble data
!----------------------------------------------------------------------
subroutine ens_load(ens,mpl,nam,geom,filename)

implicit none

! Passed variables
class(ens_type),intent(inout) :: ens    !< Ensemble
type(mpl_type),intent(in) :: mpl        !< MPI data
type(nam_type),intent(in) :: nam        !< Namelist
type(geom_type),intent(in) :: geom      !< Geometry
character(len=*),intent(in) :: filename !< Filename ('ens1' or 'ens2')

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
   call msi(ne)
   call msi(ne_offset)
   call msi(nsub)
   call mpl%abort('wrong filename in ens_load')
end select

! Allocation
call ens%alloc(nam,geom,ne,nsub)

! Initialization
call msr(ens%fld)
ietot = 1

! Loop over sub-ensembles
do isub=1,ens%nsub
   if (ens%nsub==1) then
      write(mpl%unit,'(a7,a)',advance='no') '','Full ensemble, member:'
   else
      write(mpl%unit,'(a7,a,i4,a)',advance='no') '','Sub-ensemble ',isub,', member:'
   end if
   call flush(mpl%unit)

   ! Loop over members for a given sub-ensemble
   do ie=1,ens%ne/ens%nsub
      write(mpl%unit,'(i4)',advance='no') ne_offset+ie
      call flush(mpl%unit)

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
   write(mpl%unit,'(a)') ''
   call flush(mpl%unit)
end do

! Remove mean
call ens%remove_mean

end subroutine ens_load
