load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

model = "arp"
filedir = "arp/6B60"
filename = "arp_6B60"
;model = "aro"
;filedir = "aro/5840"
;filename = "aro_5840"
;model = "mpas"
;filedir = "mpas"
;filename = "mpas"
;model = "qg"
;filedir = "../../OOPS/build/oops/qg/test"
;filename = "qg"
suffix = ""
ilplot = 1

; Load data :
; -----------

data = addfile("../../data/" + filedir + "/" + filename + "_dirac.nc","r")
if (model.eq."aro") then
   lon = data->longitude
   lat = data->latitude
   hr = data->hr(ilplot-1,:,:)
end if
if (model.eq."arp") then
   longitude = data->longitude
   latitude = data->latitude
   var = data->hr(ilplot-1,:,:)
   dims = dimsizes(longitude)
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
         hr(ic0) = var(ilat,ilon)
         ic0 = ic0+1
       end if
     end do
   end do
end if
if (model.eq."mpas") then
   lon = data->lonCell
   lat = data->latCell
   hr = data->hr(ilplot-1,:,0)
end if
if (model.eq."qg") then
   lon = data->lon
   lat = data->lat
   hr = data->hr(:,ilplot-1)
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
res@cnLevelSpacingF = 0.05
res@cnMaxLevelValF = 1.0
res@cnMinLevelValF = 0.0

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
if ((model.eq."arp").or.(model.eq."mpas").or.(model.eq."qg")) then
   res@mpProjection = "WinkelTripel"
   res@mpGridAndLimbOn = True
   res@mpGridLineDashPattern = 2
   res@mpGridLineColor = -1
   res@mpGridSpacingF = 45.0
   res@mpCenterLonF = 0.0
   res@mpCenterLatF = 0.0
end if

wks_epsi = "epsi"

; Display :
; ---------

system("mkdir -p ../fig")

res@sfXArray = lon
res@sfYArray = lat

output = "../fig/" + filename + "_dirac" + suffix
wks = gsn_open_wks(wks_epsi,output)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

plot = gsn_csm_contour_map(wks,hr,res)

draw(plot)
frame(wks)
delete(wks)

system("epstopdf " + output + ".epsi;rm -f " + output + ".epsi")

end
