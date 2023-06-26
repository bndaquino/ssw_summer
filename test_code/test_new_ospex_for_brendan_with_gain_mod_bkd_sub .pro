
pro test_new_ospex_for_Brendan

TESTING_DIR = '$SSW' + path_sep() + 'test_code' + path_sep()
;minxss_ospex_spec_file = TESTING_DIR + 'M5_0_2016-07-23 _n_26_no_electrons_minxss1_ospex_1_min_average_mission.sav'
minxss_ospex_spec_file = '/Users/bdaquino/data/minxss1/minxss1_l1_mission_length_v4.0.0.sav'


;THIS ARE BKD TIMES
start_time_BKD = '2016-07-23 1:39:00'
end_time_BKD = '2016-07-23 1:42:30'

start_time_flare = '2016-07-23 1:42:30'
end_time_flare = '2016-07-23 3:30:30'

spex_mcurvefit_itmax = 500 ; 200 ....500
min_energy = 1.
max_energy = 12.


minxss_fit_class = = '2TAllFree'


;; minxss_test_function_data_minimal_signal_to_noise = 9 ;9 ; 5 - 10


;Start OSPEX No GUI
o=ospex() ; or  ospex_proc, o, /no_

;Start OSPEX with GUI
;o=ospex() ; or  ospex_proc, o, /no_


;Set SpecFile Path 
;This is the MinXSS Data that would be fitted
o->set, spex_specfile=minxss_ospex_spec_file

;Set DRM Path from OSPEX Directory
o->set, spex_drmfile=''


; July 23, 2016 01:30 UT
;o->set, spex_fit_time_interval= [minxss_x123_ospex_structure[index_fit_time_ut_minxss_structure_data[0]].ut_edges]
o->set, spex_fit_time_interval= [start_time_BKD, end_time_BKD ]
o->set, spex_erange=[min_energy, max_energy]



;;###########################################################
;This is the new function that needs to be tested!!! vth_abun -> to vth_abun_ext
;This would be  gain_mod + vth_abund_ext  (1 T All Free)
o->set, fit_function='gain_mod+vth_abun_ext' ;Pointer,  Fit function used
;;###########################################################



;Check that the number of params == 1 vth_abund_ext 
; The number of params will double when using a 2 vth abund_ext 

if minxss_fit_class eq '2TAllFree' then begin
  o->set, fit_function='gain_mod+vth_abun_ext+vth_abun_ext' ;Pointer,  Fit function used
o->set, fit_comp_params= [0.0, 0.0, 1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1.,1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1.]
o->set, fit_comp_free = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
o->set, fit_comp_maxima = [0.1, 0.1, 1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.,1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.]
o->set, fit_comp_minima = [-0.1, -0.1, 1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01,1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]
o->set, mcurvefit_itmax = spex_mcurvefit_itmax

endif


if minxss_fit_class eq '1TAllFree' then begin
  o->set, fit_function='gain_mod+vth_abun_ext' ;Pointer,  Fit function used
  o->set, fit_comp_params= [0.0, 0.0, 1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1.]
  o->set, fit_comp_free = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  o->set, fit_comp_maxima = [0.1, 0.1, 1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.]
  o->set, fit_comp_minima = [-0.1, -0.1, 1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]
  o->set, mcurvefit_itmax = spex_mcurvefit_itmax

endif



