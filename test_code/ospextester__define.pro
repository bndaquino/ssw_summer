; OSPEXTester is a wrapper around the default OSPEX object that stores
; fit inputs, fit outputs, and a log to compare the two

; === Constructor ===

function OSPEXTester::init

  self.log = ''
  self.num_failed = 0
  
  self.spex_specfile = ''  ; path to specfile
  self.spex_drmfile = ''  ; path to DRM (can be left blank for MinXSS/DAXSS)
  self.expected = ''  ; path to expected fit results
  
  self.spex_fit_time_interval = ptr_new(/allocate)
  self.spex_erange = ptr_new(/allocate)
  self.fit_function = ''
  self.fit_comp_params = ptr_new(/allocate)
  self.fit_comp_free = ptr_new(/allocate)
  self.fit_comp_maxima = ptr_new(/allocate)
  self.fit_comp_minima = ptr_new(/allocate)
  
  self.o = ptr_new(/allocate)
  *(self.o) = ospex(/no_gui)
  *(self.o)->set, fit_comp_spectrum = ['full', '', '']
  *(self.o)->set, fit_comp_model = ['chianti', '', '']
  *(self.o)->set, spex_fit_manual = 0
  *(self.o)->set, spex_autoplot_enable = 0
  
  return, 1

end


; === Setters ===

pro OSPEXTester::set_spex_specfile, spex_specfile

  self.spex_specfile = spex_specfile
  *(self.o)->set, spex_specfile=spex_specfile

end


pro OSPEXTester::set_spex_drmfile, spex_drmfile

  self.spex_drmfile = spex_drmfile
  *(self.o)->set, spex_drmfile=spex_drmfile

end


pro OSPEXTester::set_expected, expected

  self.expected = expected

end


; === Setters for OSPEX parameters ===

pro OSPEXTester::set_spex_fit_time_interval, spex_fit_time_interval

  *(self.spex_fit_time_interval) = spex_fit_time_interval
  *(self.o)->set, spex_fit_time_interval=spex_fit_time_interval

end


pro OSPEXTester::set_spex_erange, spex_erange

  *(self.spex_erange) = spex_erange
  *(self.o)->set, spex_erange=spex_erange

end


pro OSPEXTester::set_fit_function, func

  self.fit_function = func
  *(self.o)->set, fit_function=func

end


pro OSPEXTester::set_fit_comp_params, fit_comp_params

  *(self.fit_comp_params) = fit_comp_params
  *(self.o)->set, fit_comp_params=fit_comp_params

end


pro OSPEXTester::set_fit_comp_free, fit_comp_free

  *(self.fit_comp_free) = fit_comp_free
  *(self.o)->set, fit_comp_free=fit_comp_free

end


pro OSPEXTester::set_fit_comp_maxima, fit_comp_maxima

  *(self.fit_comp_maxima) = fit_comp_maxima
  *(self.o)->set, fit_comp_maxima=fit_comp_maxima

end


pro OSPEXTester::set_fit_comp_minima, fit_comp_minima

  *(self.fit_comp_minima) = fit_comp_minima
  *(self.o)->set, fit_comp_minima=fit_comp_minima

end


pro OSPEXTester::set_mcurvefit_imax, mcurvefit_imax

  *(self.fit_comp_maxima) = mcurvefit_imax
  *(self.o)->set, mcurvefit_imax=mcurvefit_imax

end


; === Helpers for running tests ===

pro OSPEXTester::run_test

  result = self->get_fit_results()
  restore, self.expected  ; assumes that the restored variable's name is "expected"
  
  self->assert_float_equal, expected.spex_summ_chisq, result.spex_summ_chisq, 'Chi-squared'
  self->assert_farray_equal, expected.spex_summ_params, result.spex_summ_params, 'Final parameter values'
  self->assert_farray_equal, *(self.fit_comp_minima), result.spex_summ_minima, 'Parameter minima'
  self->assert_farray_equal, *(self.fit_comp_maxima), result.spex_summ_maxima, 'Parameter maxima'
  self->assert_farray_equal, *(self.fit_comp_free), result.spex_summ_free_mask, 'Parameter free mask'

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


; Runs a fit with the given specifications and returns the fit result object afterwards
function OSPEXTester::get_fit_results

  *(self.o)->dofit, /all
  return, *(self.o)->get(/spex_summ)

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
pro OSPEXTester::assert_float_equal, expected, result, name

  if ~self->floats_equal(expected, result) then begin
    self->log_append, ('Test failed: ' + name + '. Expected vs. result:')
    self->log_append, expected
    self->log_append, result
    self.num_failed += 1
  endif else begin
    self->log_append, ('Test passed: ' + name)
  endelse

end


; Prints error message if result doesn't match expected; does nothing if it does match
; Inputs are arrays of floats
pro OSPEXTester::assert_farray_equal, expected, result, name, delta=delta

  ; skip if no expected array is defined (e.g. user doesn't specify max/mins)
  if ~isa(expected) then return

  if n_elements(expected) ne n_elements(result) then begin
    self->log_append, ('Test failed: ' + name)
    self.num_failed += 1
    return ; maybe stop?
  endif
  for i = 0, n_elements(expected) - 1 do begin
    if ~self->floats_equal(expected[i], result[i], delta=delta) then begin
      self->log_append, ('Test failed: ' + name)
      self.num_failed += 1
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

  self.log += string(s)
  self.log += self->newline()

end


; === Class definition ===

pro OSPEXTester__define

  dummy = { OSPEXTester, $
    log: '', $
    num_failed: 0, $
    spex_specfile: '', $
    spex_drmfile: '', $
    expected: '', $
    spex_fit_time_interval: ptr_new(), $
    spex_erange: ptr_new(), $
    fit_function: '', $
    fit_comp_params: ptr_new(), $
    fit_comp_free: ptr_new(), $
    fit_comp_maxima: ptr_new(), $
    fit_comp_minima: ptr_new(), $
    mcurvefit_imax: 0, $
    o: ptr_new()}

end