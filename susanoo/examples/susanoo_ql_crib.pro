;+
; PROCEDURE: susanoo_ql_sample
; 
; PURPOSE: 
;-
pro susanoo_ql_sample, trange = None
  compile_opt idl2
  
  erg_init
  if trange = None then begin
    timespan, '2025-05-01', 30, /day
  endif
  initct, 1080, line_clrs = 8

  ; Load the Susanoo data
  susanoo_sw_load
  ; If you want to plot other data please choose the locations from ['earth', 'mercury', 'venus', 'mars', 'psp', 'solaro', 'bepic', 'stereoa'] as a keyword of site.
  ; e.g., susanoo_sw_load, site = 'mercury'

  ; tplot SUSANOO tvars
  tplot, ['susanoo_sw_swvv_earth', 'susanoo_sw_imfb_earth', 'susanoo_sw_dens_earth', 'susanoo_sw_pre_earth']
  stop

  split_vec, 'susanoo_sw_swvv_earth'
  calc, '"susanoo_sw_swvel" = sqrt("susanoo_sw_swvv_earth_x"^2 + "susanoo_sw_swvv_earth_y"^2 + "susanoo_sw_swvv_earth_z"^2)'

  split_vec, 'susanoo_sw_imfb_earth'
  ; print, cdf_info('susanoo_sw_imfb_earth')

  ; Convert a coordinate system from GSE to GSM
  cotrans, 'susanoo_sw_imfb_earth', 'susanoo_sw_imfb_earth_gsm', /gse2gsm
  split_vec, 'susanoo_sw_imfb_earth_gsm'
  ; Calculate B total of the SUSANOO data in GSE and GSM
  calc, '"susanoo_sw_imfb_earth_tot" = sqrt("susanoo_sw_imfb_earth_x"^2 + "susanoo_sw_imfb_earth_y"^2 + "susanoo_sw_imfb_earth_z"^2)'
  calc, '"susanoo_sw_imfb_earth_gsm_tot" = sqrt("susanoo_sw_imfb_earth_gsm_x"^2 + "susanoo_sw_imfb_earth_gsm_y"^2 + "susanoo_sw_imfb_earth_gsm_z"^2)'

  ; output ascii file for SUSANOO data in GSM
  tplot_ascii, 'susanoo_sw_imfb_earth_gsm_?'

  get_data, 'susanoo_sw_imfb_earth_x', data = d_susanoo_bx, dlimits = dl_susanoo_bx, lim = lim_susanoo_bx
  get_data, 'susanoo_sw_imfb_earth_y', data = d_susanoo_by, dlimits = dl_susanoo_by, lim = lim_susanoo_by
  get_data, 'susanoo_sw_imfb_earth_z', data = d_susanoo_bz, dlimits = dl_susanoo_bz, lim = lim_susanoo_bz

  time_susanoo = d_susanoo_bx.x

  susanoo_imfbx = d_susanoo_bx.y
  susanoo_imfby = d_susanoo_by.y
  susanoo_imfbz = d_susanoo_bz.y

  susanoo_phi = make_array(time_susanoo.length, increment = 0, /float)
  for i = 0, time_susanoo.length -1 do begin
    if susanoo_imfbx[i] ge 0.0 and susanoo_imfby[i] ge 0.0 then begin
      susanoo_phi[i] = 180/!PI * atan(susanoo_imfby[i] / susanoo_imfbx[i])
    endif else if susanoo_imfbx[i] ge 0.0 and susanoo_imfby[i] lt 0.0 then begin
      susanoo_phi[i] = 180/!PI * atan(susanoo_imfby[i] / susanoo_imfbx[i])
    endif else if susanoo_imfbx[i] lt 0.0 then begin
      susanoo_phi[i] = 180/!PI * atan(susanoo_imfby[i] / susanoo_imfbx[i])
    endif 
  endfor
  
  ; susanoo_phi = 180/!PI * atan(susanoo_imfby, susanoo_imfbx)
  ; i_neg = where(susanoo_phi lt 0.0)
  ; susanoo_phi[i_neg] = susanoo_phi[i_neg] + 360
  
  store_data, 'susanoo_sw_phi', data = {x: time_susanoo, y:susanoo_phi}

  get_data, 'susanoo_sw_imfb_earth_gsm_x', data = d_susanoo_bx_gsm, dlimits = dl_susanoo_bx_gsm, lim = lim_susanoo_bx_gsm
  get_data, 'susanoo_sw_imfb_earth_gsm_y', data = d_susanoo_by_gsm, dlimits = dl_susanoo_by_gsm, lim = lim_susanoo_by_gsm
  get_data, 'susanoo_sw_imfb_earth_gsm_z', data = d_susanoo_bz_gsm, dlimits = dl_susanoo_bz_gsm, lim = lim_susanoo_bz_gsm

  time_susanoo_gsm = d_susanoo_bx_gsm.x

  susanoo_imfbx_gsm = d_susanoo_bx_gsm.y
  susanoo_imfby_gsm = d_susanoo_by_gsm.y
  susanoo_imfbz_gsm = d_susanoo_bz_gsm.y


  susanoo_phi_gsm = make_array(time_susanoo_gsm.length, increment = 0, /float)
  for i = 0, time_susanoo_gsm.length -1 do begin
    if susanoo_imfbx_gsm[i] ge 0.0 and susanoo_imfby_gsm[i] ge 0.0 then begin
      susanoo_phi_gsm[i] = 180/!PI * atan(susanoo_imfby_gsm[i] / susanoo_imfbx_gsm[i])
    endif else if susanoo_imfbx_gsm[i] ge 0.0 and susanoo_imfby_gsm[i] lt 0.0 then begin
      susanoo_phi_gsm[i] = 180/!PI * atan(susanoo_imfby_gsm[i] / susanoo_imfbx_gsm[i]) +360
    endif else if susanoo_imfbx_gsm[i] lt 0.0 then begin
      susanoo_phi_gsm[i] = 180/!PI * atan(susanoo_imfby_gsm[i] / susanoo_imfbx_gsm[i]) + 180
    endif 
  endfor

  ; susanoo_phi_gsm = 180/!PI * atan(susanoo_imfby_gsm, susanoo_imfbx_gsm)
  ; i_neg = where(susanoo_phi_gsm lt 0.0)
  ; susanoo_phi_gsm[i_neg] = susanoo_phi_gsm[i_neg] + 360
  store_data, 'susanoo_sw_phi_gsm', data = {x: time_susanoo_gsm, y: susanoo_phi_gsm}

  omni_hro_load
  omni_hro_load, /res5min
  DSC_LOAD_MAG
  ; DSC_LOAD_FC

  cotrans, 'dsc_h0_mag_B1GSE', 'dsc_h0_mag_B1GSM', /gse2gsm
  avg_data, 'dsc_h0_mag_B1GSM', 300
  split_vec, 'dsc_h0_mag_B1GSM_avg'

  get_data, 'dsc_h0_mag_B1GSM_avg_x', data = d_dsc_bx_gsm, dlimits = dl_dsc_bx_gsm, lim = lim_dsc_bx_gsm
  get_data, 'dsc_h0_mag_B1GSM_avg_y', data = d_dsc_by_gsm, dlimits = dl_dsc_bx_gsm, lim = lim_dsc_by_gsm
  ; get_data, 'OMNI_HRO_1min_BZ_GSM', data = d_omni_bz_gsm, dlimits = dl_omni_bz_gsm, lim = lim_omni_bz_gsm
  
  time_dsc_imf = d_dsc_bx_gsm.x

  dsc_imfbx_gsm = d_dsc_bx_gsm.y
  dsc_imfby_gsm = d_dsc_by_gsm.y
  ; omni_imfbz_gsm = d_omni_bz_gsm.y

  dsc_imf_phi = make_array(time_dsc_imf.length, increment = 0, /float)
  for i = 0, time_dsc_imf.length -1 do begin
    if dsc_imfbx_gsm[i] ge 0.0 and dsc_imfby_gsm[i] ge 0.0 then begin
      dsc_imf_phi[i] = 180/!PI * atan(dsc_imfby_gsm[i] / dsc_imfbx_gsm[i])
    endif else if dsc_imfbx_gsm[i] ge 0.0 and dsc_imfby_gsm[i] lt 0.0 then begin
      dsc_imf_phi[i] = 180/!PI * atan(dsc_imfby_gsm[i] / dsc_imfbx_gsm[i]) + 360
    endif else if dsc_imfbx_gsm[i] lt 0.0 then begin
      dsc_imf_phi[i] = 180/!PI * atan(dsc_imfby_gsm[i] / dsc_imfbx_gsm[i]) + 180
    endif 
  endfor

  ; dsc_imf_phi = 180/!PI * atan(dsc_imfby_gsm, dsc_imfbx_gsm)
  ; i_neg = where(dsc_imf_phi lt 0.0)
  ; dsc_imf_phi[i_neg] = dsc_imf_phi[i_neg] + 360
  store_data, 'dsc_h0_mag_B1GSM_PHI', data = {x: time_dsc_imf, y:dsc_imf_phi}
  ; avg_data, 'dsc_h0_mag_B1GSM_PHI', 300


  calc, '"susanoo_sw_temp" = ("susanoo_sw_pre_earth"/10) /("susanoo_sw_dens_earth"*1e6) / (1.38064*1e-23)' 
  ; T [K] = (P [dyn/cm^-2] *0.1) [Pa] / (n [cm^-3] * 10^6) [m^-3] / kb [J/K]

  get_data, 'OMNI_HRO_5min_BX_GSE', data = d_omni_bx_gse, dlimits = dl_omni_bx_gse, lim = lim_omni_bx_gse
  get_data, 'OMNI_HRO_5min_BY_GSM', data = d_omni_by_gsm, dlimits = dl_omni_by_gsm, lim = lim_omni_by_gsm
  ; get_data, 'OMNI_HRO_1min_BZ_GSM', data = d_omni_bz_gsm, dlimits = dl_omni_bz_gsm, lim = lim_omni_bz_gsm
  
  time_omni_imf = d_omni_bx_gse.x

  omni_imfbx_gse = d_omni_bx_gse.y
  omni_imfby_gsm = d_omni_by_gsm.y
  ; omni_imfbz_gsm = d_omni_bz_gsm.y

  omni_imf_phi = make_array(time_omni_imf.length, increment = 0, /float)
  for i = 0, time_omni_imf.length -1 do begin
    if omni_imfbx_gse[i] ge 0.0 and omni_imfby_gsm[i] ge 0.0 then begin
      omni_imf_phi[i] = 180/!PI * atan(omni_imfby_gsm[i] / omni_imfbx_gse[i])

    endif else if omni_imfbx_gse[i] ge 0.0 and omni_imfby_gsm[i] lt 0.0 then begin
      omni_imf_phi[i] = 180/!PI * atan(omni_imfby_gsm[i] / omni_imfbx_gse[i]) + 360

    endif else if omni_imfbx_gse[i] lt 0.0 then begin
      omni_imf_phi[i] = 180/!PI * atan(omni_imfby_gsm[i] / omni_imfbx_gse[i]) + 180
    endif 
  endfor

  ; omni_imf_phi = 180/!PI * atan(omni_imfby_gsm, omni_imfbx_gse)
  ; i_neg = where(omni_imf_phi lt 0.0)
  ; omni_imf_phi[i_neg] = omni_imf_phi[i_neg] + 360
  store_data, 'OMNI_HRO_5min_GSM_phi', data = {x: time_omni_imf, y:omni_imf_phi}

  ; calc, '"OMNI_HRO_1min_phi" = (180/3.14159)*atan(COMPLEX("OMNI_HRO_1min_BX_GSE","OMNI_HRO_1min_BY_GSM"))'

  store_data, 'phi', data = ['susanoo_sw_phi_gsm', 'OMNI_HRO_5min_GSM_phi']
  ; store_data, 'phi', data = ['susanoo_sw_phi_gsm', 'dsc_h0_mag_B1GSM_PHI', 'OMNI_HRO_5min_GSM_phi']
  store_data, 'velocity', data = ['susanoo_sw_swvel', 'OMNI_HRO_1min_flow_speed']
  store_data, 'imfbs', data = ['susanoo_sw_imfb_earth_gsm_tot', 'susanoo_sw_imfb_earth_gsm_z', 'OMNI_HRO_1min_F', 'OMNI_HRO_1min_BZ_GSM']
  store_data, 'dens', data = ['susanoo_sw_dens_earth', 'OMNI_HRO_1min_proton_density']
  store_data, 'temp', data = ['susanoo_sw_temp', 'OMNI_HRO_1min_T']

  ylim, 'velocity', 200, 1000, 0
  ylim, 'phi', 0, 360, 0
  ylim, 'dens', 0.1, 200, 1
  ylim, 'imfbs', -20, 40, 0
  ylim, 'temp', 1e4, 2*1e6, 1

  options, 'dens', colors = 1, ytitle = 'Density', ysubtitle = '[1/cm!U3!N]'
  options, 'velocity', colors = 6, ytitle = 'Velocity', $
            ysubtitle = '[km/s]'

  options, 'temp', ytitle = 'Temperature', ysubtitle = '[K]'
  options, 'phi', ytitle = 'Phi in GSM', ysubtitle = '[deg]'
  options, 'phi','databar',  {yval: [180], color:0, linestyle:2, thick:2}

  options, 'OMNI_HRO_1min_*', linestyle = 1, thick = 1.2
  options, 'susanoo_sw_*', linestyle = 0, thick = 3.5
  options, 'susanoo_sw_imfb_earth_tot', colors = !COLOR.gray

  options, 'OMNI_HRO_1min_F', colors = 0
  options, 'susanoo_sw_imfb_earth_z', colors = 5
  options, 'susanoo_sw_imfb_earth_gsm_z', colors = 5
  options, 'OMNI_HRO_1min_BZ_GSM', colors = 1
  options, 'OMNI_HRO_1min_BZ_GSE', colors = 1
  options, 'OMNI_HRO_5min_GSM_phi', colors = 2, linestyle = 1, thick = 1.2
  options, 'susanoo_sw_phi_gsm', colors = 4
  options, 'dsc_h0_mag_B1GSE_PHI', colors = 2, thick = 1.2
  options, 'dsc_h0_mag_B1GSM_PHI', colors = 2, thick = 1.2
  options, 'dsc_h0_mag_B1GSM_PHI_avg', colors = 2, thick = 1.2
  options, 'imfbs','databar',  {yval: 0, color:0, linestyle:2, thick:2}
  options, 'imfbs', ytitle = 'IMF', ysubtitle = '[nT]'

  options, 'susanoo_sw_temp', colors = 3
  options, 'OMNI_HRO_1min_T', colors = 3

  popen, 'susanoo_ql_test'
  !p.font = 1
  !p.charsize = 1.3
  tplot, ['imfbs', 'phi' , 'velocity', 'dens', 'temp'] & tplot_apply_databar
  ; makepng, 'susanoo_ql_test'
  pclose


end
