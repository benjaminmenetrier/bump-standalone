load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

model = "nemo"
suffix = ""
levplot = 1
ilplot = 1

; Load data :
; -----------

data = addfile("../../data/" + model + "/" + model + "_mesh.nc","r")
lon_ns_base = data->lon_base
lat_ns_base = data->lat_base
larc_base = data->larc_base-1
ns = dimsizes(lon_ns_base)
dims = dimsizes(larc_base)
na = dims(0)
delete(dims)

nc2 = data->nc2(ilplot-1)
lon_ns = data->lon(ilplot-1,:)
lat_ns = data->lat(ilplot-1,:)
nas = data->nas(ilplot-1)
larc = data->larc(ilplot-1,:,:)-1

; Resources :
; -----------

res = True
res@gsnDraw = False
res@gsnFrame = False
res@gsnMaximize = True

res@mpOutlineOn = True
res@mpDataBaseVersion = "MediumRes"
res@mpGridLatSpacingF = 20.0
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "Geophysical"
res@mpLandFillColor = -1
res@mpGridAndLimbDrawOrder = "PreDraw"
res@mpPerimOn = False
res@mpGreatCircleLinesOn = True
res@mpProjection = "WinkelTripel"
res@mpGridAndLimbOn = True
res@mpGridLineDashPattern = 2
res@mpGridLineColor = -1
res@mpGridSpacingF = 45.0
res@mpCenterLonF = 0.0
res@mpCenterLatF = 0.0

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

dot = new(ns,graphic)
arc = new(na,graphic)

output = "../fig/" + model + "_mesh_" + sprinti("%0.3i",levplot) + suffix
wks = gsn_open_wks(wks_epsi,output)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

plot = gsn_csm_map(wks,res)
do is=0,nc2-1
   dot(is) = gsn_add_polymarker(wks,plot,lon_ns(is),lat_ns(is),pmres)
end do
do ia=0,nas-1
   arc(ia) = gsn_add_polyline(wks,plot,(/lon_ns(larc(ia,0)),lon_ns(larc(ia,1))/),(/lat_ns(larc(ia,0)),lat_ns(larc(ia,1))/),plres)
end do

draw(plot)
frame(wks)
delete(wks)

system("epstopdf " + output + ".epsi;rm -f " + output + ".epsi")

end
