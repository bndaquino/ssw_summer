
pro test_new_ospex_for_Brendan

COMPUTER_PATH = ''



minxss_ospex_spec_file = COMPUTER_PATH + path_sep()+ 'M5_0_2016-07-23 _n_26_no_electrons_minxss1_ospex_1_min_average_mission.sav'


;Start OSPEX No GUI
o=ospex(/no_gui) ; or  ospex_proc, o, /no_
;Start OSPEX with GUI
;o=ospex() ; or  ospex_proc, o, /no_


;Set SpecFile Path 
;This is the MinXSS Data that would be fitted
o->set, spex_specfile=minxss_ospex_spec_file

;Set DRM Path from OSPEX Directory
o->set, spex_drmfile=''



o->set, spex_fit_time_interval= [minxss_x123_ospex_structure[index_fit_time_ut_minxss_structure_data[0]].ut_edges]
o->set, spex_erange=[1,12]

;;###########################################################
;This is the new function that needs to be tested!!! vth_abun -> to vth_abun_ext
;This would be  vth_abund_ext and gain_mod
o->set, fit_function='gain_mod+vth_abun_ext+vth_abun_ext' ;Pointer,  Fit function used
;;###########################################################



;Check that the number of params == 2 vth_abund_ext + and gain_mod
o->set, fit_comp_params=[0., 0., 1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1., 1.0 , 4.0, 1.0 , 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 ]
o->set, fit_comp_free = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ;Pointer, Fit function parameter free/fixed mask. Values: 0 or 1
o->set, fit_comp_maxima = [1, 1, 1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.] ;Pointer, Fit function parameter maximum values
o->set, fit_comp_minima = [0, 0, 1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01,1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01] ;Pointer, Fit function parameter minimum values


o->set, fit_comp_spectrum= ['', 'full', $
  'full'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines
o->set, fit_comp_model= ['', 'chianti', $
  'chianti'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines

o->set, spex_fit_manual=0 ;0 = auto fit  // 1 = manual fit
o->set, spex_autoplot_enable=1
o->dofit, /all


end