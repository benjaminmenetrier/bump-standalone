

! Write data
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Write data'

if (nam%displ_diag) then
   ! Write displacement diagnostics
   filename = trim(nam%prefix)//'_displ_diag.nc'
   call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
   call namncwrite(nam,ncid)
   call ncerr(subr,nf90_def_dim(ncid,'nv',nam%nvp,nv_id))
   call ncerr(subr,nf90_def_dim(ncid,'nl0',geom%nl0,nl0_1_id))
   call ncerr(subr,nf90_def_dim(ncid,'na',3*hdata%nc2-6,na_id))
   call ncerr(subr,nf90_def_dim(ncid,'two',2,two_id))
   call ncerr(subr,nf90_def_dim(ncid,'niter',nam%displ_niter,displ_niter_id))
   call ncerr(subr,nf90_def_var(ncid,'vunit',ncfloat,(/nl0_1_id/),vunit_id))
   call ncerr(subr,nf90_def_var(ncid,'larc',nf90_int,(/two_id,na_id/),larc_id))
   call ncerr(subr,nf90_put_att(ncid,larc_id,'_FillValue',msvali))
   call ncerr(subr,nf90_def_var(ncid,'valid',ncfloat,(/displ_niter_id,nl0_1_id,nv_id/),valid_id))
   call ncerr(subr,nf90_put_att(ncid,valid_id,'_FillValue',msvalr))
   call ncerr(subr,nf90_def_var(ncid,'dist',ncfloat,(/displ_niter_id,nl0_1_id,nv_id/),dist_id))
   call ncerr(subr,nf90_put_att(ncid,dist_id,'_FillValue',msvalr))
   call ncerr(subr,nf90_def_var(ncid,'rhflt',ncfloat,(/displ_niter_id,nl0_1_id,nv_id/),rhflt_id))
   call ncerr(subr,nf90_put_att(ncid,rhflt_id,'_FillValue',msvalr))
   call ncerr(subr,nf90_enddef(ncid))
   call ncerr(subr,nf90_put_var(ncid,vunit_id,geom%vunit))
   call ncerr(subr,nf90_put_var(ncid,larc_id,hdata%larc))
   call ncerr(subr,nf90_put_var(ncid,valid_id,displ%valid))
   call ncerr(subr,nf90_put_var(ncid,dist_id,displ%dist))
   call ncerr(subr,nf90_put_var(ncid,rhflt_id,displ%rhflt))
   call ncerr(subr,nf90_close(ncid))
   do iv=1,nam%nvp
      call model_write(nam,geom,filename,trim(varprefix(iv))//'_dlon_raw',displ%dlon_raw(:,:,iv))
      call model_write(nam,geom,filename,trim(varprefix(iv))//'_dlat_raw',displ%dlat_raw(:,:,iv))
      call model_write(nam,geom,filename,trim(varprefix(iv))//'_dlon_flt',displ%dlon_flt(:,:,iv))
      call model_write(nam,geom,filename,trim(varprefix(iv))//'_dlat_flt',displ%dlat_flt(:,:,iv))
   end do
end if

if (nam%full_var) then
   ! Write full variances
   filename = trim(nam%prefix)//'_full_var.nc'
   do iv=1,nam%nv
      call model_write(nam,geom,filename,trim(varprefix(iv))//'_'//trim(varname(iv)),sum(mom%m2full(:,:,iv,:),dim=3)/float(mom%nsub))
   end do
end if

! Write global diagnostics
filename = trim(nam%prefix)//'_diag.nc'
call system('rm -f '//trim(nam%datadir)//'/'//trim(filename))
call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
call namncwrite(nam,ncid)
call ncerr(subr,nf90_put_att(ncid,nf90_global,'vunitchar',trim(vunitchar)))
call ncerr(subr,nf90_def_dim(ncid,'one',1,one_id))
call ncerr(subr,nf90_def_dim(ncid,'nc',nam%nc,nc_id))
call ncerr(subr,nf90_def_dim(ncid,'nl0_1',geom%nl0,nl0_1_id))
call ncerr(subr,nf90_def_dim(ncid,'nl0_2',geom%nl0,nl0_2_id))
call ncerr(subr,nf90_def_var(ncid,'disth',ncfloat,(/nc_id/),disth_id))
call ncerr(subr,nf90_def_var(ncid,'vunit',ncfloat,(/nl0_1_id/),vunit_id))
call ncerr(subr,nf90_enddef(ncid))
call ncerr(subr,nf90_put_var(ncid,disth_id,nam%disth(1:nam%nc)))
call ncerr(subr,nf90_put_var(ncid,vunit_id,geom%vunit))
call curve_write(hdata,ncid,cor,.true.)
select case (trim(nam%method))
case ('loc','hyb-avg','hyb-rnd','dual-ens')
   call curve_write(hdata,ncid,loc,.true.)
end select
select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   call curve_write(hdata,ncid,cor_sta,.false.)
   call curve_write(hdata,ncid,loc_hyb,.true.)
end select
if (trim(nam%method)=='dual-ens') then
   call curve_write(hdata,ncid,cor_lr,.true.)
   call curve_write(hdata,ncid,loc_lr,.true.)
   call curve_write(hdata,ncid,loc_deh,.true.)
   call curve_write(hdata,ncid,loc_deh_lr,.true.)
end if
call ncerr(subr,nf90_close(ncid))

if (nam%local_diag) then
   ! Allocation
   allocate(fld(geom%nc0,geom%nl0))

   ! Write support radii fields
   if ((trim(nam%fit_type)/='none').and..not.(nam%cross_diag.or.nam%displ_diag)) then
      ! Open file
      filename = trim(nam%prefix)//'_local_diag_cor.nc'
      call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
      call namncwrite(nam,ncid)
      call ncerr(subr,nf90_close(ncid))

      do iv=1,nam%nvp
         call msr(fld_nc2)
         do ic2=1,hdata%nc2
            fld_nc2(ic2,:) = cor_nc2(iv,ic2)%fit_rh
         end do
         call diag_interpolation(hdata,fld_nc2,fld)
         call model_write(nam,geom,filename,trim(varprefix(iv))//'_fit_rh',fld)
         if (trim(nam%flt_type)/='none') then
            call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
            call diag_interpolation(hdata,fld_nc2,fld)
            call model_write(nam,geom,filename,trim(varprefix(iv))//'_fit_rh_flt',fld)
         end if
         call msr(fld_nc2)
         do ic2=1,hdata%nc2
            fld_nc2(ic2,:) = cor_nc2(iv,ic2)%fit_rv
         end do
         call diag_interpolation(hdata,fld_nc2,fld)
         call model_write(nam,geom,filename,trim(varprefix(iv))//'_fit_rv',fld)
         if (trim(nam%flt_type)/='none') then
            call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
            call diag_interpolation(hdata,fld_nc2,fld)
            call model_write(nam,geom,filename,trim(varprefix(iv))//'_fit_rv_flt',fld)
         end if
      end do

      select case (trim(nam%method))
      case ('loc','hyb-avg','hyb-rnd','dual-ens')
         ! Open file
         filename = trim(nam%prefix)//'_local_diag_loc.nc'
         call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
         call namncwrite(nam,ncid)
         call ncerr(subr,nf90_close(ncid))

         do iv=1,nam%nvp
            call msr(fld_nc2)
            do ic2=1,hdata%nc2
               fld_nc2(ic2,:) = loc_nc2(iv,ic2)%fit_rh
            end do
            call diag_filter(hdata,'median',nam%diag_rhflt,fld_nc2)
            call diag_interpolation(hdata,fld_nc2,fld)
            call model_write(nam,geom,filename,trim(varprefix(iv))//'_fit_rh',fld)
            if (trim(nam%flt_type)/='none') then
               call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
               call diag_interpolation(hdata,fld_nc2,fld)
               call model_write(nam,geom,filename,trim(varprefix(iv))//'_fit_rh_flt',fld)
            end if
            call msr(fld_nc2)
            do ic2=1,hdata%nc2
               fld_nc2(ic2,:) = loc_nc2(iv,ic2)%fit_rv
            end do
            call diag_filter(hdata,'median',nam%diag_rhflt,fld_nc2)
            call diag_interpolation(hdata,fld_nc2,fld)
            call model_write(nam,geom,filename,trim(varprefix(iv))//'_fit_rv',fld)
            if (trim(nam%flt_type)/='none') then
               call diag_filter(hdata,nam%flt_type,nam%diag_rhflt,fld_nc2)
               call diag_interpolation(hdata,fld_nc2,fld)
               call model_write(nam,geom,filename,trim(varprefix(iv))//'_fit_rv_flt',fld)
            end if
         end do
      end select
   end if

   if (nam%nldwh>0) then
      ! Write local diagnostic fields
      filename = trim(nam%prefix)//'_local_diag_ldwh.nc'
      call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
      call namncwrite(nam,ncid)
      call ncerr(subr,nf90_close(ncid))

      ! Write mask
      fld = 0.0
      do il0=1,geom%nl0
         do ic0=1,geom%nc0
            if (geom%mask(ic0,il0)) fld(ic0,il0) = 1.0
         end do
      end do
      call model_write(nam,geom,filename,'mask',fld)

      do ildw=1,nam%nldwh
         ! Level and class
         il0 = nam%il_ldwh(ildw)
         ic = nam%ic_ldwh(ildw)
         write(levchar,'(i3.3)') nam%levs(il0)
         write(icchar,'(i3.3)') ic

         ! Write correlation field
         do iv=1,nam%nvp
            call msr(fld_nc2)
            do ic2=1,hdata%nc2
               fld_nc2(ic2,1) = cor_nc2(iv,ic2)%raw(ic,il0,il0)
            end do
            call diag_interpolation(hdata,il0,fld_nc2(:,1),fld(:,1))
            call model_write(nam,geom,filename,trim(varprefix(iv))//'_cor_'//levchar//'_'//icchar,fld)
         end do
   
         select case (trim(nam%method))
         case ('loc','hyb-avg','hyb-rnd','dual-ens')
            ! Write localization field
            do iv=1,nam%nvp
               call msr(fld_nc2)
               do ic2=1,hdata%nc2
                  fld_nc2(ic2,1) = loc_nc2(iv,ic2)%raw(ic,il0,il0)
               end do
               call diag_interpolation(hdata,il0,fld_nc2(:,1),fld(:,1))
               call model_write(nam,geom,filename,trim(varprefix(iv))//'_loc'//'_'//levchar//'_'//icchar,fld)
            end do
         end select
      end do
   end if

   ! Write local diagnostic profiles
   do ildw=1,nam%nldwv
      if (isnotmsi(hdata%nn_ldwv_index(ildw))) then
         ! Write data
         write(lonchar,'(f7.2)') nam%lon_ldwv(ildw)
         write(latchar,'(f7.2)') nam%lat_ldwv(ildw)

         filename = trim(nam%prefix)//'_diag_'//trim(adjustl(lonchar))//'-'//trim(adjustl(latchar))//'.nc'
         call ncerr(subr,nf90_create(trim(nam%datadir)//'/'//trim(filename),or(nf90_clobber,nf90_64bit_offset),ncid))
         call namncwrite(nam,ncid)
         call ncerr(subr,nf90_put_att(ncid,nf90_global,'vunitchar',trim(vunitchar)))
         call ncerr(subr,nf90_def_dim(ncid,'one',1,one_id))
         call ncerr(subr,nf90_def_dim(ncid,'nc',nam%nc,nc_id))
         call ncerr(subr,nf90_def_dim(ncid,'nl0_1',geom%nl0,nl0_1_id))
         call ncerr(subr,nf90_def_dim(ncid,'nl0_2',geom%nl0,nl0_2_id))
         call ncerr(subr,nf90_def_var(ncid,'disth',ncfloat,(/nc_id/),disth_id))
         call ncerr(subr,nf90_def_var(ncid,'vunit',ncfloat,(/nl0_1_id/),vunit_id))
         call ncerr(subr,nf90_enddef(ncid))
         call ncerr(subr,nf90_put_var(ncid,disth_id,nam%disth(1:nam%nc)))
         call ncerr(subr,nf90_put_var(ncid,vunit_id,geom%vunit))
         call curve_write(hdata,ncid,cor_nc2(:,hdata%nn_ldwv_index(ildw)),.true.)
         select case (trim(nam%method))
         case ('loc','hyb-avg','hyb-rnd','dual-ens')
            call curve_write(hdata,ncid,loc_nc2(:,hdata%nn_ldwv_index(ildw)),.true.)
         end select
         call ncerr(subr,nf90_close(ncid))
      else
         call msgwarning('missing local profile')
      end if
   end do
end if

! Release memory
write(mpl%unit,'(a)') '-------------------------------------------------------------------'
write(mpl%unit,'(a)') '--- Release memory'

if (nam%local_diag) then
   deallocate(fld_nc2)
   deallocate(fld)
end if

if (trim(nam%method)=='dual-ens') then
   do iv=1,nam%nvp
      call curve_dealloc(hdata,loc_deh_lr(iv))
      call curve_dealloc(hdata,loc_deh(iv))
      call curve_dealloc(hdata,loc_lr(iv))
   end do
   deallocate(loc_deh_lr)
   deallocate(loc_deh)
   deallocate(loc_lr)

   do iv=1,nam%nvp
      call curve_dealloc(hdata,cor_lr(iv))
   end do
   deallocate(cor_lr)
   call avg_dealloc(hdata,avg_lr)
   call mom_dealloc(hdata,mom_lr)
end if

if (trim(nam%method)=='hyb-rnd') then
   call avg_dealloc(hdata,avg_rnd)
   call mom_dealloc(hdata,mom_rnd)
end if

select case (trim(nam%method))
case ('hyb-avg','hyb-rnd')
   do iv=1,nam%nvp
      call curve_dealloc(hdata,loc_hyb(iv))
   end do
   deallocate(loc_hyb)
   do iv=1,nam%nvp
      call curve_dealloc(hdata,cor_sta(iv))
   end do
   deallocate(cor_sta)
end select

select case (trim(nam%method))
case ('loc','hyb-avg','hyb-rnd','dual-ens')
   if (nam%local_diag) then
      do iv=1,nam%nvp
         do ic2=1,hdata%nc2
            call curve_dealloc(hdata,loc_nc2(iv,ic2))
         end do
      end do
      deallocate(loc_nc2)
   end if
    do iv=1,nam%nvp
      call curve_dealloc(hdata,loc(iv))
   end do
   deallocate(loc)
end select

if (nam%local_diag) then
   do iv=1,nam%nvp
      do ic2=1,hdata%nc2
         call curve_dealloc(hdata,cor_nc2(iv,ic2))
      end do
   end do
   deallocate(cor_nc2)
end if
do iv=1,nam%nvp
   call curve_dealloc(hdata,cor(iv))
end do
deallocate(cor)
if (nam%local_diag) then
   deallocate(done)
   do ic2=1,hdata%nc2
      call avg_dealloc(hdata,avg_nc2(ic2))
   end do
   deallocate(avg_nc2)
end if
call avg_dealloc(hdata,avg)
call mom_dealloc(hdata,mom)
if (nam%displ_diag) call displ_dealloc(displ)

deallocate(varprefix)
deallocate(varname)

