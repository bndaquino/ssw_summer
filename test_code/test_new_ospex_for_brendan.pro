
pro test_new_ospex_for_Brendan

TESTING_DIR = '$SSW' + path_sep() + 'test_code' + path_sep()
minxss_ospex_spec_file = '/Users/bdaquino/data/minxss1/minxss1_l1_mission_length_v4.0.0.sav'


o=ospex()


;Set SpecFile Path 
;This is the MinXSS Data that would be fitted
o->set, spex_specfile=minxss_ospex_spec_file

;Set DRM Path from OSPEX Directory
o->set, spex_drmfile=''


; July 23, 2016 01:30 UT
;o->set, spex_fit_time_interval= [minxss_x123_ospex_structure[index_fit_time_ut_minxss_structure_data[0]].ut_edges]
o->set, spex_fit_time_interval=[ ['23-Jul-2016 01:47:05.671', '23-Jul-2016 01:58:15.921'] ]
o->set, spex_erange=[1,12]

;;###########################################################
;This is the new function that needs to be tested!!! vth_abun -> to vth_abun_ext
;This would be  vth_abund_ext and gain_mod
o->set, fit_function='vth_abun_ext' ;Pointer,  Fit function used
;;###########################################################



;Check that the number of params == 2 vth_abund_ext + and gain_mod
o->set, fit_comp_params= [1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1.]
o->set, fit_comp_free = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
o->set, fit_comp_maxima = [1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.]
o->set, fit_comp_minima = [1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]


o->set, fit_comp_spectrum= ['', 'full', $
  'full'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines
o->set, fit_comp_model= ['', 'chianti', $
  'chianti'] ;String, Fit function spectrum type (for thermal). Options: full / continuum / lines

o->set, spex_fit_manual=1 ;0 = auto fit  // 1 = manual fit
o->set, spex_autoplot_enable=1
o->dofit, /all


end