o->set, fit_comp_spectrum= ['', 'full', $
  'full'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines
o->set, fit_comp_model= ['', 'chianti', $
  'chianti'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines



o->set, spex_fit_progbar=1 ;Flag, If set, show progress bar during fit loop through intervals. Options: 0 or 1
o->set, spex_autoplot_bksub=1 ;Flag, If set, plot data-bk, not data with bk in autoplot. Options: 0 or 1
o->set, spex_autoplot_enable=1 ;Flag, If set, automatically plot after fitting. Options: 0 or 1
o->set, spex_autoplot_overlay_back=1 ;Flag, If set, overlay bk in autoplot. Options: 0 or 1
o->set, spex_autoplot_overlay_bksub=0 ;Flag, If set, overlay data-bk in autoplot. Options: 0 or 1
o->set, spex_autoplot_photons=0 ;Flag, If set, plot in photon space in autoplot. Options: 0 or 1
o->set, spex_autoplot_show_err=1 ;Flag, If set, show error bars in autoplot. Options: 0 or 1
o->set, spex_autoplot_units='rate' ;String, Units for autoplot ("counts", "rate", "flux"). Options: "counts", "rate", "flux"


o->set, spex_fit_manual=1 ;0 = auto fit  // 1 = manual fit
o->set, spex_autoplot_enable=1
o->dofit, /all



minxss_ospex_structure_output_0 = o -> get(/spex_summ)
;reset the ospex parameters
o->init_params
o->set, spex_fit_time_interval= [start_time_flare, end_time_flare ]
o->set, spex_erange=[min_energy, max_energy]; Energy range(s) to fit over (2,n). Units: keV


if minxss_fit_class eq '1TAllFree' then begin
  o->set, fit_function='gain_mod+vth_abun+vth_abun' ;Pointer,  Fit function used
  o->set, fit_comp_params=[0., 0., 1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1., $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_VEM1], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_T1], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_fe_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_CA_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_S_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_MG_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_SI_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_AR_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_HE_C_N_O_F_NE_NA_AL_K_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_Ni_MULTIPLIER]] ;Pointer, Fit function parameters
  o->set, fit_comp_free = [fit_drm_mod_gain, 1, 1, 1, free_fe[index_fit_time_ut_minxss_structure_data[w]], free_Ca[index_fit_time_ut_minxss_structure_data[w]], free_S[index_fit_time_ut_minxss_structure_data[w]], free_Mg[index_fit_time_ut_minxss_structure_data[w]], free_Si[index_fit_time_ut_minxss_structure_data[w]], free_Ar[index_fit_time_ut_minxss_structure_data[w]], free_He_C_N_O_F_Ne_Na_Al_K[index_fit_time_ut_minxss_structure_data[w]], free_Ni[index_fit_time_ut_minxss_structure_data[w]], $
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ;Pointer, Fit function parameter free/fixed mask. Values: 0 or 1
  o->set, fit_comp_maxima = [fit_max_mod_energy_gain_free, fit_max_energy_offset_mod_gain_free, 1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., $
    1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.] ;Pointer, Fit function parameter maximum values
  o->set, fit_comp_minima = [fit_min_mod_energy_gain_free, fit_min_energy_offset_mod_gain_free, 1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, $
    1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01] ;Pointer, Fit function parameter minimum values
  o->set, fit_comp_spectrum= ['', 'full', $
    'full'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines
  o->set, fit_comp_model= ['', 'chianti', $
    'chianti'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines
endif





;2TAllFree
if minxss_fit_class eq '2TAllFree' then begin
  o->set, fit_function='gain_mod+2vth_abun+2vth_abun' ;Pointer,  Fit function used
  o->set, fit_comp_params=[0., 0., 1.0, 0.2, 1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1., $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_VEM1], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_T1], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_VEM2], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_T2], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_fe_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_CA_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_S_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_MG_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_SI_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_AR_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_HE_C_N_O_F_NE_NA_AL_K_MULTIPLIER], $
    minxss_pre_fit_bk_function_data_structure.results_structure.SPEX_SUMM_PARAMS[minxss_pre_fit_bk_function_data_structure.info_structure.INDEX_Ni_MULTIPLIER]] ;Pointer, Fit function parameters
  o->set, fit_comp_free = [fit_drm_mod_gain, 1, 1, 1, 1, 1, free_fe[index_fit_time_ut_minxss_structure_data[w]], free_Ca[index_fit_time_ut_minxss_structure_data[w]], free_S[index_fit_time_ut_minxss_structure_data[w]], free_Mg[index_fit_time_ut_minxss_structure_data[w]], free_Si[index_fit_time_ut_minxss_structure_data[w]], free_Ar[index_fit_time_ut_minxss_structure_data[w]], free_He_C_N_O_F_Ne_Na_Al_K[index_fit_time_ut_minxss_structure_data[w]], free_Ni[index_fit_time_ut_minxss_structure_data[w]], $
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ;Pointer, Fit function parameter free/fixed mask. Values: 0 or 1
  o->set, fit_comp_maxima = [fit_max_mod_energy_gain_free, fit_max_energy_offset_mod_gain_free, 1.e20, 4.0, 1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., $
    1.e20, 4.0, 1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.] ;Pointer, Fit function parameter maximum values
  o->set, fit_comp_minima = [fit_min_mod_energy_gain_free, fit_min_energy_offset_mod_gain_free, 1.e-20, 0.1,  1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, $
    1.e-20, 0.1,  1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01] ;Pointer, Fit function parameter minimum values
  o->set, fit_comp_spectrum= ['', 'full', $
    'full'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines
  o->set, fit_comp_model= ['', 'chianti', $
    'chianti'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines
endif


o->set, spex_fit_manual=1 ;0 = auto fit  // 1 = manual fit
o->set, spex_autoplot_enable=1
o->dofit, /all




;;;; NOTES TODO: 
;Test vth_abun_ext (1T-AllFree)
;Test vth_abun_ext + vth_abun_ext (2T-AllFree)
;Test vth_abun_ext (1T-AllFree) with BKD subtract
;Test vth_abun_ext (1T-AllFree BKD) +  vth_abun_ext (1T-AllFree Flare) - Enhanced method




end