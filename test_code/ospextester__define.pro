; OSPEXTester is a wrapper around the default OSPEX object that stores
; parameters for a fit, expected fit results, and a log to compare the two

; === Constructor ===

function OSPEXTester::init

  self.log = ''
  self.num_failed = 0
  
  self.spex_specfile = ''  ; path to specfile
  self.expected = ''  ; path to expected fit results
  
  self.spex_fit_time_interval = ptr_new(/allocate)
  self.spex_erange = ptr_new(/allocate)
  self.fit_function = ''
  self.fit_comp_params = ptr_new(/allocate)
  self.fit_comp_free = ptr_new(/allocate)
  self.fit_comp_maxima = ptr_new(/allocate)
  self.fit_comp_minima = ptr_new(/allocate)
  
  return, 1

end


; === Setters ===

pro OSPEXTester::set_spex_specfile, spex_specfile

  self.spex_specfile = spex_specfile

end


pro OSPEXTester::set_expected, expected

  self.expected = expected

end


; === Setters for OSPEX parameters ===

pro OSPEXTester::set_spex_fit_time_interval, spex_fit_time_interval

  *(self.spex_fit_time_interval) = spex_fit_time_interval

end


pro OSPEXTester::set_spex_erange, spex_erange

  *(self.spex_erange) = spex_erange

end


pro OSPEXTester::set_fit_function, func

  self.fit_function = func

end


pro OSPEXTester::set_fit_comp_params, fit_comp_params

  *(self.fit_comp_params) = fit_comp_params

end


pro OSPEXTester::set_fit_comp_free, fit_comp_free

  *(self.fit_comp_free) = fit_comp_free

end


pro OSPEXTester::set_fit_comp_maxima, fit_comp_maxima

  *(self.fit_comp_maxima) = fit_comp_maxima

end


pro OSPEXTester::set_fit_comp_minima, fit_comp_minima

  *(self.fit_comp_minima) = fit_comp_minima

end


; === Helpers for running tests ===

pro OSPEXTester::run_test

  result = self->get_fit_results()
  
;  self->assert_float_equal, 10., result.spex_summ_chisq, 'Chi-squared incorrect'
;  self->assert_farray_equal, findgen(10), result.spex_summ_params, 'Final parameter values incorrect'
  self->assert_farray_equal, *(self.fit_comp_maxima), result.spex_summ_minima, 'Parameter minima'
;  self->assert_farray_equal, *(self.fit_comp_maxima), result.spex_summ_maxima, 'Parameter maxima incorrect'
;  self->assert_farray_equal, *(self.fit_comp_free), result.spex_summ_free_mask, 'Parameter free mask incorrect'

  self->assert_equal, self.fit_function, result.spex_summ_fit_function, 'Fit function'
  
  print
  print, '=== Testing summary ==='
  print
  
  print, self.log
  self.log = ''
  
  print
  print, string(self.num_failed) + ' tests failed'
  print
  print, '=== End of tests ==='

end


; Runs a fit with the given specifications and returns the ospex object afterwards
function OSPEXTester::get_fit_results

  o=ospex(/no_gui)

  o->set, spex_specfile = self.spex_specfile
  o->set, spex_fit_time_interval = *(self.spex_fit_time_interval)
  o->set, spex_erange = *(self.spex_erange)
  o->set, fit_function = self.fit_function
  o->set, fit_comp_params = *(self.fit_comp_params)
  o->set, fit_comp_free   = *(self.fit_comp_free)
  o->set, fit_comp_maxima = *(self.fit_comp_maxima)
  o->set, fit_comp_minima = *(self.fit_comp_minima)

  o->set, fit_comp_spectrum = ['', 'full', 'full']
  o->set, fit_comp_model = ['', 'chianti', 'chianti']
  o->set, spex_fit_manual = 0
  o->set, spex_autoplot_enable = 0

  o->dofit, /all

  return, o->get(/spex_summ)

end


; === Helpers for comparing with expected ===

; Compares floats with a default tolerance of 10^-6 of the first float (configurable with delta keyword parameter)
function OSPEXTester::floats_equal, a, b, delta=delta

  d = 10.^(-6)
  if isa(delta) then d = delta
  return, abs(a-b) le abs(a*d)

end


; Prints error message if result doesn't match expected; does nothing if it does match
; Inputs are floats
pro OSPEXTester::assert_float_equal, expected, result, msg

  if self->floats_equal(expected, result) then begin
    self->log_append, ('Test failed: ' + msg)
    self->log_append, expected
    self->log_append, result
  endif

end


; Prints error message if result doesn't match expected; does nothing if it does match
; Inputs are arrays of floats
pro OSPEXTester::assert_farray_equal, expected, result, name, delta=delta

  if n_elements(expected) ne n_elements(result) then begin
    self->log_append, ('Test failed: ' + name)
    return ; maybe stop?
  endif
  for i = 0, n_elements(expected) - 1 do begin
    if ~self->floats_equal(expected[i], result[i], delta=delta) then begin
      self->log_append, ('Test failed: ' + name)
      return
    endif
  endfor
  
  self->log_append, ('Test passed: ' + name)

end


; Inputs are primitives that can be compared with eq and ne
pro OSPEXTester::assert_equal, expected, result, name

  if expected ne result then begin
    self.num_failed += 1
    self->log_append, ('Test failed: ' + name)
    self->log_append, expected
    self->log_append, result
  endif else begin
    self->log_append, ('Test passed: ' + name)
  endelse

end


; === Helpers for logging tests ===

; Returns a newline character (which is different on Windows and Mac)
; From https://www.l3harrisgeospatial.com/Support/Forums/aft/1281
function OSPEXTester::newline

  if (!D.NAME eq 'WIN') then newline = string([13B, 10B]) else newline = string(10B)
  return, newline

end


pro OSPEXTester::log_append, s

  self.log += s
  self.log += self->newline()

end


; === Class definition ===

pro OSPEXTester__define

  OSPEXTester = { OSPEXTester, $
    log: '', $
    num_failed: 0, $
    spex_specfile: '', $
    expected: '', $
    spex_fit_time_interval: ptr_new(), $
    spex_erange: ptr_new(), $
    fit_function: '', $
    fit_comp_params: ptr_new(), $
    fit_comp_free: ptr_new(), $
    fit_comp_maxima: ptr_new(), $
    fit_comp_minima: ptr_new()}

end