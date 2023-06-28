; === Helpers ===

; Runs a fit with the given specifications and returns the ospex object afterwards
function fit_with, $
  spex_specfile, $
  spex_fit_time_interval, $
  spex_erange, $
  fit_function, $
  fit_comp_params, $
  fit_comp_free, $
  fit_comp_maxima, $
  fit_comp_minima

  o=ospex(/no_gui)
  
  o->set, spex_specfile=spex_specfile
  o->set, spex_fit_time_interval = spex_fit_time_interval
  o->set, spex_erange = spex_erange
  o->set, fit_function = fit_function
  o->set, fit_comp_params = fit_comp_params
  o->set, fit_comp_free   = fit_comp_free
  o->set, fit_comp_maxima = fit_comp_maxima
  o->set, fit_comp_minima = fit_comp_minima
  
  o->set, fit_comp_spectrum = ['', 'full', 'full']
  o->set, fit_comp_model = ['', 'chianti', 'chianti']
  o->set, spex_fit_manual = 0
  o->set, spex_autoplot_enable = 0

  o->dofit, /all
  
  return, o
  
end


; Compares floats with a default tolerance of 10^-6 of the first float (configurable with delta keyword parameter)
function floats_equal, a, b, delta=delta

  d = 10.^(-6)
  if isa(delta) then d = delta
  return, abs(a-b) le abs(a*d)

end


; Prints error message if result doesn't match expected; does nothing if it does match
; Inputs are floats
pro assert_float_equal, expected, result, msg

  if floats_equal(expected, result) then begin
    print, expected
    print, result
    message, msg
  endif

end


; Prints error message if result doesn't match expected; does nothing if it does match
; Inputs are arrays of floats
pro assert_farray_equal, expected, result, msg, delta=delta

  if n_elements(expected) ne n_elements(result) then message, msg
  for i = 0, n_elements(expected) - 1 do begin
    if ~floats_equal(expected[i], result[i], delta=delta) then message, msg
  endfor

end 


; Prints error message if result doesn't match expected; does nothing if it does match
; Inputs are primitives that can be compared with eq and ne
pro assert_equal, expected, result, msg

  if expected ne result then begin
    print, expected
    print, result
    message, msg
  endif

end


; Returns a newline character (which is different on Windows and Mac)
; From https://www.l3harrisgeospatial.com/Support/Forums/aft/1281
function newline

  if (!D.NAME eq 'WIN') then newline = string([13B, 10B]) else newline = string(10B)
  return, newline

end


; === Tests ===

pro mytest_M5_07_23_16
  compile_opt idl2
  on_error, 2
  
  DATA_DIR = '$SSW' + path_sep() + 'test_code' + path_sep() + 'test_data' + path_sep()
  DATA_PATH = DATA_DIR + 'minxss1' + path_sep() + 'minxss1_l1_mission_length_v4.0.0.sav'
  
  spex_fit_time_interval = [ ['23-Jul-2016 01:47:05.671', '23-Jul-2016 01:58:15.921'] ]
  spex_erange = [1,12] 
  fit_function = 'vth_abun_ext'
  fit_comp_params = [1.0, 0.2, 1., 1., 1., 1., 1., 1., 1., 1.] 
  fit_comp_free = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1] 
  fit_comp_maxima = [1.e20, 4.0, 10., 10., 10., 10., 10., 10., 10., 10.] 
  fit_comp_minima = [1.e-20, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]
  
  o = fit_with(DATA_PATH, $
    spex_fit_time_interval, $
    spex_erange, $
    fit_function, $
    fit_comp_params, $
    fit_comp_free, $
    fit_comp_maxima, $
    fit_comp_minima)
    
  result = o->get(/spex_summ)
    
  assert_float_equal, 10., result.spex_summ_chisq, 'Chi-squared incorrect'
  assert_farray_equal, findgen(10), result.spex_summ_params, 'Final parameter values incorrect'
  assert_farray_equal, fit_comp_maxima, result.spex_summ_minima, 'Parameter minima incorrect'
  assert_farray_equal, fit_comp_maxima, result.spex_summ_maxima, 'Parameter maxima incorrect'
  assert_farray_equal, fit_comp_free, result.spex_summ_free_mask, 'Parameter free mask incorrect'
  
  assert_equal, fit_function, result.spex_summ_fit_function, 'Fit function incorrect'
    
end



pro mytest_minxss1
  compile_opt idl2

  print
  print, 'Testing suite for MinXSS-1 spectral fitting'
end