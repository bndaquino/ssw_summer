;+
;
; Name        : MINXSS__DEFINE
;
; Purpose     : Define a minxss data object.  Search method finds minxss XRS data files for specified times on
;               remote site and returns list of URLs.  Default host and dir to search are defined in object, but user
;               can also control them through environment variables minxss_XRS_HOST and minxss_XRS_TOPDIR, e.g.
;                 setenv,'MINXSS_XRS_HOST=https://umbra.nascom.nasa.gov'
;                 setenv,'MINXSS_XRS_TOPDIR=/minxss'
;               Copied from spex_messenger__define
;
; Category    : Synoptic Objects
;
; Syntax      : IDL> c=obj_new('minxss')
;
; History     : Written 12-July-2023, Brendan D'Aquino
;-
;----------------------------------------------------------------

function minxss::init,_ref_extra=extra

  if ~self->synop_spex::init() then return,0

  rhost = chklog('MINXSS_XRS_HOST')
  if rhost eq '' then rhost = 'http://localhost:8000'
  topdir = chklog('MINXSS_XRS_TOPDIR')
  if topdir eq '' then topdir = 'topdir'
  self->setprop,rhost=rhost,ext='txt',org='year',$
    topdir=topdir,/full,/round

  return,1
end

;----------------------------------------------------------------
;-- search method

function minxss::search,tstart,tend,count=count,type=type,_ref_extra=extra

  type=''
  files=self->site::search(tstart,tend,_extra=extra,count=count)
  if count gt 0 then type=replicate('sxr/lightcurves',count) else files=''
  if count eq 0 then message,'No files found.',/cont

  return,files
end

;----------------------------------------------------------------

function minxss::parse_time,file,_ref_extra=extra

  ; files are formatted like messenger: m1_ or m2_ followed by yyyyddd, where Jan 1 has ddd = 001 etc.
  fil = file_break(file)
  year = strmid(fil, 3, 4)
  doy = strmid(fil, 7, 3)
  return, anytim(doy2utc(doy, year),/tai)

end

;----------------------------------------------------------------

pro minxss__define
  void={minxss, inherits synop_spex}
  return & end

