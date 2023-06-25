
pro test_new_ospex_for_Brendan

TESTING_DIR = '$SSW' + path_sep() + 'test_code' + path_sep()
;minxss_ospex_spec_file = TESTING_DIR + 'M5_0_2016-07-23 _n_26_no_electrons_minxss1_ospex_1_min_average_mission.sav'
minxss_ospex_spec_file = '/Users/bdaquino/data/minxss1/minxss1_l1_mission_length_v4.0.0.sav'


;THIS ARE BKD TIMES
start_time_flare = '2016-07-23 1:39:00'
end_time_flare = '2016-07-23 1:42:30'

spex_mcurvefit_itmax = 500 ; 200 ....500
min_energy = 1.
max_energy = 12.


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
o->set, spex_fit_time_interval= [start_time_flare, end_time_flare ]
o->set, spex_erange=[min_energy, max_energy]



;;###########################################################
;This is the new function that needs to be tested!!! vth_abun -> to vth_abun_ext
;This would be  vth_abund_ext 
o->set, fit_function='vth_abun_ext' ;Pointer,  Fit function used
;;###########################################################



;Check that the number of params == 1 vth_abund_ext 
; The number of params will double when using a 2 vth abund_ext 

o->set, fit_comp_params= [1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1.]
o->set, fit_comp_free = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
o->set, fit_comp_maxima = [1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.]
o->set, fit_comp_minima = [1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]
o->set, mcurvefit_itmax = spex_mcurvefit_itmax




o->set, fit_comp_spectrum= ['', 'full', $
  'full'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines
o->set, fit_comp_model= ['', 'chianti', $
  'chianti'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines

o->set, spex_fit_manual=1 ;0 = auto fit  // 1 = manual fit
o->set, spex_autoplot_enable=1
o->dofit, /all


;;;; NOTES TODO: 
;Test vth_abun_ext (1T-AllFree)
;Test vth_abun_ext + vth_abun_ext (2T-AllFree)
;Test vth_abun_ext (1T-AllFree) with BKD subtract
;Test vth_abun_ext (1T-AllFree BKD) +  vth_abun_ext (1T-AllFree Flare) - Enhanced method




end