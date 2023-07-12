;+
; Name: spex_minxss__define
;
; Purpose: Provide methods to deal with the minxss data when downloading,etc. for OSPEX. Copied from spex_messenger__define
;
; Written: Brendan D'Aquino, July 2023
;-

function spex_minxss::init
  return,1
end

;-----

function spex_minxss::search, time_range, count=count, _ref_extra=extra

  spex_find_data, 'minxss', time_range, url=url, count=count, _extra=extra

  if count eq 0 then return, ''

  return, url
end

;-----

pro spex_minxss__define
  void = {spex_minxss, inherits spex_instr}
end