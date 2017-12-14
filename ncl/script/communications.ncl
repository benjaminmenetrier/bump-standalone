load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

model = "arp"
xp = "6B60"
nproc = 168
ns = (/"00014314","00006362","00003580","00002291","00001592","00000896","00000574","00000399"/)
Lh = (/500.0,750.0,1000.0,1250.0,1500.0,2000.0,2500.0,3000.0/)
nns = dimsizes(ns)

; Load data :
; -----------

nc0a = new(nns,integer)
nsa = new(nns,integer)
convol = new(nns,integer)
interp = new(nns,integer)
ncom = new((/2,nns/),integer)
do ins=0,nns-1
   do mpicom=1,2
      data = addfile("../../data/" + model + "/" + xp + "/" + model + "_" + xp + "_mpi-" + mpicom + "_" + sprinti("%0.4i",nproc) + "_summary-" + ns(ins) + ".nc","r")
      if (mpicom.eq.1) then
         ncom(mpicom-1,ins) = sum(data->AB_jhalocounts)+sum(data->AC_jhalocounts)
      else
         ncom(mpicom-1,ins) = 2*sum(data->AB_jhalocounts)+sum(data->AC_jhalocounts)
      end if
   end do
   nc0a(ins) = toint(avg(data->nc0a))
   nsa(ins) = toint(avg(data->nsa))
   convol(ins) = toint(avg(data->c_n_s))
   interp(ins) = toint(avg(data->h_n_s)+avg(data->s_n_s))
end do

; Resources :
; -----------

xyres = True
xyres@gsnFrame = False
xyres@gsnDraw = False
xyres@tmXBLabelFontHeightF = 0.02
xyres@tmYLLabelFontHeightF = 0.02
xyres@xyLineThicknessF = 5.0
xyres@xyCurveDrawOrder = "PreDraw"
xyres@xyLineColors = (/"blue","blue"/)
xyres@vpWidthF = 0.8
xyres@vpHeightF = 0.4
xyres@xyDashPattern = 0
xyres@tiMainFontHeightF = 0.03
xyres@tiXAxisString = "Horizontal length-scale (km)"
xyres@trXMinF = min(Lh)
xyres@trXMaxF = max(Lh)
xyres@trYMinF = 0.0

txres = True
txres@txFontHeightF = 0.03
txres@txJust = "CenterLeft"

resP = True
resP@gsnFrame = False
resP@gsnPanelXWhiteSpacePercent = 8
resP@gsnPanelYWhiteSpacePercent = 5

; Display :
; ---------

plot = new(4,graphic)

output = "../fig/communications"
wks = gsn_open_wks("epsi",output)
gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

xyres@tiMainString = "Number of subgrid points on each proc"
xyres@trYMaxF = max(nsa)*1.1
plot(0) = gsn_csm_xy(wks,Lh,nsa,xyres)
xyres@tiMainString = "Number of convolution operations for each proc"
xyres@trYMaxF = max(convol)*1.1
plot(1) = gsn_csm_xy(wks,Lh,convol,xyres)
xyres@tiMainString = "Number of interpolation operations for each proc"
xyres@trYMaxF = max(interp)*1.1
plot(2) = gsn_csm_xy(wks,Lh,interp,xyres)
xyres@tiMainString = "Number of communications"
xyres@xyLineColors = (/"green","red"/)
xyres@trYMaxF = max(ncom)*1.1
plot(3) = gsn_csm_xy(wks,Lh,ncom,xyres)
txres@txFontColor = "green"
com1 = gsn_add_text(wks,plot(3),"1 comm. step",1600,80000,txres)
txres@txFontColor = "red"
com2 = gsn_add_text(wks,plot(3),"2 comm. steps",1000,40000,txres)

gsn_panel(wks,plot,(/2,2/),resP)
frame(wks)
delete(wks)

system("epstopdf " + output + ".epsi;rm -f " + output + ".epsi")

end
