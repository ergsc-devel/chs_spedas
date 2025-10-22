;+
; PROCEDURE: susanoo_sw_load
;
; PURPOSE:
;   To load the SUSANOO SW data
;
; KEYWORDS:
;   site  = Observation point, ex: "earth"
;   datatype = Time resolution. '5m' for 5min'
;              The default is 'all'.  If you need two of them, set to 'all'.
;   /downloadonly, if set, then only download the data, do not load it into variables.
;   /no_server, use only files which are online locally.
;   /no_download, use only files which are online locally. (Identical to no_server keyword.)
;   trange = (Optional) Time range of interest  (2 element array).
;   /timeclip, if set, then data are clipped to the time range set by timespan
;
; EXAMPLE:
;   susanoo_sw_load, site='earth', $
;       trange=['2021-10-01/00:00:00','2021-10-03/00:00:00']
;
; NOTE: See the rules of the road.
;
;
; HISTORY:
;       2021-10-19: Originally written by Y. Miyoshi
;                   ERG-Science Center, ISEE, Nagoya Univ.
;                   erg-sc-core at isee.nagoya-u.ac.jp
;       2024-09-30: Modified by S. Chiba
;                   Center for Heliospheric Science, ISEE, Nagoya Univ.
;       2025-06-24: Modified by S. Chiba
;                   Center for Heliospheric Science, ISEE, Nagoya Univ.
;-

pro susanoo_sw_load, site=site, $
        ; The list of site is ['earth', 'mercury', 'venus', 'mars', 'psp', 'solaro', 'bepic', 'stereoa']
        downloadonly=downloadonly, no_server=no_server, no_download=no_download, $
        trange=trange, timeclip=timeclip, $
        uname = uname, passwd = passwd, $
        datatype=datatype
        compile_opt idl2

        if undefined(debug) then debug = 0


;*** site codes ***
;--- all sites (default)
site_code_all = strsplit( $
                'earth,mercury,venus,mars,bepic,streoa,solaro,psp', $
                ',', /extract)

;--- check site codes
if(n_elements(site) eq 0) then site='earth'
site_code = ssl_check_valid_name(site, site_code_all, /ignore_case, /include_all)

if(site_code[0] eq '') then return
print, site_code


;*** keyword set ***
if(~keyword_set(downloadonly)) then downloadonly=0
if(~keyword_set(no_server)) then no_server=0
if(~keyword_set(no_download)) then no_download=0

;*** load CDF ***
;--- Create (and initialize) a data file structure
source = file_retrieve(/struct)


;--- Set parameters for the data file class
source.local_data_dir  = root_data_dir() + 'chs/'
source.remote_data_dir = 'https://chs.isee.nagoya-u.ac.jp/data/chs/simulation/'

;--- Download parameters
if(keyword_set(downloadonly)) then source.downloadonly=1
if(keyword_set(no_server))    then source.no_server=1
if(keyword_set(no_download))  then source.no_download=1

fres = '5m'

; if undefined(site)then site = 'earth'
print, site

for i=0, n_elements(site_code)-1 do begin
    ;--- Set the file path which is added to source.local_data_dir/remote_data_dir.

    ;pathformat = 'susanoo/cdf/earth/YYYY/MM/susanoo_sw_earth_'fres'+_YYYYMMDD.cdf'

    ;--- Generate the file paths by expanding wilecards of date/time
    ;    (e.g., YYYY, YYYYMMDD) for the time interval set by "timespan"
    ;relpathnames = file_dailynames(file_format=pathformat)
    ; 
    if (site eq site_code[i]) then begin
      file_format = 'susanoo/data/cdf/earth/YYYY/MM/susanoo_sw_'+site_code[i]+'_'+fres+'_YYYYMMDD_v01.01.cdf'
      relpathnames=file_dailynames(file_format=file_format,trange=trange)
      print,site

      files = spd_download_plus(remote_file=relpathnames, remote_path=source.remote_data_dir,$
      local_path=source.local_data_dir, $
      url_username = uname, url_password = passwd, $
      _extra=source, /last_version)

      filestest=file_test(files)

      if(total(filestest) ge 1) then begin
        files = files[where(filestest eq 1)]
        ;--- Load data into tplot variables
        if(downloadonly eq 0) then begin
          
        cdf2tplot, file=files, verbose=source.verbose, $
                      prefix='susanoo_sw_', suffix='_' + site_code[i]
        endif
    endif

      ;--- print PI info and rules of the road
      gatt = cdf_var_atts(files[0])

      print_str_maxlet, ' '
      print, '**********************************************************************'
      print, gatt.project
      print, ''
      print, 'PI:'
      print_str_maxlet, gatt.PI, 70
      print, ''
;      print, 'Affiliations:'
;      piaff=strsplit(gatt.PI_affiliation, '\([1-9]\)', /regex, /extract)
;      print, ''
      print, 'Rules of the Road for SUSANO_SW data:'
      print_str_maxlet,gatt.rules_of_use,70
;      for igatt=0, n_elements(gatt.text)-1 do print_str_maxlet, gatt.text[igatt], 70
      print, ''
;      for igatt=0, n_elements(gatt.LINK_TEXT)-1 do $
;        print, gatt.LINK_TEXT[igatt], ' ', gatt.HTTP_LINK[igatt]
      print, '**********************************************************************'
      print, ''
    endif


endfor   ; end of for loop of i

;---
return
end
