load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

; Parameters:
; -----------

datadir = "../../data/arp/877D"
prefix = "arp_877D"
nproc = 3

procs = fspan(1,nproc,nproc)

; Resources:
; ----------

res = True
res@gsnDraw = False
res@gsnFrame = False
res@gsnMaximize = True

res@cnFillMode = "RasterFill"
res@cnFillOn = True
res@cnMonoFillPattern = True
res@cnMonoFillColor = False
res@cnInfoLabelOn = False
res@cnLineLabelsOn = False
res@cnLinesOn = False
res@cnNoDataLabelOn = False
res@cnMissingValFillColor = 0
res@lbLabelBarOn = True
res@lbOrientation = "vertical"
res@trXMinF = 0.5
res@trXMaxF = nproc+0.5
res@trYMinF = 0.5
res@trYMaxF = nproc+0.5
res@tmXBMode = "Explicit"
res@tmYLMode = "Explicit"
res@tmXBValues = procs
res@tmYLValues = procs
res@tmXBLabels = procs
res@tmYLLabels = procs
res@sfXArray = procs
res@sfYArray = procs

resP = True
resP@gsnFrame = False
resP@gsnPanelXWhiteSpacePercent = 8
resP@gsnPanelYWhiteSpacePercent = 5

; Load and plot data:
; -------------------

data_distribution = addfile(datadir + "/" + prefix + "_distribution_" + sprinti("%0.4i",nproc) + ".nc","r")
mpicom = data_distribution@mpicom
strategy = data_distribution@strategy

AB_halo = new((/nproc,nproc/),integer)
AB_excl = new((/nproc,nproc/),integer)
AC_halo = new((/nproc,nproc/),integer)
AC_excl = new((/nproc,nproc/),integer)
do iproc=1,nproc
   data_ndata = addfile(datadir + "/" + prefix + "_ndata_" + mpicom + "_" + sprinti("%0.4i",nproc) + "-" + sprinti("%0.4i",iproc) + "_common.nc","r")
   AB_halo(iproc-1,:) = data_ndata->AB_jhalocounts
   AB_excl(iproc-1,:) = data_ndata->AB_jexclcounts
   AC_halo(iproc-1,:) = data_ndata->AC_jhalocounts
   AC_excl(iproc-1,:) = data_ndata->AC_jexclcounts
end do

output = "../fig/" + prefix + "_distribution_" + mpicom + "_" + sprinti("%0.4i",nproc)
wks = gsn_open_wks("epsi",output)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

plot = new(4,graphic)

res@tiMainString = "Halos A/B, halo"
plot(0) = gsn_csm_contour(wks,AB_halo,res)
res@tiMainString = "Halos A/B, excl"
plot(1) = gsn_csm_contour(wks,AB_excl,res)
res@tiMainString = "Halos A/C, halo"
plot(2) = gsn_csm_contour(wks,AC_halo,res)
res@tiMainString = "Halos A/C, excl"
plot(3) = gsn_csm_contour(wks,AC_excl,res)

gsn_panel(wks,plot,(/2,2/),resP)
frame(wks)
delete(wks)
system("epstopdf " + output + ".epsi;rm -f " + output + ".epsi")

end
