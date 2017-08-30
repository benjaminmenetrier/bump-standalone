load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

model = "arp"
xp = "6B60"
;model = "aro"
;xp = "5840"
;suffix = "_deformed"
;suffix = "_resol-10"
;suffix = "_heterogeneous"
;suffix = "_homogeneous"
levplot = 1
ilplot = 1
plotLh = False

; Load data :
; -----------

data = addfile("../../data/" + model + "/" + xp + "/" + model + "_" + xp + "_mesh.nc","r")
nc2 = data->nc2(ilplot-1)
lon_nc2 = data->lon(ilplot-1,:)
lat_nc2 = data->lat(ilplot-1,:)
nc2 = dimsizes(lon_nc2)
na = data->na(ilplot-1)
larc = data->larc(ilplot-1,:,:)-1

longitude = data->longitude
latitude = data->latitude
Lh = data->Lh(ilplot-1,:,:)*1.0e-3
if (model.eq."aro") then
   lon = longitude
   lat = latitude
   hr = Lh
   hr(0,0) = 0.0
end if
if (model.eq."arp") then
   dims = dimsizes(Lh)
   nlat = dims(0)
   nlon = dims(1)
   nc0 = num(.not.ismissing(longitude))
   lon = new(nc0,double)
   lat = new(nc0,double)
   hr = new(nc0,double)
   ic0 = 0
   do ilon=0,nlon-1
      do ilat=0,nlat-1
         if (.not.ismissing(longitude(ilat,ilon))) then
            lon(ic0) = longitude(ilat,ilon)
            lat(ic0) = latitude(ilat,ilon)
            hr(ic0) = Lh(ilat,ilon)
            ic0 = ic0+1
         end if
      end do
   end do
   imin = minind(lat)
   hr(imin) = 0.0
end if

; Resources :
; -----------

res = True
res@gsnDraw = False
res@gsnFrame = False
res@gsnMaximize = True
res@gsnAddCyclic = False

res@cnFillOn = True
res@cnFillMode = "AreaFill"
res@trGridType = "TriangularMesh"
res@cnMonoFillPattern = True
res@cnMonoFillColor = False
res@lbLabelBarOn = True
res@lbOrientation = "vertical"
res@cnInfoLabelOn = False
res@cnLineLabelsOn = False
res@cnLinesOn = False
res@cnNoDataLabelOn = False
res@cnMissingValFillColor = 0
res@cnLevelSelectionMode = "ManualLevels"
if (model.eq."aro") then
   res@cnLevelSpacingF = 10.0
   res@cnMaxLevelValF = 250.0
   res@cnMinLevelValF = 60.0
end if
if (model.eq."arp") then
   res@cnLevelSpacingF = 100.0
   res@cnMaxLevelValF = 2000.0
   res@cnMinLevelValF = 0.0
end if

res@mpOutlineOn = True
res@mpDataBaseVersion = "MediumRes"
res@mpGridLatSpacingF = 20.0
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "Geophysical"
res@mpLandFillColor = -1
res@mpGridAndLimbDrawOrder = "PreDraw"
res@mpPerimOn = False
res@mpGreatCircleLinesOn = True
if (model.eq."aro") then
   res@mpProjection = "LambertConformal"
   res@mpGridAndLimbOn = False
   res@mpLimitMode = "LatLon"
   res@mpMinLonF = min(lon)
   res@mpMaxLonF = max(lon)-3.0
   res@mpMinLatF = min(lat)
   res@mpMaxLatF = max(lat)
end if
if (model.eq."arp") then
   res@mpProjection = "WinkelTripel"
   res@mpGridAndLimbOn = True
   res@mpGridLineDashPattern = 2
   res@mpGridLineColor = -1
   res@mpGridSpacingF = 45.0
   res@mpCenterLonF = 0.0
   res@mpCenterLatF = 0.0
end if

pmres = True
pmres@gsMarkerIndex = 1
pmres@gsMarkerSizeF = 0.01
pmres@gsMarkerColor = "black"

plres = True
plres@gsLineThicknessF = 0.01
plres@gsLineColor = "black"

wks_epsi = "epsi"

; Display :
; ---------

system("mkdir -p ../fig")

res@sfXArray = lon
res@sfYArray = lat

dot = new(nc2,graphic)
arc = new(na,graphic)

output = "../fig/" + model + "_" + xp + "_mesh_" + sprinti("%0.3i",levplot) + suffix
wks = gsn_open_wks(wks_epsi,output)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

if (plotLh) then
   plot = gsn_csm_contour_map(wks,hr,res)
else
   plot = gsn_csm_map(wks,res)
end if
do ic2=0,nc2-1
   dot(ic2) = gsn_add_polymarker(wks,plot,lon_nc2(ic2),lat_nc2(ic2),pmres)
end do
do ia=0,nas-1
   arc(ia) = gsn_add_polyline(wks,plot,(/lon_nc2(larc(ia,0)),lon_nc2(larc(ia,1))/),(/lat_nc2(larc(ia,0)),lat_nc2(larc(ia,1))/),plres)
end do

draw(plot)
frame(wks)
delete(wks)

system("epstopdf " + output + ".epsi;rm -f " + output + ".epsi")

end
