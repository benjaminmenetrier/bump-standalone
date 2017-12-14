load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

if (False) then
   filename = "../../../hybrid_diag/data/aro/5840_envar/aro_5840_local_diag_loc.nc"
   data = addfile(filename,"r")
   Lh_base = data->01_adj_D_flt(0,:,:)

   dims = dimsizes(Lh_base)
   nlat = dims(0)
   nlon = dims(1)
   nl0 = 91
   Lh = new((/nl0,nlat,nlon/),double)
   do il0=0,nl0-1
      Lh(il0,:,:) = Lh_base
   end do

   filename = "../../data/aro/5840/aro_5840_Lh.nc"
   system("rm -f " + filename)
   data = addfile(filename,"c")
   data->Lh = Lh
end if

if (False) then
   filename = "../../../hybrid_diag/data/arp/86SV_ref/arp_86SV_local_diag_loc.nc"
   data = addfile(filename,"r")
   Lh_base = data->01_adj_D_flt(0,:,:)

   dims = dimsizes(Lh_base)
   nlat = dims(0)
   nlon = dims(1)
   nl0 = 106
   Lh = new((/nl0,nlat,nlon/),double)
   do il0=0,nl0-1
      Lh(il0,:,:) = Lh_base
   end do

   filename = "../../data/arp/6B60/arp_6B60_Lh.nc"
   system("rm -f " + filename)
   data = addfile(filename,"c")
   data->Lh = Lh
end if

if (True) then
   filename = "../../../hybrid_diag/data/arp/86SV_ref/grid.nc"
   data = addfile(filename,"r")
   latitude = data->latitude
   longitude = data->longitude

   lon0 = 0.0
   lat0 = 0.598

   dims = dimsizes(latitude)
   nlat = dims(0)
   nlon = dims(1)
   Lh_base = new((/nlat,nlon/),double)
   Lh_base = 1000.0e3
   do ilat=0,nlat-1
      do ilon=0,nlon-1
         if (.not.ismissing(longitude(ilat,ilon))) then
            dist = gc_latlon(lat0,lon0,latitude(ilat,ilon),longitude(ilat,ilon),2,4)
            if ((dist.gt.500.0).and.(dist.lt.1500.0)) then
               Lh_base(ilat,ilon) = 1000.0e3*(1.0-0.8*exp(-0.5*(dist-1000.0)^2/166.0^2))
            else
               Lh_base(ilat,ilon) = 1000.0e3
            end if
         else
            Lh_base(ilat,ilon) = -999.0
         end if
      end do
   end do


   nl0 = 106
   Lh = new((/nl0,nlat,nlon/),double)
   do il0=0,nl0-1
      Lh(il0,:,:) = Lh_base
   end do
   Lh@_FillValue = -999.0

   filename = "../../data/arp/6B60/arp_6B60_Lh_circle.nc"
   system("rm -f " + filename)
   data = addfile(filename,"c")
   data->Lh = Lh
end if


end
