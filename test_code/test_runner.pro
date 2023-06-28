pro test_runner

  compile_opt idl2
  
  TESTING_DIR = '$SSW' + path_sep() + 'test_code' + path_sep() + 'test_suites' + path_sep()

  if ~file_test(TESTING_DIR, /directory) then begin
    message, 'Input must be a directory.'
  endif

  test_files = file_search(TESTING_DIR, 'mytest*.pro')
  resolve_routine, file_basename(test_files,'.pro'), /compile_full_file  ; compile all test files
  tests = routine_info()  ; names of all currently compiled procedures
;  tests = file_basename(test_files, '.pro')

  print
  print,'--------------------------------------------------------------------------------'

  error_count = 0
  for i=0, tests.length-1 do begin
    catch, errorStatus
    if (errorStatus ne 0) then begin
      catch, /cancel
      print, 'ERROR: ', !ERROR_STATE.msg
      i++
      error_count++
      continue
    endif

    if (tests[i]).startswith('MYTEST_') then begin
      call_procedure, tests[i]
    endif
  endfor

  print
  print,'--------------------------------------------------------------------------------'
  print

  if error_count gt 0 then begin
    print, 'Unit test failures on: ' + TESTING_DIR
  endif else begin
    print, 'Unit tests pass.'
  endelse
  
end